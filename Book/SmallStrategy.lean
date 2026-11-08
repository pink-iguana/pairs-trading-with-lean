/-
Copyright (c) 2026 Shehzad Hathi. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shehzad Hathi
-/
module

public import PairsTrading
public meta import PairsTrading
public import VersoManual

/-!
# A small strategy

Threshold signals, next-observation fills, and a worked cash-and-holdings trace.
-/

public section

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Verso.Code.External
open PairsTrading

set_option verso.exampleProject "."
set_option verso.exampleModule "PairsTrading.Strategy"

-- Verso documents are introduced by a `#doc` command.
set_option linter.hashCommand false in
#doc (Manual) "A small strategy" =>
%%%
tag := "small-strategy"
htmlSplit := .never
%%%

```lean -show
set_option linter.hashCommand false
```

So far, we've chosen when to open and close our trade. Let's give that job to a small set of rules.
Our position is short one A and long two B, so we call it a *short-spread* position.
A long-spread position would reverse those holdings. We'll keep just the short-spread direction
and one position at a time in this example.

# Give the strategy a rule

* While flat, signal entry when the spread is 8 or more.
* While holding the position, signal exit when the spread is 2 or less.
* Otherwise, keep things as they are.

These thresholds are chosen for our invented prices. We haven't estimated a fair relationship
or adjusted for the spread's usual variability yet.

Lean can describe the three possible actions with a small type:

```anchor Action
inductive Action where
  | hold
  | enter
  | exit
deriving DecidableEq, BEq, Repr
```

`inductive` introduces a type by listing its cases. Here `.hold` means there is no order;
`.enter` and `.exit` refer to the whole paired position. The `deriving` line supplies equality
checks and a way to display the values.

The rule itself is a function of the thresholds, whether we're holding a position, and the spread:

```anchor nextShortSpreadSignal
def nextShortSpreadSignal (entryThreshold exitThreshold : ℚ)
    (isOpen : Bool) (currentSpread : ℚ) : Action :=
  if isOpen then
    if currentSpread ≤ exitThreshold then .exit else .hold
  else
    if entryThreshold ≤ currentSpread then .enter else .hold
```

`Bool` has the values `true` and `false`.
The outer `if` selects the rule for an open or flat position.
In particular, a large spread while we're already holding doesn't add another trade.

# A signal comes before its fill

Seeing a price and deciding to trade takes us to the next question: what price do we actually get?
We'll use a simple convention. An order generated at one observation fills at the next
observation's prices. We fill the pending order first, then use the new position and current
spread to decide on the next signal. We assume full fills at those prices, with the same
cost omissions as before.

Let's extend the previous price history by one observation:

```lean
def strategyPrices : List (ℚ × ℚ) :=
  [(110, 50), (116, 51), (108, 52), (104, 52), (105, 52)]

def trace : List Step :=
  runShortSpreadStrategy 2 8 2 strategyPrices
```

The first three arguments are the hedge ratio, entry threshold, and exit threshold.
Each `Step` records the prices, fill, new signal, cash, position flag, and total value.
The strategy starts flat, with zero cash and no pending order.

:::table
*
  * Observation
  * Spread
  * Fill
  * New signal
  * Cash
  * A held
  * B held
  * Value
*
  * 0
  * 10
  * —
  * Enter
  * 0
  * 0
  * 0
  * 0
*
  * 1
  * 14
  * Enter
  * —
  * 14
  * −1
  * 2
  * 0
*
  * 2
  * 4
  * —
  * —
  * 14
  * −1
  * 2
  * 10
*
  * 3
  * 0
  * —
  * Exit
  * 14
  * −1
  * 2
  * 14
*
  * 4
  * 1
  * Exit
  * —
  * 13
  * 0
  * 0
  * 13
:::

A dash means `.hold`. Negative holdings mean shares owed.
The entry signal arrives at observation 0, but we sell A at 116 and buy two B at 51
at observation 1. That leaves 14 in cash. At observation 3, the position is worth 14,
but the exit is still pending. The next prices let us close for a net payment of 1,
leaving a realised profit of 13.

Our original profit function agrees when we give it the actual fill prices:

```lean (name := filledProfit)
#eval shortSpreadPnl 2 116 51 105 52
```
```leanOutput filledProfit
13
```

We can check the cash and total value columns directly. `row.cash` accesses a field of the record:

```lean (name := cashAndValue)
#eval trace.map fun row ↦ (row.cash, row.value)
```
```leanOutput cashAndValue
[(0, 0), (14, 0), (14, 10), (14, 14), (13, 13)]
```

Lean can also check the fill and signal columns against the expected sequence:

```lean (name := signalsAndFills)
#eval trace.map (fun row ↦ (row.fill, row.signal)) ==
  [(.hold, .enter), (.enter, .hold), (.hold, .hold),
    (.hold, .exit), (.exit, .hold)]
```
```leanOutput signalsAndFills
true
```

`==` compares the computed list with the expected one.

# Non-anticipation

Once we've processed four observations, adding a fifth should leave those four rows alone,
including their signals, fills, and values. This property is called *non-anticipation*,
or *causality*. In terms of lists, we want *prefix consistency*:
extending the input preserves the output we've already produced.

We can check this for our example by comparing the first four rows of the full trace
with a run on just the first four observations:

```lean (name := prefixCheck)
#eval trace.take 4 ==
  runShortSpreadStrategy 2 8 2 (strategyPrices.take 4)
```
```leanOutput prefixCheck
true
```

The theorem makes the same claim for any two price lists, with the strategy parameters fixed:

```anchor runShortSpreadStrategy_prefix
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
```

`prices ++ future` appends the lists. Taking `prices.length` rows from that longer run
must give exactly the run on `prices` alone. The future list is arbitrary.

The proof follows the recursive simulator:

* `suffices` strengthens the claim to allow any cash balance, position flag, and pending order
  in the helper `go`. After one observation, those values may differ from the initial state.
  Proving this stronger claim lets us specialise it to `0`, `false`, and `.hold`.
* `induction prices` starts with the empty list. Taking zero rows gives an empty list,
  so the two sides agree by definition, which `rfl` checks.
* For a nonempty list, `rcases` splits the first price pair. `simp only` unfolds one step.
  Both runs see the same state and current prices, so they produce the same first row.
  `congr 1` leaves the remaining rows to check, and `apply ih` uses the induction hypothesis
  with the updated state.

This establishes non-anticipation for this simulator's price inputs. It doesn't check how we
chose the hedge ratio or thresholds: estimating them from future data could still leak that
information through a parameter. It also makes no claim about the strategy's profitability.

# When the prices run out

The final signal has no next observation at which to fill. If we're still holding a position,
the trace keeps it open and reports its marked value. That value can be negative if the spread
keeps widening. The entry rule alone gives us no guarantee of convergence.

# Try it

Run the strategy on `strategyPrices.take 4`, which keeps only the first four observations.
Check the final signal, cash, and value. Has the exit actually filled, and are the 14 in cash
now a realised profit?
