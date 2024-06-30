let
  config = (import ./../../config.nix {});
in
{
  enableACME = config.website.https;
  forceSSL = config.website.https;
}

