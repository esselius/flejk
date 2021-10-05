{ system, inputs, ... }:

{
  _module.args = {
    pkgs = import inputs.nixpkgs { inherit system; };
  };
}
