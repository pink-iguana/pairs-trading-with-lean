/-
Copyright (c) 2026 Shehzad Hathi. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shehzad Hathi
-/
module

import PairsTrading

/-!
# Paired-trade examples

Check the four closing scenarios used in the first lesson.
-/

/-- Check spread values and profits against the worked examples. -/
public def main : IO Unit := do
  let cases : List (ℚ × ℚ × ℚ × ℚ) :=
    [(100, 50, 0, 10), (120, 50, 20, -10), (130, 60, 10, 0), (120, 60, 0, 10)]
  for (exitA, exitB, expectedSpread, expectedPnl) in cases do
    unless PairsTrading.spread 2 exitA exitB == expectedSpread do
      throw <| IO.userError s!"unexpected spread at A={exitA}, B={exitB}"
    unless PairsTrading.shortSpreadPnl 2 110 50 exitA exitB == expectedPnl do
      throw <| IO.userError s!"unexpected profit at A={exitA}, B={exitB}"
  IO.println "Four paired-trade scenarios passed."
