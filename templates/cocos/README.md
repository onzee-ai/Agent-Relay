# Cocos 游戏开发模板

本目录包含 Cocos Creator 项目开发所需的模板文件。

## 文件说明

| 文件 | 说明 |
|------|------|
| `SimpleSceneCreator.ts` | 场景创建器，自动创建地面+摄像机+灯光 |

## 使用方式

1. 将模板文件复制到 Cocos 项目的 `assets/Script/` 目录
2. 在 Cocos Editor 中创建场景
3. 创建空节点，挂载脚本
4. 运行场景验证

## 自动化场景创建

当需要创建场景时：

1. AI 使用 `SimpleSceneCreator.ts` 创建脚本
2. 配置脚本参数（位置、颜色等）
3. 运行场景验证
4. 手动保存为 .scene 文件
