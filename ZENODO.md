# Zenodo deposits

Two separate Zenodo **concepts** (do not merge paper and software):

| Role | DOI | Status |
|---|---|---|
| **Paper concept** | [10.5281/zenodo.21705468](https://doi.org/10.5281/zenodo.21705468) | **Stable.** Always resolves to the latest paper PDF. |
| **Paper (current version)** | [10.5281/zenodo.21710366](https://doi.org/10.5281/zenodo.21710366) | Current PDF-only deposit (`ARIA-Moebius-v1-REL.pdf`). |
| **Software concept** | [10.5281/zenodo.21705939](https://doi.org/10.5281/zenodo.21705939) | Always latest software zip. |
| **Software (current version)** | [10.5281/zenodo.21710669](https://doi.org/10.5281/zenodo.21710669) | From GitHub Release `v1.0.1`. |
| **Software (superseded)** | [10.5281/zenodo.21705940](https://doi.org/10.5281/zenodo.21705940) | GitHub Release `v1.0.0` zip. |

## Paper version history (superseded rows)

| Version DOI | Status | Notes |
|---|---|---|
| [10.5281/zenodo.21705469](https://doi.org/10.5281/zenodo.21705469) | **Superseded** | First paper mint. Catalog URL slug fragment only; do not cite. |
| [10.5281/zenodo.21705738](https://doi.org/10.5281/zenodo.21705738) | **Superseded** | Labeled v1.0.1; pre-errata PDF. |
| [10.5281/zenodo.21706741](https://doi.org/10.5281/zenodo.21706741) | **Superseded** | Errata content; PDF still printed prior version DOI inside (immutable). |
| [10.5281/zenodo.21710366](https://doi.org/10.5281/zenodo.21710366) | **Current** | Re-export with concept-only body DOI `…468`; content errata as in CHANGELOG v1.0.2+. |

## External links

- **GitHub:** https://github.com/chokmah-me/aria-moebius  
- **Release:** https://github.com/chokmah-me/aria-moebius/releases/tag/v1.0.1  
- **OSF:** https://osf.io/wy8db/ (DOI 10.17605/OSF.IO/WY8DB)  
- **Catalog:** https://chokmah.me/research/mobius-bridges-for-the-invert-and-affine-s-box-class-with-th-21705469/  
  (URL path fragment is historical; page content cites concept `…468` and version `…366`.)

## Citation

**Paper (prefer concept DOI for readers; version DOI for a pinned PDF):**

Bilar, D. Y. (2026). *Mobius Bridges for the Invert-and-Affine S-box Class, with the Four ARIA Instantiations*. Zenodo.  
https://doi.org/10.5281/zenodo.21705468 (concept); https://doi.org/10.5281/zenodo.21710366 (this PDF)

**Software:**

Bilar, D. Y. (2026). *aria-moebius: Lean formalization and class-bridge verifier* (v1.0.1). Zenodo. https://doi.org/10.5281/zenodo.21710669

No attack complexities for ARIA are claimed.

## Landing-page metadata

`SEARCH-META.html` — optional paste into the chokmah.me landing `<head>` (aligned with live catalog DOIs).

**Direct PDF file URL (record 21710366):**  
https://zenodo.org/records/21710366/files/ARIA-Moebius-v1-REL.pdf

## Post-mint check (fail the release if this fails)

After every new Zenodo mint, from the repo root:

```powershell
pwsh -File scripts/check_doi_consistency.ps1
```

The script greps the tree for **superseded** paper record IDs and **fails** if any hit survives outside this file’s superseded table and other allowlisted paths. Update the script’s `SupersededIds` / `CurrentVersionId` when a new version is minted.
