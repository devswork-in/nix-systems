# Firefox Configuration

Home-manager configuration for Firefox with custom theme and extensions.

## Features

- **Custom Theme**: Cascade theme - minimalistic and keyboard-centered
- **Privacy-focused**: Telemetry disabled, privacy extensions included
- **Extensions**: Includes uBlock Origin, DarkReader, SponsorBlock, and more
- **Custom Homepage**: Brave Search

## Extensions Included

- Stylus
- NoScript
- DarkReader
- SponsorBlock
- uBlock Origin
- Auto Tab Discard
- Facebook Container
- Return YouTube Dislikes
- Multi Account Containers
- User Agent String Switcher
- Terms of Service; Didn't Read
- DuckDuckGo Privacy Essentials

## Theme

Uses the Cascade theme by Andreas Grafen - a minimalistic Firefox theme that:
- Removes visual clutter
- Keyboard-centered navigation
- Auto-hiding toolbar (shows on focus)
- Custom container tab colors
- Dark/light mode support

## Usage

This module is automatically imported for desktop systems through `modules/essential/configs/desktop/default.nix`.

## Dependencies

Requires NUR (Nix User Repository) for Firefox extensions via `pkgs.nur.repos.rycee.firefox-addons`.
