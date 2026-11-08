/-
Copyright (c) 2026 Shehzad Hathi. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shehzad Hathi
-/
module

import PairsTrading

/-!
# Strategy tests

Check threshold boundaries, next-observation fills, cash accounting, and unfinished trades.
-/

open PairsTrading

namespace Tests

/-- Check the worked trace and the strategy's execution boundaries. -/
public def checkStrategy : IO Unit := do
  let prices : List (ℚ × ℚ) :=
    [(110, 50), (116, 51), (108, 52), (104, 52), (105, 52)]
  let trace := runShortSpreadStrategy 2 8 2 prices
  let actual := trace.map fun row ↦
    (row.fill, row.signal, row.cash, row.isOpen, row.value)
  let expected : List (Action × Action × ℚ × Bool × ℚ) :=
    [(.hold, .enter, 0, false, 0), (.enter, .hold, 14, true, 0),
      (.hold, .hold, 14, true, 10), (.hold, .exit, 14, true, 14),
      (.exit, .hold, 13, false, 13)]
  unless actual == expected do
    throw <| IO.userError "unexpected signal, fill, cash, or value in the worked strategy trace"
  -- The inequalities include their endpoints.
  let boundaries : List (Bool × ℚ × Action) :=
    [(false, 8, .enter), (false, 7, .hold), (false, -5, .hold),
      (true, 2, .exit), (true, 3, .hold), (true, 14, .hold)]
  for (isOpen, currentSpread, expectedSignal) in boundaries do
    unless nextShortSpreadSignal 8 2 isOpen currentSpread == expectedSignal do
      throw <| IO.userError "unexpected threshold boundary signal"
  -- The data can end before either kind of order fills.
  unless (runShortSpreadStrategy 2 8 2 []).isEmpty do
    throw <| IO.userError "empty prices should produce an empty trace"
  unless (runShortSpreadStrategy 2 8 2 (prices.take 1)).map (·.fill) == [.hold] do
    throw <| IO.userError "a final entry signal must remain unfilled"
  let unfinished := runShortSpreadStrategy 2 8 2 (prices.take 4)
  unless unfinished.map (fun row ↦ (row.signal, row.isOpen, row.cash, row.value)) ==
      [(.enter, false, 0, 0), (.hold, true, 14, 0),
        (.hold, true, 14, 10), (.exit, true, 14, 14)] do
    throw <| IO.userError "a final exit signal must leave the position open and marked"
  -- Check adverse moves, repeated entry conditions, and accumulated profits.
  let widening := runShortSpreadStrategy 2 8 2 [(110, 50), (116, 51), (130, 52)]
  unless widening.map (fun row ↦ (row.fill, row.cash, row.value)) ==
      [(.hold, 0, 0), (.enter, 14, 0), (.hold, 14, -12)] do
    throw <| IO.userError "a widening spread should show a marked loss"
  let repeated := runShortSpreadStrategy 2 8 2 [(110, 50), (116, 51), (118, 52), (118, 52)]
  unless repeated.map (fun row ↦ (row.fill, row.cash)) ==
      [(.hold, 0), (.enter, 14), (.hold, 14), (.hold, 14)] do
    throw <| IO.userError "an open position must not accumulate repeated entries"
  let twoTrades := runShortSpreadStrategy 2 8 2
    (prices ++ [(110, 50), (116, 51), (104, 52), (105, 52)])
  unless (twoTrades.map (fun row ↦ (row.cash, row.isOpen, row.value))).getLast? ==
      some (26, false, 26) do
    throw <| IO.userError "completed trades should accumulate their realised profits"
  IO.println "Strategy trace and execution checks passed."

end Tests
