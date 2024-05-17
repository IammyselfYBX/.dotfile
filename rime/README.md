# 我的Rime配置文件

## 各文件夹说明
### 一、系统自带
```$RIME_HOME ``` 代表rime的家目录

```buile```文件夹是每次 ibus restart 自动生成的,删除后会重新生成

#### 1) 调试全局方案
参考```$RIME_HOME/build/default.yaml```

#### 2) 针对"明月拼音"的单独方案，切换方案会失效
```$RIME_HOME/build/luna_pinyin.schema.yaml```

#### 3) 常规设置，定制外观
```$RIME_HOME/buile/weasel.yaml```

#### 4) 定义键盘对应的符号
```$RIME_HOME/buile/symbols.yaml```

> 由于rime更新之后会覆盖掉之前的修改所以不建议直接修改系统自带

### 二、用户自定义
> 以下文件如果没有可以自己创建
#### 1) rime的家目录用```$RIME_HOME```代替
```~/.config/ibus/rime/```

#### 2)用户全局设置
```$RIME_HOME/default.custom.yaml```

#### 3)用户明月拼音设置
```$RIME_HOME/luna_pinyin.custom.yaml```

#### 4)用户常规设置，定制外观
```$RIME_HOME/weasel.custom.yaml```




## 配置部署
```bash
ibus-daemon -drx
```

## 参考
[ibus-rime配置文件：https://github.com/jayknoxqu/ibus-rime](https://github.com/jayknoxqu/ibus-rime)<br>
[rime说明书：https://github.com/rime/home/wiki/UserGuide](https://github.com/rime/home/wiki/UserGuide)<br>
[定製指南（初階）：https://github.com/rime/home/wiki/CustomizationGuide](：https://github.com/rime/home/wiki/CustomizationGuide)<br>
[輸入方案設計書（中階）：https://github.com/rime/home/wiki/RimeWithSchemata](https://github.com/rime/home/wiki/RimeWithSchemata)<br>
[程序開發（高階）：https://github.com/rime/home/wiki/RimeWithTheCode](https://github.com/rime/home/wiki/RimeWithTheCode)<br>

## 文件结构
```bash
.
├── color_schemes       # 配色方案
├── default.custom.yaml # 用户全局设置
├── symbols.custom.yaml # 定义键盘对应的符号
├── user.yaml           # 用户全局设置
├── weasel.custom.yaml  # 常规设置，定制外观
├── luna_pinyin         # 明月拼音的配置文件夹
│   ├── luna_pinyin.custom.yaml         # 用户自定义的配置文件
│   ├── luna_pinyin_simp.custom.yaml    # 简体中文的配置文件
│   ├── luna_pinyin.extended.dict.yaml  # 明月拼音的扩展词库
│   ├── luna_pinyin.cn_en.dict.yaml         # [扩展词库]中英文混合词库
│   ├── luna_pinyin.emoji_symbol.dict.yaml  # [扩展词库]emoji符号词库
│   ├── luna_pinyin.emoji_text.dict.yaml    # [扩展词库]emoji文本词库
│   ├── luna_pinyin.english.dict.yaml       # [扩展词库]英文词库
│   ├── luna_pinyin.networt_chat.dict.yaml  # [扩展词库]网络用语词库
│   ├── luna_pinyin.science_symbol.dict.yaml# [扩展词库]科学符号词库
│   └── luna_pinyin.sogou.dict.yaml        # [扩展词库]搜狗词库
├── wubi86_jidian      # 五笔86简点的配置文件夹
│   ├── wubi86_jidian_addition.dict.yaml
│   ├── wubi86_jidian.dict.yaml
│   ├── wubi86_jidian_extra.dict.yaml
│   ├── wubi86_jidian_pinyin.schema.yaml
│   ├── wubi86_jidian.schema.yaml
│   ├── wubi86_jidian_trad_pinyin.schema.yaml
│   ├── wubi86_jidian_trad.schema.yaml
│   └── wubi86_jidian_user.dict.yaml
├── installation.yaml
├── imgs                # 图片
│   └── logo.png
├── sync               # 同步文件夹
├── build       # [没用]每次ibus restart生成的文件
│   ├── default.yaml
│   ├── ibus_rime.yaml
│   ├── luna_pinyin_simp.prism.bin
│   ├── luna_pinyin_simp.schema.yaml
│   ├── luna_pinyin_tw.prism.bin
│   ├── luna_pinyin_tw.schema.yaml
│   ├── stroke.prism.bin
│   └── stroke.schema.yaml
├── cangjie5.userdb     # [没用]只要使用cangjie5自动生成的文件
├── luna_pinyin.userdb  # [没用]只要使用luna_pinyin自动生成的文件
├── stroke.userdb       # [没用]只要使用stroke自动生成的文件
└── README.md           # 说明文件
```

