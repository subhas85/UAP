# UAP Workflows — ICM Starter Templates

This folder ships **starter ICM (Interpretable Context Methodology) pipelines** for common team workflows. The wizard's Section 10 (project types) lets an operator select which of these get seeded into their `~/ops/pipelines/<type>/` during deployment.

ICM background: see `../setup/references.md` for the paper + plain-English summary.

## Planned starter pipelines

| Folder | Pattern | Stages |
|---|---|---|
| `requirements/` | meeting notes + emails → spec → handoff to dev | `01_intake/`, `02_clean/`, `03_spec/`, `04_handoff/` |
| `helpdesk/` | support ticket → triage → resolve → KB article | `01_intake/`, `02_triage/`, `03_resolve/`, `04_kb/` |
| `incidents/` | alert → diagnose → fix → postmortem | `01_intake/`, `02_diagnose/`, `03_fix/`, `04_postmortem/` |
| `dev/` | feature/bug → branch → review → ship | `01_intake/`, `02_design/`, `03_implement/`, `04_review/`, `05_ship/` |

Each pipeline folder has:
- A top-level `CLAUDE.md` orienting the agent
- A `CONTEXT.md` describing the intent and where work flows in/out
- One subfolder per stage, each with its own `CONTEXT.md` specifying Inputs / Process / Outputs

## Status

**v0.1.0**: scaffolded but not populated. The directory structure exists so the wizard knows where to look; actual pipeline templates (CONTEXT.md per stage, example handoff files) come in a future release.

**v1.0.0 target**: at minimum, `requirements/` and `helpdesk/` populated (they're the most-used patterns); `incidents/` and `dev/` populated to "skeleton" depth.

Contributors welcome — open a PR with a populated stage you've used in production.
