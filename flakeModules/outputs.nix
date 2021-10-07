{ config, lib, ... }:

with lib;
with lib.types;

{
  options = {
    outputs = {
      apps = mkOption { type = attrs; };
      checks = mkOption { type = attrs; };
      defaultApp = mkOption { type = attrs; };
      defaultPackage = mkOption { type = attrs; };
      defaultTemplate = mkOption { type = attrs; };
      devShell = mkOption { type = attrs; };
      hydraJobs = mkOption { type = attrs; };
      legacyPackages = mkOption { type = attrs; };
      nixosConfigurations = mkOption { type = attrs; };
      nixosModule = mkOption { type = attrs; };
      nixosModules = mkOption { type = attrs; };
      overlay = mkOption { type = attrs; };
      overlays = mkOption { type = attrs; };
      packages = mkOption { type = attrs; };
      templates = mkOption { type = attrs; };
    };
  };
}
