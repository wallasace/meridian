# Contributing to Meridian

Contributions are welcome — bug reports, fixes, new destinations, translations,
or a better way of doing something that is already there.

Meridian is maintained by [Wallace Ferreira de Abreu](https://github.com/wallasace),
who is also the copyright holder. The project is source-available under the
[PolyForm Internal Use License 1.0.0](LICENSE), with an additional permission
that lets you fork it in order to contribute.

## Before you start

For anything beyond a small fix, **open an issue first**. It is disappointing
to write a patch and then learn the idea does not fit, and that is the
maintainer's fault, not yours — a short conversation up front avoids it.

Small and obvious? Go straight to a pull request.

## Reporting a bug

Open an issue at <https://github.com/wallasace/meridian/issues> with:

- what you expected, and what happened instead
- your operating system and how you are running Meridian (browser, installed
  from the browser, or one of the desktop builds)
- the version — the release tag, or the commit
- for the desktop builds, any error text or stack trace, in full
- a screenshot, when the problem is visual

A stack trace pasted as text is worth more than a description of it. The
Windows crash in v1.0.1 was diagnosed from a pasted trace in minutes.

## Suggesting a change

Say what problem it solves before saying how. Meridian deliberately does a
small thing: two destinations, side by side. Proposals that keep it that way
have an easier path than proposals that broaden it.

## Pull requests

1. Fork the repository and branch from `main`
2. Make the change
3. Test it — see below
4. Write a commit message explaining **why**, not only what
5. Open the pull request, describing what you tested and on which systems

Keep a pull request to one subject. Two unrelated fixes are two pull requests.

## Code standards

The project has no build step, no framework and no package manager, and that
is a design decision rather than an omission. Please keep it that way.

**`index.html`** is the entire application — structure, style and behaviour in
one file.

- Plain JavaScript, no dependencies, no transpiling
- Two-space indentation in HTML, compact style in CSS and JS to match what is
  there
- Colours come from the CSS custom properties at the top; do not hardcode new
  ones
- Anything that reaches for the network must degrade gracefully when it fails
- Both themes must stay legible; both are in use
- Respect `prefers-reduced-motion` in anything that animates

**The desktop wrappers** (`desktop/macos`, `desktop/windows`, `desktop/linux`)
exist only to provide a window and to answer four messages from the page:
`close`, `minimize`, `drag` and `pin`. Application logic belongs in
`index.html`, never in a wrapper — otherwise the three platforms drift apart.

**Comments** explain why something is done, especially when the reason is not
obvious from the code. Several comments in this project record a platform bug
and the workaround it forced; those are the useful kind. Comments that restate
the code are not.

Write code and comments in English. Issues and pull requests may be in English
or Portuguese, whichever you are comfortable with.

## Documentation

If your change alters what a person sees or does, update the README in the same
pull request. A feature nobody can find is not finished.

New third-party material of any kind must be added to [NOTICE](NOTICE), with
its licence. A dependency whose licence conflicts with this project's cannot be
accepted — please raise it in an issue before writing the code.

## Testing

There is no automated test suite yet, so testing is manual and honest
reporting matters.

Whatever you touch, check:

- both light and dark themes
- a narrow window (around 360px) and a wide one
- that the clocks still tick and the difference line still reads correctly

If you touched the catalog, also check that the new time zone is a valid IANA
identifier and that the flag actually loads. If you touched a wrapper, say
which operating system you tested on — the maintainer does not have all three,
and an untested platform should be declared, not assumed.

## Review

The maintainer reviews pull requests. Expect questions: about the reason for a
change more often than about the code itself. Review may take a few days.

A pull request may be declined for being outside the project's scope even when
the code is good. If that happens it is not a judgement of the work, and
saying so early is the reviewer's job.

## Third-party contributions

You keep the copyright in what you write. You do not sign it away.

What the project needs is permission to use your contribution — including in
commercially licensed versions, since Meridian offers a commercial licence
alongside the internal-use one. Opening a pull request means you agree to the
terms in [CLA.md](CLA.md). Please read it; it is short.

If you are contributing as part of your job, check whether your employer claims
rights over what you write. That question belongs to you and your employer, and
the project cannot settle it for you.

Do not paste code you did not write and do not have the right to contribute.
If a change is adapted from somewhere else, say so in the pull request, with
the source and its licence, so it can be recorded in [NOTICE](NOTICE).

## Security

Do not report security problems in public issues. See [SECURITY.md](SECURITY.md).
