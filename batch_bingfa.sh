#!/bin/bash
# 接收传入的第一个参数作为pdb文件路径
# chmod +x batch_bingfa.sh
# ls foldx_outputs/*.pdb | parallel -j 32 --eta ./run_single_relax.sh {}
# 使用parallel命令，-j 32 表示启动32个并行任务，--eta会显示预计剩余时间,{}会自动被替换为ls传过来的每一个.pdb文件路径
pdb_file=$1
# 定义Rosetta执行文件和数据库路径
ROSETTA_BIN="/root/autodl-tmp/rosetta.binary.ubuntu.release-408/main/source/bin/relax.static.linuxgccrelease"
ROSETTA_DB="/root/autodl-tmp/rosetta.binary.ubuntu.release-408/main/database"

# 创建输出文件夹
# mkdir -p fast_relaxed_pdbs
filename=$(basename "$pdb" .pdb)
echo "正在使用FastRelax处理: $filename"
$ROSETTA_BIN \
    -database $ROSETTA_DB \
    -s "$pdb_file" \
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