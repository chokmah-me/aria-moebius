#!/usr/bin/env python3
"""
verify_bridge_class.py -- Mobius bridge identities for the invert-and-affine
S-box class, and the four ARIA instantiations.

Accompanies: "Mobius Bridges for the Invert-and-Affine S-box Class"
(D. Y. Bilar, Chokmah LLC).

CLAIM UNDER TEST
----------------
Let L1, L2 be GF(2)-affine bijections of GF(2^8) and let j in {0..7}. For any
S-box of the class

    S = L2 . Frob^j . inv . L1            (Frob(x) = x^2, inv(0) := 0)

write the online quantity as v_w = S(a_w) + kappa with kappa an unknown key byte
added after the S-box, s := a_0 the unknown reference value, and d_w := a_0 + a_w
the offline-known difference. Then

    g_w := [ L2lin^-1 (v_0 + v_w) ]^-1  =  alpha * D_w + beta

with

    beta  = t^(2^j),   alpha = beta^2,   D_w = ( L1lin(d_w) )^(-2^j),
    t     = L1(s).

That is: every member of the class admits an AGL(1, 2^8) bridge, parameterized
by the single Frobenius exponent j, with alpha = beta^2 throughout.

The bad indices (where inv(0) := 0 breaks the identity) are

    a_w in { L1^-1(0), s }

generalizing the {0, s} of Nasr-Carlini, which is the L1 = id case.

SUPERSEDES
----------
verify_aria_bridge.py, which tested power-sum invariants on the PRE-reciprocal
multiset. That multiset is fractional-linear rather than affine, so the
invariants there are either vacuous or non-invariant; the conclusion drawn from
it ("power-sum fingerprints do not transfer to ARIA") was an artifact of the
variable, not a property of ARIA. The reciprocal + reparametrization step above
is what linearizes the action. See CHANGELOG.

Deterministic apart from seeded draws of the affine maps. Pure Python 3, no
dependencies. Exit code 0 iff every check passes. Typical runtime: a few
seconds under CPython 3.11+ on a laptop (see results/verify_bridge_class_meta.json).
"""
import platform
import random
import sys
import time

MOD = 0x11B          # AES/ARIA field polynomial x^8+x^4+x^3+x+1
SEED = 5785


# ------------------------------------------------------------------ field
def _slow_mul(a, b):
    r = 0
    while b:
        if b & 1:
            r ^= a
        b >>= 1
        a <<= 1
        if a & 0x100:
            a ^= MOD
    return r


EXP = [0] * 512
LOG = [0] * 256
_x = 1
for _i in range(255):
    EXP[_i] = _x
    LOG[_x] = _i
    _x = _slow_mul(_x, 3)          # 3 generates GF(2^8)* for this modulus
assert _x == 1 and len(set(EXP[:255])) == 255, "generator check failed"
for _i in range(255, 510):
    EXP[_i] = EXP[_i - 255]


def mul(a, b):
    return 0 if (a == 0 or b == 0) else EXP[LOG[a] + LOG[b]]


def powf(a, e):
    return 0 if a == 0 else EXP[(LOG[a] * (e % 255)) % 255]


def inv(a):
    return EXP[(255 - LOG[a]) % 255] if a else 0


# ---------------------------------------------------------- affine maps
class Affine:
    """An invertible GF(2)-affine map x -> M(x) + c on GF(2^8)."""

    def __init__(self, basis, const):
        self.basis, self.const = basis, const
        self.fwd = [self._apply(x) for x in range(256)]
        self.bwd = [0] * 256
        for x in range(256):
            self.bwd[self.fwd[x]] = x
        # linear part only (constant dropped) -- this is what acts on differences
        self.lin = [self._apply(x) ^ const for x in range(256)]
        self.linbwd = [0] * 256
        for x in range(256):
            self.linbwd[self.lin[x]] = x

    def _apply(self, x):
        y = self.const
        for i in range(8):
            if x >> i & 1:
                y ^= self.basis[i]
        return y


def rand_affine(rng, const=None):
    while True:
        basis = [rng.randrange(256) for _ in range(8)]
        rows, r = basis[:], 0
        for bit in range(8):
            p = next((i for i in range(r, 8) if rows[i] >> bit & 1), None)
            if p is None:
                continue
            rows[r], rows[p] = rows[p], rows[r]
            for i in range(8):
                if i != r and rows[i] >> bit & 1:
                    rows[i] ^= rows[r]
            r += 1
        if r == 8:
            return Affine(basis, rng.randrange(256) if const is None else const)


