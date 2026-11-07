/-
Copyright (c) 2026 Shehzad Hathi. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shehzad Hathi
-/
module

import PairsTrading

/-!
# Library smoke test

Check the library import and executable test runner.
-/

/-- Smoke test for the library import and executable test runner. -/
public def main : IO Unit := do
  unless (1 : ℚ) / 2 + 1 / 2 == 1 do
    throw <| IO.userError "rational arithmetic smoke test failed"
  IO.println "Library smoke test passed."
