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
# Fitting a price relationship

Simple linear regression, a fitted hedge ratio, and the role of the intercept.
-/

public section

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Verso.Code.External
open PairsTrading

set_option verso.exampleProject "."
set_option verso.exampleModule "PairsTrading.Regression"

-- Verso documents are introduced by a `#doc` command.
set_option linter.hashCommand false in
#doc (Manual) "Fitting a price relationship" =>
%%%
tag := "regression"
htmlSplit := .never
%%%

We've been buying two B for every A we short. Let's see how we could estimate that ratio
from prices.

We'll fit a line predicting A's price from B's price. The slope will give us a hedge ratio;
the intercept will describe the level around which our spread sits.

# Give the line a direction

Our model is A = intercept + slope × B + residual.
The *residual* is the part of A's observed price that the line doesn't explain.
We choose the slope and intercept to minimise the sum of squared residuals on our observations.
This is *ordinary least squares* with an intercept.

The direction matters. We're predicting A from B. Regressing B on A is a different fit,
and its slope generally isn't the reciprocal of this one.

We'll reuse the three aligned observations from the covariance lesson:

```lean
def trainingPrices : List (ℚ × ℚ) :=
  [(110, 50), (112, 51), (120, 55)]
```

A's mean is 114, B's mean is 52, and their sample covariance is 14.
We also need B's *sample variance*: its covariance with itself.
Instead of multiplying A and B deviations, we square B's deviations:
4, 1, and 9. Their sum is 14, so the variance is 14 / (3 − 1) = 7.
Our `sampleVariance?` function reuses `sampleCovariance?` with each observation paired with itself.

```lean (name := varianceB)
#eval sampleVariance? (trainingPrices.map Prod.snd)
```
```leanOutput varianceB
some 7
```

The fitted slope is covariance divided by B's variance: 14 / 7 = 2.
The intercept puts the line through the two means: 114 − 2 × 52 = 10.
Using an *n* denominator for both covariance and variance would give the same slope;
the common normalisation cancels.

# Store and fit the line

A small record holds the two coefficients:

```anchor LinearFit
structure LinearFit where
  /-- The coefficient multiplying B's price. -/
  slope : ℚ
  /-- The constant offset in A's price. -/
  intercept : ℚ
deriving DecidableEq, BEq, Repr
```

As with our trace records, `fit.slope` and `fit.intercept` access its fields.
The fitting function uses the statistics we already have:

```anchor fitLine?
def fitLine? (prices : List (ℚ × ℚ)) : Option LinearFit := do
  let covariance ← sampleCovariance? prices
  let variance ← sampleVariance? (prices.map Prod.snd)
  if variance = 0 then none else do
    let meanA ← sampleMean? (prices.map Prod.fst)
    let meanB ← sampleMean? (prices.map Prod.snd)
    let slope := covariance / variance
    some ⟨slope, meanA - slope * meanB⟩
```

Here `do` works with `Option`. Each `let ... ← ...` extracts a successful result;
if a calculation returns `none`, the whole fit returns `none`.
A plain `let slope := ...` just names a value.
We need at least two observations and some variation in B to determine a unique slope.

```lean
def fitted : Option LinearFit := fitLine? trainingPrices
```

```lean (name := coefficients)
#eval fitted.map fun fit ↦ (fit.slope, fit.intercept)
```
```leanOutput coefficients
some (2, 10)
```

If every B price is 50, different slopes can be offset by different intercepts.
There isn't a unique answer, so we return `none`:

```lean (name := constantPredictor)
#eval fitLine? [(110, 50), (112, 50)]
```
```leanOutput constantPredictor
none
```

Constant A prices are fine when B varies: the fitted slope is zero and the intercept is A's price.
The fitter also allows negative slopes. Our worked fit happens to have a positive slope,
which gives the short-A, long-B position we've been using.

# Predictions and residuals

These two functions turn the coefficients into a prediction and a gap:

```anchor LinearFit.predict
def LinearFit.predict (fit : LinearFit) (priceB : ℚ) : ℚ :=
  fit.intercept + fit.slope * priceB
```

```anchor LinearFit.residual
def LinearFit.residual (fit : LinearFit) (priceA priceB : ℚ) : ℚ :=
  priceA - fit.predict priceB
```

The `LinearFit.` prefix puts them in the record's namespace, so we can write `fit.predict 52`
and `fit.residual 116 52`. For a later B price of 52, our line predicts A at 114.
If A is actually 116, its residual is 2:

```lean (name := laterResidual)
#eval fitted.map fun fit ↦
  (fit.predict 52, fit.residual 116 52)
```
```leanOutput laterResidual
some (114, 2)
```

Our training prices all lie exactly on A = 10 + 2 × B. That's convenient for checking arithmetic,
but a fitted line needn't pass through every observation. For example:

```lean (name := noisyFit)
#eval (fitLine? [(2, 1), (5, 2), (6, 3)]).map
  fun fit ↦ (fit.slope, fit.intercept)
```
```leanOutput noisyFit
some (2, 1 / 3)
```

This line predicts A = 1/3 + 2 × B. Its residuals are −1/3, 2/3, and −1/3.
Fitting a line doesn't make every gap disappear.

# A hedge ratio isn't an intercept

For our fit, shorting one A and buying two B gives the raw spread A − 2 × B.
The residual subtracts another 10: it is the raw spread minus the intercept.
The intercept is an offset in the model, not an additional holding or a cash payment.

This also affects thresholds. A residual entry level of 2 corresponds to a raw spread of 12;
a residual exit level of 0 corresponds to a raw spread of 10.
Those are the thresholds we'd pass to `runShortSpreadStrategy` with hedge ratio 2.

For a fixed fit, the intercept cancels between entry and exit:

```anchor shortSpreadPnl_eq_residual_sub
theorem LinearFit.shortSpreadPnl_eq_residual_sub (fit : LinearFit)
    (entryA entryB exitA exitB : ℚ) :
    shortSpreadPnl fit.slope entryA entryB exitA exitB =
      fit.residual entryA entryB - fit.residual exitA exitB := by
  rw [shortSpreadPnl_eq_spread_sub]
  simp only [LinearFit.residual, LinearFit.predict, spread]
  ring
```

The first rewrite reuses our original spread-profit theorem.
The `simp only` step expands the residual, prediction, and spread definitions.
Mathlib's `ring` then checks the algebra: subtracting the same intercept at both ends
leaves their difference unchanged. This identity holds for any fixed coefficients;
it doesn't depend on the line being a good fit.

Suppose we enter later at A = 118, B = 53, and close at A = 115, B = 52.
The residual falls from 2 to 1, giving a profit of 1:

```lean (name := fittedProfit)
#eval fitted.map fun fit ↦
  shortSpreadPnl fit.slope 118 53 115 52
```
```leanOutput fittedProfit
some 1
```

We fit on `trainingPrices` first and keep the coefficients fixed for these later observations.
Refitting at entry and exit would use different lines, so the theorem's fixed-fit comparison
would no longer describe that calculation.

# Try it

Add 10 to every A price in the training sample, leaving B alone.
Predict what happens to the fitted slope and intercept, then check them in Lean.

We now have an estimated hedge ratio. Next, we'll work on making gaps comparable across
different levels of spread variability. A fitted relationship alone doesn't establish
that its residuals will revert towards zero.
