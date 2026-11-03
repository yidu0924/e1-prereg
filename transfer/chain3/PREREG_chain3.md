# chain3 预注册（**已冻结**，见 `FREEZE_LOG_chain3.txt`）

版本：FROZEN v0.4 2026-10-07（review_27 GO-to-freeze，E1 已并入）；原记：DRAFT v0.4 2026-10-07（依据 DESIGN.md v0.4、review_24、review_25 §2/§4、review_26；v0.3 新增 H-exchange、零模型改为稳健 nuisance + 尖峰；v0.4 按 review_26 补执行层修订 B1–B3、代码既有规则、尖峰诊断、敏感性网格与设计历史）。冻结 = 本文件、`candidates.json`、三份 manifest、`analyze_chain3.py`、`power_chain3.py`、`prelaunch_check_chain3.py`、修订后的 `hprime/modal/modal_transfer.py`（及不变的 `run_transfer.py`）、GEAR bundle 与合成干跑输出的 sha256 写入 `chain3/FREEZE_LOG_chain3.txt`，且在第 1 期任何 run 之前。冻结前需要 Fable 复核和用户同意。

## 1. 来源声明（F7，原文写入论文附录）
- **本预注册的两个要素是在 H′ 揭盲之后才设计的**：
  - 分类规则 C3（纯 diff + 预测步数，跑前计算），是针对 H′ 中 karpathy_mar8_04 的灰区问题（预判与终判不一致）设计的；
  - 主假设 H-dose（g 与步数剂量的秩相关），来自 H′ 揭盲后的探索性分析（Spearman 0.74）。
- 回溯检查：把 C3 施加到 H′ 的 13 个 keep，H1 仍为 p = 0.041、比 6.5，C3 不是为改善 H′ 结果而定。
- **H1-R 的比值门槛 2 取自 H′ 预注册中的 WEAK 档**（H′：比 2–3 → WEAK），chain3 把"≥ WEAK"定义为复制成功；H′ 原规则（比 ≥ 3，R0）同时报告。
- 相对 H′ 共有两处放宽：比值门槛 3 → 2；主检验由单一 H1 扩为 H1-R + H-dose 双主检验。**冻结后不允许再改任何门槛或主检验。**
- 设计阶段所用的效应与噪声先验来自 H′ 的揭盲结果，只用于功效计算，不进入任何判决。
- **设计历史**（全部发生在任何 chain3 数据之前；论文附录原样给出）：

| # | 变更 | 日期 | 触发证据 | 方向 |
|---|---|---|---|---|
| 1 | 分类规则 C3（diff + 预测步数，跑前计算） | 2026-10-07 | H′ 揭盲后 karpathy_mar8_04 的预判/终判不一致 | 收紧（消除灰区） |
| 2 | 比值门槛 3 → 2（= H′ 的 WEAK 档），R0 并报 | 2026-10-07 | 设计功效（review_24 §3） | **放宽** |
| 3 | 主检验 H1 → H1-R + H-dose Holm 双主 | 2026-10-07 | H′ 揭盲后探索性剂量—响应；review_24 §3 | **放宽**（多一个主检验，Holm 控制 FWER） |
| 4 | 799f60f 移出主集合（OTHER-flag） | 2026-10-07 | review_23 DBS-64 位移；review_24 F3 | 收紧 |
| 5 | 零模型 v0.2 插入式 → v0.3 稳健 + 尖峰 | 2026-10-07 | 合成干跑 FWER 0.054、P(p_MW<.025) 0.136 | 收紧（FP ≈ 0.04，功效下降） |
| 6 | 新增次级 H-exchange（b = 0.0214） | 2026-10-07 | review_25 §2/§4 | 新增次级，不进判决 |
| 7 | 尖峰诊断、稳健性 12、敏感性网格（只报告） | 2026-10-07 | review_26 压力测试 S8、§5 | 新增只报告项 |

