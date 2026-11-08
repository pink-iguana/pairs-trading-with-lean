/-
Copyright (c) 2026 Shehzad Hathi. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shehzad Hathi
-/
module

public import Mathlib.Algebra.BigOperators.Group.List.Basic
public import Mathlib.Algebra.Field.Rat

/-!
# Sample statistics

Exact means, centred observations, and sample covariance for finite rational samples.
Empty samples have no mean; sample covariance needs at least two aligned observations.
-/

@[expose] public section

namespace PairsTrading

/-- The arithmetic mean of a nonempty sample, or `none` for an empty sample. -/
-- ANCHOR: sampleMean?
def sampleMean? (values : List ℚ) : Option ℚ :=
  match values with
  | [] => none
  | _ :: _ => some (values.sum / (values.length : ℚ))
-- ANCHOR_END: sampleMean?

/-- Subtract the sample mean from each observation, or return `none` for an empty sample. -/
-- ANCHOR: center?
def center? (values : List ℚ) : Option (List ℚ) :=
  (sampleMean? values).map fun average ↦
    values.map (fun value ↦ value - average)
-- ANCHOR_END: center?

/-- Whenever centring succeeds, the deviations sum to zero. -/
-- ANCHOR: sum_centered_eq_zero
theorem sum_centered_eq_zero {values deviations : List ℚ}
    (h : center? values = some deviations) : deviations.sum = 0 := by
  cases values with
  | nil => simp [center?, sampleMean?] at h
  | cons value rest =>
    simp only [center?, sampleMean?, Option.map_some, Option.some.injEq] at h
    rw [← h]
    simp only [sub_eq_add_neg, List.sum_map_add, List.map_id', List.map_const',
      List.sum_replicate, nsmul_eq_mul, mul_neg]
    have hlength : ((value :: rest).length : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr (by simp)
    rw [mul_div_cancel₀ _ hlength, add_neg_cancel]
-- ANCHOR_END: sum_centered_eq_zero

/-- Sample covariance with denominator `n - 1`, or `none` for fewer than two observations. -/
-- ANCHOR: sampleCovariance?
def sampleCovariance? (prices : List (ℚ × ℚ)) : Option ℚ :=
  if prices.length < 2 then none else
    match sampleMean? (prices.map Prod.fst), sampleMean? (prices.map Prod.snd) with
    | some meanA, some meanB =>
      some ((prices.map fun (priceA, priceB) ↦
        (priceA - meanA) * (priceB - meanB)).sum / (prices.length - 1 : ℚ))
    | _, _ => none
-- ANCHOR_END: sampleCovariance?

/-- Swapping the two columns leaves sample covariance unchanged. -/
-- ANCHOR: sampleCovariance?_swap
theorem sampleCovariance?_swap (prices : List (ℚ × ℚ)) :
    sampleCovariance? (prices.map Prod.swap) = sampleCovariance? prices := by
  simp only [sampleCovariance?, List.length_map, List.map_map, Function.comp_def,
    Prod.fst_swap, Prod.snd_swap]
  cases sampleMean? (prices.map Prod.fst) <;>
    cases sampleMean? (prices.map Prod.snd) <;> simp [mul_comm]
-- ANCHOR_END: sampleCovariance?_swap

end PairsTrading
