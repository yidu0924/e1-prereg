# 第三预算检验（测曲率 α）—— 预注册 v0.4（已冻结 2026-11-02）

状态：v0.4，2026-11-02（v0.3 按 review_31 修订：缺失 vm 的同容器规则、干跑行带 vm、guard 容错、账单与费率措辞；v0.2 按 review_30 修订：α-F1–F6），在 DRAFT v0.1（`PREREG_third_budget_DRAFT.md`，2026-10-09，review_29 A4）基础上补齐执行层与分析代码。**已冻结（2026-11-02，America/Detroit；用户同意记录见 §8），未发射。** 冻结 = 把本文件、`alpha_run/` 下的 manifest、wrapper、分析脚本、干跑输出与冻结 runner 的 sha256 写入 `alpha_run/FREEZE_LOG_alpha.txt`；冻结前需 Fable 复核和用户同意。写于任何 600 s 运行之前：此前唯一的第三预算数据是 H′ pilot 的 300 s 单种子（已在 exchange_model 第 (c) 节判为无信息），不用于本检验。

## 1. 目的
H′ 的两个预算只识别每个状态的罚分 Δ，不识别曲率 α（THEORY.md 第 3 节）。在同一配置上加一个更长的预算，直接测 α，让汇率模型 b = α·Δ_P 变成没有自由参数的领域内预测。必须在 chain3 揭盲之前完成，并与 chain3 的注册一起公开时间戳。

## 2. 设计（与 v0.1 相同）
- 状态（H′ 冻结 commit）：**K00**（根，d512，TBS 2^19）、**K01**（批量减半）为核心；**K02**（加深到 d640）为附加项，用来估 β。
- 臂（H100，原生 DBS，冻结 runner `transfer/hprime/run_transfer.py` 原样使用，只改种子与 TIME_BUDGET）：主臂 600 s × 种子 301–303；锚点 281 s × 种子 301–303，**同一容器**；60 s × 3 种子只作探索，不进判决。
- 顺序（`make_manifest_alpha.py` 写死，也是截断顺序）：核心（每个种子内 K00、K01 各自 600 s 然后 281 s）→ K02（同样模式）→ 60 s 探索臂。run 索引 7000–7026，与已有全部索引不相交。

## 3. 估计量与判决（`alpha_run/analyze_alpha.py`，冻结）
- 幂律 L(S) = L∞ + B_X·S^(−α)。每个状态两个差值：Δ_long = L(281) − L(600)（本检验，**同一容器**，按 GPU UUID 逐种子配对核对；没有 vm 字段的行一律不算同容器，review_31）；Δ_short = L(120) − L(281)（H′，`results_all.jsonl` 臂 2 与臂 1）。
- **H′ 的种子分布在三台 VM 上**（review_30 α-F1：K00 种子 302、K01 种子 303 两臂不同机），所以 Δ_short 不是容器内差值。H′ 的 val 先按 H′ 冻结主估计量的同一机器固定效应模型校正（状态×臂固定效应 + VM 哑变量，全部 H′ H100 臂 1/2 行；偏移当常数，bootstrap 不重估；7baa 相对 7146 约 +0.0030），再算 Δ_short。只用同机种子对、不校正的版本作敏感性报告。
  - 对 v0.1 的澄清：v0.1 的"H′ 的 L(281)、L(120) 同时平移 ±0.003"对这个估计量不起作用（两者同移，Δ_short 不变），由上面的机器校正与以下两项替代：锚点偏移 L281_new − L281_H′，以及"跨容器"敏感性估计（Δ_long 用 L281_H′ − L600_new）。都只报告，不进判决。
