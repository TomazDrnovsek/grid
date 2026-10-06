# GUARDRAILS.md — how not to fail

**Sources.** Part I is copied verbatim from `TomazDrnovsek/tabla` `GUARDRAILS.md` Part I, as carried in Appendix A of the owner's *Cloud-first development workflow* guide, version 4 (2026-09-27, read at tabla `0d6f65e`), copied here on 2026-10-06. The citations inside Part I — *(E-xxx)*, *(B)*, dated lesson tags, D-numbers, and file and section references such as `ARCHITECTURE.md` §2c — are tabla's addresses and resolve in that repository, not this one. Part I is not edited here; a correction is made in tabla and copied again.
**Structure.** Part I: universal rules 1–12. Part II: rules specific to Grid, numbered from 13.
**Numbering.** Rule numbers are addresses: never renumbered; a retired number stays reserved.

## Protocol

1. Read this file before any code-touching or design task. A brief names a rule by number and does not quote it.
2. Convert the applicable rules into concrete acceptance checks **before** changing anything.
3. Record any correction, mistake or blunder in `docs/incidents.md` during the same task. A completion report is not valid until the entry exists.
4. At the third instance of a pattern, distil it into a numbered rule in Part II. Rules that prove project-agnostic are proposed for tabla's Part I.

---

# Part I — Universal rules

### 1. Change only what was asked

The single most repeated failure across both projects. A request to fix X is not permission to improve Y.

- Implement only the requested feature plus the minimum technical change needed to make it work. Preserve every unrelated confirmed element exactly. *(E-044, B)*
- For a single-item edit, state the invariants explicitly: "remove only X, keep everything else unchanged." *(E-016)*
- A density, spacing, or interaction correction is a scoped component adjustment, not authorization to restyle adjacent surfaces. *(E-007, E-058)*
- When a screenshot accompanies a bug report, identify the exact spatial or behavioural defect before touching any adjacent styling, copy, icon, or interaction. *(E-104)*
- "This might be better" is a proposal requiring approval, never authorization. No "while I'm here" additions. *(B)*
- Never silently reopen a settled decision. Locked decisions change only when the owner initiates, via a dated superseding entry in the decision log. *(B)*
- A stated hard requirement is not a scoping question. When the owner states a requirement in absolute terms ("identical offline and online"), do not re-scope it into a later phase or a partial mechanism without asking — re-litigating a settled requirement costs the owner more than building it correctly the first time. *(2026-08-06 offline parity)*
- **A comment describing behaviour the code no longer has is a defect, not neutral leftover.** When a change invalidates a nearby comment, correct it in the same commit even if the comment sits marginally outside the stated scope — the alternative is a file that lies about itself. *(2026-08-07 features — a reverted CSS rule left two component comments describing the reverted mechanism as the current discovery affordance.)*
- **Do not turn a bug report into an infrastructure project.** A misdiagnosis chain on 2026-08-07 ended with a piece of build-versioning infrastructure being proposed as urgent, immediately after three wrong explanations for the owner's actual problem. The infrastructure was worth building; presenting it as the fix for an unresolved bug, mid-frustration, was not. Fix the reported thing first; propose adjacent work as adjacent work, separately, when the reported thing is closed. *(2026-08-07 features)*

**Check:** before handoff, compare the final diff against the stated boundary and remove anything outside it.

### 2. Trace the whole lifecycle before writing code

Partial implementations were repeatedly reported as complete.

