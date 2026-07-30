# aria-moebius

Formalization and computational checks for *Transplanting the Mobius Bridge to ARIA*.

## Python verification

```powershell
python verify_aria_bridge.py
# archived run: results/verify_aria_bridge_out.txt
```

## Lean 4 / Mathlib

Requires [elan](https://lean-lang.org/install/). Toolchain: see `lean-toolchain` (Lean 4.32.2 + Mathlib).

```powershell
lake exe cache get
lake build
```

All theorems in `AriaMobius.lean` are proved (no `sorry`). Axiom audit:
`propext`, `Classical.choice`, `Quot.sound` only — see `results/axiom_audit.txt`.
