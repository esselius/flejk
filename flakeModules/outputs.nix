{ config, lib, ... }:

with lib;
with lib.types;

{
  options = {
    outputs = mkOption {
      type = submodule {
        options = {
          apps = mkOption { type = anything; default = null; };
          checks = mkOption { type = anything; default = null; };
          defaultApp = mkOption { type = anything; default = null; };
          defaultPackage = mkOption { type = anything; default = null; };
          defaultTemplate = mkOption { type = anything; default = null; };
          devShell = mkOption { type = anything; default = null; };
          hydraJobs = mkOption { type = anything; default = null; };
          legacyPackages = mkOption { type = anything; default = null; };
          nixosConfigurations = mkOption { type = anything; default = null; };
          nixosModule = mkOption { type = anything; default = null; };
          nixosModules = mkOption { type = anything; default = null; };
          overlay = mkOption { type = anything; default = null; };
          overlays = mkOption { type = anything; default = null; };
          packages = mkOption { type = anything; default = null; };
          templates = mkOption { type = anything; default = null; };
        };
      };
      apply = filterAttrs (_: v: v != null);
    };
  };
}
