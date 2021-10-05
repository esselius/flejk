{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?dir=lib";
  inputs.terranix.url = "github:mrVanDalo/terranix/feature/flakes";
  inputs.utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, terranix, utils }:
    let
      flakeModules = nixpkgs.lib.filesystem.listFilesRecursive ./flakeModules;

      evalFlakeModules = { system, inputs ? { inherit nixpkgs terranix; }, modules ? [ ], config ? { } }:
        (nixpkgs.lib.filterAttrs
          (key: _: builtins.elem key [
            "checks"
            "packages"
            "defaultPackage"
            "apps"
            "defaultApp"
            "legacyPackages"
            "overlay"
            "overlays"
            "nixosModule"
            "nixosModules"
            "nixosConfigurations"
            "devShell"
            "hydraJobs"
            "defaultTemplate"
            "templates"
          ])
          (nixpkgs.lib.evalModules {
            specialArgs = {
              inherit inputs system;
              pkgs = import nixpkgs { inherit system; };
            };
            modules = flakeModules ++ modules ++ [ config ];
          }).config);
    in
    {
      inherit flakeModules;
      lib = { inherit evalFlakeModules; };
    };
}
