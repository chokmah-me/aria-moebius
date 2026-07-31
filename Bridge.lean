/-
  Bridge.lean -- addendum to AriaMobius.lean

  Formalization accompanying "Mobius Bridges for the Invert-and-Affine S-box
  Class" (D. Y. Bilar, Chokmah LLC).

  STATUS: builds against AriaMobius.lean / Lean 4.32.2 / Mathlib v4.32.2.
  No `sorry`. Axiom set: propext / Classical.choice / Quot.sound only.

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

  Load-bearing theorems (paper map):
    * `bridge_identity` / `bridge_frobenius`  -- inner chart after reciprocal
    * `class_bridge` / `class_bridge'`        -- paper Theorem 3.1 (full L1,L2,j)
    * `J_affine_invariant`                    -- paper Corollary 3.2 (abstract)
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
(`β = t^{2^j}`, `α = β²`), not a bare field identity. -/
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

/-! ## 2. Class S-boxes and Theorem 3.1

An AES/ARIA-style affine layer is a GF(2)-linear bijection plus a constant.
Over an arbitrary field of characteristic 2 that is exactly an additive-group
automorphism `F ≃+ F` plus a constant. Composition with field inversion
(`inv₀`, with `inv₀ 0 = 0`) and a Frobenius power yields the class. -/

section ClassBridge
variable {F : Type*} [Field F] [CharP F 2]

/-- AES/ARIA inversion convention: `inv0 0 = 0`, and `inv0 x = x⁻¹` for `x ≠ 0`. -/
noncomputable def inv0 (x : F) : F := by
  classical
  exact if x = 0 then 0 else x⁻¹

theorem inv0_of_ne {x : F} (hx : x ≠ 0) : inv0 x = x⁻¹ := by
  classical
  simp [inv0, hx]

/-- Affine bijection `x ↦ M x + c` with `M` an additive automorphism. -/
structure AffineBij (F : Type*) [AddCommGroup F] where
  M : F ≃+ F
  c : F

/-- Evaluate an affine bijection. -/
def AffineBij.apply (L : AffineBij F) (x : F) : F :=
  L.M x + L.c

/-- S-box of the form `L₂ ∘ Frobʲ ∘ inv ∘ L₁`. Uses `inv0` so `inv(0) = 0`. -/
noncomputable def classSBox (L1 L2 : AffineBij F) (j : ℕ) (x : F) : F :=
  L2.apply ((inv0 (L1.apply x)) ^ (2 ^ j))

/-- Translation parameter of the bridge action: `β = t^{2ʲ}`. -/
def bridgeBeta (t : F) (j : ℕ) : F := t ^ (2 ^ j)

/-- Multiplier of the bridge action: `α = t^{2^{j+1}} = β²`. -/
def bridgeAlpha (t : F) (j : ℕ) : F := t ^ (2 ^ (j + 1))

/-- Offline multiset element: `D = (e⁻¹)^{2ʲ}`. -/
def bridgeD (e : F) (j : ℕ) : F := (e⁻¹) ^ (2 ^ j)

theorem bridgeAlpha_eq_beta_sq (t : F) (j : ℕ) :
    bridgeAlpha t j = (bridgeBeta t j) ^ 2 := by
  unfold bridgeAlpha bridgeBeta
  rw [pow_succ, pow_mul]

/-- Key-byte addition cancels in characteristic 2. -/
theorem key_cancels (S : F → F) (a₀ aω κ : F) :
    (S a₀ + κ) + (S aω + κ) = S a₀ + S aω := by
  have hκ : κ + κ = 0 := CharTwo.add_self_eq_zero κ
  calc (S a₀ + κ) + (S aω + κ)
      = S a₀ + S aω + (κ + κ) := by ring
    _ = S a₀ + S aω + 0 := by rw [hκ]
    _ = S a₀ + S aω := by ring

