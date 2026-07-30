/-
  AriaMobius.lean

  Formalization accompanying "Transplanting the Mobius Bridge to ARIA"
  (D. Y. Bilar, Chokmah LLC).

  STATUS: NOT COMPILED. This file has not been checked by Lean. Tactic blocks
  and Mathlib lemma names require adjustment against a pinned Mathlib. Every
  proof obligation deliberately left open is a literal `sorry` and is listed in
  Appendix A.5 of the paper; nothing is disguised as proved.

  Scope. Sections 1 to 4 are stated over an arbitrary field, or an arbitrary
  field of characteristic 2, and do not mention GF(2^8). This is stronger than
  the paper's computational checks: the obstruction to power-sum fingerprints is
  not an artifact of the ARIA field. Section 5 descends to GF(2^8) only where
  cardinality is used.

  Mathlib pin: see lakefile.lean / lake-manifest.json shipped alongside.
-/

import Mathlib.Algebra.Field.Basic
import Mathlib.Algebra.CharP.Basic
import Mathlib.Algebra.CharP.Frobenius
import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Matrix.Notation
import Mathlib.FieldTheory.Finite.Basic
import Mathlib.FieldTheory.Finite.GaloisField
import Mathlib.Algebra.BigOperators.Basic

open Finset

namespace AriaMobius

/-! ## 1. The difference-of-inverses identity

Paper: proof of Proposition 3.2. Holds in any field; no characteristic
assumption is needed, since the sign that would appear in odd characteristic is
absorbed by writing the numerator as `b + a`. -/

section AnyField
variable {F : Type*} [Field F]

theorem inv_add_inv_eq (a b : F) (ha : a ≠ 0) (hb : b ≠ 0) :
    a⁻¹ + b⁻¹ = (b + a) / (a * b) := by
  field_simp
  ring

/-! ## 2. The residual action of key addition (Proposition 3.1)

`u` is the post-inversion value at key byte zero. Adding `k` before inversion
sends `u` to `u / (1 + k * u)`. -/

/-- The Mobius map induced on post-inversion values by adding the key byte `k`. -/
def mobiusKey (k u : F) : F := u / (1 + k * u)

theorem key_add_inv (x k : F) (hx : x ≠ 0) (hxk : x + k ≠ 0) :
    (x + k)⁻¹ = mobiusKey k x⁻¹ := by
  unfold mobiusKey
  have h1 : 1 + k * x⁻¹ ≠ 0 := by
    intro h
    apply hxk
    field_simp at h
    linear_combination h
  field_simp
  ring

/-- Matrix representative of `mobiusKey k`, an element of SL(2, F). -/
def U (k : F) : Matrix (Fin 2) (Fin 2) F := !![1, 0; k, 1]

theorem U_det (k : F) : (U k).det = 1 := by
  simp [U, Matrix.det_fin_two_of]

/-- Proposition 3.1, group law: `k ↦ U k` is a homomorphism from `(F, +)`. -/
theorem U_mul (k₁ k₂ : F) : U k₁ * U k₂ = U (k₁ + k₂) := by
  simp [U, Matrix.mul_fin_two]
  constructor <;> ring

theorem U_one : U (0 : F) = 1 := by
  simp [U]
  ext i j
  fin_cases i <;> fin_cases j <;> simp [Matrix.one_apply]

/-- Proposition 3.1, injectivity. -/
theorem U_injective : Function.Injective (U : F → Matrix (Fin 2) (Fin 2) F) := by
  intro k₁ k₂ h
  have := congrFun (congrFun h 1) 0
  simpa [U] using this

/-- The core cancellation lemma. Used for both Corollary 3.1.1 and
Proposition 3.3: a ratio of this shape cannot be constant unless the base
point vanishes. This is where the whole obstruction lives. -/
theorem den_not_constant {v : F} (hv : v ≠ 0) {e₁ e₂ : F} (hne : e₁ ≠ e₂)
    (h : v ^ 2 + v * e₁ = v ^ 2 + v * e₂) : False := by
  have : v * e₁ = v * e₂ := by linear_combination h
  exact hne (mul_left_cancel₀ hv this)

/-- Corollary 3.1.1: for `k ≠ 0` the induced map is not affine. Any affine map
agreeing with `mobiusKey k` at `0` has zero translation part, and its linear
part would have to be `(1 + k*u)⁻¹`, which is not constant. -/
theorem mobiusKey_not_affine {k : F} (hk : k ≠ 0)
    (hcard : ∃ a b : F, a ≠ b ∧ a ≠ 0 ∧ b ≠ 0 ∧ 1 + k * a ≠ 0 ∧ 1 + k * b ≠ 0) :
    ¬ ∃ s t : F, ∀ u : F, 1 + k * u ≠ 0 → mobiusKey k u = s * u + t := by
  sorry -- Appendix A.5, item 1

