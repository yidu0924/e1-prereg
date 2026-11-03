# 执行层 Addendum A2：严格 H100 调度（2026-11-02 America/Detroit；UTC 2026-11-03T01:23:05Z）

## 事件
- 2026-11-03T01:17:46Z 发射 chain3 第 1 期（app `ap-QUxyQlwufxbI0ldNCFYdIk`，冻结 wrapper `transfer/hprime/modal/modal_transfer.py`，`gpu="H100"`）。Modal 分配的是 **NVIDIA H200**（GPU-fc2769c1-82ee-03a6-19ed-6a7e700b0c2c，143771 MiB）。
- 冻结 runner `transfer/hprime/run_transfer.py` 在 `FAMILY_OK` 断言处拒绝（`AssertionError: wrong GPU for family H100: NVIDIA H200`），rc = 1，**没有任何训练 run 发生**；c3p1 账本记 $0.5262（容器启动费 + 约 20 s），**保留不清零**。app 于 2026-11-03T01:20:21Z 停止，已核实。
- 同时发射的 α CPU 准备（app `ap-iRdS7CXLsIOwNEJ4G2KPYv`）不涉及 GPU，STAGE PASS（01:18:40Z），镜像 27 个文件，账本 $0.1045。

## 原因
Modal 官方文档 https://modal.com/docs/guide/gpu 的 "Automatic upgrades to H200s"：对 `gpu="H100"` 的请求可能自动升级到 H200；要禁用升级（基准测试场景）须写 `gpu="H100!"`，价格不变。

## 修正（只改资源声明，不改科学规则、不改预算、不放宽 runner 的 H100 断言）
为保持冻结文件一字不改，使用**派生执行副本**，与冻结 wrapper 逐字节相同，只把 `run_h100` 的 `gpu="H100"` 改为 `gpu="H100!"`：

```
--- transfer/hprime/modal/modal_transfer.py
+++ transfer/hprime/modal/h100strict/modal_transfer.py
@@ -399,3 +399,3 @@
 
-@app.function(gpu="H100", cpu=4, memory=24576, **KW)
+@app.function(gpu="H100!", cpu=4, memory=24576, **KW)
 def run_h100(mode: str, manifest: str, billed: float = 0.0):
--- analysis/exchange_theory/alpha_run/modal_alpha.py
+++ analysis/exchange_theory/alpha_run/h100strict/modal_alpha.py
@@ -268,3 +268,3 @@
 
-@app.function(gpu="H100", cpu=4, memory=24576, **KW)
+@app.function(gpu="H100!", cpu=4, memory=24576, **KW)
 def run_h100():
```

sha256：
- 冻结 `transfer/hprime/modal/modal_transfer.py`：5b9a2990f9fff360deeb2544b80674d10d15994d4104b23bc82f586369f14d1d（不变）
- 派生 `transfer/hprime/modal/h100strict/modal_transfer.py`：842c4cb4f4ef19d1d21ac9d8206fc90f33733dcfc96d5f69503780cada80adf7
- 冻结 `analysis/exchange_theory/alpha_run/modal_alpha.py`：5848b31990ed10ef091fd01ab5bb30d7b008f2de4001cdb013dd6e7075376267（不变）
- 派生 `analysis/exchange_theory/alpha_run/h100strict/modal_alpha.py`：e8b72806f83094d570618da0839dac5f809ea7db4b14d2c0a5bdd8df79614b83

派生副本的哈希以新行追加到 `FREEZE_LOG_chain3.txt` / `FREEZE_LOG_alpha.txt`（同一文件名，wrapper 的 W2 自检取最新一行），原有哈希行一律不动。此后的发射命令改为 `modal run --detach h100strict/modal_transfer.py ...` 与 `modal run --detach h100strict/modal_alpha.py --mode main`。

## 对预算与设计的影响
- 预算：c3p1 账本从 $0.5262 续记，重新发射再计 $0.5 启动费，第 1 期预期 ≈ $18.7（上限 $20 不变，余量约 $1.3；若再出意外按冻结截断规则从最后一块起截，不追加预算）。第 2 期、α 预算不变。
- 设计：K1 参考（H100 上 876 / 382 步）、runner 的 H100 断言、manifest、分析脚本全部不变。本 addendum 只兑现已预注册的 "H100" 条件。
