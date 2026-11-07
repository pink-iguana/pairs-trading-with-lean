/-
Copyright (c) 2026 Shehzad Hathi. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shehzad Hathi
-/
module

import Book

/-!
# Book generator

Generate the companion book with Verso.
-/

open Verso.Genre Manual

/-- Generate the book, accepting Verso's command-line options. -/
public def main (args : List String) : IO UInt32 :=
  manualMain (%doc Book) (options := args) (config := {
    extraFiles := [("LICENSE", "LICENSE")]
    sourceLink := some "https://github.com/pink-iguana/pairs-trading-with-lean" })
