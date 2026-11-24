# RegionShotBridge

给 [RegionShot](https://github.com/) 加一个可点/可自动化的 URL 入口。

RegionShot 本身不注册任何 URL scheme，它内部真正触发「默认截图」的通道是 Darwin 通知：
`com.moxuan.regionshot/TakeScreenshot`。本工程就是一个极小的 app bundle，向 LaunchServices 注册
`regionshot://`，收到 URL 后转发成这条通知，然后立刻退出。

## URL

| URL | 行为 |
| --- | --- |
| `regionshot://shot` | 触发 RegionShot 默认截图 |
| `regionshot://` | 同上 |
| `regionshot://reload` | 让插件重载设置（`com.moxuan.regionshot/ReloadPrefs`） |

冷启动约 0.15–0.8s 会闪一下本 app 的启动画面，这是 URL scheme 宿主的固有代价。
需要完全无闪，得把处理逻辑放进 SpringBoard 注入的 tweak 里，让本 app 只承担注册。

## 安装

从 Release 下载 `.deb`，或：

```bash
dpkg -i --force-depends RegionShotBridge_*.deb
# roothide / rootless
/var/jb/usr/bin/uicache -a
```

装完确认 scheme 已注册：

```bash
open regionshot://shot
```

## 构建

本机（macOS Intel + Theos roothide + iOS 16.5 SDK）：

```bash
make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=roothide
```

CI：`.github/workflows/build.yml` 跑在 `macos-15-intel` 上，克隆 `roothide/theos`，
优先用 `iPhoneOS16.5.sdk`，没有则退回 `latest`，产物在 Actions Artifacts。

## 发布

- 打 tag：`git tag v1.0.0 && git push origin v1.0.0`
- 或在 Actions 里手动 `Run workflow` 并填 version，工作流会自动建 tag + Release 并附上 deb。

## 说明

- 依赖 RegionShot（`com.moxuan.regionshot`），包里已写 `Depends`。
- 本 app 无 UI、无图标资源依赖，唯一职责是持有 scheme。
- RegionShot 的开关必须是开启状态，且 SpringBoard 处于活跃状态，否则通知无人处理。
