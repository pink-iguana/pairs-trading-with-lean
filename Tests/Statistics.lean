/-
Copyright (c) 2026 Shehzad Hathi. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shehzad Hathi
-/
module

import PairsTrading

/-!
# Sample statistics tests

Check means, deviations, and covariance, including empty and constant samples.
-/

open PairsTrading

namespace Tests

/-- Check sample statistics against hand-calculated results. -/
public def checkStatistics : IO Unit := do
  let cases : List (List ℚ × Option ℚ × Option (List ℚ)) :=
    [([], none, none),
      ([50, 51, 55], some 52, some [-2, -1, 3]),
      ([7], some 7, some [0]),
      ([4, 4, 4], some 4, some [0, 0, 0]),
      ([-3, 0, 3], some 0, some [-3, 0, 3]),
      ([50, 51], some (101 / 2), some [-1 / 2, 1 / 2]),
      ([55, 50, 51], some 52, some [3, -2, -1]),
      ([1 / 2, 3 / 2], some 1, some [-1 / 2, 1 / 2]),
      ([60, 61, 65], some 62, some [-2, -1, 3])]
  for (values, expectedMean, expectedDeviations) in cases do
    unless sampleMean? values == expectedMean do
      throw <| IO.userError s!"unexpected mean for {repr values}"
    unless center? values == expectedDeviations do
      throw <| IO.userError s!"unexpected centred observations for {repr values}"
  IO.println "Nine mean and centring scenarios passed."
  -- Covariance requires two aligned observations, including repeated ones.
  let covarianceCases : List (List (ℚ × ℚ) × Option ℚ) :=
    [([], none), ([(110, 50)], none),
      ([(110, 50), (112, 51), (120, 55)], some 14),
      ([(118, 50), (116, 51), (108, 55)], some (-14)),
      ([(110, 50), (110, 51), (110, 55)], some 0),
      ([(110, 50), (112, 50), (120, 50)], some 0),
      ([(0, 0), (1, 1)], some (1 / 2)),
      ([(0, 1), (1, 0), (2, 1)], some 0),
      ([(1, 2), (1, 2)], some 0)]
  for (prices, expected) in covarianceCases do
    unless sampleCovariance? prices == expected do
      throw <| IO.userError s!"unexpected covariance for {repr prices}"
    unless sampleCovariance? (prices.map Prod.swap) == expected do
      throw <| IO.userError s!"unexpected covariance after swapping {repr prices}"
    let shifted := prices.map fun (priceA, priceB) ↦ (priceA + 10, priceB)
    unless sampleCovariance? shifted == expected do
      throw <| IO.userError s!"unexpected covariance after shifting {repr prices}"
  IO.println "Nine covariance scenarios, column swaps, and price shifts passed."

end Tests