- Translate the request into an acceptance checklist first. A new data field means: schema, existing-data population, create input and default, insert, query selection, client mapping, visible display surface, edit input, update, responsive presentation, and save-and-reload verification. *(E-090, E-088, E-089)*
- Do not begin from the first obvious code location. *(E-090)*
- Never ship a visible control that does nothing. Activate every affordance and confirm its state change. *(E-025, E-038)*
- Every workflow must be reachable from every intended entry point, and each tested from there. *(E-042, E-046, E-050)*
- Trace the full read path of every value you write: who reads it, when, and from where. A handler that sets framework state while the reader reads persistent storage produces a stale value. Writes read by another system must happen synchronously where that system expects them. *(B)*
- When renaming a key, identifier, or field, grep the whole codebase for every occurrence and assign each one to a task before writing the change. The definition site is never the only site. *(B)*
- Cleanup completeness: a new persisted key gets added to **all** reset/clear paths that should remove it; a new stateful object gets registered in **all** lifecycle helpers that manage its kind. Enumerate those paths in the plan, not after the bug. *(B)*
- Persist derived state from the **accepted** output, never from an intermediate candidate that may be rerolled or discarded. *(B)*
- When a stored value needs context to interpret (a mode, a version, a unit), store the context with the value. Interpreting an old value with the current context displays the wrong result whenever the two differ. *(B)*
- Migrating or consolidating a component into a shared primitive requires enumerating every field, state, and reachable control it has — not just confirming the component opens. *(2026-08-05 repair)*
- "Works offline" has at least three independent layers — data, app shell, and binary assets — and each needs its own mechanism. Satisfying one does not satisfy the others; state which layer a claim of offline support actually covers. *(2026-08-06 offline parity)*
- Cache-on-view can never satisfy a parity requirement. If the requirement is "identical offline," the cache must be populated proactively from the full data set. *(2026-08-06 offline parity)*
- **Check the live data before assuming a feature reaches all of it.** An ingredient-scaling feature worked perfectly on every recipe anyone tested and was silently inert on 22 of 225, because those rows carried a column (`group_label`) written by a years-old import and surfaced by no UI. A five-second `count(*) ... where <column> is not null` would have found it before the feature shipped. Query the real distribution of any column your feature's correctness depends on. *(2026-08-07 features)*
- **A "one-time" seed or default must be self-limiting by construction, not by a flag someone remembers to flip.** Prefer a condition that the seeding action itself invalidates, or — better — derive the default at read time and never store it at all. A stored seed with a separate "has been seeded" flag is two pieces of state that can disagree. *(2026-08-07 features)*
- **Feedback is gated on the result, not the attempt.** A toast placed immediately after a call is a claim about the call, not about its outcome. Three instances shipped in one phase and every one was invisible to the test suite: a sign-in success state gated on a `message` the success path never set, so its UI had never rendered; an add-meal toast with no slot named and no undo while its three siblings carried both; and a theme toast fired after a setter that returns early in local mode, announcing a change nothing had written. Fire feedback from the result, or verify the result exists before firing. *(2026-08-22, incident 99; D-183)*
- **Where one function turns rows into text, find the function that turns the text back, and pin the round trip by test.** A shared text blob read back into rows is a round trip, and the read half can be missing for months: `recipe_ingredients.group_label` was written by an import and rendered by the UI, but had no writer on the edit path, so every edit of a grouped recipe destroyed data while the gate stayed green and the screen looked right. If the reverse function cannot be found, that absence is the finding. *(2026-09-07, incident 114; D-200)*

**Check:** declare completion only after the entire checklist is verified together, not stage by stage.

### 3. Ground every claim; never guess

