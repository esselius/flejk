{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?dir=lib";
  inputs.utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, utils }:
    let
      inherit (nixpkgs.lib) evalModules filterAttrs elem;
      inherit (nixpkgs.lib.filesystem) listFilesRecursive;
      inherit (utils.lib) eachDefaultSystem;

      flakeKeys = [
        "checks"
        "packages"
        "defaultPackage"
        "apps"
        "defaultApp"
        "legacyPackages"
        "devShell"
        "hydraJobs"
      ];

      flakeModules = listFilesRecursive ./flakeModules;
    in
    {
      inherit flakeModules;

      lib.evalModule = specialArgs: module:
        let
          config = eachDefaultSystem (system: (evalModules {
            specialArgs = { inherit system; } // specialArgs;
            modules = flakeModules ++ [ module ];
          }).config);
        in
        (filterAttrs (k: _: elem k flakeKeys) config) // config.outputs.x86_64-linux;
    };
}
