/-
Copyright (c) 2026 Shehzad Hathi. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shehzad Hathi
-/
module

public meta import PairsTrading
public import VersoManual

/-!
# How prices move together

Sample covariance on aligned price pairs, with a symmetry proof.
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
#doc (Manual) "How prices move together" =>
%%%
tag := "covariance"
htmlSplit := .never
%%%

We know how to describe one column of prices relative to its average.
Now let's put A and B side by side. When A is above its average, is B usually above its own?
*Covariance* gives us a way to add up that pattern.

# Keep the observations together

We'll reuse B's prices and add an A price at each observation:

```lean
def pairedPrices : List (ℚ × ℚ) :=
  [(110, 50), (112, 51), (120, 55)]
```

Each pair represents prices observed together. Keeping them in pairs makes the alignment
explicit: we can't accidentally pass two columns of different lengths.
Repeated prices still count as separate observations.

```lean (name := columnMeans)
#eval (sampleMean? (pairedPrices.map Prod.fst),
  sampleMean? (pairedPrices.map Prod.snd))
```
```leanOutput columnMeans
(some 114, some 52)
```

`Prod.fst` selects A and `Prod.snd` selects B. Each mean still divides by the number of
observations, three. Subtracting those means gives:

:::table
*
  * A price
  * B price
  * A − 114
  * B − 52
  * Product
*
  * 110
  * 50
  * −4
  * −2
  * 8
*
  * 112
  * 51
  * −2
  * −1
  * 2
*
  * 120
  * 55
  * 6
  * 3
  * 18
:::

Two deviations on the same side of their means give a positive product.
Deviations on opposite sides give a negative product. Here all three products are positive,
and their sum is 28.

# Which denominator?

For this lesson, we'll use *sample covariance*: sum the products of deviations and divide
by one less than the number of observations. Our result is 28 / (3 − 1) = 14.

The means divide by *n*. Sample covariance divides by *n − 1*.
The adjustment accounts for estimating the means from those same observations:
once the first *n − 1* deviations in a column are known, the last is fixed by their zero sum.
Under independent, identically distributed sampling with finite second moments,
this gives an unbiased estimate of population covariance. A price history needn't satisfy
those assumptions; here we're learning the calculation.

Dividing the products by *n* is also useful: it gives the covariance of the empirical
distribution, which gives each observed pair equal weight. We'll stick to *n − 1* in this API.

```anchor sampleCovariance?
def sampleCovariance? (prices : List (ℚ × ℚ)) : Option ℚ :=
  if prices.length < 2 then none else
    match sampleMean? (prices.map Prod.fst), sampleMean? (prices.map Prod.snd) with
    | some meanA, some meanB =>
      some ((prices.map fun (priceA, priceB) ↦
        (priceA - meanA) * (priceB - meanB)).sum / (prices.length - 1 : ℚ))
    | _, _ => none
```

The first check rejects samples with fewer than two observations.
The `match` extracts both means when they are available. We then multiply each pair of
deviations, sum the products, and divide by the rational count minus one.
The result is exact:

```lean (name := positiveCovariance)
#eval sampleCovariance? pairedPrices
```
```leanOutput positiveCovariance
some 14
```

A singleton has a mean, but not a sample covariance with this denominator:

```lean (name := singletonCovariance)
#eval sampleCovariance? [(110, 50)]
```
```leanOutput singletonCovariance
none
```

# Read the sign

In our example, A and B sit above and below their respective means together.
If we reflect A's prices about its mean of 114, the products change sign:

```lean (name := negativeCovariance)
#eval sampleCovariance?
  [(118, 50), (116, 51), (108, 55)]
```
```leanOutput negativeCovariance
some (-14)
```

If A stays constant, every A deviation is zero, so covariance is zero too:

```lean (name := constantCovariance)
#eval sampleCovariance?
  [(110, 50), (110, 51), (110, 55)]
```
```leanOutput constantCovariance
some 0
```

Zero covariance can also arise when positive and negative products cancel.
It doesn't establish independence. The magnitude depends on the units of both columns,
so covariance isn't a standardised measure of how closely they move together.

# Swapping the columns

Covariance treats the two columns symmetrically. Calling B the first column shouldn't
change the answer:

```anchor sampleCovariance?_swap
theorem sampleCovariance?_swap (prices : List (ℚ × ℚ)) :
    sampleCovariance? (prices.map Prod.swap) = sampleCovariance? prices := by
  simp only [sampleCovariance?, List.length_map, List.map_map, Function.comp_def,
    Prod.fst_swap, Prod.snd_swap]
  cases sampleMean? (prices.map Prod.fst) <;>
    cases sampleMean? (prices.map Prod.snd) <;> simp [mul_comm]
```

`Prod.swap` exchanges the two prices in each pair.
The first `simp only` uses existing list and pair lemmas to simplify the swapped columns:
the count stays the same and the two means exchange places.
The `cases` commands consider each mean's `none` and `some` possibilities.
`<;>` applies the following tactic to every resulting goal.
Finally, `simp [mul_comm]` uses the commutativity of multiplication to show that
swapping each product's factors leaves the result unchanged.

This proves the property for every input list, including ones too short to return a covariance.

# What this tells a trader

These three invented pairs have positive covariance. That alone doesn't tell us how much B
to buy against one A, or whether a gap between them will close. Next, we'll fit a line
and connect its slope to the hedge ratio.

As before, this is a summary of observations already available. Estimating it from later
prices and feeding it into earlier decisions would still introduce future information.

# Try it

Add 10 to every A price, leaving B alone:

```lean
def shiftedPrices : List (ℚ × ℚ) :=
  pairedPrices.map fun (priceA, priceB) ↦
    (priceA + 10, priceB)
```

Predict what happens to A's mean and to the covariance. Then check both in Lean.
