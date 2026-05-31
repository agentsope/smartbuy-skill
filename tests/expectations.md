# Self-Eval Fixture — price-detective

**作用**:回归保护清单。改完 skill 后,人工拿这些场景过一遍,检查输出是否还满足关键点。
**不是自动测试**:我们没 CI,但有这份清单 → 改完心里有底。

每个场景给:
- **input** — 用户大概会怎么说
- **expect_contains** — 输出**必须**包含的关键点(关键词/格式)
- **expect_not_contains** — 输出**绝不能**出现的(违反 no-fabrication)
- **mode** — 期望走哪个 Output Mode

---

## 场景 1 — judge / 新品(取自 e2e 001 真实数据)

```yaml
input: "MacBook Pro 14 M5 Pro 24G/1T 京东自营 16409,值不?"
mode: judge
expect_contains:
 - "国补" # 必须识别国补维度
 - "9 折" or "9.1%" or "折扣率" # 折扣率框架
 - "新品" or "曲线短" or "2 个月" # 新品 < 3 月要标
 - "建议" or "可以下手" or "该下手" # 判断式答案
 - "京东自营" or "京东" # 平台精确到自营级
 - "2026" # 抓取时间或报道时间
expect_not_contains:
 - "你必须" or "闭眼入" or "一定" # 不能剥夺用户决策
 - "大概" or "估计" # 不能模糊估算
 - "猜" # 不能瞎猜
```

## 场景 2 — timing / 老品(取自 e2e 003 真实数据)

```yaml
input: "罗技 MX Master 3S 现在京东 499,该买吗?"
mode: timing # 触发词隐含等大促思考
expect_contains:
 - "等" or "618" or "大促" # 时机判断核心
 - "历史" or "近 1 年" or "近一年" # 老品要看历史大促底
 - "299" or "348" or "362" or "366" # 至少出现一个真实历史大促价
 - "2024" or "2025" # 历史报道时间
expect_not_contains:
 - "肯定能更低" or "保证" # 不能拍胸脯保证未来
 - "凭感觉" or "应该" or "好像"
```

## 场景 3 — debunk / 渠道差价

```yaml
input: "拼多多 iPhone 16 Pro 6299 vs 京东自营 7999,差 1700 正常吗?"
mode: debunk
expect_contains:
 - "21" or "差价" or "百分比" # 差价百分比计算
 - "港版" or "教育版" or "翻新" or "激活机" # 渠道掉档陷阱
 - "百亿补贴" or "拼多多补贴" # 拼多多特殊路径
 - "序列号" or "查验" # 核实方法
expect_not_contains:
 - "直接买" # 警惕区间不能直接推荐
 - "假货" # 不能直接指控假货(没证据)
```

## 场景 4 — non-3c-fallback / 美妆(被 cosmetics-judge 替代后此场景废弃,见场景 4b)

```yaml
# 仅在 美妆规则未启用时适用
status: deprecated_in_v010_with_cosmetics_rules
input: "[非 3C 非美妆品类,例如食品] 三只松鼠每日坚果礼盒 ¥99 值吗?"
mode: non-3c-fallback
expect_contains:
 - "不下硬判断" or "这版我给不了" or "只在 3C"
 - "慢慢买 App" or "什么值得买" # 建议外部工具
expect_not_contains:
 - "该买" or "不该买" or "好价" # 非 3C/非美妆品类不下硬结论
```

## 场景 4b — cosmetics-judge / 美妆

```yaml
input: "雅诗兰黛小棕瓶 50ml 京东 906,值吗?"
mode: cosmetics-judge
expect_contains:
 - "克单价" or "¥/ml" or "ml" # 美妆维度核心
 - "保税" or "海淘" or "渠道" # 渠道差倍数
 - "等量买赠" or "赠品" # 美妆促销机制
 - "China-care" or "国行售后" or "售后" # 渠道风险
expect_not_contains:
 - "折扣率 9 折" # 美妆不用 3C 折扣率框架(等量买赠扭曲了)
 - "等大促能再降 30%" # 美妆大促不打面价
```

---

## 场景 5 — 拒绝编造(no-fabrication 触发)

```yaml
input: "你猜下罗技这款明天会降到多少?"
expect_contains:
 - "猜不了" or "不编" or "没法预测"
 - "历史" or "去年" or "上次" # 给真实历史替代
 - "需要内部信息" or "无法"
expect_not_contains:
 - "明天大概 ¥" or "估计能到 ¥" or "预计 ¥" # 不能瞎猜未来具体数字
 - "明天会降到 ¥" # 直接回答未来价格
# 备注:可以引用真实历史价(如 "上次 618 ¥299"),那不是猜测;
# 不能拍脑袋说 "明天大概 ¥350"。
```

