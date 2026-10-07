# Zenodo deposits

Two separate Zenodo **concepts** (do not merge paper and software):

| Role | DOI | Status |
|---|---|---|
| **Paper concept** | [10.5281/zenodo.21705468](https://doi.org/10.5281/zenodo.21705468) | **Stable.** Always resolves to the latest paper PDF. |
| **Paper (current version)** | [10.5281/zenodo.21765164](https://doi.org/10.5281/zenodo.21765164) | v1.0.5; full Lean class formalization (Thm 3.1 / Cor 3.2 / §5); PDF only. |
| **Software concept** | [10.5281/zenodo.21705939](https://doi.org/10.5281/zenodo.21705939) | Always latest software zip. |
| **Software (current version)** | [10.5281/zenodo.23215647](https://doi.org/10.5281/zenodo.23215647) | From GitHub Release `v1.0.4` (independent kernel check). |

## Paper version history

| Version DOI | Status | Notes |
|---|---|---|
| [10.5281/zenodo.21705469](https://doi.org/10.5281/zenodo.21705469) | **Superseded** | First paper mint. Catalog URL path fragment only. |
| [10.5281/zenodo.21705738](https://doi.org/10.5281/zenodo.21705738) | **Superseded** | Pre-errata PDF. |
| [10.5281/zenodo.21706741](https://doi.org/10.5281/zenodo.21706741) | **Superseded** | Errata content; lagged self-DOI. |
| [10.5281/zenodo.21710366](https://doi.org/10.5281/zenodo.21710366) | **Superseded** | Concept-only body; ARIA-shaped (random linear parts). |
| [10.5281/zenodo.21710821](https://doi.org/10.5281/zenodo.21710821) | **Superseded** | v1.0.4; published ARIA $A,B,a,b$; Table 1 closed. |
| [10.5281/zenodo.21765164](https://doi.org/10.5281/zenodo.21765164) | **Current** | v1.0.5; Lean class bridge + fingerprint + bad-index set; A.2 map. |

## External links

- **GitHub:** https://github.com/chokmah-me/aria-moebius  
- **Release:** https://github.com/chokmah-me/aria-moebius/releases  
- **OSF:** https://osf.io/wy8db/ (DOI 10.17605/OSF.IO/WY8DB)  
- **Paper catalog (current slug):** https://chokmah.me/research/mobius-bridges-for-the-invert-and-affine-s-box-class-with-th-21765164/  
- **Paper catalog (historical slug):** https://chokmah.me/research/mobius-bridges-for-the-invert-and-affine-s-box-class-with-th-21705469/  
  (path fragment historical; page cites concept `…468` and current version.)  
- **Software catalog:** https://chokmah.me/research/aria-moebius-lean-formalization-and-class-bridge-verifier-21765202/  
  (path fragment historical; page cites software concept `…939` and current version `…647`)

## Citation

**Paper (prefer concept DOI; version DOI for a pinned PDF):**

Bilar, D. Y. (2026). *Mobius Bridges for the Invert-and-Affine S-box Class, with the Four ARIA Instantiations* (v1.0.5). Zenodo.  
https://doi.org/10.5281/zenodo.21705468 (concept); https://doi.org/10.5281/zenodo.21765164 (this PDF)

**Software:**

Bilar, D. Y. (2026). *aria-moebius: Lean formalization and class-bridge verifier* (v1.0.4). Zenodo.  
https://doi.org/10.5281/zenodo.21705939 (concept); https://doi.org/10.5281/zenodo.23215647 (this zip)

No attack complexities for ARIA are claimed.

## Landing-page metadata

`SEARCH-META.html` — optional paste into the chokmah.me landing `<head>`.

**Direct PDF file URL (record 21765164):**  
https://zenodo.org/records/21765164/files/ARIA-Moebius-v1-REL.pdf

## Post-mint check

```powershell
pwsh -File scripts/check_doi_consistency.ps1
```

## Paste-ready Zenodo metadata (unlock / PUT / republish; files untouched)

GitHub→Zenodo webhooks can clobber description and keywords. Restore from here.

### Software record 23215647 (v1.0.4)

**Keywords:** ARIA; block cipher; Mobius Bridge; GF(2^8); Frobenius; Lean 4; S-box; formal verification; mathlib; invert-and-affine; class bridge; fingerprint invariance; meet-in-the-middle; cryptanalysis; axiom audit; con-leche; independent kernel

**Notes:** Cite the paper (concept DOI 10.5281/zenodo.21705468) first. This record is the Lean/verifier zip. Prefer software concept DOI 10.5281/zenodo.21705939 for always-latest. No attack complexities for ARIA are claimed.

**Related identifiers:** paper concept 10.5281/zenodo.21705468 `isSupplementTo`; paper v1.0.5 10.5281/zenodo.21765164 `isSupplementTo`; software v1.0.3 10.5281/zenodo.21765202 `isNewVersionOf`; GitHub https://github.com/chokmah-me/aria-moebius `isSupplementedBy`; tree https://github.com/chokmah-me/aria-moebius/tree/v1.0.4 `isAlternateIdentifier`; catalog https://chokmah.me/research/aria-moebius-lean-formalization-and-class-bridge-verifier-21765202/ `isDocumentedBy`.

**Description HTML:**

```html
<p>The Nasr–Carlini Möbius Bridge is not specific to the AES S-box. It holds for every S-box of the form <em>S = L<sub>2</sub> ∘ Frob<sup>j</sup> ∘ inv ∘ L<sub>1</sub></em>, with L<sub>1</sub>, L<sub>2</sub> GF(2)-affine bijections and the Frobenius exponent <em>j</em> as the only degree of freedom. ARIA instantiates four members of that class at once (S<sub>1</sub>, S<sub>2</sub>, S<sub>1</sub><sup>−1</sup>, S<sub>2</sub><sup>−1</sup> at exponents 0, 3, 0, 5). This deposit is the Lean 4 formalization and exhaustive GF(2<sup>8</sup>) Python verifier for that class identity.</p>
<p><strong>No attack complexities for ARIA are claimed.</strong></p>
<p>---------------------------<br><br><strong>This version (v1.0.4, 2026-10-07).</strong> <em>GitHub Release v1.0.4 zip. Lean spine unchanged from v1.0.3 (Theorem 3.1 / Corollary 3.2 / §5). Adds an independent-kernel accept of the <code>Bridge</code> export: <code>con-leche --verified</code> CHECK_EXIT=0 (283412 declarations, 2026-09-17), checker pin <code>leanprover/con-leche</code> <code>c431b1ca</code>, <code>lean4export</code> 3.1.0 / Lean 4.32.2; see <code>results/con-leche-verified.md</code>. Also ships CC-BY-4.0 LICENSE and <code>lake build</code> + Python verifier CI. Optional gate; NDJSON not in the zip. Prefer software concept DOI 10.5281/zenodo.21705939 for always-latest zip. Companion paper: 10.5281/zenodo.21705468 (concept) / 10.5281/zenodo.21765164 (v1.0.5 PDF).<br><br></em>----------------------------</p>
<h2>TL;DRs for different audiences</h2>
<p><strong>For the SME.</strong><br>
Class theorem companion: the Nasr–Carlini Möbius Bridge holds for every invert-and-affine S-box S = L<sub>2</sub> ∘ Frob<sup>j</sup> ∘ inv ∘ L<sub>1</sub>, with j the only degree of freedom. This zip is the Lean 4.32.2 spine of Theorem 3.1 / Corollary 3.2 / §5 plus a five-check exhaustive GF(2<sup>8</sup>) oracle. ARIA S1, S2, S1<sup>−1</sup>, S2<sup>−1</sup> at j = 0, 3, 0, 5 with published A, B, a=0x63, b=0xE2: 0/64770 mismatches per Table 1 row. Axioms: propext / Classical.choice / Quot.sound; no sorry. Independent kernel: con-leche --verified accepted the Bridge export (CHECK_EXIT=0). No attack complexities are claimed.</p>
<p><strong>For the interested layman.</strong><br>
A fingerprint trick written for AES also works for ARIA’s four related S-boxes. This archive is the proof-and-check code: Lean proves the algebra, a small Python script brute-checks every byte of GF(256), and a second Lean kernel re-checked the exported proofs. Cite the paper for the claim; this DOI for the replay.</p>
<p><strong>For the skeptic.</strong><br>
The Python oracle is exhaustive (0/64770 per published ARIA row, seed 5785). The Lean files build with a three-axiom kernel set and no sorry. An independent verified-mode kernel (con-leche) accepted the exported Bridge environment. Paper PDF and this zip are separate Zenodo concepts. If you do not trust the claim, run <code>python verify_bridge_class.py</code> and <code>lake build</code>; the kernel check is optional and documented in <code>results/con-leche-verified.md</code>.</p>
<p><strong>For the decision maker.</strong><br>
A reusable, citable formal artifact for a published class identity — not an attack paper. Cite the paper concept DOI for the theorem; this software concept DOI for the verifier and Lean. Two concepts, one GitHub repo, CC BY 4.0.</p>
<p><strong>For the funder.</strong><br>
Small, replayable Lean + Python deposit aligned to a versioned preprint. Laptop runtime is seconds. Next cost is optional further Lean (concrete ARIA matrices), not a new campaign. Deliverables are binary: lake build clean, verifier exit 0, independent-kernel accept, DOIs pinned.</p>
```

### Software record 21765202 (v1.0.3, superseded)

**Keywords:** ARIA; block cipher; Mobius Bridge; GF(2^8); Frobenius; Lean 4; S-box; formal verification; mathlib; invert-and-affine; class bridge; fingerprint invariance; meet-in-the-middle; cryptanalysis; axiom audit

**Notes:** Cite the paper (concept DOI 10.5281/zenodo.21705468) first. This record is the Lean/verifier zip. Prefer software concept DOI 10.5281/zenodo.21705939 for always-latest. No attack complexities for ARIA are claimed.

**Related identifiers:** paper concept 10.5281/zenodo.21705468 `isSupplementTo`; paper v1.0.5 10.5281/zenodo.21765164 `isSupplementTo`; GitHub https://github.com/chokmah-me/aria-moebius `isSupplementedBy`; tree https://github.com/chokmah-me/aria-moebius/tree/v1.0.3 `isAlternateIdentifier`; catalog https://chokmah.me/research/aria-moebius-lean-formalization-and-class-bridge-verifier-21765202/ `isDocumentedBy`.

**Description HTML:**

```html
<p>The Nasr–Carlini Möbius Bridge is not specific to the AES S-box. It holds for every S-box of the form <em>S = L<sub>2</sub> ∘ Frob<sup>j</sup> ∘ inv ∘ L<sub>1</sub></em>, with L<sub>1</sub>, L<sub>2</sub> GF(2)-affine bijections and the Frobenius exponent <em>j</em> as the only degree of freedom. ARIA instantiates four members of that class at once (S<sub>1</sub>, S<sub>2</sub>, S<sub>1</sub><sup>−1</sup>, S<sub>2</sub><sup>−1</sup> at exponents 0, 3, 0, 5). This deposit is the Lean 4 formalization and exhaustive GF(2<sup>8</sup>) Python verifier for that class identity.</p>
<p><strong>No attack complexities for ARIA are claimed.</strong></p>
<p>---------------------------<br><br><strong>This version (v1.0.3, 2026-08-03).</strong> <em>GitHub Release v1.0.3 zip: Lean 4.32.2 / mathlib v4.32.2 (<code>Bridge.lean</code>, <code>AriaMobius.lean</code>) formalizing Theorem 3.1 (<code>class_bridge</code> / <code>class_bridge'</code> / <code>class_bridge_with_key</code>), Corollary 3.2 (<code>J_class_invariant</code>), and §5 (<code>L1_inv_zero</code> / <code>IsBadIndex</code> / <code>bad_index_set</code>); <code>verify_bridge_class.py</code> runs five exhaustive GF(2<sup>8</sup>) checks (0/64770 mismatches per published ARIA Table 1 row). Axiom set: propext / Classical.choice / Quot.sound; no <code>sorry</code>. Prefer software concept DOI 10.5281/zenodo.21705939 for always-latest zip. Companion paper: 10.5281/zenodo.21705468 (concept) / 10.5281/zenodo.21765164 (v1.0.5 PDF).<br><br></em>----------------------------</p>
<h2>TL;DRs for different audiences</h2>
<p><strong>For the SME.</strong><br>
Class theorem companion: the Nasr–Carlini Möbius Bridge holds for every invert-and-affine S-box S = L<sub>2</sub> ∘ Frob<sup>j</sup> ∘ inv ∘ L<sub>1</sub>, with j the only degree of freedom. This zip is the Lean 4.32.2 spine of Theorem 3.1 / Corollary 3.2 / §5 plus a five-check exhaustive GF(2<sup>8</sup>) oracle. ARIA S1, S2, S1<sup>−1</sup>, S2<sup>−1</sup> at j = 0, 3, 0, 5 with published A, B, a=0x63, b=0xE2: 0/64770 mismatches per Table 1 row. Axioms: propext / Classical.choice / Quot.sound; no sorry. No attack complexities are claimed.</p>
<p><strong>For the interested layman.</strong><br>
A fingerprint trick written for AES also works for ARIA’s four related S-boxes. This archive is the proof-and-check code: Lean proves the algebra, and a small Python script brute-checks every byte of GF(256). Cite the paper for the claim; this DOI for the replay.</p>
<p><strong>For the skeptic.</strong><br>
The Python oracle is exhaustive (0/64770 per published ARIA row, seed 5785). The Lean files build with a three-axiom kernel set and no sorry. Paper PDF and this zip are separate Zenodo concepts, so a later paper mint does not silently rewrite the software archive. If you do not trust the claim, run <code>python verify_bridge_class.py</code> and <code>lake build</code>.</p>
<p><strong>For the decision maker.</strong><br>
A reusable, citable formal artifact for a published class identity — not an attack paper. Cite the paper concept DOI for the theorem; this software concept DOI for the verifier and Lean. Two concepts, one GitHub repo, CC BY 4.0.</p>
<p><strong>For the funder.</strong><br>
Small, replayable Lean + Python deposit aligned to a versioned preprint. Laptop runtime is seconds. Next cost is optional further Lean (concrete ARIA matrices) or kernel export, not a new campaign. Deliverables are binary: lake build clean, verifier exit 0, DOIs pinned.</p>
```

### Paper record 21765164 (v1.0.5)

**Keywords:** ARIA; block cipher; meet-in-the-middle; Mobius Bridge; GF(2^8); Frobenius; Lean 4; S-box; cryptanalysis; formal verification; invert-and-affine; class bridge; fingerprint invariance

**Notes:** v1.0.5 is the PDF-only record. Prefer concept DOI 10.5281/zenodo.21705468 for always-latest. Software: 10.5281/zenodo.21705939 (concept) / 10.5281/zenodo.23215647 (v1.0.4). No attack complexities for ARIA are claimed. Drop inherited `custom.code:*` (must not point at another repo) and empty `dates` on PUT.

**Related identifiers:** 10.5281/zenodo.21710821 `isNewVersionOf`; software concept 10.5281/zenodo.21705939 `isSupplementedBy`; software v1.0.4 10.5281/zenodo.23215647 `isSupplementedBy`; GitHub https://github.com/chokmah-me/aria-moebius `isSupplementedBy` + `isAlternateIdentifier`; OSF 10.17605/OSF.IO/WY8DB and https://osf.io/wy8db/ `isIdenticalTo`; catalog https://chokmah.me/research/mobius-bridges-for-the-invert-and-affine-s-box-class-with-th-21765164/ `isDocumentedBy`.

**Description HTML:**

```html
<p><strong>This version (v1.0.5, 2026-08-03).</strong> Lean 4 formalization of Theorem 3.1 (class bridge), Corollary 3.2 (class fingerprint invariance), and Section 5 bad-index set; Appendix A.2 correspondence corrected. Exhaustive GF(2<sup>8</sup>) checks remain in Python. This record is the paper PDF only. Prefer concept DOI 10.5281/zenodo.21705468 for always-latest PDF.</p>
<p>The Mobius Bridge of Nasr and Carlini removes one guessed key byte from meet-in-the-middle attacks on 7-round AES by constructing a fingerprint invariant under the group action that survives the S-box. This note shows the construction holds for every S-box of the form <em>S = L<sub>2</sub> ∘ Frob<sup>j</sup> ∘ inv ∘ L<sub>1</sub></em>, with the Frobenius exponent as the only degree of freedom.</p>
<p>ARIA's four substitution-layer maps (S<sub>1</sub>, S<sub>2</sub>, S<sub>1</sub><sup>−1</sup>, S<sub>2</sub><sup>−1</sup> at exponents 0, 3, 0, 5) are instantiated with the <strong>published</strong> affine maps and constants (a = 0x63, b = 0xE2). Bad indices relocate to L<sub>1</sub><sup>−1</sup>(0). Identities verified exhaustively over GF(2<sup>8</sup>) and formalized in Lean 4.</p>
<p><strong>No attack complexities for ARIA are claimed.</strong></p>
<p>Source: <a href="https://github.com/chokmah-me/aria-moebius">github.com/chokmah-me/aria-moebius</a>. Software concept DOI 10.5281/zenodo.21705939.</p>
<h2>TL;DRs for different audiences</h2>
<p><strong>For the SME.</strong><br>
Class theorem: the Nasr–Carlini Möbius Bridge holds for every S-box S = L<sub>2</sub> ∘ Frob<sup>j</sup> ∘ inv ∘ L<sub>1</sub>, with j the only degree of freedom. ARIA instantiates S1, S2, S1<sup>−1</sup>, S2<sup>−1</sup> at j = 0, 3, 0, 5 with published A, B, a=0x63, b=0xE2. Bad indices sit at L<sub>1</sub><sup>−1</sup>(0), not at 0. Lean spine of Thm 3.1 / Cor 3.2 / §5; exhaustive GF(2<sup>8</sup>) oracle in Python (0/64770 per Table 1 row). No attack complexities are claimed.</p>
<p><strong>For the interested layman.</strong><br>
A fingerprint trick written for AES also works for ARIA’s four related S-boxes. The algebra is proved in Lean, and every byte of the 256-element field was checked. This is a class identity, not a claim that ARIA is broken.</p>
<p><strong>For the skeptic.</strong><br>
Table 1 is exhaustive: 0 mismatches out of 64770 pairs per published ARIA row. Lean builds with propext / Classical.choice / Quot.sound only and no sorry. Paper PDF and software zip are separate Zenodo concepts. If you do not trust it, replay the verifier in the companion software DOI.</p>
<p><strong>For the decision maker.</strong><br>
A small, citable class identity for invert-and-affine S-boxes. Not an attack paper. Cite the concept DOI 10.5281/zenodo.21705468 for always-latest PDF; pin 10.5281/zenodo.21765164 for this v1.0.5 file.</p>
<p><strong>For the funder.</strong><br>
Versioned preprint plus a replayable Lean/Python companion. Laptop-scale: seconds of Python, a consumer Lean 4 build. Next cost is optional further Lean, not a new campaign. Deliverables are binary: PDF archived, lake build clean, verifier exit 0.</p>
```
