# docs/DEBT.md — known wrong, stale or unfinished

A working list, not a record. An item is added the moment it is found and **deleted** by the change that fixes it: no strikethroughs, no history. Each item is checkable: file, place, what is wrong. Not here: open questions (`DECISIONS.md` §11), unverified claims (`DECISIONS.md` §13), tastes.

- GitHub Pages: the "pages build and deployment" run for merge `2a9a17a` (2026-10-06) built successfully, but its `deploy` job stayed "waiting" with no reviewers and no approve button. The site still serves the January deployment, so `privacy.html` is unaffected. Check whether the next merge deploys; if it also waits, look at Settings → Environments → `github-pages` and Settings → Pages.
- `privacy.html` versus `AndroidManifest.xml` — the policy lists two permissions; the manifest declares four (`SPEC.md` §9). Changing the wording is owner-approved text (`DECISIONS.md` §11 O-3).
- `lib/providers/photo_provider.g.dart` — the committed file does not match its source. Running `build_runner` changes `_$photoNotifierHash` and the provider's doc comment (found 2026-10-06 while regenerating `backup_models`). The hash is used only in debug builds. Regenerate it in a change of its own.
