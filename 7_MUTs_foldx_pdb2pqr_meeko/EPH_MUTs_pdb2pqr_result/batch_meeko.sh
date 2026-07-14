#!/bin/bash
# 先创建好结果文件EPH_MUTs_pdb2pqr_meeko_result
# mkdir -p EPH_MUTs_pdb2pqr_meeko_result
for file in *_H.pdb; do
    base="${file%_H.pdb}";
    echo "正在使用Meeko处理: $file";
    mk_prepare_receptor.py -i "$file" --write_pdbqt "EPH_MUTs_pdb2pqr_meeko_result/${base}.pdbqt";
done;
echo "全部转换完成！存放在EPH_MUTs_pdb2pqr_meeko_result文件夹中"