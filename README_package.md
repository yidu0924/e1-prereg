# E1 公开存证包（本地待审，2026-11-02）

这是**只在本地生成**的待审包，没有上传、没有公开。它回答一个问题："如果公开存证，哪些文件会公开、哪些只公开哈希"。
用途：chain3 预注册 §1 要求在第 1 期之前把冻结文本放到公开、服务器端带时间戳的地方（首选 OSF 注册并 embargo，其次新建只放这些文件的公开 GitHub 仓库；不要用 yidu0924/genetic-autoresearch，见 review_27 §5）。

## 状态（生成时自动核对；发布前必须全部为"是"）
- chain3 冻结哈希：18 条，全部匹配。
- AMENDMENT_A1.md：已填写同意记录。
- 第三预算 α 实验：已冻结（FREEZE_LOG_alpha.txt 存在）。
- 缺失的文件：无。
- 因含第三方代码摘录而拒绝复制的文件：无。

**授权与执行：用户已于 2026-11-02 明确同意两项实验、三个账本上限合计 $55、新建公开 GitHub 仓库存证并在预注册后发射。A1 与 α 预注册中记录用户原话；代理据此完成冻结和发布，不伪造手写签名。公开前重新生成本包并核对全部哈希。**

## 包里实际包含的文件（会公开）
只有预注册文本（FILE_LIST.tsv 中的 PUBLIC-TEXT 组）：
- `transfer/chain3/PREREG_chain3.md`
- `transfer/chain3/DESIGN.md`
- `transfer/chain3/FREEZE_LOG_chain3.txt`
- `transfer/chain3/AMENDMENT_A1.md`
- `analysis/exchange_theory/PREREG_third_budget.md`
- `analysis/exchange_theory/alpha_run/FREEZE_LOG_alpha.txt`
- `analysis/exchange_theory/THEORY.md`
再加本说明、`FILE_LIST.tsv`、`HASHES_sha256.txt`、`verify.sh`。

## 只公开哈希、不在包里的文件
### 我们自己的冻结代码与合成干跑输出（HASH-ONLY-CODE）
- `transfer/chain3/analyze_chain3.py`
- `transfer/chain3/power_chain3.py`
- `transfer/chain3/prelaunch_check_chain3.py`
- `transfer/chain3/make_manifest_chain3.py`
- `transfer/chain3/build_candidates.py`
- `transfer/chain3/dryrun_chain3.py`
- `transfer/chain3/dryrun_chain3_output.txt`
- `transfer/chain3/power_chain3_output.txt`
- `transfer/chain3/blind_k4_chain3.py`
- `transfer/hprime/run_transfer.py`
- `transfer/hprime/modal/modal_transfer.py`
- `transfer/hprime/modal/selftest_cpu.py`
- `analysis/exchange_theory/exchange_model.py`
- `analysis/exchange_theory/outputs/exchange_model.json`
- `analysis/exchange_theory/outputs/exchange_model_output.txt`
- `analysis/exchange_theory/alpha_run/make_manifest_alpha.py`
- `analysis/exchange_theory/alpha_run/manifest_alpha.json`
- `analysis/exchange_theory/alpha_run/modal_alpha.py`
- `analysis/exchange_theory/alpha_run/analyze_alpha.py`
- `analysis/exchange_theory/alpha_run/dryrun_alpha.py`
- `analysis/exchange_theory/alpha_run/dryrun_alpha_output.txt`
- `analysis/exchange_theory/alpha_run/selftest_alpha.py`
- `analysis/exchange_theory/alpha_run/guard_app.sh`
建议（由用户决定，不混进默认包）：这些是我们自己写的分析代码和合成输出，不含数据、不含第三方代码。把它们一起公开会让"分析代码在时间戳之前已定稿"的证据更强（审稿人可以直接读到冻结的检验）；如果用户同意，可以作为第二个文件夹加入同一次 OSF 注册或同一个仓库。默认只公开哈希。

### 第三方代码摘录与数据（HASH-ONLY-PRIVATE，绝不公开）
- `transfer/chain3/candidates.json`
- `transfer/chain3/manifest_chain3.json`
- `transfer/chain3/manifest_chain3_p1.json`
- `transfer/chain3/manifest_chain3_p2.json`
- `data/repos/forks/nm-le_gear6_chain3.bundle`
- `transfer/hprime/results_all.jsonl`
- `transfer/hprime/unblind_output.txt`
- `transfer/hprime/manifest_final.json`
- `transfer/hprime/FREEZE_LOG.txt`
原因：candidates.json 与三份 chain3 manifest 含 keep 的 diff 行（第三方代码摘录，上游无 LICENSE）；bundle 是第三方 git 对象；results_all.jsonl / unblind_output.txt 是第一项研究的数据与结果（随论文发布，不在存证包里）。

## 存证包证明什么
公开提交的是上面的预注册文本全文和 `HASHES_sha256.txt`。任何人以后都能核对：(1) 预注册文本在时间戳之前已定稿；(2) 哈希清单覆盖了没有公开的分析代码与输入（candidates、manifest、bundle、第一项研究的数据），所以它们也不能事后改动。它**不**证明实验没有跑过——这由 Modal 账单与 Volume 上 run 的时间戳佐证。

## 怎么用
1. 核对 A1 的用户授权记录和 α 冻结日志，然后重新运行 `python registration/make_registration_package.py`，确认上面"状态"全部为"是"。
2. 本地核对：`bash package_2026-11-02/verify.sh`（逐文件打印 OK / MISSING / MODIFIED；有任何一项不是 OK 就退出非零）。
3. OSF：新建 Registration（Open-Ended），上传本目录全部文件，选 embargo；把注册 URL 追加为一行说明到 FREEZE_LOG_chain3.txt（不改已有哈希行）。
4. 或 GitHub：新建公开仓库（例如 `e1-prereg`），一次 commit 放入本目录全部文件；论文引用 GitHub API 的 `created_at` 与 commit URL。
