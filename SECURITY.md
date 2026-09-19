# Security

## Reporting a vulnerability

**Please do not open a public issue for a security problem.**

Report it privately through GitHub:

1. Go to <https://github.com/wallasace/meridian/security/advisories/new>
2. Describe the problem and how to reproduce it

If that page is unavailable to you, reach the maintainer through
<https://github.com/wallasace> and ask for a private channel before sending
details.

Useful to include: what an attacker could achieve, the steps to reproduce,
which version and platform, and any proof of concept you have.

## What to expect

Meridian is maintained by one person in his spare time, so here is the honest
version rather than a corporate-sounding promise:

- **Acknowledgement:** within a few days
- **Assessment:** as soon as the problem is understood, with an explanation of
  what was concluded
- **Fix:** timing depends on severity and on available time
- **Credit:** you will be credited in the advisory and release notes, unless
  you prefer otherwise

There is no bug bounty. There is no money in this project.

## Supported versions

Only the [latest release](https://github.com/wallasace/meridian/releases/latest)
is supported. Fixes are not backported.

## What is worth reporting

Meridian has a small surface, so it helps to know where the risk actually is:

- **The page** (`index.html`) runs no user-supplied code and talks to no server
  of its own. Preferences live in `localStorage` on the device.
- **The desktop wrappers** host that page in a system WebView and accept four
  messages from it: `close`, `minimize`, `drag`, `pin`. A way to make a wrapper
  do something beyond those four is worth reporting.
- **External requests** go to two CDNs, for flags and fonts, over HTTPS.
- **The service worker** caches those responses for offline use. Cache
  poisoning that survives a reload is worth reporting.
- **The released binaries** are not code-signed, which is stated openly in the
  README. That is a known limitation, not a finding — certificates are paid and
  this project has none.

## Out of scope

- The unsigned-binary warnings on macOS and Windows, as above
- Vulnerabilities in the CDNs, browsers, or operating systems themselves —
  report those to their maintainers
- Findings that require an attacker to already control the user's machine
