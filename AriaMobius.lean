/-
  AriaMobius.lean

  Formalization accompanying "Transplanting the Mobius Bridge to ARIA"
  (D. Y. Bilar, Chokmah LLC).

  STATUS: building against Lean 4.32.2 / Mathlib v4.32.2. Deliberate open
  obligations are literal `sorry` and listed in Appendix A.5 of the paper;
  nothing is disguised as proved.

  Scope. Algebraic identities are stated over an arbitrary field when that is
  correct. The post-inversion difference form `e / (v^2 + v e)` is the
  characteristic-2 normal form used by ARIA/AES (where `+` is XOR), so those
  theorems take `[CharP F 2]`. Section 6 descends to GF(2^8) only where
  cardinality is used.

  Mathlib pin: see lean-toolchain / lake-manifest.json shipped alongside.
-/

import Mathlib.Algebra.Field.Basic
import Mathlib.Algebra.CharP.Basic
import Mathlib.Algebra.CharP.Two
import Mathlib.Algebra.CharP.Frobenius
import Mathlib.Data.Matrix.Basic
import Mathlib.LinearAlgebra.Matrix.Notation
import Mathlib.LinearAlgebra.Matrix.Determinant.Basic
import Mathlib.FieldTheory.Finite.Basic
import Mathlib.FieldTheory.Finite.GaloisField
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset

open Finset

namespace AriaMobius

/-! ## 1. The difference-of-inverses identity

Paper: proof of Proposition 3.2 (inner identity). Holds in any field. -/

section AnyField
variable {F : Type*} [Field F]

