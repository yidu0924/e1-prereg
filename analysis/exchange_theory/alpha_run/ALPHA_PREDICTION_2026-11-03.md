# Third-budget curvature test: result and the derived expectation for chain3 (public record)

Written 2026-11-03 (UTC, see FREEZE_LOG_alpha.txt for the exact time) **before any chain3 validation score was read**: chain3 phase 1 (app ap-Jb8E1QeR47VfD6DQDwGQ7o) was still running and phase 2 had not been launched. Pre-registration: `analysis/exchange_theory/PREREG_third_budget.md` (frozen v0.4; public timestamp commit a8bcbb38, 2026-11-03T01:13:46Z). Raw results are not published; their hash is recorded here.

## Execution
- App `ap-Kb0jxuODOiebojIvQirM3P` (strict-H100 execution copy, Addendum A2), one container (GPU `GPU-030dfe4a-3e9c-1688-04e3-b8ccf6072057`, NVIDIA H100 80GB HBM3, compute capability 9.0); 27/27 runs rc = 0 (run indices 7000–7026), seeds 301–303 in every (state, budget) cell, no attention-kernel fallback, no run dropped by the same-container rule.
- Ledger $12.0868 (cap $15.00; cap not hit). `results.jsonl` sha256 `4e1199dc8382f93f20629dbb61d5cb2d75b0e81cdf54e6dc8d53f33d69f711bc`.
- Frozen analysis script `analyze_alpha.py` sha256 `2783f0f75cf35c67133b35d282e70de53781a694a076c5058046ae3c5456c5d8` (unchanged since the freeze); its output `alpha_output.txt` sha256 `bfb649e4e54b25db507aac5130697b13ec84e06114fb585f7c8aada5f2874800`.

## Pre-registered primary result
| Quantity | Value |
|---|---|
| Shared exponent α̂ (K00 + K01, weighted least squares, step coefficients profiled out) | **0.554** |
| Seed-bootstrap 95% interval (B = 4000) | **[0.528, 0.578]** (√(3/2)-widened, report only: [0.524, 0.584]) |
| Per-state α (95% interval) | K00 0.554 [0.530, 0.580]; K01 0.546 [0.494, 0.598]; K02 (secondary) 0.476 [0.414, 0.536] |
| Heterogeneity label | no (K00 and K01 intervals overlap) |
| **Verdict** (bands fixed in advance: [0.2, 0.5] → "α ≈ 0.3"; [0.7, 1.3] → "α ≈ 1"; otherwise indeterminate) | **indeterminate** — the interval lies above the Chinchilla-type band and below the α ≈ 1 band |

Secondary, report only: sensitivity α = 0.538 (Study-1 short-budget differences from same-machine seed pairs only) and 0.578 (cross-container anchor); β = B_K02/B_K01 = 1.005; anchor offsets between this container and the earlier 281 s runs +0.0010 / −0.0002 / +0.0011 BPB; model exchange rate at α̂: b_pred = 0.0318 [0.0305, 0.0330] against the fitted 0.0215.

## Derived expectation for chain3 (section 5b of PREREG_chain3), fixed now
Using the formula written on 2026-10-09 (`exchange_model.py`, section [8]; reproduced by `chain3_slope_expectation.py`, sha256 `6c77c5d754ac7c61f25d625b9b5d43e2f828e6539a867e93d0ca9a17e8e03d8f`, which reads only Study-1 results and chain3 **design** fields), the expected weighted-least-squares slope of the measured budget sensitivity g on the prediction ĝ = 0.0214·x over the 21 H-dose edits is

| α | expected section-5b slope |
|---|---|
| **0.554 (α̂, this test)** | **1.91** (1.79 at the interval's low end 0.528; 2.02 at the high end 0.578) |
| 0.36 (implied by Study 1; declared 2026-10-09) | 1.19 |
| 0.28–0.37 (literature band) | 0.91–1.22 |
| 1.0 (rival) | 3.92 |

Reading rule (THEORY.md, section 8): a chain3 slope interval that contains about 1.9 and excludes 1.2 and 3.9 favours the in-domain exponent measured here. **Nothing in the frozen chain3 analysis changes**: its verdict rules, the frozen rate b = 0.0214 and the section-5b "calibrated transfer" criterion (slope interval includes 1) stay as registered; this record only fixes, before unblinding, what the one-parameter model expects.