- **公开时间戳**：第 1 期之前，把冻结的 PREREG_chain3.md 与 FREEZE_LOG_chain3.txt（含各文件 sha256）提交到一个公开 GitHub 仓库，以 commit 时间戳作证（需用户同意后执行；本地 FREEZE_LOG 不够）。
- **敏感性网格（承诺全部报告）**：{比值 ≥ 2, ≥ 3} × {稳健 + 尖峰零模型, v0.2 插入式零模型} × {Holm 双主, 只 H1-R 单主（α = 0.05）} 共 8 格。结论只取预注册格（≥ 2、稳健、双主）；任一其他格的 H1-R（或双主格的 H-dose）判决与预注册格不同，则该结论在论文中加 "fragile" 标签。
- **次级假设 H-exchange 的汇率 b = 0.0214 也是 H′ 揭盲之后才得到的**：它是 H′ 面板 A（臂 1 vs 臂 2，13 个 keep）上 g 对 ln(steps_C/steps_P) 的加权（1/SE_g²）过原点拟合（`hprime/exploratory/dose_response.json`，探索性，加权 R² 0.72）。chain3 把它冻结，只做样本外检验。
- **零模型的 nuisance 估计在 v0.3 改了一次（在任何 chain3 数据之前）**：v0.2 的插入式零模型（合并 σ + M3b 合并 r²，不含尖峰）在合成干跑中整体假阳性 0.054（MC SE 0.005），且 MW 的校准 p 在零假设下 P(p < 0.025) = 0.136，主要来源是尖峰抬高合并 σ 与 r²。改为稳健 nuisance + 零模型内含尖峰后，整体假阳性 0.037（§7）。这是设计阶段的方法修正，不是对结果调参。

## 2. 数据来源与披露
- keep 来源：quietsmile `autoresearch/mar8-gpu{1,3,6,7}`、nm-le GEAR-evolve、nm-le baseline keep 11–14（DESIGN §2）。
- **quietsmile 分支 keep 的成立依据**（这些分支没有 results.tsv）：
  1. 报告对账：`docs/reports:autoresearch_report_mar9_v2.md` 的 GPU1 轨迹与 `mar8-gpu1` 的 29 个提交顺序逐一对应，加上分支快照之后的 5 个，共 34 个，等于报告的 keep 数；
  2. 相邻提交最短间隔 6–7 分钟（= 一次 5 分钟 run + 评估），有 discard 时间隔变长，没有 revert 提交，符合 "commit → run → 失败则 reset"；
  3. GitHub 远端六个分支的 tip 与本地 clone 一致。
  这些 keep 没有 per-keep 的 val 记录，不能做 P2-native 式审计；gpu3/gpu5 的提交信息记录的 baseline（1.0174/1.0179）与 gpu1 / karpathy（0.9979）不同，可能反映共用节点的吞吐波动。
- 去重：三条跨分支重复边在 `candidates.json` 中显式列出（段 `R:dup`）。
- **步数模型外推**：3 参数模型由 H′ 16 个状态（约 6 种构型）拟合，样本内最大误差 3.3%；d768、D10–12、TBS 2^17 属外推。分类余量约 2 倍（最小 |Δln| 0.27 对门槛 0.14）；H-dose 用实测步数比，不用预测值。
- **DBS-64**：799f60f 是唯一在 keep 内部把 DEVICE_BATCH_SIZE 128→64 的边；review_23 显示 DBS-64 路径有 +0.014 的未解释位移。该 keep 按规则标 OTHER-flag，不进任何主检验。其余状态全部原生 DBS。
- B1 = 281 s 沿用 H′ 的单锚点校准（H′ §3.2）。

## 3. 对象与分类
- 主集合与类别以冻结的 `candidates.json` 为准：THR 10 / SP 10 / OTHER 1 / OTHER-flag 1，28 个状态。
- 规则（`build_candidates.py`）：OTHER 优先（ns_steps 改值、窗口、ve_gate、只改 DBS）→ THR（形状/批量键且 |Δln steps| ≥ ln 1.15）→ SP（只改优化器/调度常数）→ OTHER；THR 且 DBS 值改变 → OTHER-flag。
- 跑后不重分类。臂 1 实测的 |Δsteps|（THR ≥ 15%、SP ≤ 3%）只作操作检查与敏感性分析。

