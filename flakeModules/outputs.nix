{ config, lib, ... }:

with lib;
with lib.types;

{
  options = {
    outputs = mkOption {
      default = { };
      type = attrs;
    };
  };
}
