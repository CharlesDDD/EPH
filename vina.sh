#!/bin/zsh
# Vina 执行程序路径
VINA_BIN="/Users/hence/workspace/autodock_vina_1_1_2_mac_catalina_64bit/bin/vina"
# 固定的配体文件路径 
LIGAND="/Users/hence/workspace/mac_vina/ligand2_pose12.pdbqt" 
# 存放所有突变体受体(pdbqt格式)的目录
RECEPTOR_DIR="/Users/hence/workspace/mac_vina/meeko_result"
# 存放对接结果的输出目录
OUT_DIR="/Users/hence/workspace/mac_vina/vina_result"
echo "开始批量对接 (不同突变体 -> 同一个配体)..."
echo "配体文件: $LIGAND"
echo "受体目录: $RECEPTOR_DIR"
# 找到 RECEPTOR_DIR 目录下所有的 .pdbqt 文件
for RECEPTOR in "$RECEPTOR_DIR"/*.pdbqt; do
    # 提取突变体受体的纯文件名
    BASENAME=$(basename "$RECEPTOR" .pdbqt)
    echo "[$(date +'%H:%M:%S')] 正在对接突变体: $BASENAME ..."
    # 执行 Vina 对接指令
    $VINA_BIN \
        --receptor "$RECEPTOR" \
        --ligand "$LIGAND" \
        --center_x -2.725 --center_y 7.632 --center_z -2.866 \
        --size_x 25 --size_y 25 --size_z 25 \
        --cpu 9 --num_modes 30 --energy_range 20 --exhaustiveness 64 \
        --out "$OUT_DIR/${BASENAME}_out.pdbqt" \
        > "$OUT_DIR/${BASENAME}_score.txt"
done
echo "所有突变体对接任务已完成！"