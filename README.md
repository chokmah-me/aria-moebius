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

Open proof obligations (`sorry` in `AriaMobius.lean`, Appendix A.5):

1. `mobiusKey_not_affine`
2. `crossRatio_diffMap_invariant`
3. `frobenius8_add`

The file is a designed skeleton; expect tactic fixes against Mathlib before a clean build.