/-! ## 3. The post-inversion difference map (Propositions 3.2 and 3.3) -/

/-- Post-inversion difference of a delta-set element at offset `e` from the
unknown base point `v`. -/
def diffMap (v e : F) : F := (v + e)⁻¹ + v⁻¹

/-- Proposition 3.2: the difference map is fractional-linear in `e`. -/
theorem diffMap_eq (v e : F) (hv : v ≠ 0) (hve : v + e ≠ 0) :
    diffMap v e = e / (v ^ 2 + v * e) := by
  unfold diffMap
  rw [inv_add_inv_eq _ _ hve hv]
  · field_simp
    ring
  
/-- Proposition 3.3, the refutation. Over any field, for any nonzero base point,
the difference map is not a scalar multiplication, provided two suitable offsets
exist. The paper reports 0 of 255 base points for GF(2^8); this says no field
does better. -/
theorem diffMap_not_scaling {v : F} (hv : v ≠ 0) {e₁ e₂ : F}
    (hne : e₁ ≠ e₂) (h₁ : e₁ ≠ 0) (h₂ : e₂ ≠ 0)
    (hv₁ : v + e₁ ≠ 0) (hv₂ : v + e₂ ≠ 0) :
    ¬ ∃ s : F, diffMap v e₁ = s * e₁ ∧ diffMap v e₂ = s * e₂ := by
  rintro ⟨s, hs₁, hs₂⟩
  rw [diffMap_eq v e₁ hv hv₁] at hs₁
  rw [diffMap_eq v e₂ hv hv₂] at hs₂
  have d₁ : v ^ 2 + v * e₁ ≠ 0 := by
    intro h; rw [h, div_zero] at hs₁; exact h₁ (by field_simp at hs₁; tauto)
  have d₂ : v ^ 2 + v * e₂ ≠ 0 := by
    intro h; rw [h, div_zero] at hs₂; exact h₂ (by field_simp at hs₂; tauto)
  -- from each equation, s = (v^2 + v*e_i)⁻¹
  have k₁ : s * (v ^ 2 + v * e₁) = 1 := by
    field_simp at hs₁; linear_combination hs₁ / e₁
  have k₂ : s * (v ^ 2 + v * e₂) = 1 := by
    field_simp at hs₂; linear_combination hs₂ / e₂
  have hs0 : s ≠ 0 := by intro h; rw [h, zero_mul] at k₁; exact one_ne_zero k₁.symm
  exact den_not_constant hv hne (mul_left_cancel₀ hs0 (k₁.trans k₂.symm))

end AnyField

/-! ## 4. Power-sum fingerprints

`P` is indexed by an explicit finite set of representative pairs, one per
unordered pair. This matches `itertools.combinations` in the verification
script, and makes Proposition 3.4 independent of how pairs are enumerated. -/

section PowerSums
variable {F : Type*} [Field F] {ι : Type*} [DecidableEq ι]

/-- Power sum of order `m` over a chosen set of representative pairs. -/
def P (T : Finset (ι × ι)) (d : ι → F) (m : ℕ) : F :=
  ∑ p ∈ T, (d p.1 + d p.2) ^ m

/-- Homogeneity: scaling the data scales the power sum by `s ^ m`. -/
theorem P_smul (T : Finset (ι × ι)) (d : ι → F) (s : F) (m : ℕ) :
    P T (fun i => s * d i) m = s ^ m * P T d m := by
  unfold P
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl ?_
  intro p _
  rw [← mul_add, mul_pow]

/-- The corrected invariant of Proposition 3.4. -/
def J (T : Finset (ι × ι)) (d : ι → F) (m n : ℕ) : F :=
  (P T d m) ^ n / (P T d n) ^ m

/-- Proposition 3.4: `J` is invariant under the scaling action. Note the
hypothesis `P T d n ≠ 0`; the paper records it, and the script skips those
cases. -/
theorem J_smul_invariant (T : Finset (ι × ι)) (d : ι → F) (s : F)
    (hs : s ≠ 0) (m n : ℕ) (hn : P T d n ≠ 0) :
    J T (fun i => s * d i) m n = J T d m n := by
  unfold J
  rw [P_smul, P_smul, ← mul_pow, ← mul_pow]
  rw [mul_pow, mul_pow, ← pow_mul, ← pow_mul]
  rw [mul_comm n m]
  rw [mul_div_mul_left _ _ (pow_ne_zero _ (pow_ne_zero _ hs))]

