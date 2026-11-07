/-
Copyright (c) 2026 Shehzad Hathi. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shehzad Hathi
-/
module

public import PairsTrading
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

A library and companion book exploring pairs trading in Lean 4.
We will build the pipeline gradually, from a worked trade to statistics and historical backtesting.
All project algorithms will be implemented in Lean, with selected proofs and checked examples.

This is the project skeleton. Trading algorithms and lessons are not implemented yet.

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
