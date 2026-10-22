# AGENTS.md — aria-moebius

Lean 4 formalization and exhaustive GF(256) Python verifier for the invert-and-affine Möbius Bridge class identity. ARIA instantiates four members of that class.

**No ARIA attack complexities are claimed.**

## Commands

```powershell
python verify_bridge_class.py
# exit 0 iff all five checks pass

lake exe cache get
lake build
```

Toolchain: Lean **4.32.2** / Mathlib **v4.32.2** (`lakefile.toml`, `lean-toolchain`). Axiom set: `propext`, `Classical.choice`, `Quot.sound` only (no `native_decide`).

## Work rules

- Exhaustive ARIA Table 1 checks stay in Python. Lean covers Theorem 3.1, Corollary 3.2, and §5 bad-index location.
- `verify_aria_bridge.py` is legacy (pre-reciprocal). Do not treat it as the live verifier.
- Do not change locked `results/` receipts or published paper artifacts without the user's word.

## Pointers

- `README.md` — paper ↔ Lean map, five Python checks
- `ARIA-Moebius-v1-REL.md` — paper source
- `results/con-leche-verified.md` — what `con-leche --verified` buys
- `CITATION.cff` / `ZENODO.md` — cite / DOI map