/-- Difference of two affine images equals the linear image of the input
difference (characteristic 2 cancels the constants). -/
theorem AffineBij.apply_diff (L : AffineBij F) (x y : F) :
    L.apply x + L.apply y = L.M (x + y) := by
  unfold AffineBij.apply
  have hM : L.M x + L.M y = L.M (x + y) := by
    simp [map_add]
  have hc : L.c + L.c = 0 := CharTwo.add_self_eq_zero L.c
  calc L.M x + L.c + (L.M y + L.c)
      = L.M x + L.M y + (L.c + L.c) := by ring
    _ = L.M (x + y) + (L.c + L.c) := by rw [hM]
    _ = L.M (x + y) + 0 := by rw [hc]
    _ = L.M (x + y) := by ring

/-- Stripping the outer affine: `M₂⁻¹(S(x)+S(y))` is the Frob-powered inv-diff. -/
theorem classSBox_diff_stripped (L1 L2 : AffineBij F) (j : ℕ) (x y : F)
    (_hx : L1.apply x ≠ 0) (_hy : L1.apply y ≠ 0) :
    L2.M.symm (classSBox L1 L2 j x + classSBox L1 L2 j y) =
      (inv0 (L1.apply x) + inv0 (L1.apply y)) ^ (2 ^ j) := by
  unfold classSBox AffineBij.apply
  set u := inv0 (L1.M x + L1.c)
  set v := inv0 (L1.M y + L1.c)
  have hc : L2.c + L2.c = 0 := CharTwo.add_self_eq_zero L2.c
  have hsum :
      (L2.M (u ^ (2 ^ j)) + L2.c) + (L2.M (v ^ (2 ^ j)) + L2.c) =
        L2.M (u ^ (2 ^ j) + v ^ (2 ^ j)) := by
    have hM : L2.M (u ^ (2 ^ j)) + L2.M (v ^ (2 ^ j)) =
        L2.M (u ^ (2 ^ j) + v ^ (2 ^ j)) := by
      simp [map_add]
    calc L2.M (u ^ (2 ^ j)) + L2.c + (L2.M (v ^ (2 ^ j)) + L2.c)
        = L2.M (u ^ (2 ^ j)) + L2.M (v ^ (2 ^ j)) + (L2.c + L2.c) := by ring
      _ = L2.M (u ^ (2 ^ j) + v ^ (2 ^ j)) + (L2.c + L2.c) := by rw [hM]
      _ = L2.M (u ^ (2 ^ j) + v ^ (2 ^ j)) + 0 := by rw [hc]
      _ = L2.M (u ^ (2 ^ j) + v ^ (2 ^ j)) := by ring
  have hFrob : (u + v) ^ (2 ^ j) = u ^ (2 ^ j) + v ^ (2 ^ j) := by
    simpa [iterateFrobenius_def] using map_add (iterateFrobenius F 2 j) u v
  calc L2.M.symm ((L2.M (u ^ (2 ^ j)) + L2.c) + (L2.M (v ^ (2 ^ j)) + L2.c))
      = L2.M.symm (L2.M (u ^ (2 ^ j) + v ^ (2 ^ j))) := by rw [hsum]
    _ = u ^ (2 ^ j) + v ^ (2 ^ j) := by simp
    _ = (u + v) ^ (2 ^ j) := by rw [hFrob]
    _ = (inv0 (L1.M x + L1.c) + inv0 (L1.M y + L1.c)) ^ (2 ^ j) := by
        rfl

/-- **Paper Theorem 3.1 (class bridge).** For every S-box of the form
`L₂ ∘ Frobʲ ∘ inv ∘ L₁`, the reciprocal of the outer-stripped difference is
affine in the offline coordinate `D = (e⁻¹)^{2ʲ}`, with
`β = t^{2ʲ}` and `α = β² = t^{2^{j+1}}`.

