# Feature List JSON Schema 参考

feature-list.json 是 Agent Relay 的核心数据文件，定义了项目的完整功能清单。

## 顶层结构

```json
{
  "project": "项目名称 (string, 必填)",
  "version": "版本号 (string, 必填)",
  "created_at": "创建日期 (string)",
  "features": []
}
```

## Feature 对象

```json
{
  "id": "F001",
  "category": "core",
  "title": "功能标题",
  "description": "功能描述",
  "priority": 1,
  "steps": ["步骤1", "步骤2"],
  "test_criteria": ["测试条件1"],
  "passes": false,
  "dependencies": ["F001"],
  "notes": ""
}
```

## 字段说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | string | 是 | 格式 F001-F999，唯一标识 |
| category | string | 是 | 分类，见下方枚举 |
| title | string | 是 | 功能标题 |
| description | string | 是 | 功能描述 |
| priority | integer | 是 | 1-5，1 为最高优先级 |
| steps | string[] | 是 | 实现步骤，至少 1 项 |
| test_criteria | string[] | 是 | 测试验证条件，至少 1 项 |
| passes | boolean | 是 | 是否通过测试 |
| dependencies | string[] | 否 | 依赖的功能 ID 列表 |
| notes | string | 否 | 备注信息 |

## Category 枚举

- `setup` — 项目搭建与配置
- `core` — 核心业务逻辑
- `ui` — 用户界面
- `auth` — 认证与授权
- `data` — 数据管理
- `api` — API 接口
- `test` — 测试
- `deploy` — 部署
- `a11y` — 无障碍访问
- `perf` — 性能优化

## 功能选择规则

按以下优先级自动选择下一个功能：
1. `passes` 为 `false`
2. `priority` 数值最小
3. 所有 `dependencies` 已完成
4. `id` 编号最小
