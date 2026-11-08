/-
Copyright (c) 2026 Shehzad Hathi. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shehzad Hathi
-/
module

public import Book.FirstTrade
public import Book.SmallStrategy
public import Book.TradeOverTime
public import VersoManual

/-!
# Pairs Trading with Lean

The introduction to the companion Verso book.
-/

public section

open Verso.Genre Manual

-- Verso documents are introduced by a `#doc` command.
set_option linter.hashCommand false in
#doc (Manual) "Pairs Trading with Lean" =>
%%%
shortTitle := "Pairs Trading with Lean"
%%%

We'll build a pairs-trading research project in Lean 4, one piece at a time: from the cash flows
of a single trade to statistical models and historical backtests. Along the way, we'll write code,
run examples, and prove a few useful facts.

Imagine two airlines whose shares have tended to move together. One's share price rises much
further than we'd expect from that relationship. A pairs trader might buy the one that's fallen
behind and short the one that's moved ahead, hoping their usual relationship returns.
The challenge is deciding whether the gap is temporary or something has changed.

We'll need a way to measure that gap, choose the size of each position, and decide when to
close the trade. That's the mean-reversion approach we'll explore here.

[Lean](https://lean-lang.org/) is a programming language and a proof assistant.
We can run calculations and also ask Lean to check mathematical arguments about them.
[Mathlib](https://github.com/leanprover-community/mathlib4) gives us a collection of definitions
and theorems to work with.

Some programming and basic algebra are enough to get started. We'll introduce the finance,
statistics, and Lean concepts as we need them.

We won't try to cover all of those subjects, build a production trading platform, or verify
every numerical routine. A proof can establish that a calculation follows our model;
whether the model helps us make money is a separate question.

We begin with a single paired trade and its profit calculation.

{include 1 Book.FirstTrade}

{include 1 Book.TradeOverTime}

{include 1 Book.SmallStrategy}

# Development

See the [repository README](https://github.com/pink-iguana/pairs-trading-with-lean#readme)
for setup, build, and local preview commands.

The library is independent of this book.
Chapters and executable examples will import its definitions.

# License and acknowledgements

Original code and book content are licensed under [Apache-2.0](LICENSE).
Third-party components and datasets retain their own terms.

Inspired by [Pairs Trading with Python](https://github.com/KidQuant/Pairs-Trading-With-Python).
The implementation and explanations here will be written independently.

## Book dependencies

{licenseInfo}
