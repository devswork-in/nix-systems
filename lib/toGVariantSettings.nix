{ lib }:

let
  convert = value:
    if builtins.isInt value then lib.gvariant.mkInt32 value
    else if builtins.isFloat value then lib.gvariant.mkDouble value
    else if builtins.isList value then
      if value == [ ] then lib.gvariant.mkEmptyArray lib.gvariant.type.string
      else map convert value
    else if builtins.isAttrs value then lib.mapAttrs (_: convert) value
    else value;
in convert
