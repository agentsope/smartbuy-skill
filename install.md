# 安装指南 / Installation

`smartbuy-skills` 的每个 skill 是一个**自包含文件夹**(`skills/{skill-name}/`,内含 `SKILL.md` + `references/` + `examples/`)。下面任一方式都会把整个文件夹带上;**别只拷 `SKILL.md`**,否则会丢掉 `references/` 里的判断规则,功能静默失效。

> 先装好 [Claude Code](https://docs.claude.com/en/docs/claude-code)。把下文 `agentsope` 换成你实际的 GitHub 用户名 / 组织名。

---

## 3 个 skill 可单独装,也可一起装

| skill | 解决什么 | 何时装 |
|---|---|---|
| 🧮 **price-detective** | 这价划算吗 | 主 skill,**必装** |
| 🎟️ **coupon-stacker** | 凑多少能到手最低 | 大促前装,平时也好用 |
| 🔮 **promo-predictor** | 等大促还能更低吗 | 中等优先 |

3 个 skill **可独立使用** —— 装了任何 1 个都能工作。**一起装 = 完整购物决策闭环**。

---

## 方式 A — npx 一行装(推荐)

**只装 price-detective(快速试)**:

```bash
npx skills add agentsope/smartbuy-skill/skills/price-detective
```

**装完整 3 件套**:

```bash
npx skills add agentsope/smartbuy-skill/skills/price-detective
npx skills add agentsope/smartbuy-skill/skills/coupon-stacker
npx skills add agentsope/smartbuy-skill/skills/promo-predictor
```

`skills` CLI 来自 [skills.sh](https://skills.sh),会把整个 skill 文件夹装好。

---

## 方式 B — Claude Code 插件市场(整包一次装)

```text
/plugin marketplace add https://github.com/agentsope/smartbuy-skill
/plugin install smartbuy-skills
```

整 pack 一次装好,包含全部 3 个 skill。

---

## 方式 C — 手动 copy

```bash
git clone https://github.com/agentsope/smartbuy-skill.git
cd smartbuy-skills

# 装 price-detective(必装)
cp -R skills/price-detective ~/.claude/skills/

# 加装 coupon-stacker(可选,大促必备)
cp -R skills/coupon-stacker ~/.claude/skills/

# 加装 promo-predictor(可选,预测大促价)
cp -R skills/promo-predictor ~/.claude/skills/
```

> ⚠️ 一定是 `cp -R 整个文件夹`;只复制 `SKILL.md` 会丢 `references/`(判断规则全在那)。`git pull` 后重拷即可更新。

---

## 方式 D — 其他 agent / 便携使用

整个 skill 文件夹就是个便携 prompt bundle:把 `skills/<skill-name>/` 整体喂给任何支持长上下文的 agent,`SKILL.md` 是入口,`references/` 按需展开。

---

## 验证安装

### 验证 price-detective(主 skill)

随便给一个 3C 商品 + 价格测一下:

> 罗技 MX Master 3S 现在京东 499,该买吗?

`price-detective` 应触发,先给一句判断("建议等 618" 类 + 末代提示),再列历史大促价对照表,结尾问要不要看完整对比。

如果是国际大牌护肤:

> 雅诗兰黛小棕瓶 京东 ¥906,值吗?

走 `cosmetics-judge` 模式,给克单价 + 渠道差倍数 + 4 个决策点框架。

### 验证 coupon-stacker(凑单算账)

```text
京东自营 iPhone 16 128G ¥5999,我有京享红包 ¥50、PLUS 会员、北京户云闪付国补资格。最终实付多少?
```

`coupon-stacker` 应输出实付 ¥5249 + 4 步操作 + 风险提示。

### 验证 promo-predictor(大促预测)

```text
罗技 MX Master 3S 现在 ¥499,等双 11 能到多少?
```

`promo-predictor` 应给"大概率 ¥348-391 区间,置信度中,末代换代风险" + 建议。

### 验证 3 skill 协作(完整购物决策闭环)

跑 3 个问题(连续问):

1. "罗技 MX Master 3S 京东 499 该买吗?" → `price-detective` 判断
2. "等双 11 能到多少?" → `promo-predictor` 预测
3. "决定现在买,怎么叠券最低?" → `coupon-stacker` 算实付

3 个 skill 应自动切换响应,**这是 mini pack 的核心价值**。

---

## 维护者:更新共享件

```bash
# 在 shared/ 改完文件后,跑同步脚本
bash scripts/sync-shared.sh
```

这会把 `shared/no-fabrication.md` 复制到每个 skill 的 `references/`,保持每个 skill 自包含。

---

## 卸载某个 skill

```bash
rm -rf ~/.claude/skills/price-detective # 或其他 skill 名
```

可独立卸载,不影响其他 skill。

---

*中文优先(国内购物场景)。把 `agentsope` 换成你的 GitHub 用户名 / 组织名。*
