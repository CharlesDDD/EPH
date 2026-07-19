#!/bin/bash
# 存放rosetta输出文件进行清理保留标准pdb格式
mkdir -p fast_relaxed_pdbs_clean
mkdir -p EPH_MUTs_pdb2pqr_result

# 遍历原始 PDB 文件
for file in fast_relaxed_pdbs/*.pdb; do
    # 提取文件这个带完整路径,所以先去掉路径，只留干净的文件和pdb后缀123.pdb
    filename=$(basename "$file")
    # 去掉后缀123
    base="${filename%.pdb}"
    clean_pdb="fast_relaxed_pdbs_clean/${filename}"
    
    # 使用grep提取标准结构行，并备份存入clean文件夹
    grep -E "^(ATOM|HETATM|TER|END)" "$file" > "$clean_pdb"
    # 直接对清洗后的文件 ($clean_pdb) 运行 pdb2pqr
    pdb2pqr --ff=AMBER \
            --titration-state-method=propka \
            --with-ph=7.0 \
            --pdb-output="EPH_MUTs_pdb2pqr_result/${base}_H.pdb" \
            "$clean_pdb" \
            "EPH_MUTs_pdb2pqr_result/${base}.pqr"
    echo "$filename 处理完成！"
done
echo "批量处理全部完成"