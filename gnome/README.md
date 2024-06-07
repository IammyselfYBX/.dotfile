### 将```Caps Lock```与```ESC```互换
```bash
$> vi ~/.Xmodmp
!swap "Caps_Lock" and "ESC"                                                     
remove Lock = Caps_Lock
keysym Escape = Caps_Lock
keysym Caps_Lock = Escape
add Lock = Caps_Lock

$> xmodmap ~/.Xmodmap
```