## 4. 执行
- H100，臂 1 = 281 s，臂 2 = 120 s，原生 DBS，种子 {301, 302}；runner 用冻结的 `hprime/run_transfer.py` + `modal/modal_transfer.py`。
- 按段分两期，每期一个容器：第 1 期 {Q00, qs-gpu6, qs-gpu3, nmle-base}；第 2 期 {Q00 重跑, qs-gpu7, gear-evolve, qs-gpu1}。块序与块内随机化种子见 DESIGN §4；中断规则见下。
- 门槛 K0–K4 见 DESIGN §8。K0 每期包括：`modal billing summary --json`（只读）显示本月 credits = −30 且 metered = 0；第 1 期不早于 2026-11-01。不满足则不发射。
- **发射与中断（review_27 E1，写死）**：
  1. 发射命令：`modal run --detach modal_transfer.py --family H100 --mode main --manifest manifest_chain3_pN.json`（本地客户端断线不再终止容器；H′ 的两次中断都是本地断线）。
  2. 容器中断后按算术规则处理（只用账本与 guard 输出，盲态可执行）：若 账本 + 该块整块成本 + 其余未跑块成本 ≤ 本期上限（$20），则在新容器整块重跑（含根状态）；否则直接 resume（runner 跳过已有 rc = 0 的行，中断时在跑的 run 自动补跑），受影响的 keep 记为跨机，按 §5 的"第二个 r² 来源、取较大 p"规则处理，报告中以 `cross` 列标出。整块成本按每 (状态, 种子) $0.58 计。
  3. 若上限在块中途触发，该块中已完成的 keep 按 MIN_SEEDS 规则照常进入分析（块内顺序是预先随机化的，与结果无关）；未完成的 keep 排除。
  4. 截断序不变（从最后一块往前）；上限保持每期 $20。
- 每期 ledger 上限 $20，截断按写死的块序。**第 2 期估算 $18.9（含 5%；点估计约 $18.05），对上限只剩约 $1.1–1.9：一次中断（只 resume）约 $0.9–1.3，可吸收；整块重跑一般不满足上面的算术条件，因此改为 resume；若仍触及上限，先丢 B2.5 = 799f60f 对，再丢 B2.4 = qs-gpu7 SP 尾部**；这是预先写定的后果，不是临时决定。
- 执行层（review_26 B1/B2）：run 索引 i = 6000–6115，与 hprime Volume 上已有的全部 i（H′ 0–143、pilot −6…−1、M3 2000+/3000+、M4 4000–4005）不相交，由 `make_manifest_chain3.py` 与 `prelaunch_check_chain3.py` 断言（冻结的 runner 会跳过 results.jsonl 里已有 rc = 0 的 i）。wrapper 修订 C3（`hprime/modal/modal_transfer.py`，旧版备份 `.bak_m4`）：每期独立的 Volume 目录 `/vol/c3p1`、`/vol/c3p2`（各自的 results.jsonl、从 $0 起算的账本与锁），每期上限 $20；W2 读 `FREEZE_LOG_chain3.txt`；两份分期 manifest 列入 MAIN_MANIFESTS。`run_transfer.py` 不变。
- **K0(a) 可达性与回退（写死）**：每期发射前运行 `prelaunch_check_chain3.py --phase N --network --billing`，全部 OK 才发射。GEAR 的 6 个 commit 不在 nm-le 任何分支上：
  1. 首选：上游 `nm-le/genetic-autoresearch` 按全长 SHA 可取，md5 一致（manifest 原样）；
  2. 其次：用户的公开 fork **https://github.com/yidu0924/genetic-autoresearch**（同一 fork 网络；6 个 GEAR commit 以分支 `chain3/<sha7>` 推送，2026-10-07 `git ls-remote` 核对全长 SHA 一致）。用 `make_manifest_chain3.py --gear-repo yidu0924/genetic-autoresearch` 重新生成 manifest（只改 6 个 GEAR 状态的 repo 字段，SHA 与 md5 不变），重新冻结并写入 FREEZE_LOG_chain3；
  3. 再次：本地 bundle `nm-le_gear6_chain3.bundle`（sha256 d293181e215a7cbaebbb0de07221b06a44dce0d07b81c80df036c66f01ec3f90，refs/tags/chain3/<sha7>）。wrapper 每次发射都先用 Volume 上的 bundle 预置 nm-le clone（上游 clone 失败时只用 bundle 初始化，足以支撑第 2 期，因为第 2 期的 nm-le 状态只有这 6 个）；只在 1、2 都不可用时作为依据发射，并写入 FREEZE_LOG_chain3；
  4. 以上都不满足：不发射。
  两个仓库都没有 LICENSE，所以不做网络外的独立镜像；bundle 只存放在私有 Volume 与本地。
- 盲态：两期结束前协调者只看 guard 输出。若决定不跑第 2 期，必须在读任何 val 之前把该决定写入 FREEZE_LOG，然后按 §5 的"仅第 1 期"规则分析。
- 不按 val_bpb 剔除 run；崩溃时同种子重跑一次。

