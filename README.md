# Pairs Trading with Lean

A Lean 4 library and companion Verso book about pairs trading. Early development:
the repository currently contains the build skeleton, not trading algorithms.

## Develop

Install [elan](https://github.com/leanprover/elan), then run from this directory:

```sh
lake exe cache get       # Download Mathlib's compiled artifacts on first setup
lake build              # Library
lake test               # Smoke test
lake lint               # Library declaration checks
lake exe book           # Generate the book in _out/html-multi/
lake exe verso-serve _out/html-multi
```

Open the local address printed by the server. Lean is pinned to 4.35.0;
dependency revisions are recorded in `lake-manifest.json`.

Lean code follows [Mathlib's style conventions](https://leanprover-community.github.io/contribute/style.html).
Project warnings are treated as errors. CI runs the build, tests, and lint checks.

The [published book](https://pink-iguana.github.io/pairs-trading-with-lean/)
updates after successful builds on `main`. Pull requests run the same checks.

## Layout

- `PairsTrading.lean`: library entry point; modules will grow under `PairsTrading/`.
- `Book.lean` and `Book/`: Verso introduction and book generator.
- `Tests/`: executable checks. Examples and data will be added when needed.

## License

Original code and documentation: [Apache-2.0](LICENSE).
Dependencies and external data retain their own terms.

Inspired by [Pairs Trading with Python](https://github.com/KidQuant/Pairs-Trading-With-Python).
