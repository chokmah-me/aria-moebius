<p class="hebrew-epigraph" dir="rtl" lang="he">אִם יִרְצֶה הַשֵּׁם</p>

<p class="hebrew-date" dir="rtl" lang="he">HEBREW_DATE_TODO</p>

# Transplanting the Mobius Bridge to ARIA: The Residual Symmetry Group, a Corrected Invariant, and Open Proof Obligations

Daniyel Yaacov Bilar, Chokmah LLC, chokmah-dyb@pm.me
ORCID: [0000-0002-9040-6914](https://orcid.org/0000-0002-9040-6914)

29 July 2026

Licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
DOI: DOI_TODO (Zenodo record not yet minted)

---

## Abstract

The Mobius Bridge of Nasr and Carlini removes one guessed key byte from meet-in-the-middle attacks on 7-round AES by building a fingerprint invariant under the symmetry that survives field inversion inside the S-box. Both ARIA S-boxes factor through inversion over the same field, so the transplant looks immediate. It is not. This note derives the residual symmetry for ARIA exactly and identifies it as the unipotent subgroup of the projective linear group over GF(2^8), of order 256 and isomorphic to the additive group of the field, rather than the one-dimensional affine group of order 65280. The distinction decides the invariant theory. The post-inversion difference map is fractional-linear in the delta-set difference and is a pure scalar multiplication for none of the 255 base points, so power-sum ratio fingerprints, which are natural for a scaling action, do not transfer. Exhaustive computation over GF(2^8) confirms a sharp dichotomy: across seven exponent pairs, the corrected power-sum ratio is either identically one, carrying no information, or takes 51 to 143 distinct values under the true action, and so is not invariant. The cross-ratio is invariant, which locates where a working fingerprint must come from. No attack complexities for ARIA are claimed. The proof obligations any complexity claim would first have to discharge are stated, and the verification code is released.

**Keywords:** ARIA, block cipher, meet-in-the-middle attack, Mobius Bridge, S-box, GF(2^8) inversion, projective linear group, cross-ratio, cryptanalysis.

---

## Notation

| Symbol | Meaning |
|---|---|
| $\mathbb{F}$ | the field GF(2^8) modulo $x^8 + x^4 + x^3 + x + 1$ |
| $\oplus$ | addition in $\mathbb{F}$, equivalently bitwise XOR |
| $S_1, S_2$ | the two ARIA S-boxes |
| $A, B$ | fixed invertible 8-by-8 matrices over GF(2) in $S_1, S_2$ |
| $a, b$ | fixed additive constants in $S_1, S_2$ |
| $L$ | a generic GF(2)-linear map, standing for $A$ or $B$ |
| $c$ | a generic additive constant, standing for $a$ or $b$ |
| $k$ | an unknown round-key byte added before the S-box |
| $v_0$ | the unknown, key-dependent critical S-box input at the base element of the delta-set |
| $e_i$ | the known difference of delta-set element $i$ at the critical S-box input |
| $g_i$ | the corresponding unknown difference after inversion |
| $U$ | the unipotent subgroup $\{M_k\}$ of $\mathrm{PGL}(2,\mathbb{F})$, order 256 |
| $M_k$ | the projective map induced on post-inversion values by adding $k$ |
| $P_m$ | power sum of order $m$ over pairwise differences of the online multiset |
| $Q_m$ | the same power sum over the offline multiset |
| $J_{m,n}$ | the corrected power-sum ratio $P_m^{\,n} / P_n^{\,m}$ |
| $\lambda$ | a cross-ratio of four elements of $\mathbb{F} \cup \{\infty\}$ |

All acronyms are expanded at first use. SPN denotes a substitution-permutation network; MitM denotes meet-in-the-middle; PGL denotes the projective general linear group; AGL denotes the affine general linear group.

---

## 1. Introduction

Nasr and Carlini [4] attack 7 of the 10 rounds of AES-128 by exploiting the fact that the AES S-box is field inversion in GF(2^8) followed by a fixed affine map. Their Mobius Bridge constructs a fingerprint that stays constant as one unknown key byte varies, eliminating one of the nine bytes that the meet-in-the-middle attack of Derbez, Fouque and Jean [3] had to guess. Dunkelman, Keller and Shamir [2] had already handled the key byte above the meet-in-the-middle table; the Bridge handles the byte below it.

ARIA [1] invites the same treatment. It is a 128-bit SPN standardised in Korea, and its two S-boxes are built over the same field with the same nonlinear primitive: $S_1$ is the AES S-box, and $S_2$ is an affine transformation of $x \mapsto x^{247} = (x^{-1})^8$. Since $x^{255} = 1$ on $\mathbb{F}^{\times}$, the exponent 247 is $-8$, so $S_2$ differs from $S_1$ only by a Frobenius twist and different affine data. Both S-boxes factor through inversion. The transplant therefore looks like bookkeeping.

The bookkeeping does not go through, and the reason is instructive. Section 3 derives the group that actually survives inversion in ARIA and shows it is not the affine group. Its invariant theory is different, and the power-sum fingerprints that a scaling action would admit are either vacuous or not invariant. Section 3.5 identifies the cross-ratio as the invariant that does survive, which is where a working ARIA fingerprint has to be built.

This note claims a negative result and a direction, not an attack. An earlier version of this work stated parameter sheets and complexity figures for 7-round ARIA-128 and 8-round ARIA-256. Those figures rested on the symmetry claim refuted in Section 3.2 and are withdrawn. Section 5 states, as explicit obligations, what would have to be established before any such figure could be quoted.

Contributions:

1. An exact derivation of the residual symmetry group for ARIA's critical S-box layer, with its order and isomorphism type (Propositions 3.1 and 3.2).
2. A refutation, exhaustive over the 255 nonzero base points, of the hypothesis that the post-inversion difference map is a scalar multiplication.
3. A dichotomy theorem, verified across seven exponent pairs, showing that power-sum ratio fingerprints are either constant or non-invariant under the true action.
4. Identification of the cross-ratio as an invariant that does survive, with the pole cases counted.
5. A released verification script reproducing every numeric claim in the paper.

## 2. Preliminaries

### 2.1 ARIA

ARIA is a 128-bit SPN with 12, 14 or 16 rounds for key lengths of 128, 192 and 256 bits [1]. Each round applies a round-key XOR, a substitution layer drawing on the four maps $S_1, S_2, S_1^{-1}, S_2^{-1}$ in a fixed pattern, and an involutional 16-by-16 binary diffusion matrix. Each output byte of the diffusion layer depends on seven input bytes, and the matrix has branch number 8. The final round omits diffusion.

Over $\mathbb{F} = \mathrm{GF}(2^8)$ modulo $x^8 + x^4 + x^3 + x + 1$, the S-boxes are

$$S_1(x) = A \cdot x^{-1} \oplus a, \qquad S_2(x) = B \cdot x^{247} \oplus b = B \cdot (x^{-1})^8 \oplus b,$$

with $A, B$ fixed invertible matrices over GF(2) and $a, b$ fixed constants. The convention $0^{-1} = 0$ is inherited from AES; Section 3.3 shows why this convention matters here.

### 2.2 The Mobius Bridge, and what it needs

In a MitM attack the adversary builds a delta-set of 256 plaintexts differing in a single byte, and matches partial encryptions and decryptions under guessed outer key material. At a critical intermediate S-box the values, or their differences, form a multiset. The multiset is **unordered**: the adversary sees which values occur and with what multiplicity, but not which delta-set element produced which value. That is the whole reason a fingerprint is needed. A quantity computable from the multiset alone, and constant on each orbit of the unknown key byte's action, can index the offline table without the byte being guessed.

Two requirements follow, and both are load-bearing:

- **R1.** The fingerprint must be a symmetric function of the multiset, not a function of an indexed family. Any construction that pairs the $i$-th online element with the $i$-th offline element assumes a correspondence the adversary does not have, and is trivially solvable if the correspondence exists.
- **R2.** The fingerprint must be constant on the orbits of the group that actually acts. Identifying that group is therefore prior to constructing anything.

Section 3 discharges R2 and shows that it obstructs the natural candidates.

### 2.3 Attack model

Single-key, chosen-plaintext, no related keys or tweaks. Success probability, data limits, and the unit of time (table lookups, memory accesses, or full encryptions) would all have to be fixed before quoting a complexity; since this note quotes none, they are left open and listed in Section 5.

## 3. The residual symmetry group

### 3.1 What the key does to the post-inversion value

Write the critical layer as key addition followed by an S-box:

$$x \mapsto S(x \oplus k) = L\big((x \oplus k)^{-1}\big) \oplus c.$$

The outer $L$ and $c$ are fixed and known. The question is how varying $k$ moves the post-inversion value. This is where the earlier draft substituted $y = (x \oplus k)^{-1}$ and observed that the output is affine in $y$: true, but vacuous, since $k$ was hidden inside the definition of $y$. The derivation has to be done in terms of a $k$-free reference value.

**Proposition 3.1.** Let $u = x^{-1}$ for $x \neq 0$, the post-inversion value at $k = 0$. Then for every $k \in \mathbb{F}$,

$$(x \oplus k)^{-1} = \frac{u}{1 \oplus k u}.$$

The map $M_k : u \mapsto u/(1 \oplus ku)$ is the fractional-linear map with matrix $\begin{pmatrix} 1 & 0 \\ k & 1 \end{pmatrix}$, of determinant 1. The assignment $k \mapsto M_k$ is an injective group homomorphism from $(\mathbb{F}, \oplus)$ into $\mathrm{PGL}(2, \mathbb{F})$, whose image is the unipotent subgroup $U$ of order 256.

*Proof.* Since $u^{-1} \oplus k = (1 \oplus ku) u^{-1}$, inverting gives $u (1 \oplus ku)^{-1}$, which is the stated map. Matrix multiplication gives $M_{k_1} M_{k_2} = \begin{pmatrix} 1 & 0 \\ k_1 \oplus k_2 & 1 \end{pmatrix} = M_{k_1 \oplus k_2}$, so the assignment is a homomorphism from the additive group. It is injective because $M_k$ fixes a generic point only for $k = 0$. Verified computationally for all $256^2$ pairs $(k_1, k_2)$ against five probe points, in projective coordinates so that poles are handled correctly; the orbit of a generic point has size exactly 256. See check [2] of the released script. $\square$

**Corollary 3.1.1.** The residual action is not $\mathrm{AGL}(1, \mathbb{F})$. That group has order $255 \cdot 256 = 65280$ and consists of maps $v \mapsto sv \oplus t$; the residual action has order 256 and its nonidentity elements are not affine. Every occurrence of $\mathrm{AGL}(1)$ in the earlier draft should read $U \le \mathrm{PGL}(2, \mathbb{F})$. The name "Mobius" refers to exactly this: fractional-linear maps are Mobius transformations.

### 3.2 What the key does to differences

Fingerprints are built from differences, so the relevant object is the difference map. Across the delta-set, the critical S-box inputs are $v_0 \oplus e_i$, where the differences $e_i$ propagate linearly from the plaintext and are known, and the base value $v_0$ is unknown and key-dependent.

**Proposition 3.2.** The post-inversion difference of delta-set element $i$ relative to the base element is

$$g_i = (v_0 \oplus e_i)^{-1} \oplus v_0^{-1} = \frac{e_i}{v_0^2 \oplus v_0 e_i},$$

a fractional-linear function of $e_i$ with matrix $\begin{pmatrix} 1 & 0 \\ v_0 & v_0^2 \end{pmatrix}$ of determinant $v_0^2 \neq 0$, with a pole at $e_i = v_0$.

*Proof.* In characteristic 2, $\alpha^{-1} \oplus \beta^{-1} = (\alpha \oplus \beta)/(\alpha\beta)$. Setting $\alpha = v_0$ and $\beta = v_0 \oplus e_i$ gives $e_i / (v_0(v_0 \oplus e_i)) = e_i/(v_0^2 \oplus v_0 e_i)$. The identity was checked against all 64770 ordered pairs of distinct nonzero field elements, and the fractional-linear form against all 255 base points and all 255 nonzero differences: checks [1] and [3] of the script. $\square$

**Proposition 3.3 (refutation).** There is no $s \in \mathbb{F}^{\times}$ with $g_i = s \cdot e_i$ for all $i$. Exhaustively: the number of base points $v_0$ for which the difference map is a pure scalar multiplication is **0 of 255**.

*Proof.* $g_i / e_i = (v_0^2 \oplus v_0 e_i)^{-1}$ depends on $i$. Computed for every base point in check [3]. $\square$

Proposition 3.3 kills the hypothesis $g_\omega = s \cdot d_\omega \oplus s$ on which the earlier draft's Section 3.1 rested. It also shows the hypothesis was self-defeating even on its own terms: if such an indexed relation held, a single pair $(e_i, g_i)$ would recover $s$ by one field division, and no fingerprint would be needed. That is requirement R1 failing.

### 3.3 The zero case

The convention $0^{-1} = 0$ means inversion is not induced by the multiplicative group on all of $\mathbb{F}$, so the orbit argument has a boundary. Two distinct exceptions arise, and both must be scoped:

- The base point $v_0 = 0$, at which Propositions 3.2 and 3.3 do not apply.
- The pole $e_i = v_0$, at which $g_i$ is the projective point at infinity rather than a field element. For a 24-element offline difference set, 24 of the 255 base points hit a pole, matching the 231 pole-free points used in Section 3.4.

Any fingerprint construction must either handle the projective point explicitly or exclude the affected base points and carry the resulting loss into the success probability. The earlier draft did neither, and its $\chi \in \{0,1\}^{256}$ against a 255-element multiset was the same gap surfacing as an off-by-one.

### 3.4 Power-sum fingerprints do not transfer

For an unordered multiset the natural symmetric functions are power sums over unordered pairs,

$$P_m = \sum_{\{i,j\}} (g_i \oplus g_j)^m, \qquad Q_m = \sum_{\{i,j\}} (e_i \oplus e_j)^m,$$

the sums being XOR. The earlier draft proposed $P_{m+n}/Q_{m+n}$ as an invariant. Under a scaling action $g = s \cdot e$ one has $P_m = s^m Q_m$, so the ratio equals $s^m$: it recovers the unknown rather than cancelling it. Computationally the ratio takes 85 to 255 distinct values as $s$ ranges over $\mathbb{F}^{\times}$, depending on $\gcd(m, 255)$. It is never invariant. The stated hypothesis $\gcd(m+n, 255) = 1$ appears nowhere in the argument, and the two-index notation was vacuous since only $m+n$ entered.

The correct construction for a scaling action uses two power sums of the **same** multiset, so that the scalars cancel against each other:

**Proposition 3.4.** Under $g = s \cdot e$, define $J_{m,n} = P_m^{\,n} / P_n^{\,m}$ for $m \neq n$ and $P_n \neq 0$. Then $J_{m,n} = Q_m^{\,n}/Q_n^{\,m}$, independent of $s$.

*Proof.* $P_m = s^m Q_m$ gives $P_m^n = s^{mn} Q_m^n$ and $P_n^m = s^{mn} Q_n^m$; the factors $s^{mn}$ cancel. Verified to yield exactly one value across all 255 scalars, for all seven exponent pairs tested: check [4]. $\square$

Proposition 3.4 repairs the algebra but not the paper, because ARIA's action is not a scaling. Evaluating $J_{m,n}$ under the true action of Proposition 3.2 gives:

**Theorem 3.5 (dichotomy).** For every exponent pair tested, $J_{m,n}$ is either identically 1 under the true action, and so carries no information, or is not invariant. Over a 24-element offline difference set and the 231 pole-free base points:

| $m$ | $n$ | distinct $P_m/Q_m$ | distinct $J_{m,n}$ (scaling) | distinct $J_{m,n}$ (true action) | fraction with $J = 1$ |
|---|---|---|---|---|---|
| 1 | 2 | 255 | 1 | 1 | 231/231 |
| 2 | 4 | 255 | 1 | 1 | 231/231 |
| 3 | 5 | 85 | 1 | 1 | 231/231 |
| 3 | 17 | 85 | 1 | 1 | 231/231 |
| 5 | 7 | 51 | 1 | 51 | 4/228 |
| 7 | 11 | 255 | 1 | 143 | 1/229 |
| 11 | 13 | 255 | 1 | 142 | 1/230 |

*Table 1. Behaviour of power-sum fingerprints over GF(2^8) modulo 0x11B. Column 3 gives the number of distinct values taken by the earlier draft's ratio $P_m/Q_m$ as the scalar ranges over the 255 elements of $\mathbb{F}^{\times}$; a value above 1 means the quantity is not invariant. Column 4 gives the same count for the corrected ratio $J_{m,n}$ under a pure scaling action, where 1 confirms invariance. Column 5 gives the count for $J_{m,n}$ under the fractional-linear action ARIA actually induces (Proposition 3.2). Column 6 gives how often $J_{m,n}$ equals 1 under that action. Offline difference set of 24 elements drawn with seed 5785; the 24 base points hitting a pole are excluded, leaving 231. Rows where column 5 reads 1 have column 6 saturated, so the invariance is vacuous. Reproduced by check [4] of the released script.*

Part of the collapse is structural. Squaring is the Frobenius endomorphism, so it is additive, giving $P_{2m} = P_m^2$ identically; the rows $(1,2)$ and $(2,4)$ are instances. The remaining constant rows have no such one-line explanation and are recorded as observations. The interpretation is the same either way: the pairs that survive the true action are exactly the pairs that say nothing, and the pairs that say something do not survive.

### 3.5 What does survive

Cross-ratios are the classical invariants of $\mathrm{PGL}(2)$, and they survive here.

**Proposition 3.6.** For four distinct elements with $a \oplus d \neq 0$ and $b \oplus c \neq 0$, the cross-ratio $\lambda(a,b,c,d) = \frac{(a \oplus c)(b \oplus d)}{(a \oplus d)(b \oplus c)}$ is constant under the action of Proposition 3.2. Over the 251 pole-free base points for a fixed quadruple, the online cross-ratio takes exactly one value, equal to the offline value 0x7e.

*Proof.* Cross-ratio invariance under fractional-linear maps is classical and holds over any field; Proposition 3.2 places the action inside $\mathrm{PGL}(2, \mathbb{F})$. Verified in check [5]. $\square$

That is the correct starting point, and it is not yet a fingerprint. A cross-ratio is a function of an ordered quadruple, so requirement R1 is unmet: what is needed is a canonical symmetric function of the multiset of cross-ratios over all quadruples, which is a construction problem, not a corollary. Section 5 states it as such.

## 4. The second S-box

**Proposition 4.1.** The analysis transfers to $S_2$ with the scalar replaced by its eighth power.

*Proof.* $x^{247} = x^{-8} = (x^{-1})^8$ on $\mathbb{F}^{\times}$, and $x \mapsto x^8$ is the cube of the Frobenius endomorphism, hence GF(2)-linear and bijective. Composing it with the maps of Propositions 3.1 and 3.2 conjugates them within $\mathrm{PGL}(2, \mathbb{F})$; a scalar $s$ arising anywhere in the chain appears as $s^8$ after the twist. $\square$

Two consequences the earlier draft asserted away. The fingerprint for $S_2$ is therefore **not** identical to the one for $S_1$: the exponent must be carried through, and any normalising frame differs accordingly. And since the negative results of Section 3.4 concern the group rather than the affine data, conjugation does not rescue them; they apply to $S_2$ as well.

## 5. Proof obligations

The following would have to be discharged, in order, before any complexity figure for ARIA could be quoted. Each is open.

1. **A fingerprint.** Construct a canonical symmetric function of the multiset of cross-ratios that is computable from the online multiset alone, prove it constant on the orbits of $U$, and prove or measure how many bits it carries. Sections 3.4 and 3.5 show that the power-sum route is closed and the cross-ratio route is open.
2. **Pole and zero handling.** Extend the construction over the projective point at infinity, or bound the loss from excluding affected base points (Section 3.3), and carry that loss into the success probability.
3. **Cost of evaluation.** The AES result does not get its speed from the invariant alone. Nasr and Carlini reduce per-entry cost from roughly $2^{19}$ lookups to about $2^{8.6}$ using a packed power table, a Gray-code walk and an XOR-separable cache [4]; the Gray-code walk in particular depends on the structure of the diffusion layer. ARIA's involutional binary matrix is not MixColumns, so the amortisation must be re-derived, not imported. The earlier draft imported the figure $2^{8.6}$ directly, and its headline times depended on it.
4. **A distinguisher and a byte count.** State which distinguisher is used, from which source, and derive the outer key bytes on each side rather than asserting them. The claim that the ARIA-128 key schedule supplies further linear relations must be written out.
5. **A baseline that exists.** Bai and Yu [5] give attacks on 7-round ARIA-192/256 and 8-round ARIA-256. They do not give a 7-round ARIA-128 attack, so the earlier draft's comparison against $2^{121}$ time and $2^{120}$ memory for that configuration has no located source and is withdrawn. Any future comparison must also account for Li and Chen [6] on 7-round ARIA-192, for the earlier MitM attack of Tang et al. [8], and for the 8-round ARIA-128 result of Abdelkhalek et al. [7] obtained by linear cryptanalysis rather than MitM.
6. **Units and verification.** Fix the unit of the time figure, and verify the distinguisher experimentally, for instance on a reduced-word-size ARIA variant, before describing anything as within verification range.

## 6. Limitations

The negative results of Section 3.4 are exhaustive in the base point and the scalar, but not in the exponent: seven pairs were tested, not all $255^2$. Theorem 3.5 is therefore a dichotomy over the tested set, and a general proof that no power-sum ratio is both invariant and informative is not offered. The offline difference set is a single seeded draw of 24 elements; the counts in Table 1 are specific to it, though the qualitative dichotomy did not vary across the pairs tested. Proposition 3.6 is verified for one quadruple, and the classical argument supplies the general case, but the step from cross-ratio invariance to a usable fingerprint is exactly the gap this note does not close. Nothing here shows that ARIA resists a Mobius Bridge; it shows that the published AES construction does not port as claimed, and locates the obstruction.

## 7. Open questions

1. Characterise the exponent pairs $(m,n)$ for which $J_{m,n}$ is invariant under $U$, and prove that invariance forces $J_{m,n} \equiv 1$. The Frobenius relation $P_{2m} = P_m^2$ handles the even cases; the constant rows at $(3,5)$ and $(3,17)$ do not yet have an explanation.
2. Construct a canonical symmetric function of the cross-ratio multiset, and determine its entropy over random delta-sets.
3. Determine whether ARIA's diffusion layer permits two sufficiently independent fingerprints at adjacent columns. The earlier draft reported a correlation of about 0.11 from a measurement over $2^{24}$ delta-sets. That measurement has no surviving code, seed, or definition of the statistic, and the inference from a correlation coefficient to a shortfall in joint entropy does not follow without a computation. It is withdrawn, and the question is open.
4. Establish whether the same obstruction applies to CLEFIA and to other designs reusing the AES inversion. Camellia should not be assumed: its S-boxes are not invert-then-affine over this field, and the earlier draft's list was not checked.

## 8. Conclusion

Both ARIA S-boxes factor through inversion in GF(2^8), so the Mobius Bridge ought to transplant. It does not transplant as published, and the reason is a group-theoretic one that is easy to miss: what survives inversion in an SPN, where the key is added before the nonlinear map rather than after it, is a unipotent subgroup of $\mathrm{PGL}(2, \mathbb{F})$ of order 256, not the affine group of order 65280. The post-inversion difference map is fractional-linear and is a scaling for none of the 255 base points. Power-sum ratio fingerprints, which the affine reading would license, are either vacuous or not invariant across every exponent pair tested. The cross-ratio is invariant, so the invariant theory needed is projective rather than affine, and building a symmetric fingerprint from it is an open construction problem rather than a completed one. The complexity figures in the earlier version of this work depended on the affine reading and are withdrawn.

## Data and code availability

The script `verify_aria_bridge.py` reproduces every numeric claim in this paper: the difference-of-inverses identity over all 64770 ordered pairs, the homomorphism property over all $256^2$ key pairs, the scaling refutation over all 255 base points, Table 1 in full, and the cross-ratio invariance. Pure Python 3, no dependencies, deterministic apart from one seeded draw (seed 5785), a few seconds of runtime. Exit code 0 iff all five checks pass. Archived at DOI_TODO.

## AI utilization statement

Claude Opus 5 was used for critical review of the earlier draft, for the derivations in Section 3, and for drafting this version. The verification script was written by Claude Opus 5 and executed by the author; its output is the sole basis for the numeric claims in Table 1 and Propositions 3.3 and 3.6. Literature verification for references [1] through [7] was performed by web search and checked by the author. The earlier draft that this version supersedes was machine-generated, and its withdrawn claims are identified as such in Sections 1, 5 and 7 rather than silently removed. The author is responsible for all content.

## References

[1] D. Kwon, J. Kim, S. Park, S. H. Sung, Y. Sohn, J. H. Song, Y. Yeom, E.-J. Yoon, S. Lee, J. Lee, S. Chee, D. Han, and J. Hong, "New Block Cipher: ARIA," in *Information Security and Cryptology - ICISC 2003*, LNCS, vol. 2971, pp. 432-445, 2004. [Online]. Available: https://doi.org/10.1007/978-3-540-24691-6_32

[2] O. Dunkelman, N. Keller, and A. Shamir, "Improved Single-Key Attacks on 8-Round AES-192 and AES-256," in *Advances in Cryptology - ASIACRYPT 2010*, LNCS, vol. 6477, pp. 158-176, 2010. [Online]. Available: https://doi.org/10.1007/978-3-642-17373-8_10

[3] P. Derbez, P.-A. Fouque, and J. Jean, "Improved Key Recovery Attacks on Reduced-Round AES in the Single-Key Setting," in *Advances in Cryptology - EUROCRYPT 2013*, LNCS, vol. 7881, pp. 371-387, 2013. [Online]. Available: https://doi.org/10.1007/978-3-642-38348-9_23

[4] M. Nasr and N. Carlini, "Cryptanalysis of 7-Round AES via the Algebraic Structure of its S-box," Anthropic, 2026. [Online]. Available: https://www.anthropic.com/document/aes_mobius_bridge.pdf

[5] D. Bai and H. Yu, "Improved Meet-in-the-Middle Attacks on Round-Reduced ARIA," in *Information Security - ISC 2013*, LNCS, vol. 7807, 2015. [Online]. Available: DOI_TODO_CONFIRM_CHAPTER

[6] M. Li and S. Chen, "Improved meet-in-the-middle attack on ARIA cipher," *Journal on Communications (Tongxin Xuebao)*, vol. 36, pp. 89-94, 2015. [Online]. Available: https://doaj.org/article/a53b22edf92b4bce91ded22b5bc06a77

[7] A. Abdelkhalek, M. Tolba, and A. M. Youssef, "Improved Linear Cryptanalysis of Round-Reduced ARIA," 2016. [Online]. Available: DOI_TODO_CONFIRM

[8] X. Tang, B. Sun, R. Li, C. Li, and J. Yin, "A meet-in-the-middle attack on reduced-round ARIA," *Journal of Systems and Software*, vol. 84, no. 10, pp. 1685-1692, 2011. [Online]. Available: DOI_TODO_CONFIRM

---

## Appendix A. Lean 4 formalization

### A.1 What formalization is for here

The claims in Section 3 divide into two kinds, and only one kind benefits from a proof assistant. Propositions 3.1 through 3.4, the Frobenius fragment of Theorem 3.5, Proposition 3.6 and Proposition 4.1 are algebraic identities and structural statements: they are true or false independently of the field's size, and a machine-checked proof settles them. The remaining content of Theorem 3.5, the counts of distinct values in columns 3, 5 and 6 of Table 1, is a finite computation over GF(2^8) that the released script already performs.

Formalizing the first kind buys something the script cannot supply. The script reports that the difference map is a scalar multiplication for 0 of 255 base points. The Lean statement `diffMap_not_scaling` says instead that no field admits such a scalar, for any nonzero base point, given two distinct usable offsets. The obstruction is therefore not an artifact of the ARIA field, and would not dissolve in a larger one. That strengthens Section 3.2 from an exhaustive check to a theorem, and it is the reason this appendix exists.

Formalizing the second kind buys little and costs the trust story. Closing the non-invariance rows would require GF(2^8) arithmetic inside the kernel, which `decide` will not do at this size; `native_decide` would do it and would add `Lean.ofReduceBool` to the axiom set of the affected theorems, meaning the Lean compiler would join the trusted base. Trading a clean axiom audit for rows the script establishes anyway is a poor exchange, so those rows stay in Python and the appendix says so.

### A.2 Design

Three decisions.

**Generality first, specialization last.** Sections 1 through 4 of the Lean file are stated over `variable {F : Type*} [Field F]`, with `[CharP F 2]` added only for the Frobenius results. GF(2^8) appears only in Section 6, where the cardinality is genuinely used to get `x ^ 255 = 1`. The paper's numbered propositions are thus proved in greater generality than they are stated.

**One cancellation lemma carries the obstruction.** The lemma `den_not_constant` says that `v^2 + v*e` cannot take the same value at two distinct offsets unless `v = 0`. Corollary 3.1.1 (the induced map is not affine) and Proposition 3.3 (the difference map is not a scaling) both reduce to it. Locating the obstruction in a single three-line lemma is the clearest available statement of why the transplant fails.

**Power sums indexed by explicit pairs.** `P` is a sum over a `Finset (ι × ι)` of representative pairs rather than over `Sym2 ι` or an `offDiag`. This matters in characteristic 2: a sum over *ordered* distinct pairs double-counts, and doubling is zero, so the naive definition collapses to zero identically. Passing the pair set explicitly avoids the trap, matches `itertools.combinations` in the script, and makes Proposition 3.4 independent of the enumeration.

### A.3 Correspondence with the paper

| Paper | Lean name | Setting | Status |
|---|---|---|---|
| Prop 3.2, inner identity | `inv_add_inv_eq` | any field | proved |
| Prop 3.1, map | `key_add_inv` | any field | proved |
| Prop 3.1, group law | `U_mul`, `U_one`, `U_det` | any field | proved |
| Prop 3.1, injectivity | `U_injective` | any field | proved |
| Cor 3.1.1 | `mobiusKey_not_affine` | any field | `sorry` (A.5.1) |
| core obstruction | `den_not_constant` | any field | proved |
| Prop 3.2 | `diffMap_eq` | any field | proved |
| Prop 3.3 | `diffMap_not_scaling` | any field | proved |
| Sec 3.4, why `P/Q` fails | `draft_ratio_eq_scalar` | any field | proved |
| Prop 3.4 | `J_smul_invariant` | any field | proved |
| Thm 3.5, rows (1,2) and (2,4) | `P_two_mul`, `J_two_mul_trivial` | char 2 | proved |
| Thm 3.5, remaining rows | none | GF(2^8) | script only, by design (A.1) |
| Prop 3.6 | `crossRatio_diffMap_invariant` | any field | `sorry` (A.5.2) |
| Prop 4.1, exponent | `pow_247_eq` | GF(2^8) | proved |
| Prop 4.1, additivity | `frobenius8_add` | GF(2^8) | `sorry` (A.5.3) |

Two entries deserve comment. `draft_ratio_eq_scalar` has no counterpart among the paper's propositions because it formalizes a negative: it states that the withdrawn draft's ratio equals `s ^ m` exactly, which is the precise sense in which it recovered the unknown instead of cancelling it. And `J_two_mul_trivial` upgrades two rows of Table 1 from measurement to theorem, which is why the table's caption distinguishes structural rows from observed ones.

### A.4 Build

```
lake new aria math
# replace AriaMobius.lean, then
lake exe cache get
lake build
```

The Mathlib revision is pinned in the shipped `lake-manifest.json`. The file has **not** been compiled: it is a designed skeleton with real proof terms where the argument is settled, and literal `sorry` where it is not. Expect tactic-level adjustment, particularly around `field_simp` normal forms and the `Matrix.mul_fin_two` simp set, whose names have moved between Mathlib revisions. No claim in the paper body depends on this file; Table 1 and Propositions 3.3 and 3.6 rest on the Python script, whose output is reproduced in the archived record.

### A.5 Open proof obligations in the formalization

1. `mobiusKey_not_affine`. Reduce to `den_not_constant`. Evaluating at `u = 0` forces the translation part to be zero, after which the linear part must equal `(1 + k * u)⁻¹` at two distinct points; the cancellation lemma then applies. The bookkeeping is the extraction of two usable points from the cardinality hypothesis.
2. `crossRatio_diffMap_invariant`. Classical, and the only obligation with real content. Substituting `diffMap_eq` at all four arguments turns the goal into an identity between rational functions in `v, a, b, c, d`; `field_simp` followed by `ring` should close it once every denominator is discharged. The denominators are `v^2 + v*x` for the four arguments, plus the two cross-ratio denominators before and after. Cleaner alternative: prove cross-ratio invariance once for a general element of `GL(2, F)` acting on the affine chart, then instantiate at the matrix of Proposition 3.2. That is more work now and reusable later, and it is the version worth having, since obligation 1 of Section 5 will need the projective machinery anyway.
3. `frobenius8_add`. Iterate `frobenius_add` three times, or obtain it as `map_add (frobenius GF256 2 ^ 3)`. Routine.

Nothing else in the file is incomplete. The `#print axioms` calls at the end are the audit: the expected output is `propext`, `Classical.choice` and `Quot.sound`, and any appearance of `Lean.ofReduceBool` means a `native_decide` has entered and the corresponding claim must be moved back to the script.

### A.6 A note on the ASCII rule

The Chokmah style rule keeps body text pure ASCII. Lean 4 source is idiomatically Unicode, and rewriting it in ASCII surrogates would make the appendix unidiomatic and harder to check against a real build. The code fences in A.3 and A.4 and the shipped `.lean` file are therefore treated as code rather than body text and are exempt. Flagging this as a decision rather than assuming it: the alternative is to drop the appendix's code fences and reference the file only.