/-- The earlier draft's ratio, for contrast: it returns the scalar rather than
cancelling it. This is the formal statement of why `P_m / Q_m` fails. -/
theorem draft_ratio_eq_scalar (T : Finset (ι × ι)) (d : ι → F) (s : F) (m : ℕ)
    (hm : P T d m ≠ 0) :
    P T (fun i => s * d i) m / P T d m = s ^ m := by
  rw [P_smul, mul_div_assoc, div_self hm, mul_one]

/-! ### Characteristic 2: the Frobenius collapse

Explains the constant rows of Table 1 at `(m, 2m)`. Squaring is additive, so it
commutes with the sum, giving `P (2m) = (P m) ^ 2` and hence `J m (2m) = 1`
identically: invariant, and vacuous. -/

variable [CharP F 2]

theorem P_two_mul (T : Finset (ι × ι)) (d : ι → F) (m : ℕ) :
    P T d (2 * m) = (P T d m) ^ 2 := by
  unfold P
  rw [← map_sum (frobenius F 2) (fun p => (d p.1 + d p.2) ^ m) T]
  · refine Finset.sum_congr rfl ?_
    intro p _
    simp [frobenius_def, ← pow_mul, mul_comm]
  
/-- Table 1, rows `(1,2)` and `(2,4)`, as a theorem rather than a computation. -/
theorem J_two_mul_trivial (T : Finset (ι × ι)) (d : ι → F) (m : ℕ)
    (hm : P T d m ≠ 0) :
    J T d m (2 * m) = 1 := by
  unfold J
  rw [P_two_mul]
  rw [← pow_mul, ← pow_mul, mul_comm 2 m]
  exact div_self (pow_ne_zero _ hm)

end PowerSums

/-! ## 5. Cross-ratio invariance (Proposition 3.6)

The one substantive obligation left open. Classical over any field; the work is
bookkeeping over the nonvanishing hypotheses. -/

section CrossRatio
variable {F : Type*} [Field F]

def crossRatio (a b c d : F) : F := ((a + c) * (b + d)) / ((a + d) * (b + c))

theorem crossRatio_diffMap_invariant (v : F) (hv : v ≠ 0) (a b c d : F)
    (hnd : ((a + d) * (b + c)) ≠ 0)
    (hva : v + a ≠ 0) (hvb : v + b ≠ 0) (hvc : v + c ≠ 0) (hvd : v + d ≠ 0)
    (hnd' : ((diffMap v a + diffMap v d) * (diffMap v b + diffMap v c)) ≠ 0) :
    crossRatio (diffMap v a) (diffMap v b) (diffMap v c) (diffMap v d)
      = crossRatio a b c d := by
  sorry -- Appendix A.5, item 2

end CrossRatio

/-! ## 6. The second S-box over GF(2^8) (Proposition 4.1)

The only place cardinality is used. -/

section SecondSbox

abbrev GF256 := GaloisField 2 8

theorem card_GF256 : Fintype.card GF256 = 256 := by
  simpa using GaloisField.card 2 8 (by norm_num)

/-- `x ^ 247 = (x⁻¹) ^ 8`, the relation between ARIA's S2 exponent and
inversion. Uses only `x ^ 255 = 1` on the multiplicative group. -/
theorem pow_247_eq (x : GF256) (hx : x ≠ 0) : x ^ 247 = (x⁻¹) ^ 8 := by
  have h255 : x ^ 255 = 1 := by
    have := FiniteField.pow_card_sub_one_eq_one x hx
    rwa [card_GF256] at this
  have : x ^ 247 * x ^ 8 = 1 := by
    rw [← pow_add]; exact h255
  field_simp
  linear_combination this

/-- Frobenius at the ARIA exponent is additive, so it conjugates rather than
breaks the maps of Sections 2 and 3. -/
theorem frobenius8_add (x y : GF256) : (x + y) ^ 8 = x ^ 8 + y ^ 8 := by
  have h := frobenius_add GF256 2
  sorry -- Appendix A.5, item 3: iterate frobenius three times

end SecondSbox

/-! ## 7. Axiom audit

Expected output: `propext`, `Classical.choice`, `Quot.sound` only. In
particular no `Lean.ofReduceBool`, which `native_decide` would introduce. -/

#print axioms diffMap_not_scaling
#print axioms J_smul_invariant
#print axioms J_two_mul_trivial
#print axioms draft_ratio_eq_scalar
#print axioms pow_247_eq

end AriaMobius