IDENT = Affine([1 << i for i in range(8)], 0)

# ARIA published affine maps (Kwon et al. / ICISC 2003; recovered from the
# official S-box tables as L(y)=S(inv-power(y)), bit 0 = LSB).
# S1 is the AES S-box: A(y) = M_A(y) xor 0x63.
# S2: B(y) = M_B(y) xor 0xE2 with inner map x |-> inv(x)^8 = Frob^3(inv(x)).
ARIA_A = Affine([0x1F, 0x3E, 0x7C, 0xF8, 0xF1, 0xE3, 0xC7, 0x8F], 0x63)
ARIA_B = Affine([0xAC, 0xC5, 0x12, 0xCF, 0x5B, 0x5F, 0x85, 0xEE], 0xE2)


# ------------------------------------------------------------ the class
def make_sbox(L1, j, L2):
    """S = L2 . Frob^j . inv . L1"""
    return [L2.fwd[powf(inv(L1.fwd[x]), 1 << j)] for x in range(256)]


def bridge_check(name, L1, j, L2, verbose=True):
    """Exhaustive over all (s, d) with the bad indices excluded, for one kappa
    (kappa cancels identically in v_0 + v_w, checked separately)."""
    S = make_sbox(L1, j, L2)
    assert len(set(S)) == 256, f"{name}: S is not a permutation"
    zero_pre = L1.bwd[0]                     # the a with L1(a) = 0
    e2j = 1 << j
    bad = tested = skipped = 0
    for s in range(256):
        t = L1.fwd[s]
        if t == 0:                            # s is itself a bad index
            skipped += 255
            continue
        beta = powf(t, e2j)
        alpha = mul(beta, beta)
        for d in range(1, 256):
            a_w = s ^ d
            if a_w == zero_pre:
                skipped += 1
                continue
            num = S[s] ^ S[a_w]
            if num == 0:
                skipped += 1
                continue
            g = inv(L2.linbwd[num])
            D = powf(inv(L1.lin[d]), e2j)
            if g != (mul(alpha, D) ^ beta):
                bad += 1
            tested += 1
    if verbose:
        print(f"    {name:<26} j={j}  mismatches {bad:>6} / {tested:<6}"
              f" (bad indices skipped: {skipped})"
              f"  {'OK' if bad == 0 else 'FAIL'}")
    return bad == 0


def kappa_cancels(L1, j, L2):
    S = make_sbox(L1, j, L2)
    return all((S[a] ^ k) ^ (S[b] ^ k) == S[a] ^ S[b]
               for k in (0x00, 0x9E, 0xFF) for a in range(0, 256, 17)
               for b in range(0, 256, 23))


# ------------------------------------------------- power-sum invariant
def P(vals, m):
    """Pairwise-difference power sum over unordered pairs."""
    acc = 0
    n = len(vals)
    for i in range(n):
        vi = vals[i]
        for k in range(i + 1, n):
            acc ^= powf(vi ^ vals[k], m)
    return acc


def I_mn(vals, m, n):
    Pm, Pn = P(vals, m), P(vals, n)
    return None if Pn == 0 else mul(powf(Pm, n), inv(powf(Pn, m)))


# ------------------------------------------------------------- checks
def check_class(rng):
    print("[1] general class  S = L2 . Frob^j . inv . L1  (random affine maps)")
    ok = True
    for trial in range(3):
        L1, L2 = rand_affine(rng), rand_affine(rng)
        for j in range(8):
            ok &= bridge_check(f"random trial {trial}", L1, j, L2,
                               verbose=(trial == 0))
    print(f"    all 8 Frobenius exponents x 3 random (L1, L2) pairs: "
          f"{'OK' if ok else 'FAIL'}")
    return ok


def affine_inverse(M):
    basis = [M.bwd[1 << i] ^ M.bwd[0] for i in range(8)]
    return Affine(basis, M.bwd[0])