- 主估计：K00、K01 共享 α、各自 B，对四个 Δ 做加权最小二乘（权重 1/SE²，SE 由种子算），B 逐状态解析消去，α 在 0.02–2.50 网格（步长 0.002）上取最小。95% CI：种子 bootstrap（每个 (状态, 预算, 容器) 格子内有放回重抽，4000 次，种子 20261023），百分位区间。
- **判决（写死，与 v0.1 相同）**：CI ⊂ [0.2, 0.5] → "与文献带一致，α ≈ 0.3"；CI ⊂ [0.7, 1.3] → "α ≈ 1"；其他 → 不定。主估计需要 K00、K01 都可评估，缺一则主判决为"不可评估"，其余状态的 α 只作次要报告（α-F4）。
- **状态一致性（α-F2，写死）**：K00、K01 各自的 α 与种子 bootstrap 95% CI 一并报告；**两个 CI 不相交 → 判决加 "heterogeneous" 标签**，正文只能报告两个单状态值，不报告共享 α。
- **CI 覆盖率披露（α-F3）**：每格 n = 3 时百分位 bootstrap 的实际覆盖率约 0.90（review_30 模拟），不是 0.95。判决规则不改；另报一个放大 √(3/2) 的区间（只报告）。
- 次要（只报告）：K00、K01、K02 各自的 α；β = B_K02 / B_K01（在 α̂ 处，用 Δ_long）；b_pred(α̂)（`outputs/exchange_model.json` 的 b_pred_curve 线性插值）对 b_fit = 0.0215；600 s 运行的 token 用量相对已预置的训练集；60 s 探索臂的水平。
- **对 chain3 的衍生预测**：拿到 α̂ 后、chain3 揭盲前，按 `exchange_model.py` 第 [8] 节的同一公式算出 chain3 §5b 斜率的预期，写入 FREEZE_LOG_alpha 并公开提交。chain3 的冻结判决与 b = 0.0214 不变。

## 4. 合成干跑（`alpha_run/dryrun_alpha.py` → `dryrun_alpha_output.txt`，作者先验）
以机器校正后的 H′ K00–K02 水平为底，种子噪声 SD 0.001，新容器偏移 U(−0.003, 0.003)，每种情形 40 个数据集（bootstrap 400 次）：
- 真 α = 0.33：α̂ 均值 0.333（SD 0.017），CI 中位宽度 0.076，判决 100% 为"α ≈ 0.3"，其中 2.5% 误加 heterogeneous 标签；
- 真 α = 1：α̂ 均值 1.002（SD 0.031），CI 中位宽度 0.125，判决 100% 为"α ≈ 1"，2.5% 误加标签；
- K00 = 0.25、K01 = 0.45（状态不一致）：100% 加 heterogeneous 标签（87.5% 共享判决为"α ≈ 0.3"，12.5% 不定）。
真实数据中幂律可能不成立（例如 600 s 跨过数据重复或学习率调度的影响），这种情况会表现为三个状态的 α 不一致或 CI 落在两个判决带之外，按"不定"处理。

## 5. 数据量（v0.1 第 4 节，执行方式写死）
- 600 s 需要约 0.65–0.99 B token，Volume 上 H′ 的 10 个训练 shard 只有约 0.63 B。
- 执行：CPU 容器（`modal_alpha.py --mode stage`）把 H′ 镜像 `/vol/cache_mirror`（只读）复制到本地，再运行 `prepare.py --num-shards 24` 下载 shard_00010–00023（tokenizer 已在，不会重训），核对 25 个 parquet + tokenizer、原有 10 个 shard 的 md5 不变，记录全部 md5（`/vol/alpha/e1t/shards_md5.txt`），复制到新镜像 `/vol/cache_mirror_alpha`（COMPLETE 标记最后写）。H100 容器只从新镜像恢复。
- dataloader 按文件名顺序读训练 shard，新增 shard 排在原有 10 个之后，所以 281 s 运行（最多 0.47 B token）看到的数据与 H′ 相同。600 s 运行的 token 用量由分析脚本对照约 1.5 B 的预置量报告。

