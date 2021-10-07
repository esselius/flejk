{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?dir=lib";
  inputs.utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, utils }:
    let
      inherit (nixpkgs.lib) evalModules filterAttrs elem foldr recursiveUpdate;
      inherit (nixpkgs.lib.filesystem) listFilesRecursive;
      inherit (utils.lib) eachDefaultSystem eachSystem;

      flakeModules = listFilesRecursive ./flakeModules;
    in
    {
      inherit flakeModules;

      lib.evalModule = { inputs ? { inherit nixpkgs; }, specialArgs ? { }, modules ? [ ] }: module:
        foldr recursiveUpdate { } (map
          (system: (evalModules {
            specialArgs = { inherit inputs system; } // specialArgs;
            modules = flakeModules ++ modules ++ [ module ];
          }).config.outputs) [ "x86_64-darwin" "x86_64-linux" ]);
    };
}
