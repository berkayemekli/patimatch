# AGENTS.md

This repository is the PatiParent / PatiMatch Flutter + Firebase project.

Before doing any work, read these files in order:

1. `PROJECT_CONTEXT.md`
2. `TASKS.md`
3. `SYNC_WORKFLOW.md`
4. `CLOUD_WORKFLOW.md`
5. `CODEX_START_HERE.txt`

Core workflow:

- Treat GitHub as the source of truth.
- Start by checking `git status --short` and pulling latest changes when working locally.
- Prefer cloud-first work through GitHub/Codespaces when possible.
- Keep changes small, commit clearly, and push to `main` unless the user asks for a branch.
- Update `TASKS.md` and `PROJECT_CONTEXT.md` when project direction, blockers, or important decisions change.
- Do not deploy manually unless needed; GitHub Actions deploys Firebase Hosting on pushes to `main` when the required Firebase service account secret is configured.

Product direction:

- Premium AI-native pet super app.
- Four modules: PatiGezdirme, PatiBnB, PatiMatch, PatiFamily.
- Visual target: Airbnb trust + Apple polish + Uber simplicity + modern AI startup quality.
- Avoid cartoonish pet UI, cheap marketplace aesthetics, clutter, and dashboard-heavy design.

Important current notes:

- Google login uses popup flow on web. Redirect flow failed in storage-partitioned browser environments.
- Apple login is intentionally deferred because it requires Apple Developer Service ID, Team ID, Key ID, and private key.
- Master data under `app/assets/master_data/` should increasingly drive UI, filters, onboarding, and seed examples.

If the user says only "devam", "go", "start", or similar, read the context files above and continue with the highest-priority item in `TASKS.md`.
