{ system, inputs, ... }:

let
  terranix = final: prev: {
    terranix = prev.terranix.overrideAttrs (old: {
      meta.platforms = final.lib.platforms.all;
    });
  };

in
{
  _module.args = {
    pkgs = import inputs.nixpkgs { inherit system; overlays = [ terranix ]; };
  };
}
