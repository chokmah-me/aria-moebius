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
| `verify_bridge_class.py` | Exhaustive GF(2^8) checks (pure Python 3, no deps) |
| `verify_aria_bridge.py` | Legacy pre-reciprocal verifier (superseded) |
| `Bridge.lean` | Lean 4 formalization of the class bridge and affine invariance |
| `AriaMobius.lean` | Lean 4, preliminaries and pre-reciprocal geometry |
| `lakefile.toml`, `lean-toolchain`, `lake-manifest.json` | Lean **4.32.2**, Mathlib **v4.32.2** |
| `results/` | Archived runs, build logs, axiom audit |
| `CHANGELOG.md` | Version history, including the v2 retraction |

## Verification

```powershell
python verify_bridge_class.py
# exit 0 iff all five checks pass
```

Five checks: the class identity across all eight Frobenius exponents against
random affine bijections; the four ARIA maps with **published** $A$, $B$,
$a=\mathtt{0x63}$, $b=\mathtt{0xE2}$; the exponent facts `x^247 = (x^-1)^8` and
`x^223 = (x^-1)^32`; the bad-index locations and failure counts; and invariance
of the power-sum ratio `I(m,n)` across all 255 admissible reference values `s`.
Deterministic apart from seeded draws of the random affine maps in check [1].

## Lean

```powershell
lake exe cache get
lake build
```

Both `AriaMobius.lean` and `Bridge.lean` build clean. Axiom set: `propext`,
`Classical.choice`, `Quot.sound` only (no `native_decide`). See
`results/lake_build_bridge.txt` and `results/bridge_axiom_audit.txt`.

## Superseded

`verify_aria_bridge.py` remains as a legacy pre-reciprocal script only. Earlier
paper drafts (v1 REL, v2) are **removed** from the tree; the v2 retraction is
recorded in `CHANGELOG.md`. The reciprocal and change of variable to `d^-1` is
what linearizes the bridge action.

## Release

- Paper: [`ARIA-Moebius-v1-REL.md`](ARIA-Moebius-v1-REL.md) / [`ARIA-Moebius-v1-REL.pdf`](ARIA-Moebius-v1-REL.pdf)
- **Paper concept DOI (prefer for citation):** [10.5281/zenodo.21705468](https://doi.org/10.5281/zenodo.21705468) — always latest PDF
- **Paper version DOI (this PDF):** [10.5281/zenodo.21710366](https://doi.org/10.5281/zenodo.21710366) (v1.0.3)
- **Software DOI (this repo, GitHub `v1.0.1`):** [10.5281/zenodo.21710669](https://doi.org/10.5281/zenodo.21710669)
- **Software concept DOI:** [10.5281/zenodo.21705939](https://doi.org/10.5281/zenodo.21705939)
- **GitHub Release:** https://github.com/chokmah-me/aria-moebius/releases/tag/v1.0.1
- **OSF:** [osf.io/wy8db](https://osf.io/wy8db/)
- **Catalog:** [chokmah.me/research/…](https://chokmah.me/research/mobius-bridges-for-the-invert-and-affine-s-box-class-with-th-21705469/) — path fragment is historical; page cites concept `…468` / PDF version `…366`

Zenodo paper record = PDF alone. Source, Lean, and verifier = GitHub (+ software DOI zip). Superseded paper DOIs and the post-mint grep guard: `ZENODO.md`, `scripts/check_doi_consistency.ps1`.

## Citation

**Paper (preferred for the note):**

```bibtex
@misc{bilar2026moebius,
  author       = {Bilar, Daniyel Yaacov},
  title        = {Mobius Bridges for the Invert-and-Affine S-box Class,
                  with the Four ARIA Instantiations},
  year         = {2026},
  version      = {1.0.3},
  publisher    = {Zenodo},
  doi          = {10.5281/zenodo.21705468},
  url          = {https://doi.org/10.5281/zenodo.21705468},
  note         = {Concept DOI (always latest). Pinned PDF: 10.5281/zenodo.21710366}
}
```

**Software (this repository):**

```bibtex
@software{bilar2026aria_moebius_sw,
  author       = {Bilar, Daniyel Yaacov},
  title        = {aria-moebius: Lean formalization and class-bridge verifier},
  year         = {2026},
  version      = {v1.0.1},
  publisher    = {Zenodo},
  doi          = {10.5281/zenodo.21710669},
  url          = {https://doi.org/10.5281/zenodo.21710669}
}
```

## License

CC BY 4.0.
