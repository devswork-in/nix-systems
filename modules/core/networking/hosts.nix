{
  networking.hostFiles = [
    (builtins.fetchurl {
      url = "https://raw.githubusercontent.com/StevenBlack/hosts/8007e17d0a66bc9f43d79bb82a218f253d28797a/hosts";
      sha256 = "sha256:0na31fzvm5jh2c1rh260ghq61fsaqdfqmi0n7nbhjzpmcd23wx6z";
    })
  ];
}