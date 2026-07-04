# Discourse Freeze Plugin

账号冻结插件 - 允许管理员冻结用户账号，提供以下两种冻结原因：

- **账号被盗** (Account stolen)
- **用户已离世** (User has passed away)

## 功能特性

- 仅管理员可冻结/解冻用户
- 提供两种预设冻结原因
- 冻结后用户无法访问站点
- 管理后台提供直观的冻结管理界面
- 自动记录冻结/解冻操作日志

## 安装

1. 将插件克隆到 Discourse 的 `plugins` 目录
2. 运行 `./bin/rails db:migrate` 执行数据库迁移
3. 重新启动 Discourse
4. 在站点设置中启用 `freeze_enabled`

## 使用

1. 以管理员身份登录 Discourse
2. 进入 **设置 > 插件**，确保该插件已启用
3. 在管理员侧边栏点击 **冻结用户**
4. 搜索用户并选择冻结原因
5. 确认冻结

## API 端点（管理员专用）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/freeze/list` | 获取已冻结用户列表 |
| POST | `/freeze/create` | 冻结用户 (`user_id`, `reason`) |
| POST | `/freeze/revoke` | 解冻用户 (`user_id`) |
| GET | `/freeze/search_users` | 搜索用户 (`q=keyword`) |
