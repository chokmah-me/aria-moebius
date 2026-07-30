#!/usr/bin/env python3
"""
verify_aria_bridge.py -- Verification of residual-symmetry claims for the
Mobius Bridge transplant to ARIA.

Accompanies: "Transplanting the Mobius Bridge to ARIA" (Bilar, Chokmah LLC).
Field: GF(2^8) modulo x^8 + x^4 + x^3 + x + 1 (0x11B), the AES/ARIA field.

Fully deterministic. The single random draw is seeded (seed 5785) and only
selects a difference set; all claims are checked exhaustively over the 255
nonzero base points. Runtime: a few seconds, CPython 3.11, no dependencies.

Usage:  python3 verify_aria_bridge.py
Exit code 0 iff every assertion in the paper holds.
"""
import itertools
import random
import sys

MOD = 0x11B
SEED = 5785
INF = object()          # projective point at infinity


# ---------------------------------------------------------------- field ops
def mul(a, b):
    r = 0
    while b:
        if b & 1:
            r ^= a
        b >>= 1
        a <<= 1
        if a & 0x100:
            a ^= MOD
    return r


def powf(a, n):
    n %= 255
    if a == 0:
        return 0
    r = 1
    for _ in range(n):
        r = mul(r, a)
    return r


def inv(a):
    return 0 if a == 0 else powf(a, 254)


# ------------------------------------------------------------- the maps
def g_map(e, v0):
    """Post-inversion difference relative to the base point.

    g(e) = (v0 + e)^-1 + v0^-1 = e / (v0^2 + v0 e).
    Returns INF at the pole e == v0.
    """
    den = powf(v0, 2) ^ mul(v0, e)
    return INF if den == 0 else mul(e, inv(den))


def key_action(pt, k):
    """Action of pre-inversion key addition on the post-inversion value,
    in projective coordinates (U:W): u |-> u/(1 + k u), matrix [[1,0],[k,1]]."""
    U, W = pt
    return (U, mul(k, U) ^ W)


def normalize(pt):
    U, W = pt
    return ('inf', 1 if U else 0) if W == 0 else (mul(U, inv(W)), 1)


def power_sum(S, m):
    """P_m = sum over unordered pairs of (a + b)^m, sum being XOR."""
    acc = 0
    for a, b in itertools.combinations(S, 2):
        acc ^= powf(a ^ b, m)
    return acc


def cross_ratio(a, b, c, d):
    d1, d2 = a ^ d, b ^ c
    if d1 == 0 or d2 == 0:
        return None
    return mul(mul(a ^ c, b ^ d), inv(mul(d1, d2)))


# ------------------------------------------------------------------ checks
def check_field():
    assert inv(0) == 0
    assert all(mul(a, inv(a)) == 1 for a in range(1, 256))
    bad = [(a, b) for a in range(1, 256) for b in range(1, 256)
           if a != b and (inv(a) ^ inv(b)) != mul(a ^ b, inv(mul(a, b)))]
    print("  [1] difference-of-inverses identity 1/a + 1/b = (a+b)/(ab):"
          f" {len(bad)} counterexamples over all {255*254} ordered pairs")
    return not bad


def check_key_action_group():
    """Proposition 3.1: k -> M_k is an injective homomorphism
    (GF(2^8), xor) -> PGL(2, GF(2^8)), image the unipotent subgroup of order 256."""
    probes = (1, 3, 0x57, 0xC2, 0xFF)
    homo = all(
        normalize(key_action(key_action((u, 1), k2), k1))
        == normalize(key_action((u, 1), k1 ^ k2))
        for k1 in range(256) for k2 in range(256) for u in probes
    )
    orbit = {normalize(key_action((1, 1), k)) for k in range(256)}
    injective = len({normalize(key_action((1, 1), k)) for k in range(256)}) == 256
    print(f"  [2] k -> M_k is a homomorphism from (GF(2^8), xor): {homo}")
    print(f"      injective (generic orbit size): {len(orbit)} of 256 -> {injective}")
    print("      => residual key action is the unipotent subgroup U of order 256,")
    print("         isomorphic to (GF(2^8), xor); NOT AGL(1) (order 65280).")
    return homo and injective


