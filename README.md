# Omarchy

Omarchy is a beautiful, modern & opinionated Linux distribution by DHH.

Read more at [omarchy.org](https://omarchy.org).

## AArch64 fork

This fork adapts Omarchy for generic AArch64 virtual machines. Its `main`
branch is based on reviewed official releases from
[`basecamp/omarchy`](https://github.com/basecamp/omarchy), while the image
builder lives separately in
[`riverscn/omarchy-aarch64-image`](https://github.com/riverscn/omarchy-aarch64-image).

The fork keeps three source-branch roles. `main` is the stable integration line
and contains each reviewed official release plus its AArch64 adaptation.
`quattro` follows `upstream/quattro` with the same adaptation and is the only
source checkout used by the `dev` update channel. A versioned branch such as
`v4-0-2` exists only while that upstream release line needs candidates or
backports. Stable, rc, edge, and dev are update/package states; they are not
parallel long-lived AArch64 Git branches. Temporary integration branches are
deleted after their commits reach the corresponding canonical branch.

Official tags are preserved at their original upstream commits. Adapted source
releases follow the same version with an AArch64 revision suffix: for example,
official `v4.0.1` corresponds to `v4.0.1-aarch64.1`.

Scheduled automation treats the `omarchy` version already published in
`pkgs.omarchy.org/stable` as the admission signal. It merges the matching
official source tag, runs the CLI and applicable source/AArch64 tests, then
publishes both the official tag/Release and its AArch64 adaptation. This sync
workflow is the sole release authority; use its manual **Run workflow** action
instead of publishing tags by hand. The cross-repository `omarchy-iso`
assertion is intentionally excluded because this project does not consume the
ISO. A merge conflict or test failure stops publication for human review. The
package repository follows the adapted tag on its next scheduled
synchronization.

## The Omarchy Manual

The manual lives in [`manual/`](manual/), which is its authoritative source. It's
mirrored to [learn.omacom.io](https://learn.omacom.io/2/the-omarchy-manual), where
its screenshots are also hosted.

- [Welcome to Omarchy!](manual/01-welcome-to-omarchy.md)

**The Basics**

- [Getting Started](manual/02-getting-started.md)
- [Coming From Mac or Windows](manual/03-coming-from-mac-or-windows.md)
- [Navigation](manual/04-navigation.md)
- [The top bar](manual/05-the-top-bar.md)
- [Themes](manual/06-themes.md)
- [Hotkeys](manual/07-hotkeys.md)
- [Unified Clipboard & History](manual/08-unified-clipboard-history.md)
- [Reminders](manual/09-reminders.md)
- [Notices](manual/10-notices.md)
- [Text Extraction & Dictation](manual/11-text-extraction-dictation.md)
- [Screenshots & Recording](manual/12-screenshots-recording.md)
- [Toggles, idle & screensaver](manual/13-toggles-idle-screensaver.md)
- [Omarchy CLI](manual/14-omarchy-cli.md)

**The Applications**

- [Terminal](manual/15-terminal.md)
- [Neovim](manual/16-neovim.md)
- [AI](manual/17-ai.md)
- [Development Tools](manual/18-development-tools.md)
- [Shell Tools](manual/19-shell-tools.md)
- [Shell Functions](manual/20-shell-functions.md)
- [TUIs](manual/21-tuis.md)
- [GUIs](manual/22-guis.md)
- [Browsers](manual/23-browsers.md)
- [Commercial apps/services](manual/24-commercial-apps-services.md)
- [Web Apps](manual/25-web-apps.md)
- [Gaming](manual/26-gaming.md)
- [Filling out PDFs](manual/27-filling-out-pdfs.md)
- [Windows VM](manual/28-windows-vm.md)
- [Other Packages](manual/29-other-packages.md)

**Configuration**

- [Updates](manual/30-updates.md)
- [Dotfiles](manual/31-dotfiles.md)
- [Shell plugins](manual/32-shell-plugins.md)
- [Monitors](manual/33-monitors.md)
- [Keyboard, Mouse, Trackpad](manual/34-keyboard-mouse-trackpad.md)
- [Networking](manual/35-networking.md)
- [System sleep](manual/36-system-sleep.md)
- [Hardware authentication](manual/37-hardware-authentication.md)
- [Fonts](manual/38-fonts.md)
- [Backgrounds](manual/39-backgrounds.md)
- [Prompt](manual/40-prompt.md)
- [Branding](manual/41-branding.md)
- [Common tweaks](manual/42-common-tweaks.md)
- [Making your own theme](manual/43-making-your-own-theme.md)

**The Rest**

- [Mac support](manual/44-mac-support.md)
- [Troubleshooting](manual/45-troubleshooting.md)
- [FAQ](manual/46-faq.md)
- [System snapshots](manual/47-system-snapshots.md)
- [Security](manual/48-security.md)
- [Omarchy on...](manual/49-omarchy-on.md)
- [Dual Boot Install](manual/50-dual-boot-install.md)
- [Unattended Installs](manual/51-unattended-installs.md)

## License

Omarchy is released under the [MIT License](https://opensource.org/licenses/MIT).
