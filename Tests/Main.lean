/-
Copyright (c) 2026 Shehzad Hathi. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shehzad Hathi
-/
module

import PairsTrading
import Tests.Strategy

/-!
# Paired-trade examples

Check the worked trades, price history, and strategy execution.
-/

/-- Check spreads, profits, and marked values against the worked examples. -/
public def main : IO Unit := do
  let cases : List (ℚ × ℚ × ℚ × ℚ) :=
    [(100, 50, 0, 10), (120, 50, 20, -10), (130, 60, 10, 0), (120, 60, 0, 10)]
  for (exitA, exitB, expectedSpread, expectedPnl) in cases do
    unless PairsTrading.spread 2 exitA exitB == expectedSpread do
      throw <| IO.userError s!"unexpected spread at A={exitA}, B={exitB}"
    unless PairsTrading.shortSpreadPnl 2 110 50 exitA exitB == expectedPnl do
      throw <| IO.userError s!"unexpected profit at A={exitA}, B={exitB}"
  IO.println "Four paired-trade scenarios passed."
  let prices : List (ℚ × ℚ) := [(110, 50), (116, 51), (108, 52), (104, 52)]
  let spreads := prices.map fun (priceA, priceB) ↦ PairsTrading.spread 2 priceA priceB
  unless spreads == [10, 14, 4, 0] do
    throw <| IO.userError "unexpected spreads along the price history"
  let values := prices.map fun (priceA, priceB) ↦ (10 - priceA + 2 * priceB)
  unless values == [0, -4, 6, 10] do
    throw <| IO.userError "unexpected cash-and-holdings values along the price history"
  let profits := prices.map fun (priceA, priceB) ↦
    PairsTrading.shortSpreadPnl 2 110 50 priceA priceB
  unless profits == [0, -4, 6, 10] do
    throw <| IO.userError "unexpected possible closing profits along the price history"
  IO.println "Four price-history observations passed."
  Tests.checkStrategy