def check_not_a_scaling():
    """Proposition 3.2: g is fractional-linear in e and never a pure scaling."""
    frac_linear = all(
        mul(g_map(e, v0), powf(v0, 2) ^ mul(v0, e)) == e
        for v0 in range(1, 256) for e in range(1, 256)
        if g_map(e, v0) is not INF
    )
    scaling = 0
    for v0 in range(1, 256):
        ratios = {mul(g_map(e, v0), inv(e)) for e in range(1, 256)
                  if g_map(e, v0) is not INF and g_map(e, v0) != 0}
        if len(ratios) == 1:
            scaling += 1
    print(f"  [3] g is fractional-linear in e: {frac_linear}")
    print(f"      base points v0 for which g is a pure scaling: {scaling} of 255")
    print("      => the hypothesis g = s*d + s of the earlier draft is false.")
    return frac_linear and scaling == 0


def check_power_sum_invariants(D):
    """Section 3.4: the P/Q ratio is not invariant; the corrected J = P_m^n/P_n^m
    is invariant for the scaling action but useless or non-invariant for the
    action ARIA actually has."""
    pairs = [(1, 2), (2, 4), (3, 5), (3, 17), (5, 7), (7, 11), (11, 13)]
    print("  [4] power-sum fingerprints (offline difference set: "
          f"{len(D)} elements, seed {SEED})")
    print("      m,  n | P_m/Q_m vals | J vals (scaling) | J vals (true) | J==1 rate")
    rows = []
    for m, n in pairs:
        I = set()
        Jscale = set()
        for s in range(1, 256):
            G = [mul(s, d) for d in D]
            Pm, Pn, Qm = power_sum(G, m), power_sum(G, n), power_sum(D, m)
            if Qm:
                I.add(mul(Pm, inv(Qm)))
            if Pn:
                Jscale.add(mul(powf(Pm, n), inv(powf(Pn, m))))
        Jtrue, trivial, total = set(), 0, 0
        for v0 in range(1, 256):
            G = [g_map(d, v0) for d in D]
            if INF in G:
                continue
            Pm, Pn = power_sum(G, m), power_sum(G, n)
            if Pn == 0:
                continue
            J = mul(powf(Pm, n), inv(powf(Pn, m)))
            Jtrue.add(J)
            total += 1
            trivial += (J == 1)
        print(f"      {m:>2}, {n:>2} | {len(I):>12} | {len(Jscale):>16} |"
              f" {len(Jtrue):>13} | {trivial}/{total}")
        rows.append((m, n, len(I), len(Jscale), len(Jtrue), trivial, total))

    not_invariant = all(r[2] > 1 for r in rows)
    scaling_works = all(r[3] == 1 for r in rows)
    # dichotomy: under the true action, J is either constant 1 or not invariant
    dichotomy = all((r[4] == 1 and r[5] == r[6]) or r[4] > 1 for r in rows)
    print(f"      P_m/Q_m never invariant: {not_invariant}")
    print(f"      J invariant under scaling for every pair: {scaling_works}")
    print(f"      under the true action J is constant-1 or non-invariant: {dichotomy}")
    print("      => no tested exponent pair yields an informative invariant.")
    return not_invariant and scaling_works and dichotomy


def check_cross_ratio(D):
    """Section 3.5: the cross-ratio is invariant under the true action."""
    a, b, c, d = D[0], D[1], D[2], D[3]
    offline = cross_ratio(a, b, c, d)
    vals, poles = set(), 0
    for v0 in range(1, 256):
        img = [g_map(z, v0) for z in (a, b, c, d)]
        if INF in img:
            poles += 1
            continue
        q = cross_ratio(*img)
        if q is not None:
            vals.add(q)
    ok = vals == {offline}
    print(f"  [5] cross-ratio over {255 - poles} pole-free base points:"
          f" {len(vals)} distinct value(s) = {[hex(v) for v in sorted(vals)]}")
    print(f"      offline value: {hex(offline)} -> invariant: {ok}")
    print(f"      base points hitting a pole (e == v0): {poles} of 255")
    return ok


def main():
    random.seed(SEED)
    D = random.sample(range(1, 256), 24)
    print(__doc__.strip().splitlines()[0])
    print(f"Field GF(2^8) mod {hex(MOD)}; seed {SEED}\n")
    results = [
        check_field(),
        check_key_action_group(),
        check_not_a_scaling(),
        check_power_sum_invariants(D),
        check_cross_ratio(D),
    ]
    print(f"\n{sum(results)}/{len(results)} checks passed.")
    return 0 if all(results) else 1


if __name__ == "__main__":
    sys.exit(main())