Hypotheses match the paper: reference image `t = L₁(s) ≠ 0`, nonzero
difference `d ≠ 0` (so `e = M₁(d) ≠ 0`), and `L₁(s+d) ≠ 0` (bad index). -/
theorem class_bridge (L1 L2 : AffineBij F) (j : ℕ) (s d : F)
    (ht : L1.apply s ≠ 0) (hd : d ≠ 0)
    (hb : L1.apply (s + d) ≠ 0) :
    let t := L1.apply s
    let e := L1.M d
    let g := (L2.M.symm
      (classSBox L1 L2 j s + classSBox L1 L2 j (s + d)))⁻¹
    g = bridgeAlpha t j * bridgeD e j + bridgeBeta t j := by
  intro t e g
  -- e = M1 d; bijective linear part + d ≠ 0 ⇒ e ≠ 0
  have he : e ≠ 0 := by
    intro he0
    apply hd
    -- M d = 0 ⇒ d = M.symm 0 = 0
    have : L1.M d = 0 := he0
    have := congrArg L1.M.symm this
    simpa using this
  -- t + e = L1(s+d): expand apply
  have hte : t + e = L1.apply (s + d) := by
    unfold t e AffineBij.apply
    -- M s + c + M d = M(s+d) + c
    have hM : L1.M s + L1.M d = L1.M (s + d) := by
      simp [map_add]
    calc L1.M s + L1.c + L1.M d
        = L1.M s + L1.M d + L1.c := by ring
      _ = L1.M (s + d) + L1.c := by rw [hM]
  have hve : t + e ≠ 0 := by
    rw [hte]; exact hb
  -- stripped difference = (diffMap t e)^{2^j}
  have hstrip :
      L2.M.symm (classSBox L1 L2 j s + classSBox L1 L2 j (s + d)) =
        (diffMap t e) ^ (2 ^ j) := by
    have h := classSBox_diff_stripped L1 L2 j s (s + d) ht hb
    -- inv0 t + inv0 (t+e) = diffMap t e when both nonzero
    have ht0 : inv0 t = t⁻¹ := inv0_of_ne ht
    have hb0 : inv0 (L1.apply (s + d)) = (L1.apply (s + d))⁻¹ :=
      inv0_of_ne hb
    have hdiff : inv0 t + inv0 (L1.apply (s + d)) = diffMap t e := by
      unfold diffMap
      -- diffMap t e = (t+e)⁻¹ + t⁻¹; strip gives t⁻¹ + (t+e)⁻¹
      rw [ht0, hb0, hte, add_comm]
    rw [h, hdiff]
  -- g = ((diffMap t e)^{2^j})⁻¹
  have hg : g = ((diffMap t e) ^ (2 ^ j))⁻¹ := by
    unfold g; rw [hstrip]
  rw [hg, bridge_frobenius j t e ht he hve]
  unfold bridgeAlpha bridgeD bridgeBeta
  ring

/-- Online fingerprint point after stripping `M₂`: equals the affine image of
the offline coordinate. Restates `class_bridge` without `let` binders. -/
theorem class_bridge' (L1 L2 : AffineBij F) (j : ℕ) (s d : F)
    (ht : L1.apply s ≠ 0) (hd : d ≠ 0)
    (hb : L1.apply (s + d) ≠ 0) :
    (L2.M.symm (classSBox L1 L2 j s + classSBox L1 L2 j (s + d)))⁻¹ =
      bridgeAlpha (L1.apply s) j * bridgeD (L1.M d) j +
        bridgeBeta (L1.apply s) j :=
  class_bridge L1 L2 j s d ht hd hb

/-- Paper form with key byte: \(v = S(a)\oplus\kappa\); κ cancels before the strip. -/
theorem class_bridge_with_key (L1 L2 : AffineBij F) (j : ℕ) (s d κ : F)
    (ht : L1.apply s ≠ 0) (hd : d ≠ 0)
    (hb : L1.apply (s + d) ≠ 0) :
    (L2.M.symm
      ((classSBox L1 L2 j s + κ) + (classSBox L1 L2 j (s + d) + κ)))⁻¹ =
      bridgeAlpha (L1.apply s) j * bridgeD (L1.M d) j +
        bridgeBeta (L1.apply s) j := by
  have hκ := key_cancels (classSBox L1 L2 j) s (s + d) κ
  rw [hκ]
  exact class_bridge' L1 L2 j s d ht hd hb

/-- Frobenius power of an inverse is the inverse of the Frobenius power. -/
theorem inv_pow_two_pow (x : F) (hx : x ≠ 0) (j : ℕ) :
    (x⁻¹) ^ (2 ^ j) = (x ^ (2 ^ j))⁻¹ := by
  simp [inv_pow]

