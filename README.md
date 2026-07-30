# aria-moebius

Formalization and computational checks for
*[Mobius Bridges for the Invert-and-Affine S-box Class, with the Four ARIA
Instantiations](PAPER_ARIA_MOBIUS_DRAFT_v3.md)* (D. Y. Bilar, Chokmah LLC).

The Mobius Bridge of Nasr and Carlini is not specific to the AES S-box. It holds
for every S-box of the form `L2 . Frob^j . inv . L1` with `L1`, `L2` GF(2)-affine
bijections, with the Frobenius exponent `j` as the only degree of freedom. AES is
the case `j = 0`, `L1 = id`. ARIA instantiates four members of the class at once
(`S1`, `S2`, `S1^-1`, `S2^-1`, at `j = 0, 3, 0, 5`), each with a different offline
multiset, and its two inverse S-boxes move the bad indices from `0` to the affine
constants, so the published bad-index treatment does not port unchanged.

**No attack complexities for ARIA are claimed.** See section 7 of the paper for
what a complexity claim would first require.

## Contents

| Path | Role |
|---|---|
| `PAPER_ARIA_MOBIUS_DRAFT_v3.md` | Paper draft (current) |
| `PAPER_ARIA_MOBIUS_DRAFT_v2.md` | Superseded draft (record only) |
| `verify_bridge_class.py` | Exhaustive GF(2^8) checks (pure Python 3, no deps) |
| `verify_aria_bridge.py` | Legacy pre-reciprocal verifier (superseded) |
| `Bridge.lean` | Lean 4: class bridge, affine invariance, ARIA exponents |
| `AriaMobius.lean` | Lean 4: preliminaries and pre-reciprocal geometry |
| `lakefile.toml`, `lean-toolchain`, `lake-manifest.json` | Lean **4.32.2**, Mathlib **v4.32.2** |
| `results/` | Archived runs, build logs, axiom audit, priority search |
| `CHANGELOG.md` | Version history, including the v2 retraction |

## Verification

```powershell
python verify_bridge_class.py
# exit 0 iff all five checks pass
```

Five checks: the class identity across all eight Frobenius exponents against
random affine bijections; the four ARIA instantiations; the exponent facts
`x^247 = (x^-1)^8` and `x^223 = (x^-1)^32`; the bad-index locations and failure
counts; and invariance of the power-sum ratio `I(m,n)` across key values.
Deterministic apart from seeded draws of the affine maps (seed **5785**).

Archived run: [`results/verify_bridge_class_out.txt`](results/verify_bridge_class_out.txt).

## Lean

```powershell
lake exe cache get
lake build
```

Both `AriaMobius.lean` and `Bridge.lean` build clean. Axiom set:
`propext`, `Classical.choice`, `Quot.sound` only (no `native_decide`). See
[`results/lake_build_bridge.txt`](results/lake_build_bridge.txt) and
[`results/bridge_axiom_audit.txt`](results/bridge_axiom_audit.txt).

## Superseded

`verify_aria_bridge.py` and `PAPER_ARIA_MOBIUS_DRAFT_v2.md` are retained for the
record. v2 concluded that power-sum fingerprints do not transfer to ARIA. That
conclusion was wrong: it tested the pre-reciprocal multiset, where the action is
fractional-linear rather than affine. The reciprocal and change of variable to
`d^-1` is what linearizes it. See `CHANGELOG.md`.

## License

CC BY 4.0.

Repository: https://github.com/chokmah-me/aria-moebius