theorem inv_add_inv_eq (a b : F) (ha : a ≠ 0) (hb : b ≠ 0) :
    a⁻¹ + b⁻¹ = (b + a) / (a * b) := by
  field_simp

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
    -- x + k = x * (1 + k * x⁻¹) = x * 0 = 0
    have hxk' : x + k = x * (1 + k * x⁻¹) := by field_simp
    rw [hxk', h, mul_zero]
  field_simp

/-- Matrix representative of `mobiusKey k`, an element of SL(2, F). -/
def U (k : F) : Matrix (Fin 2) (Fin 2) F := !![1, 0; k, 1]

theorem U_det (k : F) : (U k).det = 1 := by
  simp [U, Matrix.det_fin_two_of]

/-- Proposition 3.1, group law: `k ↦ U k` is a homomorphism from `(F, +)`. -/
theorem U_mul (k₁ k₂ : F) : U k₁ * U k₂ = U (k₁ + k₂) := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [U, Matrix.mul_apply, Fin.sum_univ_two]

theorem U_one : U (0 : F) = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [U]

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

end AnyField

/-! ## 3. The post-inversion difference map (Propositions 3.2 and 3.3)

In characteristic 2 (ARIA/AES), `+` is XOR and
`(v+e)⁻¹ + v⁻¹ = e / (v^2 + v e)`. -/

section DiffMap
variable {F : Type*} [Field F] [CharP F 2]

/-- Post-inversion difference of a delta-set element at offset `e` from the
unknown base point `v`. -/
def diffMap (v e : F) : F := (v + e)⁻¹ + v⁻¹

/-- Proposition 3.2: the difference map is fractional-linear in `e`. -/
theorem diffMap_eq (v e : F) (hv : v ≠ 0) (hve : v + e ≠ 0) :
    diffMap v e = e / (v ^ 2 + v * e) := by
  unfold diffMap
  rw [inv_add_inv_eq _ _ hve hv]
  -- (v + (v+e)) / ((v+e)*v) = (2v+e)/(v(v+e)); in char 2, 2v = 0
  have h2v : (2 : F) * v = 0 := by simp [CharTwo.two_eq_zero]
  have hden : v * (v + e) ≠ 0 := mul_ne_zero hv hve
  field_simp
  linear_combination h2v

/-- Denominator `v^2 + v e = v(v+e)` is nonzero under the standing hypotheses. -/
theorem den_ne_zero (v e : F) (hv : v ≠ 0) (hve : v + e ≠ 0) :
    v ^ 2 + v * e ≠ 0 := by
  have : v ^ 2 + v * e = v * (v + e) := by ring
  rw [this]
  exact mul_ne_zero hv hve

/-- Proposition 3.3, the refutation. For any nonzero base point, the difference
map is not a scalar multiplication, provided two suitable offsets exist. -/
theorem diffMap_not_scaling {v : F} (hv : v ≠ 0) {e₁ e₂ : F}
    (hne : e₁ ≠ e₂) (h₁ : e₁ ≠ 0) (h₂ : e₂ ≠ 0)
    (hv₁ : v + e₁ ≠ 0) (hv₂ : v + e₂ ≠ 0) :
    ¬ ∃ s : F, diffMap v e₁ = s * e₁ ∧ diffMap v e₂ = s * e₂ := by
  rintro ⟨s, hs₁, hs₂⟩
  rw [diffMap_eq v e₁ hv hv₁] at hs₁
  rw [diffMap_eq v e₂ hv hv₂] at hs₂
  have d₁ := den_ne_zero v e₁ hv hv₁
  have d₂ := den_ne_zero v e₂ hv hv₂
  -- from e_i / den_i = s * e_i and e_i ≠ 0, get s * den_i = 1
  have k₁ : s * (v ^ 2 + v * e₁) = 1 := by
    apply mul_left_cancel₀ h₁
    calc
      e₁ * (s * (v ^ 2 + v * e₁)) = (s * e₁) * (v ^ 2 + v * e₁) := by ring
      _ = (e₁ / (v ^ 2 + v * e₁)) * (v ^ 2 + v * e₁) := by rw [← hs₁]
      _ = e₁ := by field_simp [d₁]
      _ = e₁ * 1 := by ring
  have k₂ : s * (v ^ 2 + v * e₂) = 1 := by
    apply mul_left_cancel₀ h₂
    calc
      e₂ * (s * (v ^ 2 + v * e₂)) = (s * e₂) * (v ^ 2 + v * e₂) := by ring
      _ = (e₂ / (v ^ 2 + v * e₂)) * (v ^ 2 + v * e₂) := by rw [← hs₂]
      _ = e₂ := by field_simp [d₂]
      _ = e₂ * 1 := by ring
  have hs0 : s ≠ 0 := by
    intro h
    rw [h, zero_mul] at k₁
    exact one_ne_zero k₁.symm
  exact den_not_constant hv hne (mul_left_cancel₀ hs0 (k₁.trans k₂.symm))

end DiffMap

/-! ## 4. Power-sum fingerprints

`P` is indexed by an explicit finite set of representative pairs, one per
unordered pair. This matches `itertools.combinations` in the verification
script, and makes Proposition 3.4 independent of how pairs are enumerated. -/

section PowerSums
variable {F : Type*} [Field F] {ι : Type*}

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

/-- Proposition 3.4: `J` is invariant under the scaling action. -/
theorem J_smul_invariant (T : Finset (ι × ι)) (d : ι → F) (s : F)
    (hs : s ≠ 0) (m n : ℕ) (_hn : P T d n ≠ 0) :
    J T (fun i => s * d i) m n = J T d m n := by
  unfold J
  rw [P_smul, P_smul, mul_pow, mul_pow]
  -- (s^m)^n = s^(m*n) = s^(n*m) = (s^n)^m
  have hpow : (s ^ m) ^ n = (s ^ n) ^ m := by
    simp [← pow_mul, mul_comm m n]
  rw [hpow, mul_div_mul_left _ _ (pow_ne_zero _ (pow_ne_zero _ hs))]

/-- The earlier draft's ratio: it returns the scalar rather than cancelling it. -/
theorem draft_ratio_eq_scalar (T : Finset (ι × ι)) (d : ι → F) (s : F) (m : ℕ)
    (hm : P T d m ≠ 0) :
    P T (fun i => s * d i) m / P T d m = s ^ m := by
  rw [P_smul, mul_div_assoc, div_self hm, mul_one]

/-! ### Characteristic 2: the Frobenius collapse

Explains the constant rows of Table 1 at `(m, 2m)`. -/

variable [CharP F 2]

private theorem sq_add_char_two (a b : F) : (a + b) ^ 2 = a ^ 2 + b ^ 2 := by
  rw [add_sq, two_mul, CharTwo.add_self_eq_zero, zero_mul, add_zero]

private theorem sum_sq_char_two (T : Finset (ι × ι)) (f : ι × ι → F) :
    (∑ p ∈ T, f p) ^ 2 = ∑ p ∈ T, (f p) ^ 2 := by
  classical
  induction T using Finset.induction_on with
  | empty => simp
  | insert p s hps ih =>
    rw [sum_insert hps, sum_insert hps, sq_add_char_two, ih]

theorem P_two_mul (T : Finset (ι × ι)) (d : ι → F) (m : ℕ) :
    P T d (2 * m) = (P T d m) ^ 2 := by
  unfold P
  -- a^(2m) = (a^m)^2
  simp_rw [mul_comm 2 m, pow_mul]
  simpa using (sum_sq_char_two T (fun p => (d p.1 + d p.2) ^ m)).symm

/-- Table 1, rows `(1,2)` and `(2,4)`, as a theorem rather than a computation. -/
theorem J_two_mul_trivial (T : Finset (ι × ι)) (d : ι → F) (m : ℕ)
    (hm : P T d m ≠ 0) :
    J T d m (2 * m) = 1 := by
  unfold J
  rw [P_two_mul]
  -- (P m)^(2m) / ((P m)^2)^m = (P m)^(2m) / (P m)^(2m) = 1
  have : ((P T d m) ^ 2) ^ m = (P T d m) ^ (2 * m) := by
    rw [← pow_mul]
  rw [this]
  exact div_self (pow_ne_zero (2 * m) hm)

end PowerSums

/-! ## 5. Cross-ratio invariance (Proposition 3.6)

The one substantive obligation left open. Classical; bookkeeping over dens. -/

section CrossRatio
variable {F : Type*} [Field F] [CharP F 2]

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

noncomputable instance : Fintype GF256 := Fintype.ofFinite GF256

theorem card_GF256 : Fintype.card GF256 = 256 := by
  rw [← Nat.card_eq_fintype_card]
  simpa using GaloisField.card (p := 2) (n := 8) (by decide)

/-- `x ^ 247 = (x⁻¹) ^ 8`, the relation between ARIA's S2 exponent and
inversion. Uses only `x ^ 255 = 1` on the multiplicative group. -/
theorem pow_247_eq (x : GF256) (hx : x ≠ 0) : x ^ 247 = (x⁻¹) ^ 8 := by
  have h255 : x ^ 255 = 1 := by
    have := FiniteField.pow_card_sub_one_eq_one x hx
    rwa [card_GF256] at this
  have hprod : x ^ 247 * x ^ 8 = 1 := by
    rw [← pow_add]
    exact h255
  -- multiply both sides by (x⁻¹)^8 after rearranging
  have hx8 : x ^ 8 ≠ 0 := pow_ne_zero 8 hx
  calc
    x ^ 247 = x ^ 247 * (x ^ 8 * (x ^ 8)⁻¹) := by field_simp
    _ = (x ^ 247 * x ^ 8) * (x ^ 8)⁻¹ := by ring
    _ = 1 * (x ^ 8)⁻¹ := by rw [hprod]
    _ = (x ^ 8)⁻¹ := by ring
    _ = (x⁻¹) ^ 8 := by simp [inv_pow]

/-- Frobenius at the ARIA exponent is additive, so it conjugates rather than
breaks the maps of Sections 2 and 3. -/
theorem frobenius8_add (x y : GF256) : (x + y) ^ 8 = x ^ 8 + y ^ 8 := by
  -- 8 = 2^3, and iterateFrobenius is a ring hom
  have h := map_add (iterateFrobenius GF256 2 3) x y
  -- iterateFrobenius R p n z = z ^ (p ^ n) = z ^ 8
  simpa [iterateFrobenius_def] using h

end SecondSbox

/-! ## 7. Axiom audit

Expected output: `propext`, `Classical.choice`, `Quot.sound` only (plus
`sorryAx` while Appendix A.5 items remain open). In particular no
`Lean.ofReduceBool`, which `native_decide` would introduce. -/

#print axioms diffMap_not_scaling
#print axioms J_smul_invariant
#print axioms J_two_mul_trivial
#print axioms draft_ratio_eq_scalar
#print axioms pow_247_eq
#print axioms frobenius8_add

end AriaMobius
