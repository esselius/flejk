{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?dir=lib";
  inputs.terranix.url = "github:mrVanDalo/terranix/feature/flakes";
  inputs.utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, terranix, utils }@inputs:
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

      lib.evalModule = module:
        let
          config = eachDefaultSystem (system: (evalModules {
            specialArgs = { inherit inputs system; };
            modules = flakeModules ++ [ module ];
          }).config);
        in
        (filterAttrs (k: _: elem k flakeKeys) config) // config.outputs.x86_64-linux;
    };
}
