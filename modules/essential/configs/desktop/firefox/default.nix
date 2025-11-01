{ config, pkgs, lib, ... }:

{
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      name = "Default";
      isDefault = true;
      
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        stylus
        noscript
        darkreader
        sponsorblock
        ublock-origin
        auto-tab-discard
        facebook-container
        return-youtube-dislikes
        multi-account-containers
        user-agent-string-switcher
        terms-of-service-didnt-read
        duckduckgo-privacy-essentials
      ];
      
      userChrome = builtins.readFile ./userChrome.css;
      
      settings = {
        "browser.startup.homepage" = "https://search.brave.com";
        "browser.search.region" = "IN";
        "browser.search.isUS" = false;
        "browser.download.animateNotifications" = false;
        "security.dialog_enable_delay" = 0;
        "distribution.searchplugins.defaultLocale" = "en-IN";
        "general.useragent.locale" = "en-IN";
        "browser.bookmarks.showMobileBookmarks" = true;
        "ui.systemUsesDarkTheme" = 1;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;
        "layers.acceleration.force-enabled" = true;
        "gfx.webrender.all" = true;
        "extensions.webextensions.restrictedDomains" = "";
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.ping-centre.telemetry" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.hybridContent.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.reportingpolicy.firstRun" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
      };
    };
  };
}
