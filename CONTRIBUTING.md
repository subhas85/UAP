# Contributing to UAP

Thanks for your interest in UAP. This is a small, opinionated framework — contributions, bug reports, and forks are all welcome. The guidelines below keep the project coherent.

## Dev environment

UAP is plain text — bash scripts, markdown, YAML, config templates. To work on it:

```bash
git clone https://github.com/subhas85/uap.git ~/uap
cd ~/uap
# edit any file in your editor of choice
```

To test changes end-to-end, run `bash ~/uap/bootstrap.sh` on a throwaway Ubuntu 24.04 VM (Proxmox, libvirt, multipass, or a cloud VM all work). `bootstrap.sh` is idempotent, so re-runs are safe.

For template/render changes, `bash ~/uap/setup/apply.sh --dry-run` re-renders every component and shows the diff against live files without installing.

## Reporting bugs

File issues at `https://github.com/subhas85/uap/issues`. A good bug report includes:

- Ubuntu version (`lsb_release -a`)
- Hypervisor / hardware (Proxmox, ESXi, bare metal, cloud, etc.)
- What you ran and what happened
- Relevant excerpt from `~/uap.local/answers.yaml` (redact anything sensitive)
- For apply.sh failures: the `[apply.sh] <component>: ...` log lines

## Coding conventions

- **Bash scripts** start with `#!/usr/bin/env bash` and `set -euo pipefail`. Quote all variable expansions. Prefer `install -m <mode>` over `cp` + `chmod`.
- **Templates** use GNU `envsubst` syntax: `${VAR_NAME}` (curly braces mandatory). Files end in `.tmpl`. Static files don't need the suffix.
- **One component per folder** under the appropriate scope: `os/<component>/` for system / desktop / window manager bits, `ai/<component>/` for Claude Code and assistant integration, `workflows/<component>/` for ICM pipeline starters. Each component owns its templates, assets, and (if needed) install hook in `apply.sh`. `apply.sh` resolves a component name by searching `os/` → `ai/` → `workflows/`, so component names must be unique across scopes.
- **New variables** must be documented in `setup/DESIGN.md` (under the `identity.yaml` schema section) and added to the `identity.yaml` example.
- **Markdown** uses sentence-case headings and fenced code blocks tagged with the language. No trailing whitespace.
- **No emojis** in code, config, or docs unless the user explicitly asks.

## PR workflow

1. Fork `github.com/subhas85/uap`.
2. Branch from `main`: `git checkout -b feature/short-name` or `fix/short-name`.
3. Make your change. Keep PRs focused — one logical change per PR.
4. Before opening the PR, run:
   - `bash -n bootstrap.sh setup/apply.sh` (syntax check)
   - `bash ~/uap/setup/apply.sh --dry-run` on a test VM if your change touches templates or `apply.sh`
   - A real `apply.sh` run on a test VM if your change touches install hooks
5. Open a PR with a clear description: what changed, why, and how you tested.
6. Be patient — reviews may take a few days.

## Scope

UAP v1 is opinionated about its baseline: **Ubuntu Server 24.04 LTS + i3 window manager + xrdp**. The framework is parameterized for branding, palette, apps, and AI integration on top of that baseline, but the baseline itself is fixed. If you'd like to propose support for a different distro (Debian, Fedora, NixOS) or a different WM (sway, bspwm, GNOME), please open an issue to discuss before writing code — the change is likely large enough to warrant design discussion first.

Smaller additions (new color palette, additional terminal tools, new templatable component, new known-issue fix) are welcome without prior discussion — just open a PR.

## License

By contributing, you agree your contributions are licensed under the project's MIT License (see `LICENSE`).
