/-
Copyright (c) 2026 Shehzad Hathi. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shehzad Hathi
-/
module

public meta import PairsTrading
public import VersoManual

/-!
# A trade over time

Follow an unchanged position through a price history, distinguishing cash from its total value.
-/

public section

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open PairsTrading

-- Verso documents are introduced by a `#doc` command.
set_option linter.hashCommand false in
#doc (Manual) "A trade over time" =>
%%%
tag := "trade-over-time"
htmlSplit := .never
%%%

```lean -show
set_option linter.hashCommand false
```

Last time we compared opening and closing prices. Now let's watch the same trade while it's open.
We still short one A at 110 and buy two B at 50, leaving 10 in cash.
We keep that cash aside and hold the same quantities until the final observation.
As before, we leave out fees, financing, dividends, and margin requirements.

# A short price history

Here are four observations, in time order. At the last one, we close both positions.

:::table
*
  * Observation
  * A
  * B
  * Spread
  * Value including cash
*
  * Opening
  * 110
  * 50
  * 10
  * 0
*
  * Next
  * 116
  * 51
  * 14
  * −4
*
  * Later
  * 108
  * 52
  * 4
  * 6
*
  * Closing
  * 104
  * 52
  * 0
  * 10
:::

We can store the prices as a list of pairs. The type `ℚ × ℚ` describes a pair of rational numbers;
here, A's price comes first and B's second.

```lean
def prices : List (ℚ × ℚ) :=
  [(110, 50), (116, 51), (108, 52), (104, 52)]
```

Using `map`, we apply the same spread calculation to each observation:

```lean (name := spreads)
#eval prices.map fun (priceA, priceB) ↦
  spread 2 priceA priceB
```
```leanOutput spreads
[10, 14, 4, 0]
```

# Cash and value

Our cash balance stays at 10 while we're holding the trade. The shares change in value, though.
At the second observation, replacing the borrowed A would cost 116, and our two B shares
would sell for 102. Add the cash and the whole position is worth `10 - 116 + 102 = -4`.

Valuing an open position at current prices is called *marking to market*.
For our fixed holdings, the calculation is cash minus one A plus two B:

```lean (name := markedValues)
#eval prices.map fun (priceA, priceB) ↦
  10 - priceA + 2 * priceB
```
```leanOutput markedValues
[0, -4, 6, 10]
```

The −4 is an *unrealised loss*: it's what we'd lose if we closed at those prices.
Later, the position is worth 6, an unrealised gain. These changes haven't added to or taken
away from our cash balance in this example.

# Reuse the profit calculation

We already have a function for profit given opening and closing prices.
We can use each observation as a possible closing point:

```lean (name := possibleProfits)
#eval prices.map fun (priceA, priceB) ↦
  shortSpreadPnl 2 110 50 priceA priceB
```
```leanOutput possibleProfits
[0, -4, 6, 10]
```

These are values of the same continuously held position, not separate trades.
The theorem `shortSpreadPnl_eq_spread_sub` from the first lesson explains the result:
subtract the current spread from the opening spread of 10 to get the profit if we close now.
That identity applies at every observation; we don't need a new proof for the price history.

# Close the trade

At the final observation, we buy back A for 104 and sell the two B shares for 104.
Those cash flows cancel, leaving our 10 in cash and no shares held or owed.
The gain is now *realised*. The closing profit is 10, even though the trade was losing money
at an earlier observation.

We chose the closing point in advance here. Deciding when to enter and exit will be the next step.

# Try it

Change A's second price from 116 to 120, leaving the other observations alone.
Predict the new spread and value at that point, then run the calculations again.
Why does the closing profit stay the same?
