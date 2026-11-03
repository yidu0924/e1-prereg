# chain3：吞吐敏感性的第三条预注册 keep 链（确认性复制）— 设计

状态：**DRAFT v0.4（2026-10-07；v0.4 = review_26 的 B1–B3 与 F1–F5，见 §10）**；以下为 v0.3 原文起首：**DRAFT v0.3（2026-10-07），v0.2 已按 review_24 的 F1–F7 修改；v0.3 加入 review_25 的 H-exchange、零模型改为稳健 nuisance + 尖峰、`analyze_chain3.py`、合成干跑与草稿 manifest。待 Fable 复核 → 用户同意**。manifest 只是草稿（未冻结、未上传），没有启动任何 GPU，没有花钱。
v0.1 / v0.2 的文件备份在会话 scratchpad（`*_v01.*`、`*_v02.*`）；改动见 §10。
配套文件（本目录）：
- `candidates.json`：候选清单，由 `build_candidates.py` 生成（只读访问 GitHub 和本地 clone，只用 CPU）。
- `power_chain3.py`：按真实链结构的功效与零假设校准模拟（v0.2）；输出在 `power_chain3_output.txt`。
- `PREREG_chain3.md`：预注册草案（未冻结）。
- `analyze_chain3.py`：按 PREREG 实现的分析（导入 `power_chain3.null_stats`）；`dryrun_chain3.py` → `dryrun_chain3_output.txt`：合成干跑。
- `make_manifest_chain3.py` → `manifest_chain3.json`（总表）与 `manifest_chain3_p1.json` / `_p2.json`（每期一个容器）：草稿。
- `src_cache/`：候选状态的 train.py 缓存。

## 0. 一句话
在 H100 上只跑臂 1（B1 = 281 s）和臂 2（B2 = 120 s），重放 **22 个从未重放过的公开 keep**，分类为 **THR 10 / SP 10 / OTHER 1 / OTHER-flag 1**。共 28 个状态（Q00 在第 2 期重跑一次，所以是 29 个状态-期），2 个种子，116 次 run，约 **$35**。分两期、**按段分期**。
主检验为 **H1-R 与 H-dose 的 Holm 双主检验**，两者的 p 值都来自按链结构做的参数自助零模型（M3b 做法；v0.3 起 nuisance 用稳健估计，零模型内含尖峰）。H5 符号检验降为描述性。次级预注册 **H-exchange**（review_25）：用 H′ 冻结的汇率 b = 0.0214 对 chain3 的 g 做样本外预测，不进 Holm。

## 1. 为什么需要 chain3（H′ 的弱点）
- H1 PASS 时 p = 0.026，只有 13 个 keep（7 THR / 6 SP），结果很脆：去掉任一 SP keep，p = 0.053；按描述预判分类（S1），p = 0.086；去掉种子 301，p = 0.051。
- S1 出问题的根源是分类规则有两套（预判按描述、终判按实测步数 ±3%）。
- H′ 的效应可能高估（赢家诅咒），功效必须在效应缩水下评估。
- 臂 3（A100）有 DBS-64 / d640 / TBS 2^18 的配置混杂（review_21 §2.4、review_23）。chain3 只用 H100、原生 DBS。
- H′ 揭盲后的探索性剂量—响应（Spearman 0.74，留一全部 p < 0.02）尚未经过预注册确认；chain3 把它列为第二个主检验。

## 2. keep 来源

### 2.1 来源与资格（不变）
来源：quietsmile `autoresearch/mar8-gpu{1,3,6,7}` 分支历史、nm-le GEAR-evolve（单亲 mutate 且子优于父）、nm-le baseline keep 11–14。排除 H′ 的 13 个 keep、lieexxli、chen A100 S04–S10、zixuzixu、chen L40S。
- quietsmile 分支：每个非 tip 提交算一个 keep，父状态取前一个提交。"分支历史 = keep 序列"有三条证据（review_24 §1.1）：报告轨迹表逐一对账（gpu1：29 + 5 = 34 个 keep）、相邻提交间隔与 "commit → run → 失败则 reset" 一致且无 revert、GitHub 远端 tip 与本地一致。这些 keep 没有 per-keep 的 val 记录，不能做 P2-native 式审计。
- GEAR：只取单亲 mutate、子 val_bpb 低于父的边。
- 跨分支去重：按"去掉注释与空行的 train.py md5"判断 (父, 子)。**三条重复边已显式写入 `candidates.json`（段 `R:dup`，字段 `duplicate_of` 由脚本算出）**：gpu1 2bed561 = gpu6 a361e86；gpu5 ba43b86 = gpu3 cc3e249；gpu5 ebd8796 = gpu3 a68b0a0（ebd8796 与后备 gpu4 3f43595 的子状态相同，字段 `same_child_state_as`）。

