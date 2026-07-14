'''
功能：将质子化的结果pdb文件的最后一列加上元素
'''
import glob

pdb_files = glob.glob("*_H.pdb")
print(f"发现 {len(pdb_files)}个需要修复的PDB文件，正在补齐元素列...")
for filename in pdb_files:
    with open(filename, 'r') as f:
        lines = f.readlines()
    new_lines = []
    for line in lines:
        # 如果是坐标行
        if line.startswith("ATOM") or line.startswith("HETATM"):
            element = line[76:78].strip()
            # 如果元素列为空
            if not element:
                # 取原子名称（第13-16列），提取第一个英文字母作为元素符号
                atom_name = line[12:16].strip()
                elem_guess = "C" # 默认值
                for char in atom_name:
                    if char.isalpha():
                        elem_guess = char
                        break
                
                # 补全空格并替换77-78列
                # 去掉换行符；.ljust(80)将字符串左对齐并填充空格至总长度80字符这是PDB文件的标准行宽
                line = line.rstrip('\n\r').ljust(80)
                # elem_guess.rjust(2)就是占位:空格C " C"这种
                line = line[:76] + elem_guess.rjust(2) + line[78:] + '\n'
        new_lines.append(line)
        
    # 覆盖保存原文件
    with open(filename, 'w') as f:
        f.writelines(new_lines)
print("所有文件的元素列修复完成！")