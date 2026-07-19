#!/bin/bash
# 先创建好结果文件meeko_result
mkdir -p meeko_result
LOG_FILE="meeko_result/meeko_conversion.log"
{
    for file in EPH_MUTs_pdb2pqr_result/*_H.pdb; do
        filename=$(basename "$file")
        base="${filename%_H.pdb}"
        echo "正在使用Meeko处理: $file"
        mk_prepare_receptor.py -i "$file" --write_pdbqt "meeko_result/${base}.pdbqt"
    done
    echo "全部转换完成！存放在meeko_result文件夹中"
} 2>&1 | tee "$LOG_FILE"