### 2.2 备选：自跑 autoresearch 循环（不推荐，不变）
生成成本约 $45–60 加 LLM 费用，违反不花钱约束；只有执行前核验时 THR 少于 8 才考虑。

### 2.3 主集合（`candidates.json`，primary = true）

| 段（期） | 状态 | keep：最终类（预测 Δln steps） |
|---|---|---|
| qs-gpu6（1） | Q00 → a361e86 → e2a405b → aba03be → dd95f90 → 649bb35 → 35b9270 | AR 64→80 THR(−0.31)；TBS 2^19→2^18 THR(+0.67)；AR 80→96 THR(−0.27)；EMB_LR ×2 SP；WARMDOWN SP |
| qs-gpu3（1） | Q00 → cc3e249 → a68b0a0 | DEPTH 8→10 THR(−0.47)；TBS THR(+0.66) |
| nmle-base（1） | 3acc0ff → 89d4b58 → e35cb82 → eaae5a1 → 4a94191 | DEPTH 8→9 THR(−0.40)；MATRIX_LR ×2 SP；Muon beta2 SP |
| qs-gpu7（2） | Q00（重跑）→ ec90e0e → ec2b951 → afc44f4 → 2587233 → 0bd4eec | DEPTH 11 + AR 46 + TBS THR(+0.46)；DEPTH 11→12 OTHER(−0.06)；WD、UNEMB_LR、SCALAR_LR SP |
| gear-evolve（2） | 92164bd → 799f60f；dbbdc5a → 485d3b7；99be0ce → 0747415 | TBS 2^18→2^17 + DBS 128→64 **OTHER-flag**(+0.65)；DEPTH 8→9 THR(−0.41)；TBS THR(+0.67) |
| qs-gpu1（2） | e03db57 → 67847c0 → 127c4bd | TBS THR(+0.67)；WD SP |

合计 **THR 10（预测符号 5 正 5 负）/ SP 10 / OTHER 1 / OTHER-flag 1**。
- 第 1 期：THR 6 / SP 6，14 个状态；第 2 期：THR 4 / SP 4 / OTHER 1 / OTHER-flag 1，15 个状态（含 Q00 重跑）。
- **799f60f（F3）**：按 C3 字面是 THR，但它是全集里唯一在 keep 内部切换 DBS 代码路径的边（review_23：DBS-64 路径有 +0.014 的未解释位移），而且记录改进只有 0.00016。由规则"THR 且 DBS 值改变 → OTHER-flag"判出，不进 H1-R，也不进 H-dose，只进描述性剂量图。不用 R:qs-gpu4 3f43595 补位。
- 后备池（primary = false）与替换规则不变（§7）。显存：同构型已知峰值 ≤ 66.2 GB，原生 DBS 都放得下；不允许 DBS 偏离。

## 3. 分类规则 C3（跑之前计算，跑完不重分类）
由 `build_candidates.py` 实现。
1. **OTHER 优先（F6）**：diff 改动了 ns_steps 的值、窗口（WINDOW_PATTERN / short_window / window_size）、ve_gate，或只改 DEVICE_BATCH_SIZE → OTHER，不论还改了什么。ns_steps 与 DBS 按"值是否改变"判断（Muon 那一行同时含 momentum / ns_steps / beta2，改 beta2 不触发）。
2. **THR**：改动了 {TOTAL_BATCH_SIZE, DEPTH, ASPECT_RATIO, HEAD_DIM, n_embd, MLP 倍数} 中至少一项，且步数模型预测 |Δln steps| ≥ ln 1.15。
3. **SP**：只改优化器或调度常数（*_LR、WEIGHT_DECAY、ADAM_BETAS、WARMUP/WARMDOWN、FINAL_LR_FRAC、Muon momentum/beta2、x0/resid lambda 初值、softcap、RoPE base）。
4. **OTHER**：其余。
5. **OTHER-flag（F3）**：THR 且 DEVICE_BATCH_SIZE 的值也改变。