- Every structural claim — file path, component name, function signature, storage key, config value — is confirmed against a live source (file read, grep, diff, or explicit owner statement) before it enters a plan or prompt. If not confirmed, state it as unknown. *(B)*
- "Dead code" and "unused" conclusions require a full-repo grep with zero matches. Zero matches in the files you happened to read is not evidence. *(B)*
- Distinguish confirmed bugs from inferred causes — never conflate them in a report. *(B)*
- Filenames, labels, and semantic names are not content. Verify that an asset, icon, or reference actually contains what its name implies before shipping or citing it. *(E-076, E-077, E-078, B)*
- Before telling an agent to "match the pattern from X," verify X actually achieves the stated goal in its live form. *(B)*
- Treat export files, database properties, page content, and rendered UI as **separate source layers**. When one layer contradicts another, inspect the live source read-only. Report absence as "not present in this source layer," never as proof the original has none. *(E-043)*
- **The location of a file is a structural claim.** State where a document lives only after confirming it there. *(2026-08-06 migration)*
- **Never instruct an agent to select a file by recency when its content is already known.** *(2026-08-06 migration)*
- **A search tool returning zero results is not evidence of absence.** GitHub code search returned `total_count: 0` with `incomplete_results: true` for identifiers a direct read proved present. Zero-match claims about a codebase require a local full-repo grep. *(2026-08-06 migration)*
- A rule number, line count, or file count cited from an earlier session or an audit is a claim like any other — re-verify it against the live file before repeating it. *(2026-08-05 repair)*
- **A multi-call or truncated file read must be checked against its declared extent before being treated as complete.** *(2026-08-06 local-first)*
- **A recorded diagnosis is a claim, not a finding — re-verify it before acting on it.** A documented "open defect" said Use up history writes failed because `authenticated`'s grants were select-only. Every word of the grant description was true and the conclusion was wrong: a `SECURITY DEFINER` function owned by the table's owner bypassed both the grants and RLS, the writes worked, and the table already held rows. The real defect was the transport (a direct RPC in an otherwise local-first app). Because the wrong diagnosis had been copied from the decision log into the Workplan, it aimed the next session at the wrong layer. **Verify the symptom exists before fixing the stated cause.** *(2026-08-07 features)*
- **State a diagnosis at the confidence you actually have.** Three consecutive explanations for one reported bug were delivered as settled fact and all three were wrong — a React feedback loop (real, but not the cause), failing database writes (disproved by the row's own contents), and a stale service-worker cache (disproved by reading `sw.js`, which is network-first). Each was plausible; none was verified before being asserted. Say "the evidence is consistent with X, and here is what would confirm it," and then go and confirm it. *(2026-08-07 features)*
- **Read the file before theorising about it.** The service-worker misdiagnosis above took ninety seconds to disprove by opening `public/sw.js`. It had been asserted from memory across two turns first. When a file is available and the claim is about that file, read it. *(2026-08-07 features)*
- **A class name appearing in a document is not evidence of an element.** Strip `<script>` and `<style>` content before scanning HTML for class names: on one recipe site the first occurrence of `wprm-recipe-ingredients-container` was a CSS-selector string inside an ad-configuration script, so a scan starting there found zero items and the feature degraded silently rather than failing. *(2026-09-07, incident 115; D-200)*
- **Class matching is token matching, never substring matching.** `wprm-recipe-ingredient-group` contains `wprm-recipe-ingredient`, so a substring test conflates container, groups and items and returns a plausible wrong count — plausible being the danger, since a merely wrong count passes a sanity check that an absurd one would fail. Split on whitespace and compare tokens. *(2026-09-07, incident 116)*

### 4. Test capabilities — never assert a limitation untested

- Tool availability is a thing you **test**, not a thing you assert. Before claiming any tool, connector, or capability is unavailable, run the discovery call and attempt the smallest real operation. *(B)*
- Calibrate questions to ambiguity, not to caution. When the instruction is concrete and the sources have been read, execute and report. Reserve questions for genuine blockers. *(B)*
- The companion lesson: "ask less" never means "assume more." Verify by reading and testing, then act — without narrating the verification. *(B)*
- When the owner shows multiple screens or points at a discrepancy, address all of it or ask whether to. *(B)*
- When an instruction is genuinely ambiguous about its target, surface the ambiguity and confirm before generating code. *(B)*
- **Verify a runtime primitive's actual behaviour before relying on it for correctness or security.** Node's `net.BlockList` was chosen over hand-rolled CIDR arithmetic precisely because it is maintained and tested — and registering an `::ffff:0:0/96` rule on it makes `check()` classify **every** IPv4 address as blocked, including public ones. The obvious way to write "block IPv4-mapped private addresses" would have blocked every legitimate request while looking like a correct security control. Found by running a throwaway script, not by reading documentation. *(2026-08-07 features)*

### 5. Verify in the real runtime, at the real size

- Local is not delivered. A feature is complete only after implementation, any required migration, commit, push, successful deployment, and production verification. Until every step is done, say explicitly that it is local. *(E-094)*
- A successful HTTP 200, a passing build, or compiling code is not proof the app works. Confirm client hydration and one interactive signal in the environment the owner actually uses. *(E-045)*
- DOM presence is not completion. Verify the control is visually discoverable and its purpose understandable at the target viewport. *(E-093)*
- A responsive fix is not complete until checked at the reported layout width. When a selector appears in more than one breakpoint, inspect the enclosing media query before patching. *(E-064, E-059)*
- A shared requirement belongs in the base rule; then re-check every breakpoint override. *(E-060)*
- Component layout must account for the **container**, not only the browser viewport. *(E-071)*
- Validate icon and control *perception* at rendered size, not semantic name. *(E-103, E-101)*
- Some bugs are invisible in your preview environment. Before diagnosing, confirm the issue reproduces — and after fixing, that the fix holds — in the runtime where it was reported. *(B)*
- An element that responds to input but shows nothing on the target device is a layout-clip suspect first and a paint bug second. *(B)*
- A jsdom or component-test pass does not exercise real CSS layout, cascade inheritance, or `calc()`/media-query evaluation against a real viewport. *(2026-08-05 repair)*
- Testing a CSS-Modules component by injecting an element with its literal (unhashed) class name proves nothing. *(2026-08-05 repair)*
- Verify an offline behaviour with a genuine cold start, not an already-open tab. *(2026-08-06 offline parity)*
- **Establish what code the device is actually running before concluding a fix failed.** Two correct, deployed fixes were reported as still broken because a tab opened before the deploy kept running old JavaScript — and, because PowerSync shares one local database across tabs, kept writing to the rows the new code was reading. Reloading the visible tab could not help; the writer was another window. **Before diagnosing "the fix didn't work": close other tabs, hard-reload, and confirm the deployed commit is the one being executed.** *(2026-08-07 features — the app now self-detects this, see `ARCHITECTURE.md` §2c, but the diagnostic order stands.)*
- **A push is not a deployment.** One 2026-08-07 push produced no webhook event at all — no build, no queue, no failure — and sat undeployed for ~65 minutes. Confirm a deployment exists and reached READY for the exact commit SHA before verifying anything, and before concluding a fix didn't work. *(2026-08-07 features)*
- **Verification by an agent driving the running app is real evidence, and it is not the owner's device pass.** Browser automation can prove a feature works end to end against production — a real recipe imported from a live site, a database round trip confirmed in Supabase. It cannot judge visual weight at arm's length, real touch behaviour, or dark-mode legibility. Report which of the two happened. *(2026-08-07 features)*
- **Offline behaviour is tested against a production build, never `npm run dev`.** `service-worker-registration.tsx` registers the service worker in production only, so offline navigation in dev hard-crashes to `chrome-error://chromewebdata/` — a phantom shaped exactly like the defect being hunted. Use `next build && next start` for anything touching offline, service workers or caching. *(2026-08-21, incident 95; D-181)*
- **A sync or offline verification waits for `ps_crud` to reach zero before closing the browser.** Playwright's `browser.close()` destroys the ephemeral context together with the local PowerSync database and the connector that would have retried, so operations queued at that instant are indistinguishable from a blocked queue when the server is inspected afterwards; it cost most of a session to rule out a head-of-line-blocking defect that never existed. Poll the pending CRUD count to zero, then close. *(Not a user-facing risk: a real browser profile is persistent, and a tab closed mid-import resumes its queue.)* *(2026-08-21, incident 96)*
- **A touch-target expansion is verified by live hit-testing, never by reading the CSS.** The `::after` negative-inset expansion is inert on a host that carries its own `overflow: hidden` — the host clips its own pseudo-element, so the hit area never grows while the source looks correct. Only `elementFromPoint` against the running page catches it. *(2026-08-22, incident 105; D-194)*

### 6. Protect data on the write path and the read path

- Replace operations are upsert-first, then remove surplus rows. Never delete-then-insert across a network boundary. *(E-067)*
- Keep an editing dialog open when a save fails so entered text survives. *(E-067)*
- Paginated child-table reads need a stable total ordering with a unique final tie-breaker. *(E-069)*
- **A component that both subscribes to a watched query and writes back on its own state change is a feedback loop.** The click sets state optimistically; the underlying row stays stale for the write's debounce window; any emission inside that window reverts the state; the revert is itself a state change that writes and re-emits. **The rule: React state is set only by the query's callback; setters write to the store and never set state.** Where a control needs instant local feedback (a colour picker being dragged), hold that transient value in the *component*, not in the provider, and commit through the same one-way path. *(2026-08-07 features — this shape had been latent in four preferences since the local-first cutover; only the fifth, toggled twice in quick succession, made it visible.)*
- **Never silently drop user text on a transform.** A splitter that segmented pasted instructions on numbered markers discarded everything above the first marker — a preamble sentence vanished on save, with no error. When a transform partitions input, account for every character; an extra junk segment the user can delete is strictly better than a missing one they cannot recover. *(2026-08-07 features)*

**Check:** for an intermittent persistence bug, reproduce repeated save-and-reload cycles and check total row count against page size before declaring it fixed.

### 7. A green test proves only what it asserts

- A passing suite does not imply a contract is intact. When a contract has specific structural invariants, assert those invariants explicitly. *(B)*
- A displayed aggregate must be a function of its visible inputs and nothing else. *(B)*
- When a component renders data produced by a utility, read the canonical output structure directly. *(B)*
- **A green `npm run check` proves lint, types, tests, and build — nothing else.** *(2026-08-06 local-first)*
- **An error object that is not an `Error` instance defeats string-matching classifiers.** *(2026-08-06 offline parity)*
- **A test can enforce cross-artifact consistency that convention cannot.** Where two artifacts must independently agree on the same logic, write a test that reads the shipped artifact's actual source and asserts byte-identical output. *(2026-08-06 offline parity)*
- **A test double that records a call without executing it proves only that arguments were plumbed.** Provider tests used a fake database that stored SQL strings and never parsed them, so `INSERT ... ON CONFLICT DO UPDATE` — invalid against a PowerSync view — passed as green and shipped **twice**, breaking every preference write in production both times. Where the thing under test is a statement, an expression, or a payload that a real engine must accept, make the test give it to a real engine. *(2026-08-07 features)*
- **A test that can silently not run is the same failure class it was written to prevent.** The guard added against the above `describe.skip`s when `node:sqlite` is unavailable, and whether that holds on CI was never confirmed. Prefer failing loudly on a missing prerequisite over skipping. *(2026-08-07 features)*
- **A test can pass while never reaching the branch it names.** A "repeat selection updates the count" test would have passed without exercising the update path at all, because the function under test returns early on a duplicate guard before reaching it. Assert the effect, not just the absence of an error — and when a test's setup goes through real application logic, check that the logic actually lets the test reach its target. *(2026-08-07 features)*
- **An alignment guard between two derived structures fails silently by design.** A length comparison between a rendered text blob and a parsed array was written as a safety net; when it tripped, the feature simply did nothing, on 10% of the library, with no error. If a guard's fallback is "render the old thing," that fallback is invisible — either make the guard's trip observable, or remove the possibility of tripping by deriving both structures from one shared rule. *(2026-08-07 features)*
- **An accessibility pass that never ran an automated checker has not been run.** D-136's pass did not run axe, which is how a `nested-interactive` structure on the meal card survived a pass specifically about accessibility, and how a primitive whose test *asserted the absence* of its own accessible name survived review. Reading for accessibility finds what you already know to look for; an accessibility claim needs a tool run behind it. *(2026-08-21, incident 92; D-178)*
- **A `DOMException` does not extend `Error`.** The Web Share API's cancellation arrives as a `DOMException`, so `error instanceof Error && error.name === "AbortError"` is false for the real thing and every cancelled share would have been reported as a failure. Check `.name` alone; the same trap applies to any DOM API rejection guarded with `instanceof Error`, and it is silent because the guard's intent reads correctly. The second instance of the non-`Error` bullet above. *(2026-08-21, incident 93)*

### 8. Reuse without forking; watch duplication drift

- When a control already exists, reuse that component or its exact structural style. Context may change placement, never the component design. *(E-097, E-030, E-046)*
- When the owner identifies one instance as correct, treat that component as invariant. Fix the failing call site or wrapper, never the shared component. *(E-047)*
- Shared controls keep the same hierarchy, border language, icon treatment, and brand presence across breakpoints. *(E-039)*
- Duplicated code drifts. When fixing or porting one copy of a duplicated method or pattern, diff **all** copies for the same defect — and flag the duplication itself as a refactor candidate. *(B)*
- Both sides of every contract: when a caller passes options, verify the callee actually supports and uses them. *(B)*
- Never mix two mechanisms for the same visual job inside one component. *(B)*
- When consolidating forked implementations, classify every preserved difference as either **visual drift** or **mechanism**, and give them different, clearly labeled scoping. *(2026-08-05 repair)*
- When a shared component gains a variant or an opt-out branch, that branch is unverified until it has been exercised at a real call site. *(2026-08-05 repair)*
- **Where two pieces of code must agree on a rule, extract the rule — do not write it twice and rely on them agreeing today.** This paid off four separate times on 2026-08-07: `startsNewIngredientGroup` shared by a text formatter, an insertion counter, and a raw-line mapper; `planCopySteps` shared by a confirmation dialog's stated counts and the transaction that performs the writes; `splitInstructionsText` shared by the create dialog, the edit dialog, and the URL importer; `splitCompositeId` shared by a connector's PATCH and DELETE branches. In each case the alternative — two implementations that agree at the time of writing — is a defect scheduled for whenever one of them changes. *(2026-08-07 features)*
- **A CSS class scoped inside a media query cannot be reused outside it.** The phone's seven-day chip strip lives inside a `max-width: 767px` block, so reusing it in a dialog that renders at every width would have produced an unstyled control above phone size. Building a breakpoint-independent component with identical tokens was correct — and it created a second implementation of the same visual object, which is now recorded as redesign-phase debt rather than left to be discovered. When reuse is impossible for a structural reason, say so and record the duplication deliberately. *(2026-08-07 features)*
- **A gate written to protect one render site of a control is applied to every site that renders it.** `planner-dialog.tsx` rendered "Discover recipes" twice; the top button was gated to phone width and the empty-state sibling 130 lines below was not — beneath a comment stating the rule the sibling broke — so above phone width an empty cookbook offered one action and it did nothing. Before gating a control, grep for every place it renders and gate all of them, or state why one is exempt. *(2026-08-21, incident 91)*
- **Copying a pattern copies its timing assumptions.** `Button`'s width lock worked because it measured on a `loading` transition where the previous render still held the label; the same shape in a component that swaps its content in the same commit reads the DOM after React has committed the smaller content, and the control collapsed from 259px to 71px. A footprint lock measures in the event handler, before the state that shrinks the content is set. *(2026-08-21, incident 94; D-179, D-207)*

### 9. Layout and visual analysis

- List and number every visible problem before writing any fix; state the count. If a fix does not address all listed issues, itemize the remainder explicitly. *(B)*
- Never treat a mockup pixel size as an absolute target — it is a proportion guide. *(B)*
- Never hand-approximate geometric coordinates. Compute from the defining points and include the math. *(B)*
- Never solve overflow by uniformly scaling a larger layout down. *(E-006, E-018)*
- Layout must not depend on optional or variable content. *(E-013, E-061, E-063)*
- Transient feedback (Undo, toasts) stays in the component's normal flow, aligned to the content it refers to, and never overlays the next action. *(E-072, E-074, E-075)*
- Lock row direction and prevent wrapping on compact icon-and-label controls. *(E-085, E-057)*
- Contrast is element-vs-actual-rendered-background, not element-vs-assumed-ink. *(B)*
- Do not repeat a semantic icon within one compact row; do not add a second route to the same destination. *(E-031, E-019, E-032)*
- **A control that appears on state change must not move the content around it.** Reserve its space permanently — `visibility: hidden` or a disabled state, never conditional rendering — so its arrival cannot shift a list the user is reading. A Reset button that appeared when the first item was marked pushed the entire ingredient list down mid-use. *(2026-08-07 features)*
- **A number is a readout; it is not an invitation.** A count of completed steps tells the reader progress exists, not that they can change it. Where an interactive element has no visible affordance at rest, either give it one or state the interaction in words — and if you do neither, record that as an accepted gap rather than assuming discoverability. *(2026-08-07 features)*
- **Two adjacent surfaces doing the same job must behave the same way.** An ingredients column showing "0 of 18" beside an instructions column showing a hint sentence read as inconsistency, not as considered design, however good the reason for each in isolation. Symmetry between neighbours outranks local optimisation. *(2026-08-07 features)*
- **Check what a token means in the file you are borrowing it from.** A rule instructing reuse of the ingredient checkbox's outline token would have made a completed step's left rule the same colour as its own de-emphasised text, collapsing two signals into one. The agent used the stylesheet's dedicated border token instead. *(2026-08-07 features)*
- **A bare Grid item hits `min-width: auto` before a component's own overflow rule can apply.** A button's ellipsis rule never got the chance, so a call to action overflowed its narrow day column instead of truncating. Any control dropped into a narrow Grid track gets a `min-width: 0` wrapper. *(2026-08-22, incident 104)*

### 10. Prompts to code agents are work orders

Rules for writing implementation prompts (Claude Code or any code agent):

- The prompt is an **imperative work order**, not a spec for another assistant to interpret. Name exact files, exact strings, and the verification command to run at the end. *(B)*
- Every find/target string is verified against the **current** file state — via a live read or grep — never against cached knowledge or memory of a previous session. *(B)*
- One logical change per prompt; wait for verification before the next. Batch only with explicit approval. *(B)*
- When structure is broken, output the full corrected file. *(B)*
- For large mechanical refactors, give explicit per-case instructions for every section that does not follow the obvious pattern, and specify verification greps. *(B)*
- In prompts against large single files, never instruct a global find-and-replace. *(B)*
- Specify negative constraints as content, not just prohibition. *(B)*
- Honour the requested output medium as a hard constraint. *(E-009)*
- A single prompt that migrates every instance of a shared pattern in one pass is higher-risk than the automated gate alone can catch. *(2026-08-05 repair)*
- **Configuration that lives outside the repository and outside the agent's tools must be quoted verbatim in the work order whenever a task's correctness depends on it.** *(2026-08-06 local-first)* What is outside: the Sync Streams in the PowerSync dashboard, Vercel's environment, anything on a service dashboard. *(Corrected 2026-09-14, D-210: until then this bullet said the context files themselves — `ai-guardrails.md`, `decision-log.md`, `product-spec.md`, `technical-plan.md`, `operations.md`, `project-context.md` — were Project knowledge only, that Claude Code could not read any of them, and that naming one produced an agent that stalled or invented. That was true and is the reason the documents are in the repository now, as `GUARDRAILS.md`, `DECISIONS.md`, `SPEC.md`, `ARCHITECTURE.md` and `OPERATIONS.md`. A brief now names a rule or a decision by number and the session reads it; quoting a rule that is in the repository into a brief is the new failure, because the quote goes stale and the file does not.)* *(2026-08-08 Bring!)*
- **When chat resolves a deviation from a documented procedure, the resolution and its justification belong in the work order, not only in chat.** *(2026-08-06 local-first)*
- **Do not write your own design preferences into a work order's OUT OF SCOPE list as if they were settled constraints.** A 2026-08-07 order excluded "any toast, snackbar, or undo affordance" and "any Settings entry" — neither had been decided by the owner, and both were live options. An out-of-scope list is for what the owner has ruled out and what is genuinely orthogonal to the task. A design opinion goes to the owner as a question. *(2026-08-07 features)*
- **State a fact in a work order only if you have verified it in this session.** An order asserted that `meal_slots.id` became a uuid in a specific 2026-08-06 migration; it had been a uuid since the original schema, and that migration covered two other tables. The conclusion drawn from it was right and the fact was wrong — the agent read the file and corrected it. Wrong facts in a brief cost the agent a verification cycle even when they are harmless. *(2026-08-07 features)*
- **A work order's worked examples are load-bearing and get the same verification as its instructions.** Two separate orders shipped bad arithmetic: a "3.785 l → 1 gallon" example that is actually 0.9999 gallons and drove an unnecessary tolerance into the code, and a "branch on UPDATE's affected-row count" instruction that cannot work against a PowerSync view. Both were caught by the agent running the real code. Run the arithmetic before writing the example. *(2026-08-07 features)*
- **Check the worked examples against the order's own rules before sending — they are a test suite for the instructions.** An order listed `crushed` as a strippable word while its own example required `crushed tomatoes` to survive; obeying the rules broke the example. The agent caught the contradiction and resolved it correctly, but a self-inconsistent order forces the agent to guess which half is authoritative. *(2026-08-08 Bring!)*
- **Enumerate the branches a rule applies to, or say explicitly that it applies to all of them.** A casing rule named the main path and said nothing about a no-amount early return; the agent applied it to both and flagged the extension. It was right, and it should not have had to decide. *(2026-08-08 Bring!)*
- **State UI premises as things to verify, not as facts.** An order asserted four buttons would strain at phone width; the two it worried about are `display:none` there and live in a header menu. Chat cannot see the CSS — say "confirm this by reading the file" and let the agent correct you. *(2026-08-08 Bring!)*
- **Do not mandate an implementation shape the codebase has already answered, and when a new order breaks existing tests, suspect the order before the tests.** An order required resolving a gate's state in a `Promise.resolve().then()` microtask; three shipped tests that query synchronously after `render()` then met a `null` first render and failed. The file's own precedent — a `useLayoutEffect`, which React Testing Library flushes before `render()` returns and which leaves no frame where the wrong screen can paint — was the right shape all along. Client-only startup state resolves in a layout effect, not a microtask. *(2026-08-22, incident 102; D-192)*

### 11. Environment and tooling hygiene

- Treat code editors and consoles (Supabase SQL editor, browser devtools) as stateful. Verify the full editor content before executing. *(E-068)*
- Inspect a target directory before scaffolding. Keep temporary and staging paths inside approved project roots. *(E-021, E-022)*
- Windows development: assume PowerShell syntax for terminal commands and include CRLF normalization when line-ending drift can corrupt diffs. *(B)*
- Add agent working directories (`.claude/` etc.) to `.gitignore` before the first commit in any repo where a code agent runs. *(B)* *(Narrowed 2026-09-14, D-210, for this repository: `.claude/settings.json` and `.claude/hooks/` are committed, because a cloud session starts from a fresh clone and inherits its SessionStart hook — and, since D-243, the Bash guard that refuses this rule's kill commands and the shallow-clone history questions — only from the repository; what stays ignored is the per-person and installed part — `settings.local.json`, `skills/`, `.agents/`, `skills-lock.json`. The rule's reason — an agent's scratch is not project content — is unchanged.)*
- When an agent's edit tool repeatedly fails on a class of edit, switch mechanism immediately. Do not retry the same tool with rephrased prompts. *(B)*
- For cloned or forked repos, verify project identity before any release-adjacent operation. *(B)*
- Gitignored-by-design local files will be missing on a fresh machine or clone — check for them before diagnosing anything else. *(B)*
- **A tool run for the first time in a repository may write into it.** *(2026-08-06 migration)*
- **Cross-check whether a documented CLI procedure actually works before depending on it in a gated operation.** A runbook step that has not been run is an untested claim. *(2026-08-06 migration)*
- When no browser automation tool is available in a code-agent session, say so explicitly in every report, and route every claim that would normally need visual confirmation onto an explicit manual checklist for the owner — labeled by verification method. *(2026-08-05 repair)*
- **A stateful editor that autosaves persists its contents as a retrievable artifact, not just a transient buffer.** Never leave a secret-bearing statement in an autosaving editor. *(2026-08-06 local-first)*
- **A page-editing tool that supports multi-part or multi-edit calls can report success while only partially applying.** Re-fetch and verify the actual result after any multi-edit write — and check the **parent** of whatever was edited. *(2026-08-06 local-first)*
- **Notion's page-update tool cannot apply text styling** across richly formatted blocks. *(2026-08-06 offline parity)*
- **A multi-edit that rewrites a heading can silently retitle the wrong item.** A 2026-08-07 Workplan update applied two find/replace pairs and left one entry carrying another's title. Re-fetch and read the result, not just the success response. *(2026-08-07 features)*
- **A stale `.next` build directory after a killed dev server** produces phantom module-resolution errors. Separately, "Sync error" spam from PowerSync in the dev terminal is usually a stale browser tab. *(2026-08-06 offline parity)*
- **A test runner that intermittently reports zero tests is a gate that can silently pass nothing.** *(2026-08-06 offline parity)*
- **A build tool may evaluate its own config file more than once per build.** Turbopack evaluates `next.config.ts` multiple times, so a `Date.now()` value baked into the bundle differed from the one served by a route handler in the *same* build — two timestamps ~300 ms apart, found by grepping compiled output. Any value that must be identical across a build must be deterministic (a commit SHA, a hash), never generated at config-evaluation time. *(2026-08-07 features)*
- **An invisible character in source is a real defect class.** A non-breaking space typed into an entity-decoding table looked byte-identical to a space and was caught only by an assertion failing on two visually identical strings. When a string comparison fails between values that look the same, suspect the characters before the logic. *(2026-08-07 features)*
- **Do not kill an unidentified process to free a resource.** A dev-server port conflict was resolved by killing an unknown `node.exe` without first establishing what it was. Check, then kill. *(2026-08-07 features)*
- **Browser automation against a dashboard is stateful and hostile to blind key-sending.** Single-key shortcuts capture keystrokes when focus is not where you think it is, navigating away mid-command; confirm the page is loaded and focus is in the intended field before typing, and screenshot after each run. *(2026-08-07 features)*
- **Alternating `next dev` and `next build && next start` against the same `.next` directory leaves a cache the other mode cannot resolve routes against.** It presents as every route returning 404 while `proxy.ts` still runs — exactly like a routing bug, in a repository whose routing is correct. Delete `.next` when switching modes, and check for an orphaned node process holding the port first. *(2026-08-22, incident 97)*
- **Stop a process by matching its executable, never its whole command line.** `pkill -f` — and any `ps … | grep <name> | … kill` pipeline — matches the full command line, and the shell running `pkill -f chromium; npm run build` has `chromium` in its own, so it kills itself (exit 144) and nothing after it runs, which first read as a failed gate. Grep's `[n]ame` bracket trick does not save it: it stops `grep` matching itself, not the invoking shell whenever the name appears anywhere else in the command. Match the executable field exactly — the invoking shell's second field is `-c`, so it never matches: `ps -eo pid,args | awk '$2 == "next-server" {print $1}' | xargs -r kill` (verified with the name written literally elsewhere in the same command: the shell survived, the target died). When in doubt, list and kill the PID by number in two separate commands. Three instances in two days, each while following the gotcha to kill leftover browser processes before the gate, and a fourth in the order that wrote this bullet. *(2026-09-23 to 2026-09-24, incidents 134, 140, 141, 144)* **In a cloud session `.claude/hooks/guard-bash.sh` refuses both forms before they run, with this bullet's command as the reason** *(D-243)*.

### 12. Documentation freshness

- After applying fixes, update the affected knowledge files or explicitly mark them stale. Never write a plan or prompt from documentation you know has drifted from the repo. *(B)*
- Failure entries are recorded in the same task in which they occur, before the completion report. *(E-091)*
- Plans express ordering as dependencies and sequence gates, not calendar promises. *(B)*
- A docs-sync pass that rewrites a "settled decisions" document must not attempt a full reconstruction from partial or fragmented access to that document. *(2026-08-05 repair)*
- A tracked item's position inside a nested list is part of its meaning, not decoration. *(2026-08-06 local-first)*
- **Record the correction, not just the correct answer.** Where a documented diagnosis turns out to be wrong, the replacement entry says so explicitly and names what was wrong — because the wrong version has usually been copied elsewhere (into a Workplan, into a prompt) and will keep aiming people at the wrong layer otherwise. *(2026-08-07 features)*
- **A completed feature's record includes the paths not taken and why.** Two 2026-08-07 features reversed a shipped design after live feedback (a shared Reset became two; an always-visible affordance rule was removed). Both reversals restored something that had looked like an improvement when first built. Recording the reversal *and its reason* is what stops the same "improvement" being reintroduced by the next person to look at it. *(2026-08-07 features)*
- **Attribute a verification to whoever actually performed it.** An agent report credited two browser-driven SQL checks to the owner; the numbers were right, the provenance was not. Provenance is what makes evidence re-checkable. *(2026-08-07 features)*
- **A placeholder in a plan is not a decision.** Three Phase 2 items sat in the workplan for days as one-line entries with no decision-log entry behind them; on review, none survived contact with a direct question about what they were for. Distinguish "decided and scheduled" from "written down once." *(2026-08-07 features)*

---

# Part II — Grid-specific rules

*None yet. The first rule here is number 13, distilled from `docs/incidents.md` under the protocol above.*
