# shell-sub

一个基于 Shell 的简易 Proxy Provider 提取脚本

前排提示！！

个人自用，能正常运行就行，功能应该不会再加了（只是 Clash 没有根据节点名字分流的功能而写的（

千万别去看源代码，灾难现场（（（（

# Table

- [shell-sub](#shell-sub)
- [Table](#table)
- [How-to-use](#how-to-use)
  - [Why](#why)
  - [Feat](#feat)
  - [Use](#use)
    - [list.txt](#listtxt)
    - [make.sh](#makesh)
  - [Export](#export)
  - [Clash-config](#clash-config)
    - [proxy-providers](#proxy-providers)
    - [proxy-groups](#proxy-groups)
- [Todo](#todo)
- [Contributing](#contributing)
- [License](#license)

# How-to-use

经测试, macOS、Ubuntu、Android Termux 均能正常使用

## Why

接受的订阅格式: 完整、新的 Clash 配置文件. 什么? 订阅没有完整的 Clash 配置文件? 其实可以去 https://sub.dler.io/ 这里转化呢

[这里](https://sub.dler.io/)转化完的直接可以用? 那没事儿了, 我嘛, 就是遇到这里的订阅导入后一直报错, 才写了这个呢 🤣

```
initial proxy provider Clash-Sub error: yaml: line 28: mapping values are not allowed in this context
```

## Feat

- 极奇轻量( 毕竟就一个 shell 脚本嘛
- 配置简单( 复制粘贴订阅链接, 再想个文件名就行啦
- 更新无忧( 不需要手动更新订阅! 一次导入即可
- CI 支持( GitHub Actions 吼啊
- 批量生成( 废话

## Use

可修改的配置在 `list.txt` 与 `make.sh` 的指定位置

### list.txt

每行可写入订阅链接以及文件(任意)名字, 需要用空格 ` ` 分隔开, [示例](./list.example.txt)

### make.sh

说明打注释里了~

```shell
configGenerate="true" # 配置文件自动生成 'ture' -> 开; 'flase' -> 关
templateFileURL="https://gist.githubusercontent.com/LufsX/a522b340a8e62e008c049c39a82951a0/raw/clash.yaml" # 默认示例配置文件地址, 仅支持直链
link="https://lufsx.github.io/shell-sub/" # HTTP 订阅地址, 若文件部署在网络上
templateFilePath="./Template.yaml" # 模板文件地址, 一般不用动
## 需要被替换的 URL
## 一般不需要改( 前提是用我的配置文件 🤣
replaceKey="https://url" # 修改范围是整个文件, 需要唯一字符
replaceSEKey="https://se.url"# 港澳台, 修改范围是整个文件, 需要唯一字符
## 各 ProxyList 路径
## 一般不需要改( 前提是用我的配置文件 🤣
replacePath="List.yaml" # 修改范围是整个文件, 需要唯一字符
replaceSEPath="List-SE.yaml" # 修改范围是整个文件, 需要唯一字符
```

注意 ⚠️️: 部分系统不自带 `wget`, 需自行安装

## Export

脚本会在目录:

- `./public/Proxy/` 中下载订阅文件.
- `./public/ProxyList/` 下则是提取出来的 `Proxy Provider` 文件, 文件按 `list.txt` 中的命名为 `xxx.yaml`, 可直接写入 clash 配置文件中的 [`proxy-providers:`](https://lancellc.gitbook.io/clash/clash-config-file/proxy-provider) 节点使用
- `./public/ProxyList/SE/` 下则是过滤出的港澳台 `Proxy Provider` 文件
- `./public/links/` 下则是自动生成的完整配置文件( 可直接使用
  - 导出链接例: `https://lufsx.github.io/shell-sub/links/Example.yaml`

## Clash-config

Clash 配置文件示例:

### proxy-providers

```yaml
# 服务器节点订阅
proxy-providers:
  Example: # Provider 名称
    type: https://lufsx.github.io/ProxyList/Example.yaml
    path: # 文件路径
    url: # 只有当类型为 HTTP 时才可用
    interval: # 自动更新间隔，仅在类型为 HTTP 时可用

  Example-SE: # Provider 名称
    type: https://lufsx.github.io/ProxyList/SE/Example.yaml
    path: # 文件路径
    url: # 只有当类型为 HTTP 时才可用
    interval: # 自动更新间隔，仅在类型为 HTTP 时可用
```

### proxy-groups

```yaml
# 注意此处的「use」而不是「proxies」，当然也可以不用在此先嵌套一个策略组进行选择，可以直接使用，如
#
# # 代理节点选择
# - name: "PROXY"
#   type: select
#   use:
#     - DuckDuckGo # 嵌套使用订阅节点策略组
#   proxies:
#     - Fallback
#     - 1
#     - 2
#     - 3
#
# 但如果订阅节点很多选起来就很麻烦，不如先嵌套一个策略组进行手动或自动的选择。

# 手动选择订阅节点
- name: "Proxy"
  type: select # 亦可使用 fallback 或 load-balance
  use: # 注意此处是「use」
    - Example # 这是上面「proxy-providers」的名称

- name: "Example-SE"
  type: select # 亦可使用 fallback 或 load-balance
  use: # 注意此处是「use」
    - Example-SE # 这是上面「proxy-providers」的名称
```

# Todo

- [x] 自动生成完整的配置文件
- [ ] 公共环境安全部署
- [ ] 自定义节点排序
- [ ] checkCommand
- [ ] 优化配置文件生成
- [ ] 重构代码, 增加 Python 版本(学习中~)

# Contributing

菜鸡啥都不会, 请帮助我做的更好

欢迎提 PR 呀 😆

# License

MIT © 2020 Lufs