## 5. 主分析
- 估计量：Δ_k(a) = 种子均值(y_P − y_C)，g_k = Δ_k(2) − Δ_k(1)；SE_g 不配对，按 (段, 臂) 合并 σ（Q00 并入同期的 qs-gpu6 / qs-gpu7）。
- **H1-R**：THR vs SP 的 |g| 单侧 MW；统计量 U。PASS = Holm 拒绝 且 中位比 ≥ 2 且 med|g|_THR > 1.0 × med SE_g。同时报告 R0（比 ≥ 3）与比值的 keep 级 bootstrap 95% CI。
- **H-dose**：Spearman ρ(g, x) > 0，x = 臂 1 实测 ln(steps_C/steps_P) 的种子均值；对象为 THR + SP + OTHER（21 个 keep），不含 OTHER-flag。
- **p 值**：结构感知参数自助零模型（M3b 做法，`power_chain3.null_stats`）。保留真实链/树结构、共享根 Q00、种子集与实测 x；g ≡ 0；B = 10000；p = (1 + #{零统计量 ≥ 观测}) / (B + 1)；随机种子写死（20261101）。nuisance（v0.3）：
  - σ(段, 臂) = sqrt(median_states[s²_state / (χ²_med(df)/df)])，即每个 (状态, 机器) 的种子方差先除以 χ² 中位数校正，再在该 sigma 段内取中位数（Q00 并入同期 qs-gpu6 / qs-gpu7）；
  - r²(类, 臂) = median_keeps[var(d) / (2σ²) / (χ²_med(n−1)/(n−1))]，截断到 [0, 1]；类 = THR / SP / OTHER*（OTHER 与 OTHER-flag 合并）；子状态与父状态的相关 = 1 − r²；
  - 零模型内加入尖峰：每次 run 以 2.1% 的概率加 U(0.015, 0.030) bpb（H′ 先验，写死）。
  - 若有跨机配对（中断后 resume 导致），r² 再用"只同机配对"算一次，两个 p 取较大者。
  - 估计量本身（Δ、g、SE_g、护栏）不变：SE_g 仍用 H′ 的合并 σ（均值型）。
  - v0.2 的插入式零模型（合并 σ、M3b 合并 r²、无尖峰）作敏感性报告（稳健性 10），不用于判决。
- **代码中既有、此处写明的四条规则**（review_26 F1）：
  1. 护栏的 "med SE_g" 是在 THR + SP keep 上取中位数；
  2. 完整种子数 < 2 的 keep（两次崩溃）排除，不进任何检验、描述或稳健性；
  3. 某 keep 的臂 1 步数缺失时，x 回退为预测剂量（报告中以 `*` 标记）；
  4. "跨机配对时第二个 r² 来源、取较大 p" 只用于两个主检验；稳健性 1–12 只用原样（稳健）r²。
- 披露：小 sigma 段（qs-gpu3 两个状态、qs-gpu1 三个状态）的"中位数" σ 实际接近均值，对尖峰不稳健；方向上对 H1-R 保守（这些段多为 THR），不改。
- **多重性**：Holm，α = 0.05。按 p 值做 step-down：较小的 p < 0.025 则拒绝该假设，然后另一个与 0.05 比；step-down 只看 p，不看 H1-R 的比值与护栏（与 `power_chain3.py`、`analyze_chain3.py` 一致）。H1-R 的 PASS 另外要求比值 ≥ 2 且护栏成立。
- **仅第 1 期**：若第 2 期未执行，同一规则用于第 1 期（6 THR / 6 SP；H-dose 12 个 keep），结论标为"半数据集"。
- **结论映射**：两者都过 → 幅度复制 + 剂量机制确认；只有 H-dose → 剂量—响应确认，二分复制功效不足；只有 H1-R → 复制成立，剂量机制未确认；都不过 → 未复制。

## 5b. 次级预注册假设 H-exchange（不进 Holm 家族，不影响 §5 的任何判决与结论映射）
- 来源：review_25 §2/§4（"两账本 + 显式汇率"中唯一非循环的验证）。汇率 **b = 0.0214 bpb / ln(步数比)** 冻结，来源见 §1（H′ 揭盲后得到）。
- **预测对象（选定一种，写死）**：预测 g 本身，ĝ_k = b · x_k，x_k = 臂 1 实测 ln(steps_C/steps_P) 的种子均值（与 H-dose 的 x 相同）；符号约定与 `analyze_transfer.py` 一致：g = D_slow − D_fast = Δ(2) − Δ(1)，b > 0 表示步数增加的 keep 在慢臂（步数少的臂）上的收益更大。等价写法是由臂 2 预测臂 1：Δ̂(1) = Δ(2) − b·x（注意是减号；review_25 §4 写成 "+ b·x"，与 g 的符号约定不符，此处更正）。两种写法的残差只差一个符号，本预注册只报告 g 的版本。
- 对象：主集合 = THR + SP + OTHER（21 个 keep，与 H-dose 相同）；799f60f（OTHER-flag）单独报告，另报"含 799f60f 的全部 22 个"。
- 指标（全部写死）：
  1. 样本外加权 R²：R²_oos = 1 − Σw(g − ĝ)² / Σw(g − ḡ_w)²，w = 1/SE_g²，ḡ_w 为 chain3 自身的加权均值（与 H′ `dose_response.py` 的定义相同；另报以 0 为基准的版本）；
  2. 符号一致率：|x| ≥ ln 1.15 的 keep 中 sign(g) = sign(x) 的比例，附单侧二项 p（描述性）；
  3. g 对 ĝ 的加权最小二乘斜率（含截距，权重 w），95% CI 为 keep 级 bootstrap 百分位（4000 次，种子写死）；
  4. |g − ĝ| > 2 SE_g 的 keep 清单（b 视为常数，不计其不确定性）。
- **标题结论（v0.4，review_26 F2）**："汇率校准迁移" = R²_oos > 0 **且** 斜率 95% CI 下限 > 0 **且** CI 包含 1。只满足前两条时只作方向性陈述（"方向一致"），因为"斜率 > 0"与 H-dose 是同一信息，不是 b 的独立证据。
- |残差| > 2 SE_g 的 keep **只报告个数与清单，不设门槛**（v0.3 的"≤ 2"已删除：SE_g 用段合并 σ，状态间 σ 异质与尖峰使该数在作者自己的 FULL 合成数据下也常为 3–4）。
- 预先写下的预测：799f60f 的 |z| > 2，不预注册方向（review_25 原文的"残差为正"依赖有符号错误的写法，DBS-64 位移的预算依赖性未知）。披露：gear 段两种子的 SE_g ≈ 0.003–0.006，+0.014 的位移对应 z ≈ 2.4–4.7，是边缘值。
- 仅第 1 期时同样计算（12 个 keep），标"半数据集"。

## 6. 描述性与稳健性（不改判决）
- H5 符号检验（THR 上 sign(g) = 预测符号）；剂量图（22 个 keep 含 799f60f，+ H′ + lieexxli）；斜率与 CI；van Elteren 与 Fisher 合并（写明只有 chain3 是新数据）。
- **尖峰诊断（review_26 F3，只报告）**："尖峰 state-arm" = 同一 (状态, 臂, 机器) 内种子极差 > 0.01 bpb。按"该状态作为子状态所属 keep 的类别"报告分布（根状态记为 root）。稳健性 12 = 剔除父或子为尖峰状态的 keep 后重做两个主检验。**"spike-driven" 标签规则**：尖峰 state-arm ≥ 3、其中 ≥ 2/3 落在 THR 子状态、预注册格 H1-R PASS 且稳健性 12 下 H1-R 不 PASS → 论文把 H1-R 标为 "spike-driven"。背景：review_26 压力测试 S8（6% 尖峰只落在 THR 侧子状态）下两种零模型的 FWER 都约 0.07，|g| 统计量无法区分"THR 效应"与"THR 噪声更大"。
- 敏感性网格（§1）由 `analyze_chain3.py` 一并输出。
- 稳健性（`analyze_chain3.py` 中编号 1–12，全部只报告；12 见上）：1 逐 keep 留一；2 逐段留一（6 段）；3 去掉 Q00 的 3 个子 keep；4 按实测步数分类（在 C3 的 THR/SP keep 中，臂 1 实测 |Δsteps| > 3% → THR，否则 SP，即 H′ 的终判规则）；5 护栏 1.5×；6 可选种子 303；7 H-dose 用预测剂量；8 H-dose 只用 THR；9 剔除操作检查不合格的 keep（THR 实测 < 15% 或 SP > 3%）；10 v0.2 插入式零模型；11 M3b α̂（以拟合的稳健 nuisance + 尖峰生成 1000 个零数据集，每个重新估计 nuisance 并以 B = 1000 重新校准，统计整套判决的 FWER；α̂ ≤ 0.05 标"已校准"）。教科书 p 值并报，标"未校准"。
- 数据检查（`analyze_chain3.py` 自动输出）：K0(a) commit/md5 与 manifest 一致、全长 SHA、各格完成数；K0(b,c) 第 1 期首个 run 时间 ≥ 2026-11-01（额度检查只能在发射前做，必须记录在 FREEZE_LOG）；K1 每期 Q00 种子 301 臂 1/臂 2 的步数（876/382 ±5%）、compute_cap、sdpa/fallback、臂 1 val 窗口 [H′ 均值 1.001899 − 0.008, + 0.004]；K2 显存 > 76 GiB 或 OOM；K3 每期按墙钟估算的花费 ≤ $20；K4 第 1 期有效 THR ≥ 5 且 SP ≥ 5；budget_seen 与操作步数检查。

## 7. 设计阶段的功效与零假设表现（作者先验下）
- 合成干跑（`dryrun_chain3.py` → `dryrun_chain3_output.txt`；真实链结构；合成 jsonl 行经 `analyze_chain3.py` 的 estimate → primary 全流程；每个数据集 B = 1000）：

| 零模型 | 情形 | H1-R | R0 | H-dose | 至少一个 | 两个 | P(p_MW<.025) | P(p_dose<.025) |
|---|---|---|---|---|---|---|---|---|
| 稳健+尖峰（预注册） | NULL，全设计（n=4000） | 0.015 | 0.013 | 0.024 | **0.037**（SE 0.003） | 0.001 | 0.036 | 0.022 |
| | NULL，尖峰率 ×2（n=2000） | 0.013 | 0.011 | 0.024 | 0.034 | 0.003 | 0.028 | 0.022 |
| | NULL，仅第 1 期（n=2000） | 0.013 | 0.011 | 0.025 | 0.036 | 0.003 | 0.028 | 0.025 |
| | FULL / HALF / QUARTER，全设计（各 n=1000） | 0.89 / 0.50 / 0.15 | 0.87 / 0.42 / 0.09 | 0.97 / 0.81 / 0.52 | 0.98 / 0.85 / 0.55 | 0.89 / 0.46 / 0.13 | | |
| | FULL / HALF / QUARTER，仅第 1 期 | 0.61 / 0.29 / 0.09 | 0.59 / 0.25 / 0.07 | 0.77 / 0.52 / 0.31 | 0.80 / 0.55 / 0.32 | 0.58 / 0.26 / 0.08 | | |
| v0.2 插入式（不用） | NULL，全设计（n=2000） | 0.018 | 0.011 | 0.039 | 0.054（SE 0.005） | 0.002 | 0.136 | 0.036 |
| | HALF，全设计 | 0.66 | 0.49 | 0.86 | 0.88 | 0.63 | | |

- 所有功效与假阳性数字都是**在作者先验 DGP 下**；真实数据下的整体假阳性由稳健性 11（揭盲后以实测 nuisance 重估 α̂）给出。review_26 的独立压力测试（每格 300 次，B = 400，SE ≈ 0.01）：作者先验、按类异方差、相关种子、t₃ 重尾、配对结构错设、尖峰率 ×3 下 FWER 0.013–0.037；唯一失守的是"尖峰只落在 THR 侧"（0.073，两种零模型相同），由上面的尖峰诊断处理。表述为"FWER ≈ 0.04"。
- 读法：预注册零模型的整体假阳性 0.037 ≤ 0.05，对尖峰率翻倍与仅第 1 期都稳定；代价是 HALF 下 H1-R 功效由 0.66 降到 0.50，"至少一个"由 0.88 降到 0.85。MW 的单项 P(p < 0.025) 为 0.036，仍略高于名义 0.025，但 H1-R 的 PASS 还需比值与护栏，单项 PASS 率 0.015。
- 冻结时把上表与 `dryrun_chain3_output.txt` 的哈希写入 FREEZE_LOG；揭盲后以实测 nuisance 重算 M3b α̂（稳健性 11）并报告。

## 8. 待定（冻结前）
- 已完成（草稿，未冻结）：`analyze_chain3.py`、`dryrun_chain3.py` + 输出、三份 manifest（i = 6000–6115）、`prelaunch_check_chain3.py`、wrapper 修订 C3 + `selftest_cpu.py`、GEAR bundle。
- 未完成：Fable 复核 v0.4；用户同意；（可选，需用户同意）公开时间戳提交（公开 fork 已由用户建立：yidu0924/genetic-autoresearch）；冻结（`FREEZE_LOG_chain3.txt` 条目已准备，未写入）；每期 K0 时点的 `prelaunch_check_chain3.py --network --billing`；把 manifest、FREEZE_LOG_chain3、bundle 上传到 Volume（冻结后）。
