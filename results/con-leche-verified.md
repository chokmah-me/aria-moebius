# What `CHECK_EXIT=0` from con-leche means

This note records an independent kernel check of this repository’s Lean
formalization with [con-leche](https://github.com/leanprover/con-leche), and
states what a successful run buys — and what it does not.

## The run

| Item | Value |
|---|---|
| Subject | Module `Bridge` (imports `AriaMobius` and the Mathlib transitive closure needed by those proofs) |
| Export | `lean4export` **3.1.0**, Lean **4.32.2** → NDJSON (~1.5 GB; not committed) |
| Checker | `con-leche --verified --jobs=4` (the mode the consistency theorem is about) |
| Result | **`CHECK_EXIT=0`** — accept |
| Accepted | **283412** declarations |
| Timing (recorded log) | parse 17.6 s, install 72.6 s, check 198.3 s, wall ~288.5 s |
| Log | [`con-leche-verified.log`](con-leche-verified.log), [`con-leche-verified.exit.txt`](con-leche-verified.exit.txt) |

Exit codes follow the lean kernel arena convention used by con-leche:

| Code | Meaning |
|---|---|
| **0** | **Accept** — the stream was installed and checked successfully |
| 1 | Reject — invalid input (ill-typed / unsound relative to the checker) |
| 2 | Decline — the checker positively detects an unsupported feature |
| 3 | Error — crash / unclear failure |

This run produced **0**, not 1, 2, or 3.

Final lines from the log:

```text
con-leche: check done: 282123/282123 t=288.5s (check 198.3s)
con-leche: done: parse 17.6s, install 72.6s, check 198.3s, 4 workers t=288.5s
con-leche: accepted 283412 declarations (--verified)
```

## Assurance this buys

**Independent acceptance in verified mode.** An external checker, implemented in
Lean and distinct from Lean’s official C++ kernel, accepted the exported
environment in `--verified` mode.

**Consistency corollary for that mode.** con-leche’s main theorem is stated for
exactly this configuration: a stream that is accepted in `--verified` mode does
not contain a theorem (or constant) of type `False`. More strongly, accepted
environments are shown to have a model in a suitable set theory (parametric in
con-leche’s `SetTheory` interface). So this exit code is not “the binary printed
OK”; it is acceptance under the configuration the machine-checked argument talks
about.

**Coverage of this package’s Lean theorems.** Because the export was rooted at
`Bridge`, the load-bearing statements in `Bridge.lean` / `AriaMobius.lean`
(class bridge, fingerprint invariance, bad-index location, ARIA exponents, and
their proof dependencies) were part of the checked closure, together with the
Mathlib material those proofs rely on.

In short: **the formalized theorems in this repo, as exported, were accepted by
a consistency-oriented independent kernel.** That is a stronger check than
“`lake build` succeeded on this machine,” though it is complementary to it (see
below).

## What it does *not* buy

- **Not a substitute for the Python oracle.** Exhaustive GF(2⁸) Table 1 / class
  identity / fingerprint numeric checks remain the job of
  `verify_bridge_class.py`. con-leche does not re-run those byte-level
  experiments.
- **Not a claim about the English paper.** Acceptance does not establish attack
  complexities, operational relevance, or any prose claim outside the Lean
  statements. Section 7 of the paper still applies: no ARIA attack complexities
  are claimed.
- **Does not erase Lean’s axiom footprint.** The formalization still depends on
  `propext`, `Classical.choice`, and `Quot.sound` (see
  [`bridge_axiom_audit.txt`](bridge_axiom_audit.txt)). con-leche accepts the
  three standard Lean axioms in the stream; it does not mean the development is
  axiom-free.
- **Trust boundaries that remain.** Soundness of the *story* still depends on
  (among other things) faithfulness of `lean4export`, con-leche’s Nat
  acceleration pins / runtime, and the set-theory hypotheses of the consistency
  proof. A wrong export or an unsupported feature would surface as reject,
  decline, or error — not as a silent green check.
- **Not a Mathlib product certification.** The export pulled a large Mathlib
  transitive slice because the proofs import Mathlib. Acceptance means *this
  export* checked; it is not a blanket warranty of all of Mathlib as a
  standalone product.

## How this sits next to the other gates

| Gate | What it answers |
|---|---|
| `python verify_bridge_class.py` | Do the GF(2⁸) / ARIA Table 1 numeric identities hold? |
| `lake build` + axiom audit | Do the Lean files elaborate; only the three standard axioms? |
| **`con-leche --verified` → 0** | Does an independent verified kernel accept the exported proof environment? |

Reproduce (requires a built `con-leche`, `lean4export` matching Lean 4.32.2, and
enough disk/RAM for a ~1.5 GB export):

```powershell
# from aria-moebius, with LEAN_PATH from lake:
lake env path\to\lean4export Bridge > bridge.ndjson
path\to\con-leche --verified --jobs=4 bridge.ndjson
# expect CHECK_EXIT=0 / "accepted … declarations (--verified)"
```
