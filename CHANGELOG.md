# Changelog

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
