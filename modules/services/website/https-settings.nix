{ userConfig, ... }:

{
  enableACME = userConfig.services.website.https;
  forceSSL = userConfig.services.website.https;
}
