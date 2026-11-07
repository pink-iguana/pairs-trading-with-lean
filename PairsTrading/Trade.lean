/-
Copyright (c) 2026 Shehzad Hathi. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shehzad Hathi
-/
module

public import Mathlib.Algebra.Field.Rat

import Mathlib.Tactic.Ring

/-!
# A paired trade

The spread and profit of a position short one share of A and long a fixed
number of shares of B. Prices are in a common currency; trading costs are omitted.
-/

@[expose] public section

namespace PairsTrading

/-- The price of A less the price of the hedge in B. -/
-- ANCHOR: spread
def spread (hedgeRatio priceA priceB : ℚ) : ℚ :=
  priceA - hedgeRatio * priceB
-- ANCHOR_END: spread

/-- Profit from shorting one share of A and buying `hedgeRatio` shares of B. -/
-- ANCHOR: shortSpreadPnl
def shortSpreadPnl (hedgeRatio entryA entryB exitA exitB : ℚ) : ℚ :=
  (entryA - exitA) + hedgeRatio * (exitB - entryB)
-- ANCHOR_END: shortSpreadPnl

/-- For fixed quantities, a short-spread trade earns the decrease in the spread. -/
-- ANCHOR: shortSpreadPnl_eq_spread_sub
theorem shortSpreadPnl_eq_spread_sub (hedgeRatio entryA entryB exitA exitB : ℚ) :
    shortSpreadPnl hedgeRatio entryA entryB exitA exitB =
      spread hedgeRatio entryA entryB - spread hedgeRatio exitA exitB := by
  unfold shortSpreadPnl spread
  ring
-- ANCHOR_END: shortSpreadPnl_eq_spread_sub

end PairsTrading
