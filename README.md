<div align="center">

# Meridian

**A world clock that puts two destinations side by side** — each with its own
flag waving behind the time, the current UTC offset, and how far apart the two are.

![Meridian in action](docs/demo.gif)

[**Open in your browser**](https://wallasace.github.io/meridian/) ·
[Download for desktop](https://github.com/wallasace/meridian/releases/latest) ·
[How it works](#how-its-put-together)

[![License](https://img.shields.io/badge/license-PolyForm%20Internal%20Use%201.0.0-7fb0ea.svg)](LICENSE)
[![Source available](https://img.shields.io/badge/source--available-not%20open%20source-8b93a7.svg)](#licence)
![Countries](https://img.shields.io/badge/countries-200-4bc89a.svg)
![Size](https://img.shields.io/badge/app-33%20KB-4bc89a.svg)
![Platforms](https://img.shields.io/badge/macOS%20·%20Windows%20·%20Linux%20·%20web-7fb0ea.svg)

</div>

Nothing to install to try it. Your browser can also keep it as a real app —
see [Install from the browser](#install-from-the-browser).

Meridian is **source-available**: free to run and modify for your own and your
company's internal use, and the code is here to read. It is not open source —
see [Licence](#licence).

## What it does

- Live local time for two destinations, to the second, from one shared instant
- **200 countries and territories, 245 cities** — every country spanning several
  time zones lets you pick the city (Brazil has 8, the US 7, Russia 7)
- Handles daylight saving automatically, and offsets that aren't whole hours
  (Nepal is `UTC+5:45`, India `UTC+5:30`)
- Says the difference in plain words: *"Israel is 6h ahead of Brazil"*, and
  flags when the two are on different calendar days
- Search by country or city, accent-insensitive — typing `sao` finds São Paulo
- Flags wave like cloth; the motion can be paused, and it respects your system's
  reduced-motion setting
- Follows your light/dark theme
- Remembers your destinations, the wind setting and the pin between sessions

## Install from the browser

On the [live page](https://wallasace.github.io/meridian/):

| | |
|---|---|
| **Chrome / Edge** (Windows, Linux, macOS) | Click the install icon in the address bar, or menu → *Cast, save and share* → *Install page as app* |
| **Android** | Menu → *Add to Home screen* |
| **iPhone / iPad** | Share → *Add to Home Screen* |

It opens in its own window, with no address bar, and works offline after the
first visit. No download, no security warnings.

## Desktop apps

Native windows with no browser chrome — and a **pin** button that keeps the
clock above other windows, which the browser version cannot do.

Grab one from the [latest release](https://github.com/wallasace/meridian/releases/latest):

| System | File | First launch |
|---|---|---|
| macOS 11+ | `Meridian-macOS.zip` | Right-click the app → **Open** (once) |
| Windows 10/11 | `Meridian-Windows.zip` | **More info** → **Run anyway** (once) |
| Linux (GTK) | `Meridian-Linux.tar.gz` | `./install.sh` |

That extra click on the first launch is the unsigned-app warning. Code signing
certificates cost money every year and this project has none — the warning is
about a missing certificate, not about the app.

**Window controls:** 📌 keep on top · − minimize · × close (⌘W / Ctrl+W also
work). Drag the window by its header or footer.

## Building it yourself

The app itself is one file, `index.html`, and needs no build step at all — open
it and it runs. Each desktop wrapper is a thin native shell around it:

```bash
# macOS — needs Xcode command line tools
./desktop/macos/build.sh

# Windows — needs the .NET 8 SDK (winget install Microsoft.DotNet.SDK.8)
.\desktop\windows\build.ps1

# Linux — no build, just system packages
sudo apt install python3-gi gir1.2-webkit2-4.1   # Debian/Ubuntu
./desktop/linux/install.sh
```

Or let GitHub build all three: push a tag and the
[release workflow](.github/workflows/release.yml) compiles on macOS, Windows and
Linux runners and publishes the files.

```bash
git tag v1.0.0 && git push origin v1.0.0
```

## How it's put together

```
index.html              the whole app — layout, clocks, catalog, flag animation
manifest.webmanifest    lets browsers install it as an app
sw.js                   offline cache
icons/                  app icons
desktop/macos/          Swift + WebKit wrapper
desktop/windows/        C# + WebView2 wrapper
desktop/linux/          Python + GTK/WebKitGTK wrapper
```

All three wrappers answer the same four messages from the page — `close`,
`minimize`, `drag`, `pin` — plus `fit` on Windows, which sizes the window to the
card because its frame cannot be transparent.

Time is computed with `Intl.DateTimeFormat` over IANA time zone identifiers, so
daylight saving and odd offsets come from the system's own tz database rather
than from hardcoded rules.

## Contributing

Bug reports, fixes and ideas are welcome. Start at
[CONTRIBUTING.md](CONTRIBUTING.md) — it covers how to report a problem, the
code conventions, what to test, and how review works.

Security problems go through [SECURITY.md](SECURITY.md) instead of public
issues.

## Credits

- Flags — [flag-icons](https://github.com/lipis/flag-icons) by Panayiotis Lipiridis (MIT)
- Type — [Manrope](https://github.com/sharanda/manrope) by Mikhail Sharanda and
  [DM Sans](https://github.com/googlefonts/dm-fonts) by Colophon Foundry (both SIL OFL 1.1)
- Time zones — the [IANA time zone database](https://www.iana.org/time-zones),
  via the browser's `Intl` API
- Country codes — ISO 3166-1 alpha-2

## Licence

Meridian is **source-available software, not open source**. The code is public
to read, study, run and modify — but it is not published under an OSI-approved
open source licence, and it does not turn into one later. Calling it open
source would be inaccurate, so this project does not.

It is licensed under the
[PolyForm Internal Use License 1.0.0](https://polyformproject.org/licenses/internal-use/1.0.0),
a standard licence written by lawyers. The full text is in [LICENSE](LICENSE).

**Free, no licence to request:**

- running Meridian yourself, on any device
- your team or your entire company running it internally
- reading the code and learning from it
- modifying it for your own internal use
- forking it to send a pull request — granted explicitly in [LICENSE](LICENSE)

**Needs a commercial licence:**

- selling it, or charging for access to it
- shipping it inside a product or service you offer to customers
- hosting it as a service reachable from outside your organization
- redistributing it through a store, registry or installer

The boundary between the two, with each term defined, is in
[COMMERCIAL.md](COMMERCIAL.md) — including how to ask. Asking is free, and the
answer is often "what you are doing is already covered".

Third-party material and its licences are listed in [NOTICE](NOTICE).

## Maintainer

Meridian is created and maintained by **Wallace Ferreira de Abreu**
([@wallasace](https://github.com/wallasace)), who holds the copyright.

Copyright © 2026 Wallace Ferreira de Abreu

Contributors keep the copyright in their own contributions — see
[CLA.md](CLA.md). Forks are welcome under the terms above, and a fork does not
imply endorsement by this project.
