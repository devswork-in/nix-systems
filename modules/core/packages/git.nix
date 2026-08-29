{ pkgs, ... }:

{
  # User settings are kept in the repository-synced gitconfig.
  environment.systemPackages = with pkgs; [ git lazygit ];
}