## 场景 6 — 短链解不开

```yaml
input: "https://e.tb.cn/h.XXXXXX 这个价划算吗?"
expect_contains:
 - "短链" or "e.tb.cn" or "解不开" or "拿不到" # 诚实告知工具限制
 - "标准 PC 链接" or "item.taobao.com" or "配置 + 标价" # 给真实退路
expect_not_contains:
 - "我帮你解析了" # 不能假装解析成功
 - "这款应该是" # 不能从标题瞎补配置
```

## 场景 7 — 慢慢买没命中

```yaml
input: "罗技 MX Anywhere 3S 京东 469 值吗?" # 假设慢慢买搜不到,但 WebSearch 能找到
expect_contains:
 - "京东" or "WebSearch" or "IT之家" or "中关村" # 走 WebSearch 退路
 - "近 1 年" or "近期" or "历史"
expect_not_contains:
 - "慢慢买历史新低" # 不能假装慢慢买给了数据
 - "慢慢买标签"
```

## 场景 8 — 配置不全

```yaml
input: "买 MacBook Pro 该买哪个?" # 没具体配置,只问"哪个"
expect_contains:
 - "具体" or "配置" or "M5 还是 M5 Pro" or "多大内存" # 必须问配置
expect_not_contains:
 - "建议买 X" # 在没配置时不能擅自推荐
 - "推荐 M5 Pro"
```

---

---

## 场景 9 — 合法差价豁免

```yaml
input: "索尼 WH-1000XM5 海外版 1888 vs 国行 2488,差 600 怎么选"
mode: debunk + 合法差价豁免
expect_contains:
 - "国行" and "海外版"
 - "已知" or "合法" or "正常" # 不能误报假优惠
 - "China-care" or "国行售后" or "保修" # 必须解释差价来源
 - "看你" or "适合" or "决策" # 分流给适用人群
expect_not_contains:
 - "假货" or "翻新" or "钓鱼" # 这不是假优惠
 - "几乎确定有问题" # D-1 误报
# 备注:命中 D-1.5 豁免,不能套 D-1 阈值
```

## 场景 10 — 美妆全球同价例外

```yaml
input: "修丽可 CE 精华 30ml 京东 1020 是好价吗"
mode: cosmetics-judge + 全球同价例外
expect_contains:
 - "全球同价" or "国内官旗 就是最优" or "海淘反而" or "海淘不省"
 - "高浓度" or "L-抗坏血酸" or "活性成分" # 解释为什么贵
 - "国内" and ("¥1020" or "1020" or "国内价")
expect_not_contains:
 - "海淘省" or "海淘便宜" or "美国官网更便宜" # 修丽可不成立
 - "等大促能降 30%" # 美妆 + 同价品牌都不成立
```

## 场景 11 — 末代清库存(§7-1 应用,e2e 005 T1/T10)

```yaml
input: "iPhone 16 Pro 256G 京东 7199 能买吗"
mode: judge + §7-1 末代清库存
expect_contains:
 - "末代" or "停产" or "已发 17" or "清库存"
 - "5 折" or "72%" or "30%" or "历史性低价"
 - "谁该买" or "急用" or "性价比"
 - "保值" or "更新优先级" or "维修零件" # 末代的代价
expect_not_contains:
 - "闭眼入" # 末代不能无脑推
 - "保值" # 不能直接说保值好(末代不保值)
```

## 场景 12 — 多商品对比拒绝品类推荐(e2e 005 T8)

```yaml
input: "iPhone 16 Pro 7199 还是 小米 14 Ultra 3499,买哪个"
mode: judge × 2 + Boundary #8
expect_contains:
 - "分别" or "两个都" or "各自" # 分拆判断
 - "替你选" or "不替" or "不做品类推荐" # 拒绝选品牌
 - "iPhone" and "小米" # 真分别判断了
 - "需求" or "看你" or "适合" # 引导用户按需求选
expect_not_contains:
 - "我推荐买 X" or "建议你买 X" # 不替选
```

## 场景 12.5 — 估算价必须标

```yaml
input: "飞利浦电动牙刷 HX9362 京东 369 值吗"
# 上市原价没拿到精确数据 → 模型可能引用 "上市原价 ~¥1500"
mode: judge + 估算标注
expect_contains:
 - "估算" or "约" or "上市价" or "未独立核实" # 任何模糊词必须标
 - "京东" and "369" # 真实抓到的价
 - "618" or "秒杀" or "节点底" # 真实历史促销节奏
expect_not_contains:
 - "原价 ¥1500"(单独出现,不带"约/估算/未核实" 任一) # 不能把估算写成事实
# 备注:no-fabrication DTS-01 三件套硬约束在估算价上的应用
```

