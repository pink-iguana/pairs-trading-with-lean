/-
Copyright (c) 2026 Shehzad Hathi. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shehzad Hathi
-/
module

public meta import PairsTrading
public import VersoManual

/-!
# Averages and centred prices

Exact sample means, centred observations, and a zero-sum property.
-/

public section

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Verso.Code.External
open PairsTrading

set_option verso.exampleProject "."
set_option verso.exampleModule "PairsTrading.Statistics"

-- Verso documents are introduced by a `#doc` command.
set_option linter.hashCommand false in
#doc (Manual) "Averages and centred prices" =>
%%%
tag := "means"
htmlSplit := .never
%%%

```lean -show
set_option linter.hashCommand false
```

Our strategy buys two B for every A it shorts. So far, that two has come from us.
How might we estimate a relationship from prices instead?
We'll get there in small steps. First, let's find the average of a few prices and see
how far each price sits above or below it.

# An average needs observations

Here are three prices for B:

```lean
def bPrices : List ℚ := [50, 51, 55]
```

Their arithmetic mean is (50 + 51 + 55) / 3 = 52. Our library wraps that calculation
in a function that also handles an empty sample:

```anchor sampleMean?
def sampleMean? (values : List ℚ) : Option ℚ :=
  match values with
  | [] => none
  | _ :: _ => some (values.sum / (values.length : ℚ))
```

`values.sum` adds the observations and `values.length` counts them.
The count is a natural number; `(values.length : ℚ)` converts it to a rational before division.
The two branches distinguish an empty list from a list with at least one observation.

`Option ℚ` means we return either `some` rational or `none`. An empty sample has no mean;
it shouldn't quietly look like a sample whose mean is zero. The `?` in the name is a convention
for a function that might return no result.

```lean (name := meanPrices)
#eval sampleMean? bPrices
```
```leanOutput meanPrices
some 52
```

```lean (name := emptyMean)
#eval sampleMean? []
```
```leanOutput emptyMean
none
```

Rationals also let us keep fractional answers exactly:

```lean (name := fractionalMean)
#eval sampleMean? [50, 51]
```
```leanOutput fractionalMean
some (101 / 2)
```

# Put the average at zero

To *centre* a sample, subtract its mean from every observation. For our prices, that gives:

:::table
*
  * B price
  * Price minus 52
*
  * 50
  * −2
*
  * 51
  * −1
*
  * 55
  * 3
:::

We keep the order of the prices, but express each one as a deviation from the average:

```anchor center?
def center? (values : List ℚ) : Option (List ℚ) :=
  (sampleMean? values).map fun average ↦
    values.map (fun value ↦ value - average)
```

There are two uses of `map` here. The outer one works on `Option`: if we have a mean,
use it; otherwise, return `none`. The inner one works on the list, subtracting the mean
from each price.

```lean (name := centredPrices)
#eval center? bPrices
```
```leanOutput centredPrices
some [-2, -1, 3]
```

An empty sample cannot be centred around its own mean:

```lean (name := emptyCentre)
#eval center? []
```
```leanOutput emptyCentre
none
```

# The deviations balance out

The negative deviations add up to −3 and the positive one is 3. Together they sum to zero:

```lean (name := centredSum)
#eval (center? bPrices).map List.sum
```
```leanOutput centredSum
some 0
```

This is a property of centring, rather than a lucky choice of prices. Here is the general claim
and its proof:

```anchor sum_centered_eq_zero
theorem sum_centered_eq_zero {values deviations : List ℚ}
    (h : center? values = some deviations) : deviations.sum = 0 := by
  cases values with
  | nil => simp [center?, sampleMean?] at h
  | cons value rest =>
    simp only [center?, sampleMean?, Option.map_some, Option.some.injEq] at h
    rw [← h]
    simp only [sub_eq_add_neg, List.sum_map_add, List.map_id', List.map_const',
      List.sum_replicate, nsmul_eq_mul, mul_neg]
    have hlength : ((value :: rest).length : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr (by simp)
    rw [mul_div_cancel₀ _ hlength, add_neg_cancel]
```

The hypothesis `h` says that centring `values` succeeded and returned `deviations`.
The conclusion says those deviations sum to zero.

The proof splits into empty and nonempty samples with `cases values`.
For the empty sample, `h` would say `none` equals `some deviations`, which is impossible.
For a nonempty sample, we substitute the definition of the deviations using `rw [← h]`.

Mathlib's `List.sum_map_add` distributes the sum over addition, and `List.sum_replicate`
sums a repeated constant. Along with the other simplification rules, they turn the sum of
deviations into the sum of prices minus the count times the mean.
The count is nonzero (`hlength`), so multiplying the mean by the count cancels its denominator.
We are left with a number minus itself.

# Where this fits

We've summarised one column of prices. Next, we'll compare deviations in A and B to describe
how they move together, on the way to estimating our hedge ratio.

Timing still matters. We can calculate this mean once all three prices have arrived.
Using it to make a decision at the first price would use information from the future.
The simulator's non-anticipation theorem doesn't prevent us from supplying such a parameter.

# Try it

Add 10 to each price using `bPrices.map (fun price ↦ price + 10)`.
Before running the code, predict the new mean and centred observations. Which changes?
