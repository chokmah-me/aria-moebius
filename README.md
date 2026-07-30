# aria-moebius

Machine-checked algebra and computational checks for **Möbius bridges on the
invert-and-affine S-box class**, with ARIA’s four substitution-layer maps as
instances.

Author: D. Y. Bilar, Chokmah LLC.  
Upstream: [Nasr–Carlini, *Cryptanalysis of 7-Round AES via the Algebraic
Structure of its S-box*](https://www.anthropic.com/document/aes_mobius_bridge.pdf)
(2026-07-28).

**No attack complexities for ARIA are claimed.** This repo ships the *class
bridge* (identity + affine fingerprint invariance + bad-index locus), not a
MitM parameter sheet.

## Claim

Any S-box of the form

\[
S = L_2 \circ \mathrm{Frob}^{j} \circ \mathrm{inv} \circ L_1
\]

(\(L_1,L_2\) GF(2)-affine bijections, \(\mathrm{Frob}(x)=x^2\), \(\mathrm{inv}(0):=0\))
admits an **AGL(1)** bridge after the Nasr–Carlini reciprocal reparametrization:

\[
\beta = t^{2^{j}},\quad \alpha = \beta^{2},\quad
g = \alpha\cdot D \oplus \beta,\quad
D = \bigl(L_1^{\mathrm{lin}}(d)\bigr)^{-2^{j}},\quad t = L_1(s).
\]

Bad indices (where `inv(0):=0` breaks the identity) are \(\{L_1^{-1}(0),\, s\}\),
not always \(\{0,s\}\). ARIA instantiates four members (`j ∈ {0,3,0,5}` for
\(S_1,S_2,S_1^{-1},S_2^{-1}\)).

Priority search (2026-07-30): no public Bridge port to ARIA/Camellia/CLEFIA/SM4
— see [`results/priority_search_log.md`](results/priority_search_log.md).

## Contents

| Path | Role |
|---|---|
| `verify_bridge_class.py` | **Primary** verifier: class + four ARIA maps + exponents + bad indices + \(I_{m,n}\) |
| `verify_aria_bridge.py` | **Legacy** pre-reciprocal script (superseded; kept for audit) |
| `AriaMobius.lean` | Base Lean module (field lemmas, intermediate chart geometry) |
| `Bridge.lean` | Addendum: `bridge_identity`, `bridge_frobenius`, `P_affine`, `J_affine_invariant`, ARIA exponents |
| `lakefile.toml`, `lean-toolchain`, `lake-manifest.json` | Lean **4.32.2** / Mathlib **v4.32.2** |
| `PAPER_ARIA_MOBIUS_DRAFT_v2.md` | Draft text (**stale negative framing** — rewrite pending) |
| `results/` | Archived verifier output, Lean builds, priority search |
| `CHANGELOG.md` | History |

## Python (class theorem)

```powershell
python verify_bridge_class.py
```

- Pure Python 3, no deps; seed **5785**; exit **0** iff 5/5.
- Archived: [`results/verify_bridge_class_out.txt`](results/verify_bridge_class_out.txt)

Checks: (1) class over all 8 Frobenius exponents × 3 random affine pairs;
(2) four ARIA maps; (3) \(x^{247}=(x^{-1})^8\), \(247\cdot223\equiv1\pmod{255}\),
\(x^{223}=(x^{-1})^{32}\); (4) bad indices at \(L_1^{-1}(0)\); (5) \(I(m,n)\)
invariant under the bridge action.

## Lean 4 / Mathlib

```powershell
# elan: https://lean-lang.org/install/
lake exe cache get
lake build          # AriaMobius + Bridge
```

| Module | Status |
|---|---|
| `AriaMobius.lean` | Builds; intermediate pre-reciprocal geometry + Frobenius facts |
| `Bridge.lean` | Builds; load-bearing bridge + affine \(P,J\) + \(S_2^{-1}\) exponent |

Axioms (both modules): `propext`, `Classical.choice`, `Quot.sound` only.
See [`results/lake_build_bridge.txt`](results/lake_build_bridge.txt).

Load-bearing for the note: `bridge_identity`, `bridge_frobenius`, `P_affine`,
`J_affine_invariant`, `aria_S2inv_exponent` / `pow_247_eq`. Intermediate
(pre-reciprocal chart): `diffMap_not_scaling`, `crossRatio_*`, `U_*`.

## License

Paper draft: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
Code accompanies the note unless a separate license is added.

## Citation

Repository: https://github.com/chokmah-me/aria-moebius  
DOI: TODO (Zenodo not yet minted).
