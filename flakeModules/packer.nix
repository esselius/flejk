{ system, inputs, pkgs, lib, config, ... }:

with lib;
with lib.types;

let
  cfg = config.packer;

  inherit (pkgs.writers) writeBashBin;
  inherit (pkgs) packer writeTextFile;

  pkrScript = name: config: writeBashBin name ''
    set -x
    ${packer}/bin/packer build ${writeTextFile { inherit name; text = (builtins.toJSON config);}}
  '';

  mkPackerApp = k: v: nameValuePair ("pkr-${k}") {
    type = "app";
    program = "${pkrScript "pkr-${k}" v}/bin/pkr-${k}";
  };

  mkPackerNixosConfig = k: v: inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      "${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
      {
        fileSystems."/".device = "/dev/disk/by-label/nixos";
        boot.loader.grub.enable = true;
        boot.loader.grub.version = 2;
        boot.loader.grub.device = "/dev/sda";
        passthru = { };
      }
      ({ pkgs, ... }:

        {
          environment.systemPackages = with pkgs; [
            git
          ];

          nix = {
            package = pkgs.nixUnstable;
            extraOptions = ''
              experimental-features = nix-command flakes ca-references
            '';
          };
        }
      )
    ];
  };

  builderSubmodule = submodule {
    options = {
      boot_wait = mkOption {
        type = str;
      };
      boot_key_interval = mkOption { type = str; };
      boot_command = mkOption { type = listOf str; };
      http_directory = mkOption { type = str; };
      shutdown_command = mkOption { type = str; };
      ssh_private_key_file = mkOption { type = str; };
      ssh_port = mkOption { type = int; };
      ssh_username = mkOption { type = str; };
      headless = mkOption { type = bool; };
      type = mkOption { type = str; };
      iso_url = mkOption { type = str; };
      iso_checksum = mkOption { type = str; };
      display = mkOption { type = str; };
      accelerator = mkOption { type = str; };
      disk_interface = mkOption { type = str; };
      disk_size = mkOption { type = str; };
      format = mkOption { type = str; };
      qemuargs = mkOption { type = listOf (listOf str); };
    };
  };
  provisionerSubmodule = submodule {
    options = {
      type = mkOption { type = nullOr str; default = null; };
      source = mkOption { type = nullOr str; default = null; };
      destination = mkOption { type = nullOr str; default = null; };
      execute_command = mkOption { type = nullOr str; default = null; };
      script = mkOption { type = nullOr str; default = null; };
    };
  };
in
{
  options = {
    packer = {
      template = mkOption {
        type = attrsOf (submodule {
          options = {
            builders = mkOption { type = listOf builderSubmodule; };
            provisioners = mkOption { type = listOf provisionerSubmodule; apply = map (filterAttrs (_: v: v != null)); };
            post-processors = mkOption { type = listOf attrs; };
          };
        });
      };
    };
  };

  config = mkIf (cfg.template != { }) {
    outputs.apps.${system} = mapAttrs' mkPackerApp cfg.template;
    outputs.nixosConfigurations = mapAttrs mkPackerNixosConfig cfg.template;
  };
}
