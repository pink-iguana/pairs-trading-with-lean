/-
Copyright (c) 2026 Shehzad Hathi. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shehzad Hathi
-/
module

public import PairsTrading.Trade

/-!
# A small short-spread strategy

Generate threshold signals and fill each order at the next observation.
The position is short one A and long `hedgeRatio` B. Fills use the observed prices
without fees or slippage. Open positions are marked at the final observation.
-/

@[expose] public section

namespace PairsTrading

/-- An instruction to hold, enter, or exit a strategy position. -/
-- ANCHOR: Action
inductive Action where
  | hold
  | enter
  | exit
deriving DecidableEq, BEq, Repr
-- ANCHOR_END: Action

/-- One observation after filling the previous order and generating the next signal. -/
structure Step where
  /-- Current price of A. -/
  priceA : ℚ
  /-- Current price of B. -/
  priceB : ℚ
  /-- Order filled at this observation, or `hold` if no order was pending. -/
  fill : Action
  /-- New signal, to be filled at the next observation if one is available. -/
  signal : Action
  /-- Cash after the fill. -/
  cash : ℚ
  /-- Whether the position is open after the fill. -/
  isOpen : Bool
  /-- Cash plus the marked value of the holdings after the fill. -/
  value : ℚ
deriving DecidableEq, BEq, Repr

/-- Enter at or above the entry threshold; exit an open position at or below the exit threshold. -/
-- ANCHOR: nextShortSpreadSignal
def nextShortSpreadSignal (entryThreshold exitThreshold : ℚ)
    (isOpen : Bool) (currentSpread : ℚ) : Action :=
  if isOpen then
    if currentSpread ≤ exitThreshold then .exit else .hold
  else
    if entryThreshold ≤ currentSpread then .enter else .hold
-- ANCHOR_END: nextShortSpreadSignal

/--
Run the short-spread strategy from zero cash and no holdings, with next-observation fills.
Use a positive hedge ratio and an exit threshold below the entry threshold for the intended
mean-reversion interpretation. The final signal remains unfilled and any open position is marked.
-/
-- ANCHOR: runShortSpreadStrategy
def runShortSpreadStrategy (hedgeRatio entryThreshold exitThreshold : ℚ)
    (prices : List (ℚ × ℚ)) : List Step :=
  go 0 false .hold prices
where
  /-- Process remaining prices with cash, holdings, and the previous observation's order. -/
  go (cash : ℚ) (isOpen : Bool) (pending : Action) :
      List (ℚ × ℚ) → List Step
    | [] => []
    | (priceA, priceB) :: rest =>
      let currentSpread := spread hedgeRatio priceA priceB
      let (cashAfter, openAfter) := match pending with
        | .hold => (cash, isOpen)
        | .enter => (cash + currentSpread, true)
        | .exit => (cash - currentSpread, false)
      let signal := nextShortSpreadSignal entryThreshold exitThreshold openAfter currentSpread
      let value := if openAfter then cashAfter - currentSpread else cashAfter
      { priceA, priceB, fill := pending, signal, cash := cashAfter, isOpen := openAfter, value } ::
        go cashAfter openAfter signal rest
-- ANCHOR_END: runShortSpreadStrategy

/-- Non-anticipation: extending the price history preserves all earlier trace rows. -/
-- ANCHOR: runShortSpreadStrategy_prefix
theorem runShortSpreadStrategy_prefix (hedgeRatio entryThreshold exitThreshold : ℚ)
    (prices future : List (ℚ × ℚ)) :
    (runShortSpreadStrategy hedgeRatio entryThreshold exitThreshold
      (prices ++ future)).take prices.length =
      runShortSpreadStrategy hedgeRatio entryThreshold exitThreshold prices := by
  suffices h : ∀ (cash : ℚ) (isOpen : Bool) (pending : Action),
      (runShortSpreadStrategy.go hedgeRatio entryThreshold exitThreshold cash isOpen pending
        (prices ++ future)).take prices.length =
      runShortSpreadStrategy.go hedgeRatio entryThreshold exitThreshold
        cash isOpen pending prices from
    h 0 false .hold
  induction prices with
  | nil => intros; rfl
  | cons price rest ih =>
    intro cash isOpen pending
    rcases price with ⟨priceA, priceB⟩
    simp only [List.cons_append, List.length_cons, runShortSpreadStrategy.go, List.take_succ_cons]
    congr 1
    apply ih
-- ANCHOR_END: runShortSpreadStrategy_prefix

end PairsTrading