## 6. 费用与守卫
- H100 $3.95 + CPU $0.38 = $4.33/h（发射前 `modal billing rates` 核对，不符则中止）。H′ 实测墙钟：281 s 运行约 320 s，120 s 运行约 160 s；600 s 运行估计约 640 s。
- 估算：核心 6 对约 1.6 h，K02 约 0.8 h，60 s 臂约 0.25 h，准备约 0.2 h，合计约 2.9 GPU-h ≈ **$12.5**；加 CPU 准备约 $0.2。
- **账本上限 $15**（准备 + 主运行合计，每个 GPU 容器启动计 $0.5，CPU 计 $0.1），到达即停，按第 2 节顺序从后往前截断。
- 资金：用户 2026-10-23 决定自付（与 chain3 修正 A1 同一决定）。2026-11-02 只读 `modal billing summary --json`：本月 metered = 0、billed = 0、credits = 0；**不能据此声称存在 $30 免费额度**。发射前再次只读查询，输出原样写入 FREEZE_LOG_alpha。费率（2026-11-02 `modal billing rates`）：H100 $3.95/h，4 CPU + 24 GiB $0.3812/h，合计 $4.3312/h（wrapper 按 $4.33 记账）。**$15 是本实验的账本上限（stage + main），不是账户总费用的硬封顶**：同账号同期还有 chain3 两期各 $20 的账本，三者合计 $55 的上限只约束实验账本。
- 中断：runner 会跳过已有 rc = 0 的行，中断后在新容器 resume（新容器 = 新 VM）。600 s 与 281 s 不在同一 VM 的 (状态, 种子) 对被剔除（没有 vm 字段的行也按不同容器处理），冻结 runner 无法补跑同一对；某状态剩不足 2 个同机种子则该状态不可评估，K00 或 K01 不可评估则主判决为"不可评估"（review_30 NOTE-2，接受这一代价）。
- 与 chain3 可以同时运行：不同的 Volume 目录、账本与锁，H′ 镜像只读；每个发射各有自己的 guard（`alpha_run/guard_app.sh`），只停自己记录下的 app id，各用自己的工作目录（review_30 α-B1）；guard 的下载失败、文件解析失败、`modal app list` 失败只记 WARN、不停 app，停机规则只在连续正常周期上计数（review_31）。
- 发射清单（α-F5/F6）：(1) 三个 SHA 可达且 train.py md5 一致；(2) 上传三份冻结文件后 `modal volume ls e1-hprime-vol /alpha` 核对；(3) `modal run --detach modal_alpha.py --mode stage`，看到 STAGE PASS 且 `/cache_mirror_alpha/COMPLETE.json` 存在；(4) `modal run --detach modal_alpha.py --mode main`，记下 app id，启动 guard；(5) α̂ 与 chain3 斜率预期公开提交之前，不运行 `analyze_chain3.py`。

## 7. 冻结清单
`PREREG_third_budget.md`、`alpha_run/make_manifest_alpha.py`、`alpha_run/manifest_alpha.json`、`alpha_run/modal_alpha.py`、`alpha_run/analyze_alpha.py`、`alpha_run/dryrun_alpha.py` 与其输出、`alpha_run/selftest_alpha.py`、`alpha_run/guard_app.sh`（执行层）、`transfer/hprime/run_transfer.py`（冻结 runner，不改）。冻结前置条件：Fable 复核（review_31 已复核 v0.4 的执行层）＋ 用户同意金额；冻结动作（写 FREEZE_LOG_alpha.txt）由用户或用户明确授权后执行。

## 8. 用户同意记录（2026-11-02）
- 日期：2026-11-02（America/Detroit）；记录时间 UTC 2026-11-03T01:10:46Z。
- 用户原话（经 Codex 协调消息 E1-LAUNCH-20261102 转达，非手写签名）："同意，两项都跑，三个实验账本上限合计55美元，用新建公开 GitHub 仓库存证，完成预注册后发射，继续让 Fable max 推进。"
- 对应的承诺：本实验账本上限 $15（stage + main），预期 ≈ $13，自付；与 chain3 两期各 $20 的账本合计 $55（只约束实验账本）。
- 冻结：本文件与 §7 清单的 sha256 写入 `alpha_run/FREEZE_LOG_alpha.txt`。冻结后本文件不再修改；发射前的账单查询、α̂ 与对 chain3 的斜率预期都追加到 FREEZE_LOG_alpha.txt。公开存证与 chain3 同一仓库（候选 https://github.com/yidu0924/e1-prereg）。
