# aria-moebius

Formalization and computational checks accompanying work on the
[Nasr–Carlini Möbius Bridge](https://www.anthropic.com/document/aes_mobius_bridge.pdf)
and its extension to invert-and-GF(2)-affine S-boxes (including ARIA).
Author contact for the note: D. Y. Bilar, Chokmah LLC.

**Status (2026-07-30).** The draft text in `PAPER_ARIA_MOBIUS_DRAFT_v2.md` still
reflects an earlier, **retracted** framing (pre-reciprocal multiset / negative
result). A corrected class-theorem verifier and Lean addendum are in progress
from SME; this README is a **holding** description until that rewrite lands.
See [`results/priority_search_log.md`](results/priority_search_log.md) for the
priority search (no public ARIA/Camellia/CLEFIA/SM4 Bridge ports found as of
2026-07-30; NC paper dated 2026-07-28).

**No attack complexities for ARIA are claimed.**

## Intended technical spine (post-rewrite)

Any S-box of the form \(S = L_2 \circ \mathrm{Frob}^j \circ \mathrm{inv} \circ L_1\)
admits an affine bridge after the Nasr–Carlini reciprocal change of variable,
with \(\beta = L_1(s)^{2^j}\) and \(\alpha = \beta^2\). ARIA’s four maps
(\(S_1, S_2, S_1^{-1}, S_2^{-1}\)) are instances; bad indices for the inverse
maps sit at \(\{c, s\}\) (affine constant), not \(\{0, s\}\).

Existing Lean in `AriaMobius.lean` still proves load-bearing field lemmas
(including Frobenius facts for \(S_2\)); some results (e.g. geometry in the
pre-reciprocal chart) become **intermediate**, not a refutation of power-sum
fingerprints under the affine action.

## Contents

| Path | Role |
|---|---|
| `PAPER_ARIA_MOBIUS_DRAFT_v2.md` | Paper draft (**stale framing** — rewrite pending) |
| `verify_aria_bridge.py` | Python checks (**pre-correction** script still on `master`; class-theorem verifier pending merge) |
| `AriaMobius.lean` | Lean 4 / Mathlib formalization (base module; affine-bridge addendum pending merge) |
| `lakefile.toml`, `lean-toolchain`, `lake-manifest.json` | Lake pin (Lean **4.32.2**, Mathlib **v4.32.2**) |
| `results/` | Archived runs, axiom audit, [priority search log](results/priority_search_log.md) |
| `CHANGELOG.md` | Version history |

## Python verification

```powershell
python verify_aria_bridge.py
```

- Pure Python 3, no dependencies; exit **0** iff checks pass.
- Archived output of the **legacy** script:  
  [`results/verify_aria_bridge_out.txt`](results/verify_aria_bridge_out.txt)  
  (seed 5785; 5/5 on that script’s claims — **not** the class-theorem suite).

Class-theorem suite (SME, 5/5, exit 0; pending drop into this repo): class over
all 8 Frobenius exponents × random affines; four ARIA maps; exponent facts
\(247/223\); bad-index locus; \(I(m,n)\) invariance. Cosmetic: check [4] print
“255 of 254” to fix on merge.

## Lean 4 / Mathlib

```powershell
# elan: https://lean-lang.org/install/
lake exe cache get
lake build
```

- Base file `AriaMobius.lean`: builds clean; axioms `propext`, `Classical.choice`,
  `Quot.sound` only — see [`results/axiom_audit.txt`](results/axiom_audit.txt).
- Addendum (pending merge): `P_affine`, `J_affine_invariant`, `bridge_identity`,
  `bridge_frobenius`, `aria_S2inv_exponent`. Drop `bridge_alpha_eq_beta_sq` if
  present as bare `rfl`; record ARIA exponents as `def`, not a vacuous `example`.

## License

Paper text: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
(see draft header). Code accompanies the note unless a separate license is added.

## Citation

See the paper draft for author/date/DOI (DOI may still be TODO).  
Repository: https://github.com/chokmah-me/aria-moebius
