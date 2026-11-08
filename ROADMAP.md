# Learning roadmap

For programmers learning Lean, with finance and mathematics introduced as needed.
Develop one small, runnable lesson at a time; keep later stages broad.

## Sequence

| Stage | Status | Result |
|---|---|---|
| One trade | Complete | Exact profit calculations and an accounting proof |
| A trade over time | Complete | Cash, position value, and realised profit along a price history |
| A small strategy | Planned — next | Entry and exit rules on invented data, with signals and fills separated |
| Estimate the relationship | Planned | Means, covariance, regression, and an estimated hedge ratio |
| Build a comparable signal | Planned | Rolling statistics and standardised spreads |
| Investigate convergence | Planned | Synthetic examples, stationarity, and cointegration tests |
| Historical research | Planned | Data loading, pair selection, costs, and out-of-sample evaluation |

Stages may span several short lessons. Update their status as work starts or finishes.

## Next lesson: a small strategy

Review [A trade over time](Book/TradeOverTime.lean), then agree on the strategy rules
before implementing them.

- Use one invented price history, a supplied pair, and a fixed hedge ratio.
- Introduce entry and exit rules, with a trace of signals, fills, cash, and holdings.
- Reuse the spread and valuation calculations from the opening lessons.
- Decide the execution timing and treatment of positions at the end of the history.

The worked trace should have expected values we can check by hand, with a small reader
experiment. Build, tests, lint, and book generation must pass.

## Agreed decisions

- All project algorithms are implemented in Lean.
- Use rationals for the first worked models; introduce floats when numerical statistics need them.
- Build a small strategy before developing the statistical foundations.
- Keep reusable definitions in the library and use checked excerpts in the Verso book.
- Add selected useful proofs, rather than requiring a proof for every component.
- Follow Mathlib conventions and keep the prose conversational and concise.
- No commits or pushes without an explicit request.