重新生成后核对：全部 keep（含后备池）的 C3 类与 v0.1 相同；只有 799f60f 的最终类变为 OTHER-flag。规则单元测试（ns_steps 改值 → OTHER；改 beta2 → SP；改窗口 → OTHER；只改 DBS → OTHER；ve_gate → OTHER）通过。
- 主集合 THR 全部 |Δln| ≥ 0.27，SP 全部为 0，没有 3–15% 灰区的 keep。
- 步数模型：3 参数，16 个状态，约 6 种构型；"最大误差 3.3%"是样本内数字，d768、D10–12、TBS 2^17 属外推。对分类无影响（最小 |Δln| 0.27 对门槛 0.14）。H-dose 的 x 不用预测值，用臂 1 实测值（§5）。
- 操作检查（不改分类）：臂 1 实测 |Δsteps| 应满足 THR ≥ 15%、SP ≤ 3%；不满足的逐个报告并做剔除敏感性分析。

## 4. 设计
- 臂 1 TIME_BUDGET = 281 s（H′ 校准的 B1，不再跑 pilot）；臂 2 = 120 s；DBS 一律原生。
- 种子：主分析 {301, 302}；可选 303 只用于稳健性。
- runner：沿用冻结的 `hprime/run_transfer.py` 与 `modal/modal_transfer.py`，只新建 chain3 的 manifest 与 `analyze_chain3.py`。
- **分期按段（F4）**，每期一个容器，一个 keep 的两个种子、两个臂都在同一台机器上：
  - 第 1 期 = {Q00, qs-gpu6, qs-gpu3, nmle-base}：14 个状态 × 2 种子 × 2 臂 = 56 run。THR 6 / SP 6，**单独可分析**。
  - 第 2 期 = {Q00 重跑, qs-gpu7, gear-evolve, qs-gpu1}：15 个状态 × 2 种子 × 2 臂 = 60 run。
  - 第 2 期没跑成时，第 1 期是一个可分析的半数据集（功效见 §6 第二张表）。
- **块**：共享根的段合成一个块。第 1 期块序 {Q00 + qs-gpu6 + qs-gpu3} → {nmle-base 头部 3acc0ff、89d4b58、e35cb82} → {nmle-base SP 尾部 eaae5a1、4a94191}（v0.3 拆成两块，使 §7 的"先截 SP 尾部"就是"截最后一块"；尾块若按下面的算术规则整块重跑，连同根 e35cb82）；第 2 期块序 {Q00 + qs-gpu7 头部 ec90e0e、ec2b951} → {gear 0747415、485d3b7 两对} → {qs-gpu1} → {qs-gpu7 尾部 afc44f4→0bd4eec} → {gear 799f60f 对}。块内状态 × 种子 × 臂随机排列，随机种子写死。
- **发射与中断（review_27 E1，写死）**：
  1. 发射命令：`modal run --detach modal_transfer.py --family H100 --mode main --manifest manifest_chain3_pN.json`（本地客户端断线不再终止容器；H′ 的两次中断都是本地断线）。
  2. 容器中断后按算术规则处理（只用账本与 guard 输出，盲态可执行）：若 账本 + 该块整块成本 + 其余未跑块成本 ≤ 本期上限（$20），则在新容器整块重跑（含根状态）；否则直接 resume（runner 跳过已有 rc = 0 的行，中断时在跑的 run 自动补跑），受影响的 keep 记为跨机，按 PREREG §5 的"第二个 r² 来源、取较大 p"规则处理，报告中以 `cross` 列标出。整块成本按每 (状态, 种子) $0.58 计。
  3. 若上限在块中途触发，该块中已完成的 keep 按 MIN_SEEDS 规则照常进入分析（块内顺序是预先随机化的，与结果无关）；未完成的 keep 排除。
  4. 截断序不变（从最后一块往前）；上限保持每期 $20。
- 盲态：两期全部完成前，协调者只看 guard 输出（rc、步数、budget_seen、compute_cap、显存），不读 val_bpb。例外：如果第 2 期最终不跑，第 1 期按 §5 的"仅第 1 期"规则揭盲（这个决定必须在读任何 val 之前写入 FREEZE_LOG）。
- 冻结：`candidates.json`、manifest、`analyze_chain3.py`、`power_chain3.py`（零模型函数）和合成干跑的输出，在第 1 期开始前写入 `chain3/FREEZE_LOG.txt`（哈希 + 时间戳）。
- manifest 草稿（`make_manifest_chain3.py`）：状态 id = `p{期}:{sha7}`（Q00 为 `p1:2a8a0b7` 与 `p2:2a8a0b7` 两次独立重跑）；每行含全长 commit、原始 train.py 的 md5（即 `run_transfer.py` 断言的值）、budget 281/120、dbs = null（原生）、seed、phase、block；顺序 = 期 → 块序 → 块内随机（种子 20261101），每期以 Q00 种子 301 的臂 1、臂 2 开头（K1）。29 个状态-期、116 行，估算 $17.7 + $18.9。`run_transfer.patch()`（从冻结文件用 AST 抽出）对全部 116 行自检通过。
  - GEAR 的 6 个 commit 不在 nm-le 的任何分支上（GitHub compare 均为 diverged），但 2026-10-07 用全长 SHA 做 `git fetch --depth 1` 可以取到，md5 与 src_cache 一致；`run_transfer.py` 的按 SHA fetch 路径可用。风险：仓库若做 GC，这些对象可能消失——发射前 K0(a) 会再验一次。
  - `run_transfer.py` 只按 gpu_family 过滤、按文件顺序执行，所以每期用自己的分期文件；`modal_transfer.py` 的 MAIN_MANIFESTS 需要加入这两个文件名（冻结前的 wrapper 修订）。

