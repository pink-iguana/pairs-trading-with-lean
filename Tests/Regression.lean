/-
Copyright (c) 2026 Shehzad Hathi. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shehzad Hathi
-/
module

import PairsTrading

/-!
# Regression tests

Check exact fits, noisy observations, degenerate inputs, and the connection to trade execution.
-/

open PairsTrading

namespace Tests

/-- Check fitted lines and their use as fixed hedge ratios. -/
public def checkRegression : IO Unit := do
  let cases : List (List (ℚ × ℚ) × Option LinearFit) :=
    [([], none), ([(110, 50)], none),
      ([(110, 50), (112, 50)], none),
      ([(110, 50), (110, 50)], none),
      ([(110, 50), (112, 51), (120, 55)], some ⟨2, 10⟩),
      ([(3, 1), (5, 2)], some ⟨2, 1⟩),
      ([(5, 1), (5, 2)], some ⟨0, 5⟩),
      ([(8, 1), (6, 2), (4, 3)], some ⟨-2, 10⟩),
      ([(1, 1), (2, 3)], some ⟨1 / 2, 1 / 2⟩),
      ([(2, 1), (5, 2), (6, 3)], some ⟨2, 1 / 3⟩),
      ([(110, 50), (114, 51), (120, 55)], some ⟨13 / 7, 380 / 21⟩),
      ([(50, 110), (51, 114), (55, 120)], some ⟨39 / 76, -130 / 19⟩)]
  for (prices, expected) in cases do
    unless fitLine? prices == expected do
      throw <| IO.userError s!"unexpected line fit for {repr prices}"
  -- Variance is covariance of a column with itself.
  let varianceCases : List (List ℚ × Option ℚ) :=
    [([], none), ([50], none), ([50, 50], some 0),
      ([50, 51, 55], some 7), ([0, 1], some (1 / 2))]
  for (values, expected) in varianceCases do
    unless sampleVariance? values == expected do
      throw <| IO.userError s!"unexpected variance for {repr values}"
  -- A fitted line need not pass through every observation.
  let some noisy := fitLine? [(2, 1), (5, 2), (6, 3)]
    | throw <| IO.userError "no fit for the noisy example"
  let residuals := [(2, 1), (5, 2), (6, 3)].map fun (a, b) ↦ noisy.residual a b
  unless residuals == [-1 / 3, 2 / 3, -1 / 3] do
    throw <| IO.userError "unexpected residuals for the noisy example"
  -- Fit on earlier observations and hold the coefficients fixed for later prices.
  let some fit := fitLine? [(110, 50), (112, 51), (120, 55)]
    | throw <| IO.userError "no fit for the worked price relationship"
  unless fit.predict 52 == 114 && fit.residual 116 52 == 2 do
    throw <| IO.userError "unexpected prediction or residual for a later observation"
  let laterPrices : List (ℚ × ℚ) := [(116, 52), (118, 53), (114, 52), (115, 52)]
  let trace := runShortSpreadStrategy fit.slope (fit.intercept + 2) fit.intercept laterPrices
  let expected : List (Action × Action × ℚ) :=
    [(.hold, .enter, 0), (.enter, .hold, 0), (.hold, .exit, 2), (.exit, .hold, 1)]
  unless trace.map (fun row ↦ (row.fill, row.signal, row.value)) == expected do
    throw <| IO.userError "unexpected strategy trace using the fitted relationship"
  unless shortSpreadPnl fit.slope 118 53 115 52 == 1 do
    throw <| IO.userError "unexpected profit using the fitted hedge ratio"
  IO.println "Regression fits, variances, residuals, and fitted-strategy checks passed."

end Tests
