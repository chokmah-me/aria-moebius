<p class="hebrew-epigraph" dir="rtl" lang="he">אִם יִרְצֶה הַשֵּׁם</p>

# Mobius Bridges for the Invert-and-Affine S-box Class, with the Four ARIA Instantiations

Daniyel Yaacov Bilar, Chokmah LLC, chokmah-dyb@pm.me ORCID: [0000-0002-9040-6914](https://orcid.org/0000-0002-9040-6914)

<p class="hebrew-date" dir="rtl" lang="he">ט״ז בְּאָב תשפ״ו</p>

30 July 2026

Licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). DOI: [10.5281/zenodo.21705468](https://doi.org/10.5281/zenodo.21705468) (Zenodo concept DOI; always resolves to latest).

------

## Abstract

The Mobius Bridge of Nasr and Carlini removes one guessed key byte from meet-in-the-middle attacks on 7-round AES by constructing a fingerprint invariant under the group action that survives the S-box. Their derivation is written for the AES S-box, which is field inversion followed by a GF(2)-affine map. This note shows the construction is not specific to that shape. For any S-box of the form

$$S = L_2 \circ \mathrm{Frob}^j \circ \mathrm{inv} \circ L_1,$$

with $L_1$ and $L_2$ GF(2)-affine bijections and $\mathrm{Frob}$ the squaring map $x \mapsto x^2$, the same reciprocal-and-reparametrize step yields an affine bridge identity in which both parameters are raised to the $2^j$ power and the multiplier remains the square of the translation. The Frobenius exponent is the only degree of freedom. AES instantiates the case $j = 0$ with $L_1 = \mathrm{id}$. ARIA instantiates four distinct members at exponents $0$, $3$, $0$ and $5$: $S_1$, $S_2$, $S_1^{-1}$ and $S_2^{-1}$. The bad indices move from $0$ to $L_1^{-1}(0)$, which for ARIA's inverse S-boxes are the affine constants, so the published bad-index treatment does not port unchanged. The bridge identities are verified exhaustively over $\mathrm{GF}(2^8)$ and formalized in Lean 4. No attack complexities for ARIA are claimed.

**Keywords:** ARIA, block cipher, meet-in-the-middle attack, Mobius Bridge, S-box, GF(2^8) inversion, Frobenius endomorphism, affine group, Lean 4.

------

## Notation

| Symbol          | Meaning                                                      |
| --------------- | ------------------------------------------------------------ |
| $\mathbb{F}$    | the field GF(2^8) modulo $x^8 + x^4 + x^3 + x + 1$           |
| $\oplus$        | addition in $\mathbb{F}$, equivalently bitwise XOR           |
| $\mathrm{inv}$  | field inversion, with the convention $\mathrm{inv}(0) = 0$   |
| $\mathrm{Frob}$ | the squaring map $x \mapsto x^2$, a field automorphism       |
| $L_1, L_2$      | GF(2)-affine bijections of $\mathbb{F}$                      |
| $M_1, M_2$      | their linear parts, so $L_i(x) = M_i(x) \oplus c_i$          |
| $j$             | the Frobenius exponent of an S-box in the class              |
| $S$             | an S-box, $S = L_2 \circ \mathrm{Frob}^j \circ \mathrm{inv} \circ L_1$ |
| $\kappa$        | the unknown key byte added after the S-box                   |
| $a_\omega$      | the unknown intermediate value at delta-set index $\omega$   |
| $s$             | the unknown reference value $a_0$                            |
| $d_\omega$      | the offline-known difference $a_0 \oplus a_\omega$           |
| $v_\omega$      | the online-known value $S(a_\omega) \oplus \kappa$           |
| $t$             | the bridge base point $L_1(s)$                               |
| $e_\omega$      | the transported difference $M_1(d_\omega)$                   |
| $g_\omega$      | the online bridge value                                      |
| $\alpha, \beta$ | the bridge multiplier and translation                        |
| $D_\omega$      | the offline multiset element                                 |
| $P_m$           | pairwise-difference power sum of order $m$                   |
| $I_{m,n}$       | the power-sum ratio $P_m^{\,n} / P_n^{\,m}$                    |
| $A$, $a$        | linear part and additive constant of ARIA $S_1$ (AES affine) |
| $B$, $b$        | linear part and additive constant of ARIA $S_2$              |

SPN denotes a substitution-permutation network; MitM denotes meet-in-the-middle; AGL denotes the affine general linear group; DDT denotes the difference distribution table.

------

## 1. Introduction

Nasr and Carlini [1] improve meet-in-the-middle attacks on 7-round AES-128 by eliminating one of the nine key bytes guessed by Derbez, Fouque and Jean [2]. Dunkelman, Keller and Shamir [3] had already absorbed the key byte above the meet-in-the-middle table using a multiset fingerprint; the Mobius Bridge absorbs the byte below it. The mechanism is algebraic: the AES S-box is field inversion followed by a fixed GF(2)-affine map, and after a reciprocal and a change of variable the unknown byte acts on the tabulated data as an element of AGL(1, 256), against which a fingerprint can be made invariant.

The derivation in [1] is written throughout for the AES S-box. The question this note answers is how much of it depends on that particular shape. The answer is: only one integer.

Write $\mathrm{Frob}$ for the squaring map on $\mathbb{F}$, which is a field automorphism because the characteristic is 2, and consider S-boxes of the form

$$S = L_2 \circ \mathrm{Frob}^j \circ \mathrm{inv} \circ L_1,$$

with $L_1, L_2$ GF(2)-affine bijections. Theorem 3.1 shows every member of this class admits a bridge identity of the same affine shape, with both parameters raised to the $2^j$ power and the multiplier still the square of the translation. AES is the case $j = 0$, $L_1 = \mathrm{id}$.

ARIA [4] is a useful test of the generalization because it instantiates four distinct members at once. Its substitution layer draws on $S_1$, $S_2$, $S_1^{-1}$ and $S_2^{-1}$ in a fixed per-round pattern, where $S_1$ is the AES S-box and $S_2$ is an affine transformation of $x^{247}$. Since $x^{247} = (x^{-1})^8$ on $\mathbb{F}^\times$, the map $S_2$ sits at $j = 3$. The two inverse S-boxes are affine-then-invert rather than invert-then-affine, which at first looks like an obstruction, since the bridge appears to need the affine map outermost so that it factors out of a difference. It is not an obstruction: the affine map simply moves from $L_2$ to $L_1$, and the offline multiset absorbs it. Section 4 gives the four instantiations.

One consequence has no analogue in the AES case and is easy to miss. The derivation treats $\mathrm{inv}$ as a genuine field inverse, so it fails where the argument of the inner inversion vanishes. In [1] that is the pair of bad indices $a_\omega \in \{0, s\}$, handled by an appended-parity variant of the fingerprint. In the general class the inner inversion sees $L_1(a_\omega)$, so the bad set is $\{L_1^{-1}(0), s\}$. For ARIA's two inverse S-boxes $L_1^{-1}(0)$ is the affine constant of the corresponding forward S-box, not zero. Section 5 makes this precise and reports the exhaustive check: at those indices the identity fails for every reference value, so the failure is a full family rather than a corner case, and the treatment in [1] does not port unchanged.

**Contributions.**

1. A class bridge theorem (Theorem 3.1) covering every S-box of the form above, with the Frobenius exponent as the only parameter, proved over an arbitrary field of characteristic 2.
2. The four ARIA instantiations, at exponents 0, 3, 0 and 5, each with its offline multiset (Section 4).
3. The bad-index relocation to $\{L_1^{-1}(0), s\}$, with an exhaustive check that the failure is total at those indices (Section 5).
4. Verification of every identity over GF(2^8), and a Lean 4 formalization of the bridge identities and of the affine invariance of the power-sum fingerprint. Neither is formalized in the artifacts accompanying [1], which contain a single theorem bounding false positives for the parity-vector fingerprint.

**What is not claimed.** No attack on ARIA is presented, and no data, time or memory figure for ARIA appears anywhere in this note. Section 7 lists what a complexity claim would require.

## 2. Preliminaries

### 2.1 The setting

In a Demirci-Selcuk meet-in-the-middle attack the adversary builds a delta-set of 256 plaintexts differing in one byte and tracks a single byte of an intermediate state. At the critical position the adversary knows, online, a value $v_\omega$ obtained by peeling the outer rounds under guessed key material, and the offline table is built from differences $d_\omega$ of the corresponding unknown intermediate values. The relation between them passes through one S-box and one unknown key byte $\kappa$:

$$v_\omega = S(a_\omega) \oplus \kappa, \qquad d_\omega = a_0 \oplus a_\omega .$$

Two facts about this setting matter for what follows.

First, $\kappa$ is additive and cancels in any difference $v_0 \oplus v_\omega$. What does not cancel is the unknown reference value $s := a_0$, which enters nonlinearly through the inversion. Removing the dependence on $s$ is what the bridge does.

Second, the online and offline sides do not share an indexing of the delta-set, so the fingerprint must be a symmetric function of the multiset. This is the constraint that forces power sums rather than individual ratios, and it is inherited unchanged from [3] and [1].

### 2.2 The class

$L_1$ and $L_2$ are GF(2)-affine bijections of $\mathbb{F}$, written $L_i(x) = M_i(x) \oplus c_i$ with $M_i$ GF(2)-linear and invertible. Since the characteristic is 2, $\mathrm{Frob}(x) = x^2$ is a field automorphism, and $\mathrm{Frob}^j(x) = x^{2^j}$ is additive for every $j$. The convention $\mathrm{inv}(0) = 0$ is inherited from AES and ARIA; Section 5 is about where it bites.

### 2.3 Scope

Single-key, chosen-plaintext. The results below are algebraic identities about one S-box and one key byte. They say nothing about round counts, distinguishers, or key schedules, and they are stated independently of any particular attack. Where a claim is verified computationally rather than proved, this is said explicitly.

## 3. The class bridge theorem

**Theorem 3.1.** Let $S = L_2 \circ \mathrm{Frob}^j \circ \mathrm{inv} \circ L_1$ and let $v_\omega = S(a_\omega) \oplus \kappa$. Set

$$t := L_1(s), \qquad e_\omega := M_1(d_\omega), \qquad g_\omega := \big[M_2^{-1}(v_0 \oplus v_\omega)\big]^{-1} .$$

If $t \neq 0$, $d_\omega \neq 0$, and $L_1(a_\omega) \neq 0$, then

$$g_\omega = \alpha \cdot D_\omega \oplus \beta, \qquad \beta = t^{2^j}, \quad \alpha = \beta^2, \quad D_\omega = e_\omega^{-2^j}.$$

(The conclusion $D_\omega = e_\omega^{-2^j}$ needs $e_\omega \neq 0$, which follows from $d_\omega \neq 0$ because $M_1$ is a linear bijection. The definition of $g_\omega$ uses a reciprocal, so $v_0 \oplus v_\omega \neq 0$ is required; for bijective $S$ this is equivalent to $d_\omega \neq 0$. The Lean statement `bridge_identity` records $(he : e \neq 0)$ and $(hve : v + e \neq 0)$ explicitly.)

*Proof.* The key byte cancels, $v_0 \oplus v_\omega = S(a_0) \oplus S(a_\omega)$. Write $b_\omega := L_1(a_\omega)$. The constant $c_2$ cancels in the difference and $M_2$ is additive, so

$$v_0 \oplus v_\omega = M_2\big( \mathrm{Frob}^j(\mathrm{inv}(b_0)) \oplus \mathrm{Frob}^j(\mathrm{inv}(b_\omega)) \big).$$

Because $\mathrm{Frob}^j$ is additive this becomes $M_2\big(\mathrm{Frob}^j(b_0^{-1} \oplus b_\omega^{-1})\big)$, and therefore

$$M_2^{-1}(v_0 \oplus v_\omega) = \mathrm{Frob}^j\big(b_0^{-1} \oplus b_\omega^{-1}\big).$$

In any field $b_0^{-1} \oplus b_\omega^{-1} = (b_0 \oplus b_\omega)/(b_0 b_\omega)$. The constant $c_1$ cancels in $b_0 \oplus b_\omega = M_1(d_\omega) = e_\omega$, and $b_0 = t$, $b_\omega = t \oplus e_\omega$, so

$$b_0^{-1} \oplus b_\omega^{-1} = \frac{e_\omega}{t^2 \oplus t\, e_\omega}.$$

Taking reciprocals, and using that $\mathrm{Frob}^j$ commutes with inversion because it is a field automorphism,

$$g_\omega = \mathrm{Frob}^j\!\left( \frac{t^2 \oplus t\, e_\omega}{e_\omega} \right) = \mathrm{Frob}^j\big( t^2 e_\omega^{-1} \oplus t \big) = t^{2^{j+1}} e_\omega^{-2^j} \oplus t^{2^j},$$

which is the stated identity with $\beta = t^{2^j}$ and $\alpha = \beta^2$. $\square$

Three remarks.

**The reciprocal is the whole trick.** Before it, the map $e_\omega \mapsto e_\omega / (t^2 \oplus t e_\omega)$ is fractional-linear in $e_\omega$ and is a scalar multiplication for no base point. After it, and read as a function of $e_\omega^{-1}$ rather than of $e_\omega$, it is affine. The two descriptions are of the same object in different coordinates, and only the second gives a group action with usable invariant theory.

**The multiplier is the square of the translation.** The unknown therefore contributes one byte of freedom, not two: the action is a one-parameter curve inside AGL(1, 256), not the full 65280-element group. A fingerprint invariant under the whole of AGL(1, 256) is invariant under it, which is what [1] uses, and is what makes the construction insensitive to the exact form of the curve.

**Only $j$ survives.** $L_1$ and $L_2$ appear only through the substitutions $s \mapsto L_1(s)$, $d \mapsto M_1(d)$ and the outer $M_2^{-1}$. They change which quantities are fed in, not the shape of the identity. This is why the theorem is stated for arbitrary affine bijections rather than for ARIA's published constants, and why instantiating with those constants requires no new argument.

**Corollary 3.2 (fingerprint invariance).** Since $g_\omega \oplus g_\mu = \alpha (D_\omega \oplus D_\mu)$, the pairwise-difference power sums satisfy $P_m(G) = \alpha^m P_m(D)$, so

$$I_{m,n} := \frac{P_m^{\,n}}{P_n^{\,m}}$$

takes the same value online and offline whenever $P_n \neq 0$ and $t \neq 0$ (equivalently $\alpha \neq 0$). This is the invariant of [1, Section 4.1], and the derivation above shows it applies to every member of the class. (Lean `J_affine_invariant` carries `hα : α ≠ 0`.)

## 4. ARIA's four substitution-layer maps

ARIA [4] is a 128-bit SPN with 12, 14 or 16 rounds. Its substitution layer applies $S_1$, $S_2$, $S_1^{-1}$, $S_2^{-1}$ in a fixed pattern, with $S_1(x) = A(x^{-1}) \oplus a$ the AES S-box ($a = \mathtt{0x63}$) and $S_2(x) = B(x^{247}) \oplus b$ ($b = \mathtt{0xE2}$).

Two exponent facts place the pair $S_2$, $S_2^{-1}$ in the class. First, $x^{247} = x^{-8} = (x^{-1})^8$ on $\mathbb{F}^\times$, so $S_2$ sits at $j = 3$. Second, $247 \cdot 223 \equiv 1 \pmod{255}$ and $223 = 255 - 32$, so the inverse exponent satisfies $x^{223} = (x^{-1})^{32}$ and $S_2^{-1}$ sits at $j = 5$. Both are verified exhaustively.

| ARIA map   | $L_1$                    | $j$  | $L_2$               | $\beta$                             | offline $D_\omega$                 | bad index $L_1^{-1}(0)$ |
| ---------- | ------------------------ | ---- | ------------------- | ----------------------------------- | ---------------------------------- | ----------------------- |
| $S_1$      | $\mathrm{id}$            | 0    | $A(\cdot) \oplus a$ | $s$                                 | $d_\omega^{-1}$                    | $0$                     |
| $S_2$      | $\mathrm{id}$            | 3    | $B(\cdot) \oplus b$ | $s^{8}$                             | $d_\omega^{-8}$                    | $0$                     |
| $S_1^{-1}$ | $A^{-1}(\cdot \oplus a)$ | 0    | $\mathrm{id}$       | $A^{-1}(s \oplus a)$                | $\big(A^{-1}(d_\omega)\big)^{-1}$  | $a$                     |
| $S_2^{-1}$ | $B^{-1}(\cdot \oplus b)$ | 5    | $\mathrm{id}$       | $\big(B^{-1}(s \oplus b)\big)^{32}$ | $\big(B^{-1}(d_\omega)\big)^{-32}$ | $b$                     |

*Table 1. The four maps of ARIA's substitution layer as members of the class of Theorem 3.1. In every row the multiplier is the square of the translation shown. The offline multiset differs in all four rows, so an implementation must select the right one per byte position. $A^{-1}$ and $B^{-1}$ denote the inverses of the linear parts. Each row is verified exhaustively against ARIA's published $A$, $B$, $a$, $b$ over all pairs $(s,d)$ with the bad indices excluded: 0 mismatches out of 64770 per row (Section 6).*

The forward S-boxes put the affine map outermost, so it is stripped online by applying $M_2^{-1}$ before the reciprocal, exactly as in [1]. The inverse S-boxes put it innermost, so nothing is stripped online and the affine map is absorbed into the offline multiset instead. This is a mild practical advantage for the inverse S-boxes, since it removes one table lookup per delta-set element from the online loop.

## 5. Bad indices move with $L_1$

The proof of Theorem 3.1 uses $b_\omega^{-1}$ as a genuine field inverse. Under the convention $\mathrm{inv}(0) = 0$ this fails when $b_\omega = L_1(a_\omega) = 0$, that is, when $a_\omega = L_1^{-1}(0)$. Together with the trivial index $a_\omega = s$, the bad set is

$$\{\, L_1^{-1}(0),\ s \,\}.$$

For $L_1 = \mathrm{id}$ this is $\{0, s\}$, which is the set treated in [1] by computing a second fingerprint with an appended synthetic zero and accepting a hit on either parity. For ARIA's two inverse S-boxes $L_1^{-1}(0)$ is the affine constant of the corresponding forward S-box, so the bad index is not zero, and a parity treatment that appends a zero is appending the wrong element.

The exhaustive check makes the size of the discrepancy clear. At $a_\omega = L_1^{-1}(0)$ the identity fails for **every** admissible reference value, 255 of 255 for the forward S-boxes and 254 of 254 for the inverse ones. This is not a rare corner that can be absorbed into a success probability; it is a complete family, and it is the same size as the family that [1] handles. The correct generalization is to append $L_1^{-1}(0)$ rather than 0, and to note that the two forward and two inverse positions require different appended elements.

Of the $65280 = 256 \times 255$ ordered pairs $(s, d)$ with $d \neq 0$, the verifier skips $510$ and tests $64770$ per variant. The $510$ skips split as $255$ with $t = 0$ (the full difference-row when the reference itself is a bad index) plus $255$ with $b_\omega = L_1(a_\omega) = 0$ (one difference per remaining reference). The branch $S(s) = S(a_\omega)$ never fires for bijective $S$. These $510$ exclusions are exactly the bad-index family of the theorem, not a residual of failed identities.

## 6. Verification

`verify_bridge_class.py` performs five checks over GF(2^8), deterministic apart from seeded draws of the affine maps, and exits 0 only if all pass. On the archived run (CPython 3.14.4, Windows 11, seed 5785) the full suite completes in a few seconds; see `results/verify_bridge_class_meta.json`.

1. **The class.** Theorem 3.1 for all eight Frobenius exponents against three independently drawn pairs $(L_1, L_2)$ of random affine bijections, exhaustive over all $(s, d)$: 0 mismatches out of 64770 per exponent.
2. **ARIA.** The four rows of Table 1 with ARIA's published affine maps $A$, $B$ and constants $a = \mathtt{0x63}$, $b = \mathtt{0xE2}$: 0 mismatches out of 64770 each. The key byte $\kappa$ verified to cancel in every case. Bad indices land at $L_1^{-1}(0) \in \{0, a, b\}$ as predicted.
3. **Exponents.** $x^{247} = (x^{-1})^8$ and $x^{223} = (x^{-1})^{32}$ over all nonzero $x$, and $247 \cdot 223 \equiv 1 \pmod{255}$.
4. **Bad indices.** Located at $L_1^{-1}(0)$ for each variant, with the total-failure counts of Section 5.
5. **Fingerprint.** $I_{m,n}$ over all 255 admissible reference values $s$ for each of the four variants at exponent pairs $(7,11)$, $(7,13)$, $(11,23)$, $(31,127)$: a single value in every case, matching the offline value. ($\kappa$ cancels before $g_\omega$ is formed, so this loop is not a key-variation test.)

Check 1 uses random affine bijections and establishes the class. Check 2 instantiates the four published ARIA maps; no further substitution is required for Table 1.

## 7. What this note does not establish

The following are open, and none of them is addressed here.

1. **Byte geometry.** Whether a byte position exists in a reduced-round ARIA MitM attack where the last unknown key byte reaches the match point through exactly one S-box, with the equivalent-subkey trick collapsing the diffusion layer to a single byte. ARIA's diffusion matrix is an involutory binary matrix, so the algebraic step is available, but the byte-level accounting has not been done.
2. **Cost.** The per-element cost figures of [1] depend on a packed power table, a DDT-aware Gray-code walk tuned to the AES difference distribution table, and an S-box cache over a four-byte anti-diagonal peel. ARIA's diffusion layer has weight 7 rather than 4 and $S_2$ has its own DDT, so none of these transfers without re-derivation.
3. **Fingerprint entropy at attack width.** The invariance of $I_{m,n}$ is established here. Its collision entropy at the 12 or 13 byte width an attack would need is not. An earlier-draft measurement at two-byte width and a sample size four to five orders of magnitude below [1] is withdrawn with the v2 draft (see `CHANGELOG.md`); no replacement figure is claimed here.
4. **A baseline.** Bai and Yu [5] attack 7-round ARIA-192/256 and 8-round ARIA-256. They do not give a 7-round ARIA-128 attack, so any future comparison at that parameter must locate a real baseline or state that none exists.
5. **Complexities.** No data, time or memory figure for ARIA appears in this note, and none should be quoted from it.

## 8. Related work and priority

The Mobius Bridge is due to Nasr and Carlini [1], published 28 July 2026 together with an unrelated result on HAWK. Their artifact repository [8] contains code for AES, HAWK and LEA-128, and contains no ARIA, Camellia, CLEFIA or SM4. Their Lean development consists of one theorem, `chi_fp`, bounding false-positive collisions of the parity-vector fingerprint under a uniformity assumption; the bridge identity itself is not formalized there. The present note is, to the author's knowledge as of 30 July 2026, the first statement of the class generalization and the first treatment of the inverse-S-box case. The search log underlying these priority claims is shipped as `results/priority_search_log.md`.

The line of work the bridge improves runs from Demirci and Selcuk through Dunkelman, Keller and Shamir [3] to Derbez, Fouque and Jean [2]. Prior meet-in-the-middle analysis of ARIA is due to Tang et al. [6] and Bai and Yu [5], with a later improvement by Li and Chen [7]; none uses S-box algebraic structure in the sense here.

## 9. Conclusion

The Mobius Bridge is a fact about the class of S-boxes that factor as an affine map, a Frobenius power, an inversion and another affine map, and within that class the only quantity that varies is the Frobenius exponent. ARIA exhibits four members of the class simultaneously, at exponents 0, 3, 0 and 5, and its two inverse S-boxes relocate the bad indices from zero to the affine constants, which is the one place where the published treatment needs amendment rather than substitution. Whether any of this yields an attack on reduced-round ARIA is a separate question, and this note deliberately does not open it.

## Data and code availability

`verify_bridge_class.py` reproduces every numeric claim above: the class identity across all eight Frobenius exponents, the four published ARIA rows, the exponent facts, the bad-index locations and failure counts, and the fingerprint invariance. Pure Python 3, no dependencies, deterministic apart from seeded draws, exit code 0 iff all five checks pass. Archived run and provenance metadata in `results/`. Lean sources in `AriaMobius.lean` and `Bridge.lean`. Repository: `https://github.com/chokmah-me/aria-moebius`. Paper (Zenodo concept DOI, always latest): https://doi.org/10.5281/zenodo.21705468. Software (concept, always latest): https://doi.org/10.5281/zenodo.21705939. Version-specific DOIs are recorded in the repository file `ZENODO.md`.

## AI utilization statement

This note has an unusual revision history, and stating it plainly is more useful than concealing it.

An initial draft was generated by a large language model and presented parameter sheets and complexity figures for attacks on 7-round ARIA-128 and 8-round ARIA-256. Those figures rested on a garbled bridge identity and on a comparison baseline that does not exist in the literature, and were withdrawn.

A second draft was produced after review by Claude Opus 5. That review correctly identified the garbled identity and the missing baseline, but introduced an error of its own: it derived the residual action in the pre-reciprocal variable, concluded that power-sum fingerprints could not transfer to ARIA, and recommended reframing the work as a negative result. The conclusion was an artifact of the coordinate choice. It was retracted after the source paper [1] was read directly, at which point the reciprocal-and-reparametrize step made the correct derivation immediate.

The present note is the third draft. Claude Opus 5 derived Theorem 3.1, wrote the verification script and the Lean sources, and drafted the text; the author designed the checks, ran them, and is responsible for all content. Both `AriaMobius.lean` and `Bridge.lean` were built and audited by the author against Lean 4.32.2 and Mathlib v4.32.2, with only the standard three axioms and no use of `native_decide`; see `results/bridge_axiom_audit.txt`. Two failed intermediate computations, a degenerate multiset sample and a mis-specified field generator, were caught by assertion and are recorded in the changelog rather than silently removed.

The episode is a small case study in a failure mode relevant to [1, Section 6]: a machine-generated result, a machine review that corrected it in one place and broke it in another, and a correction that arrived only when the primary source was consulted rather than paraphrased.

No AI system is listed as a co-author. Affiliation: Chokmah LLC, Norwich, VT. Contact: chokmah-dyb@pm.me.

## References

[1] M. Nasr and N. Carlini, "Cryptanalysis of 7-Round AES via the Algebraic Structure of its S-box," Anthropic, 2026. [Online]. Available: https://www.anthropic.com/document/aes_mobius_bridge.pdf

[2] P. Derbez, P.-A. Fouque, and J. Jean, "Improved Key Recovery Attacks on Reduced-Round AES in the Single-Key Setting," in *Advances in Cryptology - EUROCRYPT 2013*, LNCS, vol. 7881, pp. 371-387, 2013. [Online]. Available: https://doi.org/10.1007/978-3-642-38348-9_23

[3] O. Dunkelman, N. Keller, and A. Shamir, "Improved Single-Key Attacks on 8-Round AES-192 and AES-256," in *Advances in Cryptology - ASIACRYPT 2010*, LNCS, vol. 6477, pp. 158-176, 2010. [Online]. Available: https://doi.org/10.1007/978-3-642-17373-8_10

[4] D. Kwon, J. Kim, S. Park, S. H. Sung, Y. Sohn, J. H. Song, Y. Yeom, E.-J. Yoon, S. Lee, J. Lee, S. Chee, D. Han, and J. Hong, "New Block Cipher: ARIA," in *Information Security and Cryptology - ICISC 2003*, LNCS, vol. 2971, pp. 432-445, 2004. [Online]. Available: https://doi.org/10.1007/978-3-540-24691-6_32

[5] D. Bai and H. Yu, "Improved Meet-in-the-Middle Attacks on Round-Reduced ARIA," in *Information Security - ISC 2013*, LNCS, pp. 155-168, 2015. [Online]. Available: https://doi.org/10.1007/978-3-319-27659-5_11

[6] X. Tang, B. Sun, R. Li, C. Li, and J. Yin, "A meet-in-the-middle attack on reduced-round ARIA," *Journal of Systems and Software*, vol. 84, no. 10, pp. 1685-1692, 2011. [Online]. Available: https://doi.org/10.1016/j.jss.2011.04.053

[7] M. Li and S. Chen, "Improved meet-in-the-middle attack on ARIA cipher," *Journal on Communications*, vol. 36, pp. 89-94, 2015. [Online]. Available: https://doaj.org/article/a53b22edf92b4bce91ded22b5bc06a77

[8] M. Nasr and N. Carlini, cryptography-research-demo (AES / HAWK / LEA artifact repository), GitHub, commit `fa01c398b42bb7d94eadff75a42dfb45da484457`, accessed 2026-07-30. [Online]. Available: https://github.com/anthropics/cryptography-research-demo

------

## Appendix A. Lean 4 formalization

### A.1 Scope

The identities of Theorem 3.1 and Corollary 3.2 are algebraic and hold over any field of characteristic 2, so they are formalized over `variable {F : Type*} [Field F] [CharP F 2]` and descend to `GaloisField 2 8` only for the two exponent facts of Section 4, where the cardinality is used to get `x ^ 255 = 1`.

The counts in Sections 5 and 6 are finite computations and stay in Python. Closing them in Lean would require GF(2^8) arithmetic inside the kernel, which `decide` will not do at this size, and `native_decide` would add `Lean.ofReduceBool` to the axiom set of the affected results. A clean axiom audit is worth more than coverage of numbers the script already establishes.

### A.2 Correspondence

| Paper                                          | Lean name             | File              | Setting           |
| ---------------------------------------------- | --------------------- | ----------------- | ----------------- |
| reciprocal step, $j = 0$                       | `bridge_identity`     | `Bridge.lean`     | any field, char 2 |
| Theorem 3.1                                    | `bridge_frobenius`    | `Bridge.lean`     | any field, char 2 |
| $P_m(\alpha D \oplus \beta) = \alpha^m P_m(D)$ | `P_affine`            | `Bridge.lean`     | any field, char 2 |
| Corollary 3.2                                  | `J_affine_invariant`  | `Bridge.lean`     | any field, char 2 |
| $x^{247} = (x^{-1})^8$                         | `pow_247_eq`          | `AriaMobius.lean` | GF(2^8)           |
| $x^{223} = (x^{-1})^{32}$                      | `aria_S2inv_exponent` | `Bridge.lean`     | GF(2^8)           |
| Frobenius additivity                           | `frobenius8_add`      | `AriaMobius.lean` | GF(2^8)           |
| Section 5 counts                               | none                  | script only       | by design, A.1    |

`AriaMobius.lean` additionally contains results derived for the second draft and retained as the geometry of the pre-reciprocal chart: `diffMap_eq`, `diffMap_not_scaling`, `crossRatio_diffMap_invariant`, and the unipotent-subgroup lemmas `U_mul`, `U_injective`. These are true and are not load-bearing for anything in this note. `diffMap_not_scaling` in particular states that the pre-reciprocal map is a scalar multiplication for no base point, which is correct and which does not obstruct Theorem 3.1, since the theorem concerns the reciprocal in a different variable. They are kept because they document why the coordinate choice matters.

`P_smul` and `J_smul_invariant` are the scaling special cases of `P_affine` and `J_affine_invariant`; the affine versions are the ones the bridge needs, because the action carries a translation.

### A.3 Build and audit

```
lake exe cache get
lake build
```

Pinned to Lean 4.32.2 and Mathlib v4.32.2 in `lean-toolchain` and `lake-manifest.json`. Both `AriaMobius.lean` and `Bridge.lean` build with exit 0 against that toolchain. Every `#print axioms` for the load-bearing declarations reports only `[propext, Classical.choice, Quot.sound]` (for `P_affine`, `[propext, Quot.sound]`). The archived log is `results/lake_build_bridge.txt` (Built Bridge, 2017 jobs); the axiom lines for both files are recorded in `results/bridge_axiom_audit.txt`. Note that `results/axiom_audit.txt` is an earlier AriaMobius-only run and does not contain Bridge rows — use `bridge_axiom_audit.txt` for the correspondence table in A.2.