## 5. 假设与检验（`analyze_chain3.py`：估计量同 `analyze_transfer.py`，零模型导入 `power_chain3.py`）
记号沿用 H′：g = Δ(2) − Δ(1)；SE_g 用不配对公式（按段、臂合并 σ；Q00 并入其所在期的 qs-gpu6 / qs-gpu7）。

### 两个主假设，Holm（F2）
α = 0.05；较小的 p 与 0.025 比，过了以后另一个与 0.05 比。
- **H1-R**：THR 与 SP 的 |g| 做单侧 MW。PASS = Holm 拒绝 **且** 中位比 ≥ 2 **且** 护栏 med|g|_THR > 1.0 × med SE_g。比 ≥ 2 就是 H′ 预注册里的 WEAK 档下限，不是新数字。同时报告 R0（H′ 原规则，比 ≥ 3）的判决，以及比值的 keep 级 bootstrap CI。
- **H-dose**：Spearman(g, x) > 0，x = 臂 1 **实测**的 ln(steps_C / steps_P)（种子平均；步数由吞吐决定，不含 val 信息）。范围：THR + SP + OTHER 共 21 个 keep，不含 OTHER-flag。预测剂量版本作敏感性分析。
- **两者的 p 值都来自结构感知的参数自助零模型**（M3b 做法）。**v0.3**：nuisance 用稳健估计——各 (段, 臂) 的 σ 取状态内种子方差（χ² 中位数校正后）的中位数，各 (类, 臂) 的 r² 取 keep 级 var(d)/(2σ²)（同样校正）的中位数——并在零模型中加入 H′ 先验的尖峰（2.1%/run，U(0.015, 0.030)）。原因：v0.2 的插入式 nuisance（合并 σ、M3b 合并 r²、无尖峰，见下一行）在合成干跑中整体假阳性 0.054，MW 校准 p 在零下 P(p < 0.025) = 0.136——一个尖峰会同时抬高该段的合并 σ 和该类的 r²，零模型把它摊到所有 keep 上，而 MW/中位数只受一两个 keep 影响。改后 0.037（§6）。v0.2 原文：nuisance 从数据插入，即各 (段, 臂) 合并 σ、各 (类, 臂) 的配对 r²（M3b 公式，OTHER 与 OTHER-flag 合为一类）；真实的链/树结构、共享根、种子数和实测 x 都保持不变；令所有 g = 0，模拟 B ≥ 4000 次，p = (1 + #{零统计量 ≥ 观测值}) / (B + 1)。统计量为 MW U 与 Spearman ρ。教科书 p 值只作参考，不用于判决。按段分期后所有父子配对都同机，H′ M3b 的"原样 / 同机"两个 r² 来源在 chain3 中重合，只算一次；若因中断重跑导致某块跨机，则两个来源各算一次，取较大的 p。
- **仅第 1 期**的规则：若第 2 期未执行，同一套检验在第 1 期的 6 THR / 6 SP / 12 个 H-dose keep 上进行，论文标为"半数据集"。

### 次级预注册：H-exchange（review_25 §2/§4；不进 Holm，不影响结论映射）
- 汇率 b = 0.0214 bpb / ln 步数比，冻结；来自 H′ 面板 A 的加权过原点拟合（`hprime/exploratory/dose_response.json`），**是 H′ 揭盲后得到的**。
- 预测 g 本身：ĝ_k = b · x_k，x_k = 臂 1 实测 ln(steps_C/steps_P)（与 H-dose 相同）。符号约定同 `analyze_transfer.py`：g = D_slow − D_fast = Δ(2) − Δ(1)。等价写法 Δ̂(1) = Δ(2) − b·x；review_25 §4 写成 "+ b·x" 是符号笔误。
- 报告：主集合（THR + SP + OTHER，21 个）与含 799f60f 的 22 个；加权（1/SE_g²）样本外 R²（以 chain3 自身加权均值为基准，另报以 0 为基准）；|x| ≥ ln 1.15 的 keep 的符号一致率；g 对 ĝ 的加权斜率与 keep 级 bootstrap 95% CI；|g − ĝ| > 2 SE_g 的 keep 清单。
- 标题结论（v0.4）："校准迁移" = R²_oos > 0 且斜率 CI 下限 > 0 且 CI 含 1；只满足前两条为"方向一致"。> 2 SE 的 keep 只报个数，不设门槛（v0.3 的"≤ 2"删除：FULL 合成数据下也常有 3–4 个）。799f60f 的 |z| > 2 保留，不预注册方向，标为边缘（SE_g 0.003–0.006 → z ≈ 2.4–4.7）。

### 描述性（不进判决）
- H5：THR keep 上 sign(g) = sign(预测 Δln steps) 的符号检验（与 H-dose 信息重叠）。
- 剂量图：全部 22 个 keep（含 799f60f）+ H′ + lieexxli；斜率 g / Δln steps 与 keep 级 bootstrap CI。
- 合并：chain3、H′、lieexxli 三层分层 van Elteren；chain3 与 H′ 的 Fisher 合并；写明只有 chain3 是新数据。

### 稳健性（全部写死，只报告）
1. 逐 keep 留一；2. 逐段留一（6 段）；3. 去掉共享根 Q00 的 3 个 keep；4. 按实测步数分类（|Δsteps| > 3% → THR，H′ 终判规则）；5. 护栏 1.5×；6. 可选种子 303；7. H-dose 用预测剂量；8. H-dose 只在 THR 上；9. 剔除操作检查不合格的 keep；10. v0.2 插入式零模型；11. M3b α̂（1000 个外层零数据集 × 内层 B = 1000，整套判决的 FWER）。

### 结论映射（写死）
| H1-R | H-dose | 结论 |
|---|---|---|
| PASS | PASS | "幅度复制 + 剂量机制确认" |
| 不过 | PASS | "剂量—响应确认；THR/SP 二分复制功效不足" |
| PASS | 不过 | "复制成立，剂量机制未确认" |
| 不过 | 不过 | "未复制"；论文只报告 H′ 并加注脆弱性 |

论文措辞："H′ 预注册 H1（p = 0.026）+ 探索性剂量—响应；chain3 对两者各做一次预注册确认。"

## 6. 功效（`power_chain3.py` v0.2；每格 2000 次，每个数据集插入式零模型 B = 1000；2 种子）
**F1**：模拟用 `candidates.json` 的真实结构：状态 = (commit, 期)，相邻 keep 共享状态，Q00 在第 1 期是 3 个 keep 的共同父状态，在第 2 期单独重跑。先验同 v0.1（H′ 的 7 个 THR g、5 个 SP g、30 个 σ、尖峰 2.1%/run、配对相关 0.8 / 0.3 / 0）。OTHER 的 g = 剂量 × |THR 抽样| / 0.5。实测 x = 预测 × (1 + N(0, 0.05)) + N(0, 0.005)。

全设计（THR 10 / SP 10，H-dose 21 个 keep）：

| 情形 | H1-R（校准） | R0（校准） | H-dose（校准） | 至少一个 | 两个都过 | 朴素 Holm 至少一个 | 朴素 MW p<0.05 | H5（描述） |
|---|---|---|---|---|---|---|---|---|
| FULL（= H′ 效应） | 0.92 | 0.89 | 0.99 | 0.99 | 0.92 | 1.00 | 0.97 | 0.95 |
| HALF | 0.65 | 0.49 | 0.85 | 0.88 | 0.62 | 0.92 | 0.72 | 0.78 |
| QUARTER | 0.17 | 0.07 | 0.59 | 0.61 | 0.14 | 0.70 | 0.35 | 0.62 |
| LRDRIFT | 0.67 | 0.53 | 0.82 | 0.86 | 0.63 | 0.91 | 0.73 | 0.77 |
| **NULL（假阳性）** | **0.016** | 0.013 | **0.042** | **0.056** | 0.002 | **0.109** | **0.191** | 0.023 |
| NULL，尖峰率 ×2 | 0.013 | 0.011 | 0.040 | 0.052 | 0.001 | 0.088 | 0.155 | 0.021 |

只有第 1 期（THR 6 / SP 6，H-dose 12 个 keep）：

| 情形 | H1-R | R0 | H-dose | 至少一个 | 两个都过 |
|---|---|---|---|---|---|
| FULL | 0.71 | 0.65 | 0.83 | 0.86 | 0.68 |
| HALF | 0.41 | 0.31 | 0.63 | 0.67 | 0.37 |
| QUARTER | 0.12 | 0.07 | 0.41 | 0.43 | 0.10 |
| NULL | 0.018 | 0.013 | 0.044 | 0.059 | 0.002 |

**v0.3 合成干跑（`dryrun_chain3_output.txt`；预注册的稳健 + 尖峰零模型；合成 jsonl → `analyze_chain3.py` 全流程；每个数据集 B = 1000）**：

| 情形 | H1-R | R0 | H-dose | 至少一个 | 两个都过 |
|---|---|---|---|---|---|
| NULL，全设计（n = 4000） | 0.015 | 0.013 | 0.024 | **0.037**（SE 0.003） | 0.001 |
| NULL，尖峰率 ×2（n = 2000） | 0.013 | 0.011 | 0.024 | 0.034 | 0.003 |
| NULL，仅第 1 期（n = 2000） | 0.013 | 0.011 | 0.025 | 0.036 | 0.003 |
| FULL，全设计（n = 1000） | 0.89 | 0.87 | 0.97 | 0.98 | 0.89 |
| HALF，全设计 | 0.50 | 0.42 | 0.81 | 0.85 | 0.46 |
| QUARTER，全设计 | 0.15 | 0.09 | 0.52 | 0.55 | 0.13 |
| FULL / HALF / QUARTER，仅第 1 期 | 0.61 / 0.29 / 0.09 | 0.59 / 0.25 / 0.07 | 0.77 / 0.52 / 0.31 | 0.80 / 0.55 / 0.32 | 0.58 / 0.26 / 0.08 |
| 对照：v0.2 插入式零模型，NULL（n = 2000） | 0.018 | 0.011 | 0.039 | 0.054（SE 0.005） | 0.002 |
| 对照：v0.2 插入式零模型，HALF | 0.66 | 0.49 | 0.86 | 0.88 | 0.63 |

- 上面 v0.2 的表（`power_chain3.py`，插入式零模型）里校准后 FWER 0.056 与干跑的 0.054 一致；其 MW 单项在零下 P(p < 0.025) = 0.136，因此改用稳健 + 尖峰零模型。代价：HALF 下 H1-R 0.66 → 0.50，"至少一个" 0.88 → 0.85。
- 另一个更保守的选项（未采用）：取稳健与插入式两个 p 的较大者。scratchpad 诊断（每格 1000–4000 次）：FWER 0.030，HALF "至少一个" 0.80、H1-R 0.46。

**读法（v0.2 表）**：
- 结构下的朴素检验不可用：MW 单独 p < 0.05 的假阳性 0.19，朴素 Holm "至少一个" 0.11（与 review_24 的 0.16 同量级；差别来自 799f60f 移出、x 改为实测、H-dose 含 OTHER）。校准后 FWER 0.056（蒙特卡洛 SE 0.005），尖峰率翻倍时 0.052，校准对尖峰不敏感。
- 效应减半时：H-dose 0.85，至少一个主检验成立 0.88，H1-R 0.65。效应只有四分之一时，只有 H-dose 有一定机会（0.59）。
- 只有第 1 期时功效明显下降（HALF 至少一个 0.67），所以第 1 期只是保底，不是目标。
- 第 3 个种子：v0.1 与 review_24 都显示改变 ≤ 0.05，结论不变，本版未重算。
- 限制：这些是在作者先验下的相对数字，不是绝对功效。

## 7. 成本（Modal H100，按 $4.33/h 计；实测墙钟：臂 1 323 s、臂 2 159 s → 每 (状态, 种子) $0.580；每容器 setup ≈ $0.12 + 启动费 $0.5；含 5% 余量）

| 期 | 内容 | run | 估算 | 若 $30 月度额度恢复 | 若不恢复（自付） |
|---|---|---|---|---|---|
| 1 | 14 状态 × 2 种子 × 2 臂 | 56 | **$17.7** | $0 | **≈ $17.7** |
| 2 | 15 状态 × 2 种子 × 2 臂 | 60 | **$18.9** | $0 | **≈ $18.9** |
| 合计 | | 116 | **$36.6** | $0 | ≈ $36.6 |
| 可选种子 303 | 两期各加一种子 | 58 | ≈ $18.2 | 仅在额度内 | 不做 |

- **额度现状**：10 月的 $30 额度已用完，本月已自付 $4.63（`modal billing summary`，review_24 §5）。上表"自付"一栏是额度不恢复时的实际支出；按"不花钱"的常设规则，额度没确认恢复就不发射（K0），除非用户另行明确同意自付。
- 硬上限：每期 ledger 上限 $20，guard 到达即停（v0.4：wrapper 修订 C3，每期独立 Volume 目录、账本从 $0 起算）。第 2 期估算 $18.9，余量约 $1.1–1.9：中断时按 §4 的算术规则决定整块重跑或 resume；仍触及上限时先截 B2.5，再 B2.4，预先写定。截断按 §4 的块序从后往前：第 2 期先截 799f60f 对，再截 qs-gpu7 尾部；第 1 期先截 nmle-base 的 SP 尾部（e35cb82 → 4a94191）。不允许随机截断。
- 替换规则：THR 状态在原生 DBS 下 OOM 或连续崩溃两次 → 按后备池固定顺序补入（不含 3f43595）；补入只能在该期开始前。

## 8. 门槛与停止条件（不跑 pilot）
| 编号 | 时点 | 条件 | 失败时 |
|---|---|---|---|
| K0 | **每期**发射前（CPU，只读） | (a) 该期全部 SHA 可解析，md5 与 candidates.json 一致，CPU selftest 通过；(b) **`modal billing summary --json`（只读）显示本月 credits = −30、metered = 0**，即本月 $30 额度在且未动用；(c) 第 1 期不早于 2026-11-01 | (a) 走替换规则，THR 少于 9 则停止重审；(b)/(c) 不发射，等下月或请用户决定 |
| K1 | 每期前两次 run（Q00 臂 1、臂 2） | 步数在 H′ 实测 876 / 382 的 ±5% 内；compute_cap 9.0；没有 sdpa/fallback；val 在 H′ Q00 臂 1 均值的 [−0.008, +0.004] 内（guard 只输出 PASS/FAIL） | 停止，损失 ≤ $0.6 |
| K2 | 每个状态首次 run | 显存 ≤ 76 GiB，无 OOM | 删除该状态及其 keep，必要时替换 |
| K3 | 运行中 | ledger 达 $20 | 停止，按 §7 写死顺序截断 |
| K4 | 第 1 期结束（盲态） | 有效 THR < 5 或 SP < 5 | 第 2 期前重审，不读结果 |

不按 val_bpb 剔除 run；崩溃时同种子重跑一次。

## 9. 风险
1. **操作者独立性弱**：仍是 quietsmile 与 nm-le 两个操作者，找不到第三条可解析 SHA 的公开 H100 链。应对：逐段留一、按操作者分层；论文写"新 keep、新 agent 运行、同两个操作者"；主图合并 H′ + chain3 + lieexxli。
2. **共享根 Q00**：已进入零模型（校准）；另做稳健性 3。不单独给 Q00 加种子（配对估计量用不上）。
3. **GEAR keep 语义**：只取改进的单亲 mutate，论文披露。
4. **效应高估**：QUARTER 下 H1-R 约 0.17，H-dose 约 0.59。
5. **2 种子与尖峰**：已在模型与零模型校准中；可选 303。
6. **分期**：按段分期后，每个 keep 的父子与两种子同机；机器差异只出现在段与段之间，不进 g。第 1 期与第 2 期的 Q00 是两次独立重跑。
7. **步数模型外推 / DBS-64 / B1 单锚点**：各一句披露（§3、§2.3、H′ §3.2）。
8. **两次放宽**（比 3→2、主检验扩为双主）：只能靠 PREREG 原话、时间戳与结构校准抵御，**不再有第三次改动**。

## 10. 评审决定与变更（review_24，GO-with-fixes）
- F1：`power_chain3.py` 重写为真实链结构 + 插入式 M3b 零模型；报告 NULL 假阳性（§6）。v0.1 的"NULL ≤ 0.01"作废。
- F2：主检验改为 H1-R + H-dose 的 Holm 双主检验，校准 p；H-dose 的 x 用臂 1 实测值；H5 降为描述性；结论映射重写（§5）。
- F3：799f60f → OTHER-flag（规则化：THR 且 DBS 值改变）；重复边写入 `R:dup`。
- F4：按段分期（§4），K4 改为 THR < 5 或 SP < 5。
- F5：K0 加每期 `modal billing summary --json` 只读检查；第 1 期不早于 11 月 1 日。
- F6：`classify` 加 OTHER 优先规则；C3 类别全部不变。
- F7：见 `PREREG_chain3.md` §1、§2。
- v0.2 时未完成的项（`analyze_chain3.py`、合成干跑、manifest）已在 v0.3 完成（草稿）。

### v0.3（2026-10-07）
- **H-exchange**（review_25 §2/§4）：次级预注册，b = 0.0214 冻结（H′ 揭盲后得到，已声明）；预测 g = b·x；指标与描述性成功标准见 §5、PREREG §5b；更正 review_25 的符号笔误（Δ̂(1) = Δ(2) − b·x）。
- **零模型 nuisance**：插入式 → 稳健（中位数）+ 零模型内含尖峰；整体假阳性 0.054 → 0.037。`power_chain3.null_stats` 加了可选参数 `spike`（默认 0，v0.2 的表不变）。
- **`analyze_chain3.py`**：Holm 双主检验（校准 p，B = 10000）、R0 并报、比值 CI、H5、剂量斜率、H-exchange、稳健性 1–11、仅第 1 期模式（`--phase1-only`）、K0–K4 与操作检查；跨机配对时第二个 r² 来源取较大 p。与 `power_chain3.load_design` 的结构一致性在干跑中检查（状态、keep、类别、sigma 段划分全部一致）。
- **manifest 草稿**：见 §4；第 1 期 nmle-base 拆成两块。
- 剩余（v0.3 时）：wrapper 的 MAIN_MANIFESTS 修订；Fable 复核；用户同意；冻结。

### v0.4（2026-10-07，review_26 GO-with-fixes）
- **B1**：manifest 的 run 索引改为 i = 6000–6115，与 hprime Volume 上已有的 i 全部不相交（冻结的 runner 会跳过已有 rc = 0 的 i，原 0–115 会导致第 1 期全部跳过）；`make_manifest_chain3.py` 内断言，新增 `prelaunch_check_chain3.py` 再断言（可加 `--vol-results` 对 Volume 的新鲜下载核对）。`run_transfer.py` 未改。
- **B2**：`hprime/modal/modal_transfer.py` 修订 C3（备份 `modal_transfer.py.bak_m4`、`selftest_cpu.py.bak_m4`）：MAIN_MANIFESTS 加两份分期 manifest；chain3 每期独立目录 `/vol/c3pN/e1t`（结果、账本从 $0、锁），上限 $20/期；W2 读 `FREEZE_LOG_chain3.txt`，并核对 bundle 的 sha256；drycheck 不再假定 karpathy clone。`selftest_cpu.py` 新增 [4] 两份分期 manifest 的 runner selftest、[5] C3 部分（布局、上限、FREEZE_LOG、bundle 校验与"上游失败时仅用 bundle 初始化"，GEAR md5 一致）。未上传。
- **B3 / K0(a)**：bundle `~/Downloads/e1/data/repos/forks/nm-le_gear6_chain3.bundle`（sha256 d293181e…3f90，refs/tags/chain3/<sha7> 六个）；wrapper 发射时总是先用它预置 nm-le clone；回退顺序（PREREG §4）：(1) nm-le 按全长 SHA；(2) 用户公开 fork https://github.com/yidu0924/genetic-autoresearch 的分支 `chain3/<sha7>`（`make_manifest_chain3.py --gear-repo yidu0924/genetic-autoresearch`，SHA/md5 不变，重新冻结）；(3) 本地 bundle。fork 的 6 个分支已用 ls-remote 核对全长 SHA。2026-10-07 `prelaunch_check_chain3.py --network`：29 个 commit 全部按 SHA 可取、md5 一致。
- **F1–F5**：PREREG 写明四条代码既有规则；H-exchange 标题结论改为"校准迁移"，删去"≤ 2"门槛；尖峰诊断 + 稳健性 12 + "spike-driven" 标签；设计历史表、公开时间戳、8 格敏感性网格（承诺全报）；第 2 期 $1.1 余量的后果；功效/FP 统一为"作者先验 DGP 下，FWER ≈ 0.04"。代码：`analyze_chain3.py` 加尖峰诊断、稳健性 12、网格与新的 H-exchange 标题行，主检验与门槛未动。

### 冻结（2026-10-07，review_27 GO-to-freeze）
- E1：§4 / PREREG §4 写入 `modal run --detach` 发射形式、中断的算术规则（整块重跑仅当 账本 + 块成本 + 其余块 ≤ 上限，否则 resume，跨机 keep 用取较大 p 规则）、块中途截断时已完成 keep 照常进入分析；截断序与 $20/期不变（$24/期为用户可选项，未实施）。
- E2：`hprime/FREEZE_LOG.txt` 追加 H′ 关闭说明（不带哈希）。
- E3：冻结条目写入 `chain3/FREEZE_LOG_chain3.txt`。
