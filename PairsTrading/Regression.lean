/-
Copyright (c) 2026 Shehzad Hathi. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shehzad Hathi
-/
module

public import PairsTrading.Statistics
public import PairsTrading.Trade

import Mathlib.Tactic.Ring

/-!
# A fitted price relationship

Fit A's price as an intercept plus a slope times B's price, using exact rational arithmetic.
-/

@[expose] public section

namespace PairsTrading

/-- A fitted line predicting A's price from B's price. -/
-- ANCHOR: LinearFit
structure LinearFit where
  /-- The coefficient multiplying B's price. -/
  slope : ℚ
  /-- The constant offset in A's price. -/
  intercept : ℚ
deriving DecidableEq, BEq, Repr
-- ANCHOR_END: LinearFit

/-- Predict A's price from B's price using a fitted line. -/
-- ANCHOR: LinearFit.predict
def LinearFit.predict (fit : LinearFit) (priceB : ℚ) : ℚ :=
  fit.intercept + fit.slope * priceB
-- ANCHOR_END: LinearFit.predict

/-- A's observed price minus its predicted price. -/
-- ANCHOR: LinearFit.residual
def LinearFit.residual (fit : LinearFit) (priceA priceB : ℚ) : ℚ :=
  priceA - fit.predict priceB
-- ANCHOR_END: LinearFit.residual

/-- Fit A on B by ordinary least squares with an intercept.
Return `none` for fewer than two observations or constant B prices. -/
-- ANCHOR: fitLine?
def fitLine? (prices : List (ℚ × ℚ)) : Option LinearFit := do
  let covariance ← sampleCovariance? prices
  let variance ← sampleVariance? (prices.map Prod.snd)
  if variance = 0 then none else do
    let meanA ← sampleMean? (prices.map Prod.fst)
    let meanB ← sampleMean? (prices.map Prod.snd)
    let slope := covariance / variance
    some ⟨slope, meanA - slope * meanB⟩
-- ANCHOR_END: fitLine?

/-- With the fitted slope held fixed, short-spread profit equals the decrease in the residual. -/
-- ANCHOR: shortSpreadPnl_eq_residual_sub
theorem LinearFit.shortSpreadPnl_eq_residual_sub (fit : LinearFit)
    (entryA entryB exitA exitB : ℚ) :
    shortSpreadPnl fit.slope entryA entryB exitA exitB =
      fit.residual entryA entryB - fit.residual exitA exitB := by
  rw [shortSpreadPnl_eq_spread_sub]
  simp only [LinearFit.residual, LinearFit.predict, spread]
  ring
-- ANCHOR_END: shortSpreadPnl_eq_residual_sub

end PairsTrading