def aria_variants(_rng=None):
    """The four ARIA substitution-layer maps with published A, B, a, b [4].

    S1  = A . inv                  -> L1 = id,   j=0, L2 = A  (a = 0x63)
    S2  = B . Frob^3 . inv         -> L1 = id,   j=3, L2 = B  (b = 0xE2)
    S1^-1 = inv . A^-1             -> L1 = A^-1, j=0, L2 = id
    S2^-1 = Frob^5 . inv . B^-1    -> L1 = B^-1, j=5, L2 = id
    """
    A, B = ARIA_A, ARIA_B
    return [("ARIA S1",     IDENT,               0, A),
            ("ARIA S2",     IDENT,               3, B),
            ("ARIA S1^-1",  affine_inverse(A),   0, IDENT),
            ("ARIA S2^-1",  affine_inverse(B),   5, IDENT)]


def check_aria(variants):
    print("\n[2] the four ARIA substitution-layer maps (published A, B, a, b)")
    ok = True
    for name, L1, j, L2 in variants:
        ok &= bridge_check(name, L1, j, L2)
        ok &= kappa_cancels(L1, j, L2)
    print(f"    key byte kappa cancels in every case: OK")
    return ok


def check_exponent_identities():
    print("\n[3] exponent facts underpinning S2 and S2^-1")
    a = all(powf(x, 247) == powf(inv(x), 8) for x in range(1, 256))
    b = (247 * 223) % 255 == 1
    c = all(powf(x, 223) == powf(inv(x), 32) for x in range(1, 256))
    print(f"    x^247 = (x^-1)^8          : {a}   (S2 is Frobenius^3 of an inverse)")
    print(f"    247 * 223 = 1 mod 255     : {b}")
    print(f"    x^223 = (x^-1)^32         : {c}   (S2^-1 is Frobenius^5 of an inverse)")
    return a and b and c


def check_bad_index_location(variants):
    print("\n[4] bad-index location: { L1^-1(0), s }, not { 0, s }")
    ok = True
    for name, L1, j, L2 in variants:
        z = L1.bwd[0]
        S = make_sbox(L1, j, L2)
        # the identity must fail at a_w = z for at least one s, and hold elsewhere
        fails = 0
        total = 0
        for s in range(1, 256):
            t = L1.fwd[s]
            if t == 0 or (s ^ z) == 0:
                continue
            total += 1
            d = s ^ z
            num = S[s] ^ S[z]
            if num == 0:
                continue
            g = inv(L2.linbwd[num])
            D = powf(inv(L1.lin[d]), 1 << j)
            if g != (mul(mul(powf(t, 1 << j), powf(t, 1 << j)), D) ^ powf(t, 1 << j)):
                fails += 1
        print(f"    {name:<20} L1^-1(0) = 0x{z:02x}   identity fails there for"
              f" {fails} of {total} reference values")
        ok &= fails > 0
    return ok


def check_invariant(variants, rng):
    print("\n[5] I(m,n) = P_m^n / P_n^m invariance under the bridge action")
    ok = True
    d_set = [rng.randrange(1, 256) for _ in range(40)]
    for name, L1, j, L2 in variants:
        e2j = 1 << j
        D = [powf(inv(L1.lin[d]), e2j) for d in d_set]
        for (m, n) in [(7, 11), (7, 13), (11, 23), (31, 127)]:
            vals = set()
            for s in range(1, 256):
                t = L1.fwd[s]
                if t == 0:
                    continue
                beta = powf(t, e2j)
                alpha = mul(beta, beta)
                G = [mul(alpha, x) ^ beta for x in D]
                v = I_mn(G, m, n)
                if v is not None:
                    vals.add(v)
            offline = I_mn(D, m, n)
            good = len(vals) == 1 and offline in vals
            ok &= good
            if (m, n) == (7, 11):
                print(f"    {name:<20} m,n=({m},{n}): {len(vals)} distinct over"
                      f" 255 admissible reference values s, matches offline: {offline in vals}")
    print(f"    all four variants x four exponent pairs: {'OK' if ok else 'FAIL'}")
    return ok


def main():
    t0 = time.perf_counter()
    rng = random.Random(SEED)
    print(__doc__.strip().splitlines()[0])
    print(f"GF(2^8) mod 0x{MOD:03X}, seed {SEED}")
    print(f"Python {sys.version.split()[0]}, {platform.system()} {platform.release()}\n")
    variants = aria_variants(rng)
    results = [
        check_class(rng),
        check_aria(variants),
        check_exponent_identities(),
        check_bad_index_location(variants),
        check_invariant(variants, rng),
    ]
    elapsed = time.perf_counter() - t0
    print(f"\n{sum(results)}/{len(results)} checks passed in {elapsed:.2f}s.")
    return 0 if all(results) else 1


if __name__ == "__main__":
    sys.exit(main())
