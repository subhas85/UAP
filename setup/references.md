# References

External resources the UAP setup wizard or operator may want during or after a deployment. Linked, not bundled — these stay current at their origin.

## Methodology

### Interpretable Context Methodology (ICM)

The folder-structure-as-agent-architecture pattern that UAP's `~/workspace/` hub and `~/ops/` pipelines are built on.

- Paper: [arXiv 2603.16021 — Interpretable Context Methodology: Folder Structure as Agentic Architecture](https://arxiv.org/abs/2603.16021)
- Reference implementation: [github.com/RinDig/Interpretable-Context-Methodology-ICM](https://github.com/RinDig/Interpretable-Context-Methodology-ICM)
- Background: [Anthropic — Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)

**Plain-English summary (read this if you've never encountered ICM):**

ICM is a pattern for organizing work so a single AI coding agent (like Claude Code) can run multi-step pipelines without an orchestration framework. The trick is that **the filesystem itself is the workflow**:

- Numbered stage folders (`01_intake/`, `02_clean/`, `03_handoff/`, …) define the sequence the work moves through.
- Each level has a small markdown file telling the agent its current job:
  - `CLAUDE.md` — *where am I?* (project/workspace identity, always loaded ~800 tokens)
  - `CONTEXT.md` — *where do I go next?* (read on entry to a folder, ~300 tokens)
  - Stage-level `CONTEXT.md` — *what do I do here?* (read per task, ~200–500 tokens, specifies Inputs / Process / Outputs)
  - Reference files — *what rules apply?* (loaded on demand)
- Humans review the handoff file between stages — that's the design, not a bug.

The benefit: instead of writing a CrewAI/LangChain orchestration with N specialized agents talking to each other, you write zero orchestration code and let one agent walk the folder structure. The structure *is* the orchestration.

UAP applies ICM at two scopes: the home-directory **hub** (`~/workspace/CLAUDE.md` routes the agent to the right subworkspace) and **inside each workspace** (`~/ops/pipelines/<name>/01_intake/`, etc.).

---

## Convention — where docs belong (workspace doc vs repo doc)

A practical rule that flows from ICM's "every folder serves a purpose" principle. Useful when the operator has both a workspace hub (`~/workspace/`, with subworkspaces for ops/dev/etc.) AND individual code repos:

**Rule:** *if the doc still makes sense without the code checked out, it goes in the workspace (`ops/projects/`, `shared/runbooks/`, etc.). If understanding it requires the codebase nearby — file paths, configs, code examples — it goes in the repo (`<repo>/README.md`, `<repo>/docs/`).*

| Doc type | Where | Why |
|---|---|---|
| Architecture, API, build, code internals | **In the repo** (`README.md`, `docs/`) | Useless without the code |
| `CHANGELOG.md` of code changes | **In the repo** | Tied to commits |
| Cross-project business framing, owner, blockers, status | **In `<workspace>/projects/`** | About the project as a unit, not about its code |
| Runbooks | **Repo** if specific to one codebase (`docs/operations/`); **`<workspace>/shared/runbooks/`** if cross-cutting | Depends on coupling |

A workspace `<workspace>/projects/<name>.md` should typically be a *short* one-pager linking to the deeper architecture doc in the repo, not a duplicate. One canonical source per fact.

## OS / system

- [Ubuntu Server 24.04 LTS install guide](https://ubuntu.com/server/docs/installation)
- [Tailscale install on Linux](https://tailscale.com/kb/1031/install-linux)
- [xrdp project documentation](https://github.com/neutrinolabs/xrdp/wiki)
- [Plymouth theming guide](https://wiki.archlinux.org/title/Plymouth)
- [i3wm user's guide](https://i3wm.org/docs/userguide.html)

## Tools used in UAP

- [Alacritty configuration reference](https://alacritty.org/config-alacritty.html)
- [Rofi manpage / configuration](https://github.com/davatorium/rofi/wiki)
- [Tokyo Night colour palette (source)](https://github.com/folke/tokyonight.nvim)
- [JetBrains Mono Nerd Font releases](https://github.com/ryanoasis/nerd-fonts/releases)
- [Typora — Tokyo Night theme](https://github.com/Aemiii91/typora-theme-tokyo-night)
- [Typora — Monospace theme (official)](https://github.com/typora/typora-monospace-theme)

## Known issues / upstream context

- [xrdp #1990 — Unicode keyboard event support](https://github.com/neutrinolabs/xrdp/issues/1990)
- [xrdp #3249 — partial-upgrade RandR error](https://github.com/neutrinolabs/xrdp/issues/3249)
- [xrdp #3339 — will 0.10 land on Ubuntu 24.04?](https://github.com/neutrinolabs/xrdp/discussions/3339)
- [Microsoft Remote Desktop — Android keyboard modes](https://learn.microsoft.com/en-us/azure/virtual-desktop/users/client-features-android-chrome-os) (where to find the scancode-vs-Unicode toggle)
