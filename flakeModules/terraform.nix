{ pkgs, lib, config, ... }:

with lib;
with lib.types;

let
  cfg = config.terraform;

  inherit (pkgs.writers) writeBashBin;
  inherit (pkgs) terraform symlinkJoin mkShell;

  buildTerranix = { pkgs, terranix_config, ... }@terranix_args:
    let
      terraform = import "${pkgs.terranix}/core/default.nix" terranix_args;
      config_json = pkgs.writeTextFile {
        name = "terraform-config";
        text = builtins.toJSON terraform.config;
        executable = false;
        destination = "/config.tf.json";
      };
    in
    config_json;

  configDir = modules: buildTerranix {
    inherit pkgs;
    terranix_config = {
      imports = modules;
    };
  };

  tfScript = name: modules: writeBashBin "tf-${name}" ''
    rundir="/tmp/.flejk/tf/${name}"
    mkdir -p "$rundir"
    cp -f "${configDir modules}/config.tf.json" "$rundir/" 

    ${terraform}/bin/terraform -chdir="$rundir" "''$@"
  '';

  # FIXME
  perEnvLayer = stack: { global, environments, layers, terraformModules }: head (flatten (map
    (env: map
      (layer: { type = "app"; program = "${tfScript "${stack}-${env}-${layer}" (terraformModules ++ [ global environments.${env} layers.${layer} ])}/bin/tf-${stack}-${env}-${layer}"; })
      (attrNames layers))
    (attrNames environments)));

  mkTerraformConfigs = modules: stack: { global, environments, layers }: perEnvLayer stack { inherit global environments layers; terraformModules = modules; };
in
{
  options = {
    terraform = {
      stack = mkOption {
        default = { };
        type = attrsOf (submodule {
          options = {
            global = mkOption { type = attrs; default = { }; };
            environments = mkOption { type = attrsOf attrs; default = { }; };
            layers = mkOption { type = attrsOf attrs; default = { }; };
          };
        });
      };
      modules = mkOption {
        default = [ ];
        type = listOf (either path attrs);
      };
    };

    apps = mkOption { type = attrs; };
  };

  config = mkIf (cfg != { }) {
    apps = mapAttrs (mkTerraformConfigs cfg.modules) cfg.stack;
  };
}
