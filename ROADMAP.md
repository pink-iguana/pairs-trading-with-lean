# Learning roadmap

For programmers learning Lean, with finance and mathematics introduced as needed.
Develop one small, runnable lesson at a time; keep later stages broad.

## Sequence

| Stage | Status | Result |
|---|---|---|
| One trade | Complete | Exact profit calculations and an accounting proof |
| A trade over time | Planned — next | Cash, position value, and realised profit along a price history |
| A small strategy | Planned | Entry and exit rules on invented data, with signals and fills separated |
| Estimate the relationship | Planned | Means, covariance, regression, and an estimated hedge ratio |
| Build a comparable signal | Planned | Rolling statistics and standardised spreads |
| Investigate convergence | Planned | Synthetic examples, stationarity, and cointegration tests |
| Historical research | Planned | Data loading, pair selection, costs, and out-of-sample evaluation |

Stages may span several short lessons. Update their status as work starts or finishes.

## Next lesson: a trade over time

Continue the first lesson: short one A and buy two B at opening prices 110 and 50.
Reuse the existing spread, profit function, and theorem; no new library API is needed.

| Observation | A | B | Spread | Value including cash |
|---|---:|---:|---:|---:|
| Opening | 110 | 50 | 10 | 0 |
| Next | 116 | 51 | 14 | −4 |
| Later | 108 | 52 | 4 | 6 |
| Closing | 104 | 52 | 0 | 10 |

Explain that cash stays at 10 while the positions are held. Their changing value
produces an unrealised gain or loss; closing leaves 10 in cash and no holdings.
Introduce marking to market using Lean lists and `map`, then add one small reader experiment.
Keep quantities fixed and prices in a common currency; omit trading and financing costs.

Acceptance criteria:

- Checked examples reproduce all four rows, including opening value 0 and closing value 10.
- The explanation distinguishes cash, unrealised profit, and realised profit.
- Library build, tests, lint, and book generation pass; review the rendered lesson.
- Review this lesson before specifying the strategy simulator's rules.

## Agreed decisions

- All project algorithms are implemented in Lean.
- Use rationals for the first worked models; introduce floats when numerical statistics need them.
- Build a small strategy before developing the statistical foundations.
- Keep reusable definitions in the library and use checked excerpts in the Verso book.
- Add selected useful proofs, rather than requiring a proof for every component.
- Follow Mathlib conventions and keep the prose conversational and concise.
- No commits or pushes without an explicit request.
