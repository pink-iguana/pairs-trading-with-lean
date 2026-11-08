# Learning roadmap

For programmers learning Lean, with finance and mathematics introduced as needed.
Develop one small, runnable lesson at a time; keep later stages broad.

## Sequence

| Stage | Status | Result |
|---|---|---|
| One trade | Complete | Exact profit calculations and an accounting proof |
| A trade over time | Complete | Cash, position value, and realised profit along a price history |
| A small strategy | Complete | Entry and exit rules on invented data, with signals and fills separated |
| Estimate the relationship | In progress | Means, covariance, regression, and an estimated hedge ratio |
| Build a comparable signal | Planned | Rolling statistics and standardised spreads |
| Investigate convergence | Planned | Synthetic examples, stationarity, and cointegration tests |
| Historical research | Planned | Data loading, pair selection, costs, and out-of-sample evaluation |

Stages may span several short lessons. Update their status as work starts or finishes.

## Next stage: estimate the relationship

[Averages and centred prices](Book/Means.lean) introduces exact sample means, empty-sample
handling, and a proof that centred observations sum to zero.
[How prices move together](Book/Covariance.lean) adds sample covariance and column symmetry.

- Next: develop simple regression on aligned price pairs.
- Connect the fitted slope to the hedge ratio, keeping the intercept separate from quantities held.
- Choose worked examples and handling of degenerate data before implementing each component.

Keep examples hand-checkable and add one small reader experiment per lesson.
Build, tests, lint, and book generation must pass.

## Agreed decisions

- All project algorithms are implemented in Lean.
- Use rationals for the first worked models; introduce floats when numerical statistics need them.
- Build a small strategy before developing the statistical foundations.
- Means divide by `n`; sample covariance uses `n - 1` and needs at least two observations.
- The worked strategy shorts one A and buys two B: entry at spread ≥ 8, exit at spread ≤ 2.
  Signals fill at the next observation; final signals remain unfilled and open positions are marked.
- The strategy lesson explains non-anticipation through `runShortSpreadStrategy_prefix`,
  including its fixed-parameter scope and proof by induction.
- Keep reusable definitions in the library and use checked excerpts in the Verso book.
- Add selected useful proofs, rather than requiring a proof for every component.
- Reuse Mathlib definitions and lemmas wherever they fit.
- Follow Mathlib conventions and keep the prose conversational and concise.
- No commits or pushes without an explicit request.