theorem inv0_pow_two_pow (x : F) (hx : x ≠ 0) (j : ℕ) :
    (inv0 x) ^ (2 ^ j) = (x ^ (2 ^ j))⁻¹ := by
  rw [inv0_of_ne hx, inv_pow_two_pow x hx j]

/-- Pairwise difference of online bridge points: the translation `β` cancels. -/
theorem class_bridge_pair_diff (L1 L2 : AffineBij F) (j : ℕ) (s d₁ d₂ : F)
    (ht : L1.apply s ≠ 0)
    (hd₁ : d₁ ≠ 0) (hb₁ : L1.apply (s + d₁) ≠ 0)
    (hd₂ : d₂ ≠ 0) (hb₂ : L1.apply (s + d₂) ≠ 0) :
    let g₁ := (L2.M.symm
      (classSBox L1 L2 j s + classSBox L1 L2 j (s + d₁)))⁻¹
    let g₂ := (L2.M.symm
      (classSBox L1 L2 j s + classSBox L1 L2 j (s + d₂)))⁻¹
    g₁ + g₂ =
      bridgeAlpha (L1.apply s) j *
        (bridgeD (L1.M d₁) j + bridgeD (L1.M d₂) j) := by
  intro g₁ g₂
  have h1 := class_bridge' L1 L2 j s d₁ ht hd₁ hb₁
  have h2 := class_bridge' L1 L2 j s d₂ ht hd₂ hb₂
  have hβ : bridgeBeta (L1.apply s) j + bridgeBeta (L1.apply s) j = 0 :=
    CharTwo.add_self_eq_zero _
  -- g₁ + g₂ = (α D₁ + β) + (α D₂ + β) = α (D₁ + D₂)
  calc g₁ + g₂
      = (bridgeAlpha (L1.apply s) j * bridgeD (L1.M d₁) j +
            bridgeBeta (L1.apply s) j) +
          (bridgeAlpha (L1.apply s) j * bridgeD (L1.M d₂) j +
            bridgeBeta (L1.apply s) j) := by
        rw [show g₁ = _ from h1, show g₂ = _ from h2]
    _ = bridgeAlpha (L1.apply s) j * bridgeD (L1.M d₁) j +
          bridgeAlpha (L1.apply s) j * bridgeD (L1.M d₂) j +
          (bridgeBeta (L1.apply s) j + bridgeBeta (L1.apply s) j) := by ring
    _ = bridgeAlpha (L1.apply s) j * bridgeD (L1.M d₁) j +
          bridgeAlpha (L1.apply s) j * bridgeD (L1.M d₂) j + 0 := by rw [hβ]
    _ = bridgeAlpha (L1.apply s) j *
          (bridgeD (L1.M d₁) j + bridgeD (L1.M d₂) j) := by ring

/-! ### Bad indices (paper §5)

The identity uses a genuine field inverse of `L₁(a_ω)`. Under `inv0 0 = 0`
this fails when `L₁(a_ω) = 0`, i.e. at the unique preimage of zero under `L₁`.
Together with the trivial index `a_ω = s` (difference zero), the bad set is
`{ L1_inv_zero L1, s }`. -/

/-- Unique input with `L₁(z) = 0`. In char 2: `M z + c = 0 ⇒ z = M.symm c`. -/
def L1_inv_zero (L1 : AffineBij F) : F := L1.M.symm L1.c

/-- Paper §5: bad absolute index sits at `L₁⁻¹(0)`. -/
theorem apply_L1_inv_zero (L1 : AffineBij F) :
    L1.apply (L1_inv_zero L1) = 0 := by
  unfold L1_inv_zero AffineBij.apply
  -- M (M.symm c) + c = c + c = 0 in char 2
  have hc : L1.c + L1.c = 0 := CharTwo.add_self_eq_zero L1.c
  calc L1.M (L1.M.symm L1.c) + L1.c
      = L1.c + L1.c := by simp
    _ = 0 := hc

