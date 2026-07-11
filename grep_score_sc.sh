# 两次运行的score_relaxed.sc合并在了一起
# 把已经质子化组的分数单独提出来
grep "EPH_input_for_rosetta" score_relaxed.sc > score_grep_protonated_clean.sc

# 把AF3原始组的分数单独提出来
grep "EPH_relaxed" score_relaxed.sc > score_grep_rawAF3_clean.sc