## 场景 13 — 数据不足时优雅退路(e2e 005 T4)

```yaml
input: "戴尔 U2723QE 京东 3549 值吗" # 国补/历史曲线拿不到
mode: judge → 数据不足退路
expect_contains:
 - "数据" and ("有限" or "不足" or "拿不到")
 - "你自己" or "你确认" or "请告诉我" # 让用户补数据
 - "下单页" or "京东" or "慢慢买 App" # 给具体补法
expect_not_contains:
 - "建议下手" or "强烈推荐" # 数据不足不能硬推
 - "大概" or "估计" or "应该差不多" # 不能模糊填空
```

---

---

## 场景 14 — coupon-stacker 算实付

```yaml
input: "京东自营 iPhone 16 128G ¥5999,我有京享红包 ¥50、PLUS 会员、北京户云闪付国补资格。最终实付多少?"
mode: calc-final
skill: coupon-stacker
expect_contains:
 - "5249" or "实付" # 真实计算结果
 - "红包" and "PLUS" and "国补" # 3 类优惠都识别
 - "封顶" or "500" # 国补封顶 ¥500
 - "云闪付" or "支付" # 操作步骤
 - "结算" or "下单页" or "为准" # 不替用户下单
expect_not_contains:
 - "大概" or "估算" # 算实付要精确
 - "应该可以叠" # 不编互斥规则
```

## 场景 15 — coupon-stacker 国补品类不符(关键边界)

```yaml
input: "罗技 MX Master 3S 京东 ¥499,我有国补,实付多少?"
mode: calc-final + 品类不符警告
skill: coupon-stacker
expect_contains:
 - "鼠标" or "外设" or "不在" or "不享" # 必须告诉用户鼠标不在国补
 - "手机" or "平板" or "家电" or "电脑" # 列出国补品类
expect_not_contains:
 - "国补减 75" or "国补 15% × 499" # 不能瞎算不适用品类的国补
```

## 场景 16 — coupon-stacker 凑单值不值

```yaml
input: "购物车 ¥499,差 ¥1 能用满 500-50,值得凑吗?"
mode: add-to-cart-suggest
skill: coupon-stacker
expect_contains:
 - "值得" or "强烈" # 加 ¥1 省 ¥49 必须推
 - "49" or "48" # 真实算出多省多少
 - "1 件" or "凑单 ¥1" # 加什么件
expect_not_contains:
 - "加 ¥100" # 不能瞎建议加贵的
```

## 场景 17 — promo-predictor 预测区间

```yaml
input: "罗技 MX Master 3S 现在 ¥499,等双 11 能到多少?"
mode: predict-range
skill: promo-predictor
expect_contains:
 - "区间" or "¥" and "-" and "¥" # 区间不是单点
 - "置信度" # 必标置信度
 - "末代" or "MX Master 4" # 末代换代风险
 - "不保证" or "再问" # 时效声明
expect_not_contains:
 - "肯定" or "一定" or "保证" # 不打包票
 - "双 11 ¥348"(单点,无区间) # 必须区间
```

## 场景 18 — promo-predictor 数据不足退路

```yaml
input: "iPhone 17 Pro 现在 9999,等双 11 能到多少?"
mode: data-insufficient-fallback
skill: promo-predictor
expect_contains:
 - "新品" or "数据不足" or "无法预测"
 - "至少 3" or "3 个时点" # 解释为什么不能预测
 - "类比" or "参考" # 给替代信号
expect_not_contains:
 - "双 11 ¥X-Y 置信度高" # 数据不足不能给高置信
```

## 场景 19 — 3 skill 协作完整闭环

```yaml
# 这是一个连续对话,不是单 turn
input_1: "罗技 MX Master 3S 京东 499 该买吗?"
expected_skill_1: price-detective
expect_1_contains: ["¥348", "国补", "末代"]

input_2: "那等双 11 能到多少?"
expected_skill_2: promo-predictor
expect_2_contains: ["区间", "置信度", "末代换代"]

input_3: "决定现在买,怎么叠券实付最低?"
expected_skill_3: coupon-stacker
expect_3_contains: ["实付", "京东", "操作步骤"]
```

---

## 运行方式

人工跑(没自动化):

1. 装好 skill
2. 在 Claude Code 里复制 `input` 字段当输入
3. 拿 skill 的回答 grep `expect_contains` 关键词(都要 ✓)
4. 拿 skill 的回答 grep `expect_not_contains` 关键词(都要 ✗ 找不到)
5. 任一项不满足 → 记 bug,用 `.github/ISSUE_TEMPLATE/bug-report.md` 报告

每次改 SKILL.md 或 references 之后,**至少跑 1-3-5 这三个核心场景**。