/-- Any root of `L₁` is that unique bad index. -/
theorem eq_L1_inv_zero_of_apply_eq_zero (L1 : AffineBij F) {a : F}
    (ha : L1.apply a = 0) : a = L1_inv_zero L1 := by
  unfold L1_inv_zero AffineBij.apply at *
  -- M a + c = 0 ⇒ M a = c (char 2) ⇒ a = M.symm c
  have hsum : L1.M a + L1.c = 0 := ha
  have hMa : L1.M a = L1.c := by
    calc L1.M a
        = L1.M a + 0 := by ring
      _ = L1.M a + (L1.c + L1.c) := by rw [CharTwo.add_self_eq_zero L1.c]
      _ = (L1.M a + L1.c) + L1.c := by ring
      _ = 0 + L1.c := by rw [hsum]
      _ = L1.c := by ring
  calc a = L1.M.symm (L1.M a) := by simp
    _ = L1.M.symm L1.c := by rw [hMa]

/-- At the bad index the nonzero-image hypothesis of `class_bridge` fails. -/
theorem class_bridge_hyp_fails_at_L1_inv_zero (L1 : AffineBij F) (s : F) :
    L1.apply (s + (L1_inv_zero L1 + s)) = 0 := by
  -- s + (z + s) = z in char 2
  have : s + (L1_inv_zero L1 + s) = L1_inv_zero L1 := by
    calc s + (L1_inv_zero L1 + s)
        = L1_inv_zero L1 + (s + s) := by ring
      _ = L1_inv_zero L1 + 0 := by rw [CharTwo.add_self_eq_zero s]
      _ = L1_inv_zero L1 := by ring
  rw [this, apply_L1_inv_zero]

/-- When `L₁ = id` (linear part refl, constant 0), the bad index is `0`. -/
theorem L1_inv_zero_of_id (L1 : AffineBij F)
    (hM : L1.M = AddEquiv.refl F) (hc : L1.c = 0) :
    L1_inv_zero L1 = 0 := by
  unfold L1_inv_zero
  simp [hM, hc]

/-- Absolute indices that break the bridge hypotheses for reference `s`:
paper §5 set \(\{ L_1^{-1}(0),\ s \}\). -/
def IsBadIndex (L1 : AffineBij F) (s a : F) : Prop :=
  a = L1_inv_zero L1 ∨ a = s

theorem isBadIndex_L1_inv_zero (L1 : AffineBij F) (s : F) :
    IsBadIndex L1 s (L1_inv_zero L1) :=
  Or.inl rfl

theorem isBadIndex_ref (L1 : AffineBij F) (s : F) :
    IsBadIndex L1 s s :=
  Or.inr rfl

/-- If the absolute index is the L₁-root, the class-bridge nonzero-image hyp fails. -/
theorem class_bridge_hyp_fails_of_isBadIndex_root (L1 : AffineBij F) (s a : F)
    (h : a = L1_inv_zero L1) :
    L1.apply a = 0 := by
  rw [h, apply_L1_inv_zero]

/-- Offset `d = 0` is excluded by `class_bridge` (`hd : d ≠ 0`); it is the
case of absolute index equal to the reference `s`. -/
theorem offset_zero_is_ref (s : F) : s + (0 : F) = s := by ring

/-- Finite bad set (classical `DecidableEq` for `Finset` literals). -/
noncomputable def bad_index_set (L1 : AffineBij F) (s : F) : Finset F := by
  classical
  exact ({L1_inv_zero L1, s} : Finset F)

theorem mem_bad_index_set_iff (L1 : AffineBij F) (s a : F) :
    a ∈ bad_index_set L1 s ↔ IsBadIndex L1 s a := by
  classical
  simp [bad_index_set, IsBadIndex, or_comm]

end ClassBridge

/-! ## 3. Affine invariance of the power-sum ratio

`AriaMobius.P_smul` covers `v ↦ s * v`. The action that actually occurs is
`v ↦ α * v + β`. The translation cancels inside every pairwise difference. -/

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

