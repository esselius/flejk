{ system, pkgs, lib, config, ... }:

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

  tfScript = name: modules: writeBashBin name ''
    rundir="/tmp/.flejk/${name}"
    mkdir -p "$rundir"
    cp -f "${configDir modules}/config.tf.json" "$rundir/" 

    ${terraform}/bin/terraform -chdir="$rundir" "''$@"
  '';

  mkTerraformApp = name: modules: global: env: layer: {
    type = "app";
    program = "${tfScript "${name}" (modules ++ [ global env layer ])}/bin/${name}";
  };

  perStackEnvLayer = modules: stacks: foldr recursiveUpdate { } (flatten
    (mapAttrsToList
      (stack: stackVals: (mapAttrsToList
        (env: envVals: (mapAttrsToList
          (layer: layerVals: {
            "tf-${stack}-${env}-${layer}" = mkTerraformApp "tf-${stack}-${env}-${layer}" modules stackVals.global envVals layerVals;
          })
          stackVals.layers))
        stackVals.environments))
      stacks)
  );
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

  };

  config = mkIf (cfg.stack != { }) {
    outputs.apps.${system} = perStackEnvLayer cfg.modules cfg.stack;
  };
}
