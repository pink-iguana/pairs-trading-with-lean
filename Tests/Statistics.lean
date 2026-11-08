/-
Copyright (c) 2026 Shehzad Hathi. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shehzad Hathi
-/
module

import PairsTrading

/-!
# Sample statistics tests

Check exact means and deviations, including empty and constant samples.
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
  IO.println "Nine sample-statistics scenarios passed."

end Tests
