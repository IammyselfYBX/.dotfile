#!/bin/bash  
# latex语法检查
  
# 定义主tex文件的名称  
TEX_FILE="main.tex"  
  
# 定义检查文件夹的名称  
CHECK_FOLDER="check"  
  
# 检查检查文件夹是否存在，如果不存在则创建  
if [ ! -d "$CHECK_FOLDER" ]; then  
  mkdir "$CHECK_FOLDER"  
fi  
  
# 执行xelatex命令进行语法检查，并将中间文件重定向到检查文件夹  
xelatex -syntax-only -output-directory="$CHECK_FOLDER" "$TEX_FILE"  
  
# 可选：列出检查文件夹中的内容以确认文件已生成  
# ls "$CHECK_FOLDER"
