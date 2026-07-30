/-
  Bridge.lean -- addendum to AriaMobius.lean

  Formalization accompanying "Mobius Bridges for the Invert-and-Affine S-box
  Class" (D. Y. Bilar, Chokmah LLC).

  STATUS: compiled against AriaMobius.lean / Lean 4.32.2 / Mathlib v4.32.2.
  Expect `field_simp` normal-form drift and possible lemma renames around
  `iterateFrobenius` on other pins.

  WHY THIS FILE EXISTS
  --------------------
  AriaMobius.lean proves true statements about the PRE-reciprocal variable:
  `diffMap v e = e / (v^2 + v e)` is fractional-linear and is a scaling for no
  base point (`diffMap_not_scaling`). Both hold. What they do NOT establish is
  that power-sum fingerprints fail, because the working coordinates are the
  RECIPROCAL in the variable `e⁻¹`, where the action is affine. This file
  supplies the missing link and the class generalization.

  Relation to the existing file:
    * `diffMap_eq`, `den_ne_zero`, `inv_add_inv_eq`  -- reused as-is
    * `P`, `J`, `P_smul`, `J_smul_invariant`         -- generalized here from
        the scaling action to the affine action that actually occurs
    * `diffMap_not_scaling`, `crossRatio_*`, `U_*`   -- retained as the geometry
        of the intermediate chart; no longer load-bearing for the fingerprint
    * `frobenius8_add`, `pow_247_eq`                 -- special cases of the
        class results below (j = 3)
-/

import AriaMobius

open Finset

namespace AriaMobius

/-! ## 1. The bridge identity

The step that linearizes the action: reciprocate, and read the result as a
function of `e⁻¹` rather than of `e`. -/

section Bridge
variable {F : Type*} [Field F] [CharP F 2]

/-- **Bridge identity.** `diffMap` is not a scaling (`diffMap_not_scaling`), but
its reciprocal is affine in `e⁻¹`, with multiplier `v^2` and translation `v`. -/
theorem bridge_identity (v e : F) (hv : v ≠ 0) (he : e ≠ 0) (hve : v + e ≠ 0) :
    (diffMap v e)⁻¹ = v ^ 2 * e⁻¹ + v := by
  rw [diffMap_eq v e hv hve, inv_div]
  have hd := den_ne_zero v e hv hve
  field_simp [hd, he, hv]

/-- **Class bridge identity.** Applying `Frob^j` to the inner difference -- which
is what an S-box of the form `L₂ ∘ Frob^j ∘ inv ∘ L₁` does -- preserves the
affine shape and raises both parameters to the `2^j`.

The relation `α = β²` is a property of each instantiation
(`β = t^{2^j}`, `α = β²`), not a bare field identity, so it is not stated as a
separate theorem here. -/
theorem bridge_frobenius (j : ℕ) (v e : F) (hv : v ≠ 0) (he : e ≠ 0)
    (hve : v + e ≠ 0) :
    ((diffMap v e) ^ (2 ^ j))⁻¹
      = v ^ (2 ^ (j + 1)) * (e⁻¹) ^ (2 ^ j) + v ^ (2 ^ j) := by
  rw [← inv_pow, bridge_identity v e hv he hve]
  have hadd : ∀ a b : F, (a + b) ^ (2 ^ j) = a ^ (2 ^ j) + b ^ (2 ^ j) := by
    intro a b
    simpa [iterateFrobenius_def] using map_add (iterateFrobenius F 2 j) a b
  rw [hadd, mul_pow, ← pow_mul]
  congr 2
  rw [pow_succ]
  ring

end Bridge

/-! ## 2. Affine invariance of the power-sum ratio

`AriaMobius.P_smul` covers `v ↦ s * v`. The action that actually occurs is
`v ↦ α * v + β`. The translation cancels inside every pairwise difference, so
the same homogeneity holds -- but that step is what was missing. -/

section AffineInvariance
variable {F : Type*} [Field F] [CharP F 2] {ι : Type*}

