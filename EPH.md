

## 1. 质子化
---
**pdb2pqr/propka**
[emoji](https://gist.github.com/rxaviers/7360908)
[文档](https://pdb2pqr.readthedocs.io/en/latest/):memo:
[github](https://github.com/Electrostatics/pdb2pqr):point_left:

```bash
ligand1:https://www.ebi.ac.uk/chebi/CHEBI:62456
老师给的(手性有问题): C/C(C)=C/CC[C@@H](C)C1CC[C@@]2(C)C3CC=C4C(C)(C)[C@@H](O)CCC4[C@]3(C)CC[C@@]21C
3D:结构pubchem:14543446：https://pubchem.ncbi.nlm.nih.gov/compound/Cucurbitadienol#section=3D-Conformer

ligand2(P450环氧):https://www.ebi.ac.uk/chebi/CHEBI:229949
老师给的(手性有问题): C[C@H](CCC1C(C)(C)O1)C2CC[C@@]3(C)C4CC=C5C(C)(C)[C@@H](O)CCC5[C@]4(C)CC[C@@]32C
3D:结构：https://pubchem.ncbi.nlm.nih.gov/compound/171037431#section=3D-Conformer

ligand3:(24,25-dihydroxy-cucurbitadienol) (水解-OH):https://pubchemlite.lcsb.uni.lu/e/compound/171037432
3D结构：https://pubchem.ncbi.nlm.nih.gov/compound/171037432#section=3D-Conformer

# pubchem/chebi官方ligands结构
ligand1 = "[H][C@@]12CC=C3C(C)(C)[C@@H](O)CC[C@@]3([H])[C@]1(C)CC[C@@]1(C)[C@@]2(C)CC[C@]1([H])[C@H](C)CCC=C(C)C"
ligand2 = "[H][C@@]12CC=C3C(C)(C)[C@@H](O)CC[C@@]3([H])[C@]1(C)CC[C@@]1(C)[C@@]2(C)CC[C@]1([H])[C@H](C)CC[C@@H]1OC1(C)C"

```
**propka指令**
```bash
propka3 EPH.pdb -o 7.0
```
- **EPH.pdb**：要预测Pka的pdb文件
- **-o**：PH 

**pdb2pqr指令**
```bash
pdb2pqr --ff=AMBER --titration-state-method=propka --with-ph=7.0 --pdb-output=EPH_input_for_rosetta.pdb EPH.pdb EPH.pqr
```
- **--ff=AMBER**：力场算法
- **--titration-state-method=propka**：Propka做Pka预测
- **--with-ph=7.0**：PH7
- **--pdb-output=EPH_input_for_rosetta.pdb**：默认不输出pdb这里指定
- **EPH.pdb**：输出文件pdb (参数必须)
- **EPH.pqr**：输出的pqr添加缺失的重原子，优化氢键，使用力场如AMBER或CHARMM分配电荷和半径(参数必须)


## 2. 详细步骤
**①先做Fastrelax**
- 至于为什么可以看**3**小节
- 先对AF3或其他结构预测模型的**EPH.pdb**结果做**Fastrelax**，优化侧链可能存在的clash
- 结果：**EPH_relaxed_0001.pdb**
```bash
#!/bin/bash
/root/autodl-tmp/rosetta.binary.ubuntu.release-408/main/source/bin/relax.static.linuxgccrelease \
    -database /root/autodl-tmp/rosetta.binary.ubuntu.release-408/main/database \
    -s EPH.pdb \
    -in:file:fullatom \
    -use_input_sc \
    -relax:fast \
    -ignore_unrecognized_res \
    -relax:ramp_constraints false \
    -relax:constrain_relax_to_start_coords \
    -relax:coord_constrain_sidechains \
    -ex1 -ex2 \
    -linmem_ig 10 \
    -nstruct 5 \
    -out:suffix _relaxed
```
**②做pdb2pqr质子化**
- 对Fastrelax结果**sc**文件找能量最低的pdb文件:**EPH_relaxed_0001.pdb**
- 结果:**EPH_relaxed_0001_pdb2pqr.pdb**
- HIS 295质子化带正电荷
```bash
# 先对AF3结果的EPH结构Fastrelax在pdb2pqr指令
pdb2pqr --ff=AMBER --titration-state-method=propka --with-ph=7.0 --pdb-output=EPH_relaxed_0001_pdb2pqr.pdb EPH_relaxed_0001.pdb EPH_relaxed_0001.pqr
```
**③做Meeko转pdbqt**
```bash
mk_prepare_ligand.py -i EPH_relaxed_0001_pdb2pqr.pdb -o EPH_relaxed_0001_pdb2pqr.pdbqt
```
- 结果:**EPH_relaxed_0001_pdb2pqr.pdbqt**
- 可以计算HIS295总电荷为+1

**④vina/chai-1/AF3/boltz2分子对接找构象**
- 催化三联体:101ASP 295HIS 260ASP
- 阳阴离子洞:150Tyr & 230Tyr  二者到环氧氧距离3.0
- 核心motif:HGFP--H31-G32-F33-P34(定位催化水)
```bash
# 以101ASP的OD2为盒子中心
vina.exe --receptor EPH_relaxed_0001_pdb2pqr.pdbqt --ligand ligand2_Conformer3D_COMPOUND_CID_171037431.pdbqt --center_x -2.638 --center_y 5.770 --center_z -0.390 --size_x 25 --size_y 25 --size_z 25 --cpu 6 --num_modes 40 --energy_range 100 --exhaustiveness 64 --out "result_vina\EPH_ligand2.pdbqt" > "result_vina\EPH_ligand2_score.txt"

# 三点质心为盒子中心：-2.725, 7.632, -2.866✅️101asp 150tyr 230tyr
vina.exe --receptor EPH_relaxed_0001_pdb2pqr.pdbqt --ligand ligand2_Conformer3D_COMPOUND_CID_171037431.pdbqt --center_x -2.725 --center_y 7.632 --center_z -2.866 --size_x 25 --size_y 25 --size_z 25 --cpu 6 --num_modes 40 --energy_range 100 --exhaustiveness 64 --out "result_vina\EPH_ligand2.pdbqt" > "result_vina\EPH_ligand2_score.txt"

# 找合适的构象在pymol中保存
# 对vina的对接结果找几何距离满足的构象保存
save ligand2_pose12.sdf, EPH_ligand2, state=12
save ligand2_pose13.sdf, EPH_ligand2, state=13

# 对接产物ligand3--质心
vina.exe --receptor EPH_relaxed_0001_pdb2pqr.pdbqt --ligand ligand3_Conformer3D_COMPOUND_CID_171037432.pdbqt --center_x -2.725 --center_y 7.632 --center_z -2.866 --size_x 25 --size_y 25 --size_z 25 --cpu 6 --num_modes 40 --energy_range 100 --exhaustiveness 64 --out "vina_result_ligand3\EPH_ligand3.pdbqt" > "vina_result_ligand3\EPH_ligand3_score.txt"
# 对vina的对接结果找几何距离满足的构象保存
save ligand3_pose8.sdf, EPH_ligand3, state=8
save ligand3_pose15.sdf, EPH_ligand3, state=15

# 显示ligand的原子名字
label ligand2_pose12, name
# 显示ligand的原子index(这里显示的是pymol的方法27 28，实际文献标注是24 25)
label ligand2_pose12, index
# 显示单个残基的原子名字
label EPH_relaxed_0001_pdb2pqr and resi 101, name
# 每个原子的**名称（比如 OD1, OD2）和对应的 PDB 原子序号（ID）
label resi 101, "%s (ID:%s)" % (name, ID)
label resi 101, name
# 打印原子坐标和序号，注意氢导致序号和pdb有出入
iterate_state 1, resi 101 and name OD1, print("Atomic Index: %s | Coordinates: X=%.3f, Y=%.3f, Z=%.3f" % (ID, x, y, z))

# 精简写法打印坐标
iterate_state 1, resi 101 and name OD1, print("Coordinates: X=%.3f, Y=%.3f, Z=%.3f" % (x, y, z))

# 
# 关闭化合价显示
set valence, off
```
- ASP的OD2到C24 C25距离<3.5, 两个Tyr的-OH到环氧距离
- 角度:攻击环氧背面的C24 25
- NAC构象朝向问题-是出口还是入口

⑤CAVER通道
出发点ASP101坐标，蛋白EPH.pdb

```bash
# 找ligand5A范围残基
# 方式2 这个sele加不加括号都一样
temp=[];iterate (ligand5A_resides) and name CA, temp.append(resn+resi)

# 和上面的分开打印不然就是乘法表那种形式，上面的运行完之后最后打印
print(",".join(temp))


```




---




## 3. Rosetta--Fastrelax模块测试

指令集合：https://docs.rosettacommons.org/manuals/archive/rosetta_2016.28.58794_user_guide/all_else/d9/de0/md_src_basic_options_full-options-list.html

---

```bash
#!/bin/bash
/root/autodl-tmp/rosetta.binary.ubuntu.release-408/main/source/bin/relax.static.linuxgccrelease \
    -database /root/autodl-tmp/rosetta.binary.ubuntu.release-408/main/database \
    -s EPH_input_for_rosetta.pdb \
    -in:file:fullatom \
    -use_input_sc \
    -relax:fast \
    -ignore_unrecognized_res \
    -relax:ramp_constraints false \
    -relax:constrain_relax_to_start_coords \
    -relax:coord_constrain_sidechains \
    -ex1 -ex2 \
    -linmem_ig 10 \
    -nstruct 5 \
    -out:suffix _relaxed \
    -out:file:scorefile score_rawAF3_relaxed.sc \
```

**①先pdb2pqr再Fastrelax**❌️
最终的
```bash
core.io.pose_from_sfr.PoseFromSFRBuilder: [ WARNING ] discarding 1 atoms at position 17 in file EPH_input_for_rosetta.pdb. Best match rsd_type:  HIS
core.io.pose_from_sfr.PoseFromSFRBuilder: [ WARNING ] discarding 1 atoms at position 100 in file EPH_input_for_rosetta.pdb. Best match rsd_type:  HIS
core.io.pose_from_sfr.PoseFromSFRBuilder: [ WARNING ] discarding 1 atoms at position 295 in file EPH_input_for_rosetta.pdb. Best match rsd_type:  HIS
...
抛弃了EPH_input_for_rosetta.pdb中第 17、100、295号位置上的各1个原子,因为它最匹配的残基类型是标准HIS
Rosetta读取结构时，依然只看了文字缩写标签HIS，而默认地把PDB2PQR给His295、His100额外加的那第2个极性质子HD1/HE2当成了非标准多余杂原子，给直接无情抛弃了

pdbqt文件中电荷总量
0.242
-0.272
0.177
-0.343
0.090
0.037
-0.347
0.134
0.167
0.196
-0.245
0.164
===0
```


**②先Fastrelax再pdb2pqr**✅️
最终结果
```bash
有质子HD1 HE2
0.242
-0.273
0.179
-0.343
0.119
0.142
-0.248
0.244
0.312
0.400
-0.250
0.312
0.164
===1.00 对应Pka中的10.85

```
**③换参数**
和①一样的结果，rosetta还是会忽略❌️
```bash
#!/bin/bash
/root/autodl-tmp/rosetta.binary.ubuntu.release-408/main/source/bin/relax.static.linuxgccrelease \
    -database /root/autodl-tmp/rosetta.binary.ubuntu.release-408/main/database \
    -s EPH_input_for_rosetta.pdb \
    -in:file:fullatom \
    -use_input_sc \
    -relax:fast \
    -ignore_unrecognized_res \
    -relax:ramp_constraints false \
    -relax:constrain_relax_to_start_coords \
    -relax:coord_constrain_sidechains \
    -pH:pH_mode true \
    -pH:value_pH 7.0 \
    -keep_input_protonation_state true \
    -ex1 -ex2 \
    -linmem_ig 10 \
    -nstruct 5 \
    -out:suffix _protonation \
    -out:file:scorefile score_protonation.sc \

```


