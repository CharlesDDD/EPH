#!/bin/bash
# 定义 Rosetta 执行文件和数据库路径
ROSETTA_BIN="/root/autodl-tmp/rosetta.binary.ubuntu.release-408/main/source/bin/relax.static.linuxgccrelease"
ROSETTA_DB="/root/autodl-tmp/rosetta.binary.ubuntu.release-408/main/database"

# 创建输出文件夹
mkdir -p fast_relaxed_pdbs

# 遍历 foldx_outputs 目录下的所有 pdb
for pdb in foldx_outputs/*.pdb; do
    filename=$(basename "$pdb" .pdb)
    echo "正在使用FastRelax处理: $filename"
    $ROSETTA_BIN \
        -database $ROSETTA_DB \
        -s "$pdb" \
        -ignore_unrecognized_res \
        -in:file:fullatom \
        -relax:fast \
        -relax:default_repeats 2 \
        -relax:constrain_relax_to_start_coords \
        -relax:coord_constrain_sidechains \
        -relax:ramp_constraints false \
        -nstruct 1 \
        -out:path:pdb fast_relaxed_pdbs/ \
        -out:suffix _r2 > "fast_relaxed_pdbs/${filename}.log" 2>&1
    echo "$filename 处理完成！"
done
echo "所有突变体的侧链Clash优化完毕！"