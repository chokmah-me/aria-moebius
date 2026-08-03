# Changelog

## v1.0.5 -- 2026-07-31 -- Paper prep: full Lean spine in Appendix A.2 (Zenodo DOI pending)

Paper source freeze for deposit (you rebuild the PDF from `ARIA-Moebius-v1-REL.md`).

- Appendix **A.2** rewritten: Thm 3.1 → `class_bridge` / `class_bridge_with_key`; Cor 3.2 → `J_class_invariant`; §5 → `L1_inv_zero` / `IsBadIndex` / `bad_index_set`
- Abstract and contributions aligned with SME greenlight formalization
- Ref [5] Bai–Yu: LNCS vol. 8783 (ISC 2013 revised selected papers; DOI `10.1007/978-3-319-27659-5_11`)
- Ref [6] Tang et al.: DOI confirmed `10.1016/j.jss.2011.04.053` (JSS 84(10) ARIA MitM article; not `…045`)
- Regenerated `results/verify_bridge_class_meta.json` / out on the v1.0.5 prep tree; verifier now auto-writes meta (`python_version`, `platform`, `git_commit`, `paper_version_label`)
- Removed dual draft `PAPER_ARIA_MOBIUS_DRAFT_v3.md` (REL.md is sole markdown source)
- Prior Lean commits: full class formalization (`1ce031a`) + L1 hygiene (`a35f6b9`)