/-- **The fingerprint is invariant under the bridge action.** Nasr–Carlini
`I_{m,n}` over an arbitrary field of characteristic 2 and the full affine action. -/
theorem J_affine_invariant (T : Finset (ι × ι)) (d : ι → F) (α β : F)
    (hα : α ≠ 0) (m n : ℕ) (_hn : P T d n ≠ 0) :
    J T (fun i => α * d i + β) m n = J T d m n := by
  unfold J
  rw [P_affine, P_affine, mul_pow, mul_pow]
  have hpow : (α ^ m) ^ n = (α ^ n) ^ m := by
    simp [← pow_mul, mul_comm m n]
  rw [hpow, mul_div_mul_left _ _ (pow_ne_zero _ (pow_ne_zero _ hα))]

/-- **Paper Corollary 3.2 for the class.** Online fingerprints after stripping
`M₂` equal the offline fingerprint on the multiset `D_i = (M₁(d_i)⁻¹)^{2ʲ}`,
for every delta-set whose offsets avoid the bad indices of §5. -/
theorem J_class_invariant (L1 L2 : AffineBij F) (j : ℕ) (s : F)
    (ht : L1.apply s ≠ 0) (T : Finset (ι × ι)) (d : ι → F)
    (hd : ∀ i, d i ≠ 0) (hb : ∀ i, L1.apply (s + d i) ≠ 0)
    (m n : ℕ)
    (hn : P T (fun i => bridgeD (L1.M (d i)) j) n ≠ 0) :
    J T (fun i =>
        (L2.M.symm
          (classSBox L1 L2 j s + classSBox L1 L2 j (s + d i)))⁻¹)
      m n =
      J T (fun i => bridgeD (L1.M (d i)) j) m n := by
  -- Pointwise: each online g_i is the affine image of offline D_i
  have hg : ∀ i,
      (L2.M.symm
        (classSBox L1 L2 j s + classSBox L1 L2 j (s + d i)))⁻¹ =
        bridgeAlpha (L1.apply s) j * bridgeD (L1.M (d i)) j +
          bridgeBeta (L1.apply s) j := by
    intro i
    exact class_bridge' L1 L2 j s (d i) ht (hd i) (hb i)
  -- Rewrite left-hand J under this pointwise equality
  have hfun :
      (fun i =>
        (L2.M.symm
          (classSBox L1 L2 j s + classSBox L1 L2 j (s + d i)))⁻¹) =
        fun i =>
          bridgeAlpha (L1.apply s) j * bridgeD (L1.M (d i)) j +
            bridgeBeta (L1.apply s) j :=
    funext hg
  rw [hfun]
  -- α = t^{2^{j+1}} ≠ 0 because t ≠ 0
  have hα : bridgeAlpha (L1.apply s) j ≠ 0 :=
    pow_ne_zero _ ht
  exact J_affine_invariant T (fun i => bridgeD (L1.M (d i)) j)
    (bridgeAlpha (L1.apply s) j) (bridgeBeta (L1.apply s) j) hα m n hn

end AffineInvariance

/-! ## 5. ARIA's four substitution-layer maps

Each is a member of the class with a specific Frobenius exponent `j`. -/

section AriaVariants

/-- Frobenius exponents for ARIA's four substitution-layer maps:
`S1`, `S2`, `S1⁻¹`, `S2⁻¹` use `j = 0, 3, 0, 5` respectively. -/
def aria_exponents : Fin 4 → ℕ
  | 0 => 0
  | 1 => 3
  | 2 => 0
  | 3 => 5

theorem aria_S2_exponent (x : GF256) (hx : x ≠ 0) : x ^ 247 = (x⁻¹) ^ 8 :=
  pow_247_eq x hx

theorem aria_S2_exponent_inverse : (247 * 223) % 255 = 1 := by norm_num

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

/-! ## 6. Axiom audit -/

#print axioms bridge_identity
#print axioms bridge_frobenius
#print axioms class_bridge
#print axioms class_bridge'
#print axioms class_bridge_with_key
#print axioms class_bridge_pair_diff
#print axioms apply_L1_inv_zero
#print axioms eq_L1_inv_zero_of_apply_eq_zero
#print axioms mem_bad_index_set_iff
#print axioms J_class_invariant
#print axioms key_cancels
#print axioms P_affine
#print axioms J_affine_invariant
#print axioms aria_S2inv_exponent

end AriaMobius
