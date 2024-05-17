# 我的Rime配置文件

## 各文件夹说明
### 一、系统自带
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