**Zenodo paper version:** [10.5281/zenodo.21765164](https://doi.org/10.5281/zenodo.21765164)
(concept still [10.5281/zenodo.21705468](https://doi.org/10.5281/zenodo.21705468)).
Supersedes `…821` (v1.0.4).

## 2026-07-31 -- Lean: full class bridge formalization (Thm 3.1 + Cor 3.2 + §5)

Formalized the paper’s load-bearing algebraic spine in `Bridge.lean` (no `sorry`;
axioms: `propext` / `Classical.choice` / `Quot.sound` only).

- **Theorem 3.1:** `class_bridge` / `class_bridge'` for
  $S = L_2 \circ \mathrm{Frob}^j \circ \mathrm{inv} \circ L_1$
  (`AffineBij`, `classSBox`, outer-affine strip, reduce to `bridge_frobenius`)
- **§5 bad indices:** `L1_inv_zero` is the unique root of $L_1$; uniqueness and
  identity special case (`L1_inv_zero_of_id` recovers the NC index $0$)
- **Corollary 3.2:** `J_class_invariant` — online class-S-box fingerprint equals
  the offline multiset fingerprint (`class_bridge_pair_diff` → `J_affine_invariant`)
- Docs: README paper↔Lean map; `results/bridge_axiom_audit.txt` refreshed

Python `verify_bridge_class.py` remains the exhaustive Table 1 oracle. Concrete
ARIA matrices in Lean are optional later work.

## v1.0.4 -- 2026-07-30 -- ARIA published constants closed + Zenodo `…821`

Section 7 item 1 closed: `verify_bridge_class.py` instantiates Table 1 with
ARIA's published $A$, $B$, $a=\mathtt{0x63}$, $b=\mathtt{0xE2}$ (recovered from
the official S-box tables; S1 = AES). Exhaustive check: 0/64770 per row;
bad indices at $0$, $0$, $0x63$, $0xE2$. Paper Section 6/7 and Table 1 caption
updated; "ARIA-shaped" wording removed for those rows.

**Zenodo paper version:** [10.5281/zenodo.21710821](https://doi.org/10.5281/zenodo.21710821)
(concept still [10.5281/zenodo.21705468](https://doi.org/10.5281/zenodo.21705468)).
Supersedes `…366`.

## v1.0.1 software -- 2026-07-30 -- GitHub + Zenodo software

GitHub Release `v1.0.1` → Zenodo software version DOI
`10.5281/zenodo.21710834` (concept still `10.5281/zenodo.21705939`).
Supersedes software `…940` (v1.0.0).

## v1.0.3 paper -- 2026-07-30 -- Zenodo version `…366` (concept-only PDF body)

Current paper **version** DOI: `10.5281/zenodo.21710366`.  
Concept (in paper body; always latest): `10.5281/zenodo.21705468`.

| Paper DOI | Role |
|---|---|
| `…468` | concept (stable; in paper body) |
| `…469` | superseded first mint (catalog slug only) |
| `…738` | superseded v1.0.1 |
| `…741` | superseded (immutable; PDF self-DOI lagged) |
| `…366` | **current** version (CITATION.cff, ZENODO.md, SEARCH-META) |

## v1.0.2 -- 2026-07-30 -- DOI hygiene + errata content

Content errata (LaTeX, Thm 3.1 / Cor. 3.2, skip 510, ARIA-shaped, A.3, refs,
audit, verifier labels). Body cites concept only. Intermediate Zenodo version
was `…741` (now superseded by `…366`).

## v1.0.1 errata -- 2026-07-30 -- (superseded by v1.0.2 DOI layout)

Earlier errata pass; version DOI was `10.5281/zenodo.21705738`. Superseded.

## v3 -- 2026-07-30 -- scientific pivot: negative result retracted

**The v2 thesis was wrong and is withdrawn.**

v2 claimed that power-sum ratio fingerprints do not transfer from the AES Mobius
Bridge to ARIA, and that the residual symmetry is the unipotent subgroup of order
256 in `PGL(2, GF(2^8))` rather than `AGL(1, 256)`. The error was a coordinate
choice. The residual action was derived in the pre-reciprocal variable `e`, where
it is fractional-linear. Nasr and Carlini reciprocate and reparametrize to `d^-1`,
where the same action is affine. Power-sum invariants work there, and the ratio
form `I(m,n) = P_m^n / P_n^m` is exactly theirs.

Consequences:

- The `AGL(1, 256)` statement in the v1 draft was correct. The v2 "correction" to
  `PGL(2)` was wrong and is withdrawn.
- v2 Theorem 3.5 (the power-sum dichotomy) and its Table 1 are withdrawn. They
  evaluated the invariant on the pre-reciprocal multiset.
- v2 criticisms that stand: the v1 ratio form `P_{m+n}/Q_{m+n}` was wrong; the v1
  bridge identity `g = s d + s` was wrong (correct: `g = s^2 d^-1 + s`); there is
  no Bai-Yu 7-round ARIA-128 attack to use as a baseline; the `2^8.6` per-element
  cost is AES-specific engineering.
- v2 criticisms withdrawn: the `chi` off-by-one (256 bins for 255 elements is
  correct) and the `gcd(m,255)=1` complaint (it is needed).

**New in v3.** The class bridge theorem: every S-box of the form
`L2 . Frob^j . inv . L1` admits an affine bridge with `beta = L1(s)^(2^j)` and
`alpha = beta^2`. ARIA instantiates four members at `j = 0, 3, 0, 5`. The bad
indices sit at `{L1^-1(0), s}`, not `{0, s}`; for ARIA's inverse S-boxes these are
the affine constants, and the failure there is total (255 of 255 reference values),
not a corner case.

**Superseded artifacts.** `verify_aria_bridge.py` is replaced by
`verify_bridge_class.py`. Its checks 1-3 (field identities, key-action
homomorphism, the pre-reciprocal map is not a scaling) remain true; check 4 (the
power-sum dichotomy) is withdrawn as a refutation.

**Two computational errors caught during v3 development**, recorded rather than
removed. First, an entropy measurement drew 255-element multisets by sampling
without replacement from the 255 nonzero field elements, which yields the whole
multiplicative group every time and makes every power sum vanish; real delta-set
difference sequences are drawn with replacement. Second, a log/antilog table was
built with 2 as the generator, which does not generate `GF(2^8)*` under this
modulus; 3 does. Both produced results that looked clean (a single "invariant"
value that was in fact a set containing only `None`). Both are now guarded by
assertions in `verify_bridge_class.py`.

## v2 -- 2026-07-29

Negative result. Retracted; see v3.

## v1

Machine-generated draft with attack parameter sheets for 7-round ARIA-128 and
8-round ARIA-256. Withdrawn: garbled bridge identity, nonexistent baseline.

