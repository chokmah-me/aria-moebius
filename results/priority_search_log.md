# Priority search log — Möbius Bridge ports

**Purpose.** Determine whether a public port of the Nasr–Carlini Möbius Bridge
(or an equivalent affine fingerprint for invert-then-affine / Frobenius-twisted
S-boxes) already exists for ARIA, Camellia, CLEFIA, or SM4 before investing in
a class-theorem note.

**Date of search (repo / Grok pass):** 2026-07-30 (UTC)  
**Date of search (SME pass):** 2026-07-30 (UTC), same window  
**Source paper age:** published **2026-07-28** with the HAWK result (press
coverage 28–29 July 2026) — **two days old** at search time, not weeks.

**Source paper (not on eprint at search time):**

- Milad Nasr and Nicholas Carlini, *Cryptanalysis of 7-Round AES via the
  Algebraic Structure of its S-box*, Anthropic.
- PDF (Anthropic):  
  `https://www.anthropic.com/document/aes_mobius_bridge.pdf`  
  (CDN variant also linked from press:  
  `https://www-cdn.anthropic.com/.../aes_mobius_bridge.pdf`)

**Conclusion (both passes):** **No ARIA / Camellia / CLEFIA / SM4 Möbius Bridge
port found.** Field appears clear for a short class-theorem note. Window is
**days-to-weeks**, not months (open Anthropic harness + CryptanalysisBench;
ARIA is an obvious next SPN target).

---

## 1. Grok / repo pass (2026-07-30)

### 1.1 Queries and surfaces

| # | Surface | Query / action | Result |
|---|---|---|---|
| G1 | IACR eprint search UI | `Möbius Bridge` | **No results** (spell-suggest: `mobius Bridge`) |
| G2 | IACR eprint search UI | `"Mobius Bridge"` | **No results** |
| G3 | IACR eprint search UI | `Nasr Carlini` | **No results** (spell-suggest: `naor calling`) |
| G4 | Web | `Möbius Bridge ARIA S-box meet-in-the-middle fingerprint` | Topological Möbius / unrelated noise only |
| G5 | Web | `Nasr Carlini AES Mobius Bridge ARIA OR Camellia OR CLEFIA OR SM4` | NC AES paper + press; **no cipher port** |
| G6 | Web | `site:eprint.iacr.org ARIA Möbius OR Mobius Bridge OR residual symmetry inversion S-box` | Unrelated ARIA/quantum/MitM; **no Bridge port** |
| G7 | Web | `site:arxiv.org ARIA Möbius Bridge OR affine fingerprint GF(2^8) inversion S-box` | No relevant hit |
| G8 | Web | `site:eprint.iacr.org "Möbius" OR "Mobius Bridge" AES S-box` | Boolean Möbius transform / unrelated; **no NC Bridge** |
| G9 | Web | `site:eprint.iacr.org "invert-then-affine" OR fingerprint AGL S-box` | No Bridge port |
| G10 | Web | `"Nasr" "Carlini" AES bridge OR Möbius ARIA OR Camellia OR CLEFIA OR SM4` | AES + HAWK press only |
| G11 | Web | `Anthropic "Möbius Bridge" ARIA OR Camellia OR CLEFIA OR SM4 port OR transplant` | **No port paper** |

### 1.2 Null / negative findings (Grok pass)

- NC Möbius Bridge **not indexed** on eprint under title/author/abstract search
  for the strings above (paper lives on Anthropic hosting as of search date).
- **No paper** found claiming a Möbius Bridge (or equivalent post-reciprocal
  AGL fingerprint) for **ARIA**, **Camellia**, **CLEFIA**, or **SM4**.
- Pre-2026 ARIA MitM literature (Bai–Yu, Tang et al., etc.) **pre-dates** NC
  and is not a Bridge transplant.
- eprint hits on “Möbius” are overwhelmingly **Möbius transform** (ANF / cubes),
  not the NC Bridge.

### 1.3 Caveats (Grok pass)

- eprint UI search covers titles, authors, abstracts, keywords — **not** full
  PDF body; a silent fulltext mention could be missed.
- NC may appear on eprint under a different title later.
- Non-English venues and private drafts are out of scope for this log.

---

## 2. SME pass (2026-07-30) — decisive artifacts

SME inspected the **open-sourced Nasr–Carlini / Anthropic harness** (Apache 2.0)
and related artifacts (including CryptanalysisBench collaboration notes).

### 2.1 Word-boundary search on artifact repo

| Cipher / term | Files matching as cipher target | Notes |
|---|---|---|
| ARIA | **0** | — |
| Camellia | **0** | — |
| CLEFIA | **0** | — |
| SM4 | **0** | — |
| SEED | vocabulary only | RNG wording, **not** the block cipher SEED |
| AES | present | Primary symmetric target |
| HAWK | present | Companion PQC result (same release) |
| LEA-128 | present | **Other** Korean standard; **ARX** differential-linear (13-round), not S-box Bridge |

**Read:** They reached for a Korean cipher and took **LEA** (ARX), not ARIA
(SPN / AES-field S-boxes).

### 2.2 Formalization status in their repo (SME)

- Lean material ~**427 lines**, **one** theorem: `chi_fp` (χ\* orbit false-positive bound).
- **Bridge identity is not formalized** in their Lean (consistent with prose §5.5).
- Computational check of Frobenius power-sum relation exists in Rust
  (`AES/rust/src/exp_basic.rs`: “Frobenius \(P_{2m} = P_m^2\)” failures / cosets) —
  verified computationally, **not** proved in Lean.

### 2.3 Timing correction

| Earlier belief | Corrected |
|---|---|
| Paper “weeks” old | **Two days** old (release **2026-07-28**) |
| Quiet follow-up window | **Days-to-weeks**; multi-agent harness open-sourced |

---

## 3. Strategic summary for this repo

| Question | Answer as of 2026-07-30 |
|---|---|
| Does an ARIA Möbius Bridge port exist publicly? | **No evidence found** |
| Camellia / CLEFIA / SM4 Bridge port? | **No evidence found** |
| Is the note blocked by prior art on the *class theorem*? | **Not by this search** |
| Should attack-parameter work block a short class note? | **No** (SME: split papers) |
| Largest residual risk | Competing group points the open harness at ARIA next |

**Out of scope for this log:** implementing verifiers, Lean proofs, paper rewrite
(those are later steps once the class theorem is locked in code).

---

## 4. Re-run checklist (if revalidating later)

1. eprint: `Mobius Bridge`, `Möbius Bridge`, `Nasr`, `Carlini`, `ARIA`+`fingerprint`/`AGL`/`S-box`.
2. arXiv cs.CR: same strings + `invert-then-affine`.
3. Google Scholar: cite-forward on NC AES Möbius Bridge PDF / Anthropic page.
4. Anthropic / Mythos / CryptanalysisBench repos: word search ARIA, Camellia, CLEFIA, SM4.
5. Record date, queries, and any **first positive hit** immediately (stop and reassess).

---

## 5. Provenance

| Pass | Operator | Date |
|---|---|---|
| Web + eprint UI | Grok (repo session) | 2026-07-30 |
| Harness / artifact repo word search | SME | 2026-07-30 |
| Log file checked into `aria-moebius` | Grok | 2026-07-30 |

This file is an **audit trail**, not a literature review suitable for publication
as-is. Re-run before camera-ready.
