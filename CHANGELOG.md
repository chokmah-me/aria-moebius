# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses informal date-based versions until a public release is
tagged.

## [Unreleased]

### Planned

- Full paper rewrite around the class theorem (draft still has retracted framing).

## [0.3.0] - 2026-07-30

Class-theorem verifier and Lean bridge addendum; priority search archived.

### Added

- `verify_bridge_class.py` — primary suite (class + four ARIA maps + exponents +
  bad indices + \(I_{m,n}\)); archived `results/verify_bridge_class_out.txt`.
- `Bridge.lean` — `bridge_identity`, `bridge_frobenius`, `P_affine`,
  `J_affine_invariant`, `aria_exponents`, `aria_S2inv_exponent`; Lake target
  `Bridge`.
- `results/priority_search_log.md` — no ARIA/Camellia/CLEFIA/SM4 Bridge ports
  found (NC paper 2026-07-28).

### Changed

- README holds class-theorem spine; documents supersession of pre-reciprocal
  verifier conclusions.
- Cut vacuous `bridge_alpha_eq_beta_sq` / theorem-shaped `example`; exponents
  recorded as `def aria_exponents`.

### Notes

- `verify_aria_bridge.py` retained as **legacy** (pre-reciprocal multiset). Its
  “fingerprints do not transfer” reading is retracted; the script remains for
  audit only.
- No attack parameters / entropy campaign in this tag.

## [0.2.0] - 2026-07-30

Lean formalization complete against Lean 4.32.2 / Mathlib v4.32.2; verification
artifacts archived; project docs.

### Added

- Lake project: `lakefile.toml`, `lean-toolchain`, `lake-manifest.json`, `.gitignore`.
- Mathlib dependency pinned at **v4.32.2** (toolchain **leanprover/lean4:v4.32.2**).
- Archived Python run under `results/` (`verify_aria_bridge_out.txt`, meta JSON).
- Lean build and axiom audit under `results/` (`lake_build_final.txt`, `axiom_audit.txt`).
- Expanded README (setup, status table, paper ↔ Lean map).
- `CHANGELOG.md` (Keep a Changelog style).

### Changed

- `AriaMobius.lean` updated for current Mathlib module paths and APIs
  (e.g. matrix notation under `LinearAlgebra.Matrix`, BigOperators layout).
- Difference-map statements take `[CharP F 2]` where the ARIA/XOR form
  \(e/(v^2 + v e)\) is used.
- Header status: skeleton with open `sorry` → fully proved.

### Fixed / proved

- Closed all Appendix A.5 obligations:
  - `mobiusKey_not_affine` (Cor 3.1.1)
  - `crossRatio_diffMap_invariant` (Prop 3.6)
  - `frobenius8_add` (Prop 4.1 additivity)
- Remaining algebraic proofs adjusted so `lake build` succeeds with only
  standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

### Verified

- `python verify_aria_bridge.py` → **5/5** checks, exit 0 (seed 5785).
- `lake build` → success, **no `sorry`** in declarations.

## [0.1.0] - 2026-07-29

Initial public draft of the repository.

### Added

- Paper draft: `PAPER_ARIA_MOBIUS_DRAFT_v2.md`.
- Computational verification script: `verify_aria_bridge.py`.
- Lean skeleton: `AriaMobius.lean` (designed statements; not yet compiled;
  three deliberate `sorry`s per Appendix A.5).

[Unreleased]: https://github.com/chokmah-me/aria-moebius/compare/d5f9b23...HEAD
[0.2.0]: https://github.com/chokmah-me/aria-moebius/compare/81e1dec...d5f9b23
[0.1.0]: https://github.com/chokmah-me/aria-moebius/tree/81e1dec
