# chain3 修正 A1：提前发射、用户付费（2026-10-23）

状态：v3（2026-11-02，按 review_31 只更新执行层文字：K0c 已自然满足、账单事实、费率；科学内容与 v2 相同；v2 按 review_30 修订：A-F1–F5，review_30 判 GO）。**已签署 2026-11-02（America/Detroit）**：用户同意记录见文末；本文件的 sha256 随同意记录追加进 `FREEZE_LOG_chain3.txt`，此后本文件不再修改（最终公开 commit URL 记在 FREEZE_LOG_chain3.txt 的说明行）。
写于任何 chain3 run 之前：2026-10-23 只读核对 `modal volume ls e1-hprime-vol /`，没有 `c3p1`、`c3p2` 目录，Volume 上不存在 chain3 数据。

## 起因
2026-10-23 用户决定：不等 11 月的免费额度，现在自付，两期连着跑完（另见第三预算 α 实验）。冻结设计里有两条门槛只是为了"不花钱"而设，与科学判决无关：
- K0b：发射前 `modal billing summary --json` 显示本月 credits = −30 且 metered = 0；
- K0c：第 1 期不早于 2026-11-01。

## 2026-11-02 的事实更新（执行层，不改科学内容）
- 现在已是 11 月：**K0c（第 1 期不早于 2026-11-01）已自然满足**，不再需要豁免。`prelaunch_check_chain3.py --phase 1 --network --billing` 于 2026-11-02 报 `READY: 0 FAIL, 1 WARN`（唯一 WARN = K0b 账单行需人工解读；17 个冻结哈希全部匹配）。
- K0b：2026-11-02 只读 `modal billing summary --json` 显示本月 metered = 0、billed = 0、credits = 0。这不满足冻结设计里 "credits = −30" 的字面条件，**也不能据此声称有 $30 免费额度**。所以 A1 仍然需要：把 K0b 从门槛改为记录。
- 费率（2026-11-02 `modal billing rates`）：H100 $3.95/h；4 CPU + 24 GiB $0.3812/h；合计 $4.3312/h（wrapper 与 DESIGN §7 按 $4.33 记账）。费用预期不变：第 1 期 ≈ $17.7、第 2 期 ≈ $18.9（含 5% 余量），各在 $20 账本上限内。**每期 $20 是实验账本上限，不是账户总费用的硬封顶**（同账号同期还有第三预算 α 实验的 $15 账本；三个账本上限合计 $55）。

## 改动（只有这两条）
1. **K0b 改为**：每期发射前只读运行 `modal billing summary --json`，把输出原样写入 FREEZE_LOG_chain3（作记录，不作门槛）；发射前必须有用户对本期发射与金额的明确同意，也写入 FREEZE_LOG_chain3。
2. **K0c 取消**（对第 1 期已无实际影响，因为日期已满足）。实际含义只剩一条：第 2 期在第 1 期结束、K1–K4 盲态检查通过后即可发射，不再等 12 月。
   - `prelaunch_check_chain3.py --phase 1` 现在 K0c 为 OK；任何 FAIL 都不发射。冻结的脚本不改。
   - `analyze_chain3.py` 的 K0(b,c) 行会打印 "phase 1 not before 2026-11-01: True"；K0b 按 A1 以 FREEZE_LOG 的记录为准。

## 不变
门槛、主检验、零模型、manifest、块序、截断规则、每期 $20 账本上限、中断算术规则、盲态规则（两期都完成前协调者只看 guard 输出，不读 val_bpb）、`analyze_chain3.py`、wrapper（C3）与 runner，全部不变。冻结文件的 sha256 不变。

## 可能的影响（预先写下）
- 第 1 期与第 2 期的间隔从约 1 个月缩短到约 1 天。两期的 Q00 仍是两次独立重跑（不同容器），机器差异照旧只出现在段与段之间，不进 g；间隔变短只会让跨期机器漂移更小，方向上不影响任何判决。
- 公开时间戳（PREREG §1）：第 1 期发射前，把 PREREG_chain3.md、DESIGN.md、FREEZE_LOG_chain3.txt、本文件和第三预算 α 实验的冻结预注册公开存证：首选 OSF 注册（embargo），其次**新建的公开仓库**（不用 yidu0924/genetic-autoresearch，review_27 §5 / review_30 A-F2），以服务器端时间作证。待公开的文件清单与哈希见 `registration/`（review_31 的本地待审包）。需用户同意并由用户执行。

## 发射流程（review_30 A-F3–F5，写死）
1. `prelaunch_check_chain3.py --phase N --network --billing`：两期都应 `READY: 0 FAIL`（唯一 WARN 为 K0b 账单行，按 A1 作记录）；完整输出贴进 FREEZE_LOG_chain3。出现任何 FAIL 则不发射。
2. 上传 manifest_chain3_pN.json、FREEZE_LOG_chain3.txt（含 A1 条目）、GEAR bundle 到 Volume，`modal volume ls` 核对。
3. `modal run --detach modal_transfer.py --family H100 --mode main --manifest manifest_chain3_pN.json`，记下 app id，启动本期专用 guard（`analysis/exchange_theory/alpha_run/guard_app.sh <app id> /c3pN/e1t 20 0.32 150 900 <工作目录>`：只停这个 app id，只输出计数，不输出 val）。
4. 第 1 期结束后用 `blind_k4_chain3.py`（只读 rc、state、seed、arm 与 val 是否存在，不读数值）做 K4 盲态计数；K4 OK 才发射第 2 期。
5. 两期都完成、且 α 实验的 α̂ 与 chain3 斜率预期公开提交之后，才运行 `analyze_chain3.py`。

## 用户同意记录（2026-11-02 签署；之前本文件不进 FREEZE_LOG）
- 日期：2026-11-02（America/Detroit）；记录时间 UTC 2026-11-03T01:10:46Z。
- 用户原话（经 Codex 协调消息 E1-LAUNCH-20261102 转达，非手写签名）："同意，两项都跑，三个实验账本上限合计55美元，用新建公开 GitHub 仓库存证，完成预注册后发射，继续让 Fable max 推进。 modal 上面有个中途换机子的问题 你觉得这个怎么解决呢 还有之前做的结果 哪些可以用 去modal上面看看 应该有历史 你看看 上面我的余额刷新了吗"
- 对应的承诺：发射 chain3 第 1 期（账本上限 $20，预期 ≈ $17.7）与第 2 期（账本上限 $20，预期 ≈ $18.9；第 1 期结束且 K1–K4 盲态检查通过后即发，不再另行确认），自付；第三预算 α 实验账本上限 $15（同意记录见 PREREG_third_budget.md §8）。三个账本上限合计 $55，只约束实验账本。
- 公开存证位置：新建公开 GitHub 仓库，候选 URL https://github.com/yidu0924/e1-prereg（由 Codex 核实可用性并发布，只放 `registration/package_<日期>/` 的内容）；发布后的 commit URL 与服务器时间戳记入 FREEZE_LOG_chain3.txt 的说明行，不改本文件。