/-- Pairwise power sums are blind to the translation and homogeneous in the
multiplier. -/
theorem P_affine (T : Finset (ι × ι)) (d : ι → F) (α β : F) (m : ℕ) :
    P T (fun i => α * d i + β) m = α ^ m * P T d m := by
  unfold P
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl ?_
  intro p _
  have : (α * d p.1 + β) + (α * d p.2 + β) = α * (d p.1 + d p.2) := by
    have hβ : β + β = 0 := CharTwo.add_self_eq_zero β
    calc (α * d p.1 + β) + (α * d p.2 + β)
        = α * d p.1 + α * d p.2 + (β + β) := by ring
      _ = α * d p.1 + α * d p.2 + 0 := by rw [hβ]
      _ = α * (d p.1 + d p.2) := by ring
  rw [this, mul_pow]

/-- **The fingerprint is invariant under the bridge action.** This is the
Nasr-Carlini `I_{m,n}`, stated over an arbitrary field of characteristic 2 and
for the full affine action rather than a scaling. -/
theorem J_affine_invariant (T : Finset (ι × ι)) (d : ι → F) (α β : F)
    (hα : α ≠ 0) (m n : ℕ) (_hn : P T d n ≠ 0) :
    J T (fun i => α * d i + β) m n = J T d m n := by
  unfold J
  rw [P_affine, P_affine, mul_pow, mul_pow]
  have hpow : (α ^ m) ^ n = (α ^ n) ^ m := by
    simp [← pow_mul, mul_comm m n]
  rw [hpow, mul_div_mul_left _ _ (pow_ne_zero _ (pow_ne_zero _ hα))]

end AffineInvariance

/-! ## 3. ARIA's four substitution-layer maps

Each is a member of the class with a specific Frobenius exponent `j`. The affine
maps `L₁, L₂` only relabel which variable is fed in, so the content is the
exponent; `bridge_frobenius` covers all four uniformly. -/

section AriaVariants

/-- Frobenius exponents for ARIA's four substitution-layer maps:
`S1`, `S2`, `S1⁻¹`, `S2⁻¹` use `j = 0, 3, 0, 5` respectively. -/
def aria_exponents : Fin 4 → ℕ
  | 0 => 0  -- S1
  | 1 => 3  -- S2
  | 2 => 0  -- S1⁻¹
  | 3 => 5  -- S2⁻¹

/-- `S2` is `Frobenius^3` of an inverse. Already in `AriaMobius` as
`pow_247_eq`; restated to sit beside its `S2⁻¹` partner. -/
theorem aria_S2_exponent (x : GF256) (hx : x ≠ 0) : x ^ 247 = (x⁻¹) ^ 8 :=
  pow_247_eq x hx

/-- `247 * 223 = 1 (mod 255)`, so `223` inverts the `S2` exponent. -/
theorem aria_S2_exponent_inverse : (247 * 223) % 255 = 1 := by norm_num

/-- `S2⁻¹` is `Frobenius^5` of an inverse: `223 = 255 - 32`. -/
theorem aria_S2inv_exponent (x : GF256) (hx : x ≠ 0) : x ^ 223 = (x⁻¹) ^ 32 := by
  have h255 : x ^ 255 = 1 := by
    have := FiniteField.pow_card_sub_one_eq_one x hx
    rwa [card_GF256] at this
  have hmul : x ^ 223 * x ^ 32 = 1 := by
    rw [← pow_add]; exact h255
  have hx32 : x ^ 32 ≠ 0 := pow_ne_zero 32 hx
  calc
    x ^ 223 = x ^ 223 * (x ^ 32 * (x ^ 32)⁻¹) := by field_simp
    _ = (x ^ 223 * x ^ 32) * (x ^ 32)⁻¹ := by ring
    _ = 1 * (x ^ 32)⁻¹ := by rw [hmul]
    _ = (x ^ 32)⁻¹ := by ring
    _ = (x⁻¹) ^ 32 := by simp [inv_pow]

end AriaVariants

/-! ## 4. Axiom audit -/

#print axioms bridge_identity
#print axioms bridge_frobenius
#print axioms P_affine
#print axioms J_affine_invariant
#print axioms aria_S2inv_exponent

end AriaMobius
