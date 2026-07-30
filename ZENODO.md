# Zenodo deposits

Two separate Zenodo **concepts** (do not merge paper and software):

| Role | DOI | Status |
|---|---|---|
| **Paper concept** | [10.5281/zenodo.21705468](https://doi.org/10.5281/zenodo.21705468) | **Stable.** Always resolves to the latest paper PDF. |
| **Paper (current version)** | [10.5281/zenodo.21710821](https://doi.org/10.5281/zenodo.21710821) | v1.0.4; published ARIA $A,B,a,b$; PDF only. |
| **Software concept** | [10.5281/zenodo.21705939](https://doi.org/10.5281/zenodo.21705939) | Always latest software zip. |
| **Software (current version)** | [10.5281/zenodo.21710669](https://doi.org/10.5281/zenodo.21710669) | From GitHub Release `v1.0.1` (pre-constants-close; see latest GH release). |

## Paper version history

| Version DOI | Status | Notes |
|---|---|---|
| [10.5281/zenodo.21705469](https://doi.org/10.5281/zenodo.21705469) | **Superseded** | First paper mint. Catalog URL path fragment only. |
| [10.5281/zenodo.21705738](https://doi.org/10.5281/zenodo.21705738) | **Superseded** | Pre-errata PDF. |
| [10.5281/zenodo.21706741](https://doi.org/10.5281/zenodo.21706741) | **Superseded** | Errata content; lagged self-DOI. |
| [10.5281/zenodo.21710366](https://doi.org/10.5281/zenodo.21710366) | **Superseded** | Concept-only body; ARIA-shaped (random linear parts). |
| [10.5281/zenodo.21710821](https://doi.org/10.5281/zenodo.21710821) | **Current** | Published ARIA $A$, $B$, $a=\mathtt{0x63}$, $b=\mathtt{0xE2}$; Table 1 closed. |

## External links

- **GitHub:** https://github.com/chokmah-me/aria-moebius  
- **Release:** https://github.com/chokmah-me/aria-moebius/releases  
- **OSF:** https://osf.io/wy8db/ (DOI 10.17605/OSF.IO/WY8DB)  
- **Catalog:** https://chokmah.me/research/mobius-bridges-for-the-invert-and-affine-s-box-class-with-th-21705469/  
  (path fragment historical; page cites concept `…468` and current version.)

## Citation

**Paper (prefer concept DOI; version DOI for a pinned PDF):**

Bilar, D. Y. (2026). *Mobius Bridges for the Invert-and-Affine S-box Class, with the Four ARIA Instantiations* (v1.0.4). Zenodo.  
https://doi.org/10.5281/zenodo.21705468 (concept); https://doi.org/10.5281/zenodo.21710821 (this PDF)

**Software:**

Bilar, D. Y. (2026). *aria-moebius: Lean formalization and class-bridge verifier*. Zenodo.  
https://doi.org/10.5281/zenodo.21705939 (concept)

No attack complexities for ARIA are claimed.

## Landing-page metadata

`SEARCH-META.html` — optional paste into the chokmah.me landing `<head>`.

**Direct PDF file URL (record 21710821):**  
https://zenodo.org/records/21710821/files/ARIA-Moebius-v1-REL.pdf

## Post-mint check

```powershell
pwsh -File scripts/check_doi_consistency.ps1
```
