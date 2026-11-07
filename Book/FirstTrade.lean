/-
Copyright (c) 2026 Shehzad Hathi. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shehzad Hathi
-/
module

public meta import PairsTrading
public import VersoManual

/-!
# One paired trade

A worked short-spread trade, with checked calculations and an accounting identity.
-/

public section

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Verso.Code.External
open PairsTrading

set_option verso.exampleProject "."
set_option verso.exampleModule "PairsTrading.Trade"

-- Verso documents are introduced by a `#doc` command.
set_option linter.hashCommand false in
#doc (Manual) "One paired trade" =>
%%%
tag := "first-trade"
htmlSplit := .never
%%%

```lean -show
set_option linter.hashCommand false
```

Pairs trading combines positions in two assets. We will short one share of A and buy two
shares of B, expecting A to become cheaper relative to B.
The two shares of B per share of A are our *hedge ratio*. For now, we supply this number.

# Open the trade

A costs 110 and B costs 50, in the same currency.

* Short one A: borrow a share and sell it, receiving 110. We must later buy a share to return.
* Buy two B: pay 100.

Opening the trade leaves 10 in cash. This is not profit: the two B shares are worth 100,
and replacing the borrowed A costs 110. Together with the cash, the position is worth zero.
Real brokers require collateral; this example leaves out margin, fees, financing, and dividends.

# Define the spread

The *spread* subtracts the value of the hedge from A's price:

```anchor spread
def spread (hedgeRatio priceA priceB : ℚ) : ℚ :=
  priceA - hedgeRatio * priceB
```

In Lean, `def` introduces a function. The three arguments and result have type `ℚ`,
the rational numbers. `:=` introduces the function body; multiplication is written `*`.
Rationals keep these calculations exact, including fractional quantities.

Function arguments are separated by spaces. `#eval` evaluates an expression:

```lean (name := openingSpread)
#eval spread 2 110 50
```
```leanOutput openingSpread
10
```

# Close both positions

If A falls to 100 while B stays at 50, we buy back A for 100 and sell the two B shares for 100.
Closing uses no net cash, leaving the opening 10 as profit.

More generally, the short A earns its opening price minus its closing price.
The long B earns the price increase multiplied by the number of shares:

```anchor shortSpreadPnl
def shortSpreadPnl (hedgeRatio entryA entryB exitA exitB : ℚ) : ℚ :=
  (entryA - exitA) + hedgeRatio * (exitB - entryB)
```

Here are four possible outcomes for the same opening trade:

:::table
*
  * Closing A
  * Closing B
  * Closing spread
  * Profit
*
  * 100
  * 50
  * 0
  * 10
*
  * 120
  * 50
  * 20
  * −10
*
  * 130
  * 60
  * 10
  * 0
*
  * 120
  * 60
  * 0
  * 10
:::

```lean (name := outcomes)
#eval [(100, 50), (120, 50), (130, 60), (120, 60)].map
  fun (exitA, exitB) ↦ shortSpreadPnl 2 110 50 exitA exitB
```
```leanOutput outcomes
[10, -10, 0, 10]
```

The square brackets construct a list. `map` applies the function after `fun` to each pair.
In the final outcome both prices rise: the short A loses 10, but the long B gains 20.
What matters for this trade is the change in the spread.

# Prove the accounting identity

For any fixed hedge ratio, profit equals the opening spread minus the closing spread:

```anchor shortSpreadPnl_eq_spread_sub
theorem shortSpreadPnl_eq_spread_sub (hedgeRatio entryA entryB exitA exitB : ℚ) :
    shortSpreadPnl hedgeRatio entryA entryB exitA exitB =
      spread hedgeRatio entryA entryB - spread hedgeRatio exitA exitB := by
  unfold shortSpreadPnl spread
  ring
```

`theorem` states a proposition, and `by` starts its proof.
`unfold` replaces the function names with their definitions; `ring` verifies the algebra.
This proves the accounting identity for all rational inputs, not just our four examples.
It does not tell us whether the spread will shrink. We will investigate that in later lessons.

# Try it

Keep B's closing price at 50 and change A's to 105. Predict the profit, then evaluate
`shortSpreadPnl 2 110 50 105 50` in Lean.
