# aria-moebius

Formalization and computational checks for
*[Transplanting the Mobius Bridge to ARIA](PAPER_ARIA_MOBIUS_DRAFT_v2.md)*
(D. Y. Bilar, Chokmah LLC).

The paper derives the residual symmetry that survives field inversion in ARIA’s
S-boxes: the unipotent subgroup of order 256 in \(\mathrm{PGL}(2,\mathrm{GF}(2^8))\),
not \(\mathrm{AGL}(1)\). Power-sum ratio fingerprints therefore fail to transfer
from the AES Mobius Bridge; the cross-ratio does survive. This repository
ships the verification script and a Lean 4 / Mathlib formalization of the
algebraic claims.

**No attack complexities for ARIA are claimed.**

## Contents

| Path | Role |
|---|---|
| `PAPER_ARIA_MOBIUS_DRAFT_v2.md` | Paper draft |
| `verify_aria_bridge.py` | Exhaustive GF(\(2^8\)) checks (pure Python 3, no deps) |
| `AriaMobius.lean` | Lean 4 formalization (Mathlib) |
| `lakefile.toml`, `lean-toolchain`, `lake-manifest.json` | Lake / Mathlib pin (Lean **4.32.2**, Mathlib **v4.32.2**) |
| `results/` | Archived Python run, Lean build log, axiom audit |
| `CHANGELOG.md` | Version history |

## Python verification

Reproduces every numeric claim in the paper: difference-of-inverses identity,
key-action homomorphism and injectivity, scaling refutation over all 255 base
points, power-sum fingerprint table, and cross-ratio invariance.

```powershell
python verify_aria_bridge.py
```

- Deterministic (seed **5785** for the offline difference set).
- Exit code **0** iff all five checks pass.
- Archived output: [`results/verify_aria_bridge_out.txt`](results/verify_aria_bridge_out.txt)
  (meta in `results/verify_aria_bridge_meta.json`).

Last archived run: **5/5 checks passed**.

## Lean 4 / Mathlib

Algebraic identities are machine-checked. Finite GF(\(2^8\)) enumeration stays
in Python by design (no `native_decide` / `Lean.ofReduceBool`).

### Requirements

Install [elan](https://lean-lang.org/install/) (Lean version manager). On Windows:

```powershell
curl -O --location https://elan.lean-lang.org/elan-init.ps1
powershell -ExecutionPolicy Bypass -Command "& { .\elan-init.ps1 -NoPrompt 1 -DefaultToolchain stable }"
# then open a new shell, or: $env:Path = "$env:USERPROFILE\.elan\bin;" + $env:Path
```

### Build

```powershell
lake exe cache get   # download Mathlib oleans (once)
lake build
```

### Status

- **All theorems in `AriaMobius.lean` are proved** (no `sorry`).
- Axiom audit (expected only): `propext`, `Classical.choice`, `Quot.sound`.
- See [`results/axiom_audit.txt`](results/axiom_audit.txt) and
  [`results/lake_build_final.txt`](results/lake_build_final.txt).

### Correspondence (paper ↔ Lean)

| Paper | Lean name | Notes |
|---|---|---|
| Prop 3.2 (inner identity) | `inv_add_inv_eq` | any field |
| Prop 3.1 | `key_add_inv`, `U_mul`, `U_one`, `U_det`, `U_injective` | any field |
| Cor 3.1.1 | `mobiusKey_not_affine` | any field |
| Prop 3.2 / 3.3 (diff map) | `diffMap_eq`, `diffMap_not_scaling` | char 2 |
| Prop 3.4 | `J_smul_invariant`, `draft_ratio_eq_scalar` | any field |
| Thm 3.5 rows (1,2),(2,4) | `P_two_mul`, `J_two_mul_trivial` | char 2 |
| Thm 3.5 other rows | — | Python only |
| Prop 3.6 | `crossRatio_diffMap_invariant` | char 2 |
| Prop 4.1 | `pow_247_eq`, `frobenius8_add` | GF(\(2^8\)) |

## License

Paper text: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
(see draft header). Code in this repository accompanies the paper; reuse under
the same terms unless a separate license file is added later.

## Citation

See the paper draft for author, date, and DOI status (DOI may still be TODO).
Repository: https://github.com/chokmah-me/aria-moebius
