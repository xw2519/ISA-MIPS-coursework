import sys

# Compares reference and test .stdout files, outputs 0 if Pass, outputs 1 if Fail
def compare_files(ref_dir, test_dir):
    ref_file  = open(ref_dir)
    test_file = open(test_dir)

    ref_accesses = []
    ref_writes   = []

    for line in ref_file.readlines():
        if "RAM_ACCESS" in line:
            ref_accesses.append(line)
            if "Write" in line: ref_writes.append(line)

    for line in test_file.readlines():
        if "RAM_ACCESS" not in line: continue
        if line in ref_accesses: ref_accesses.remove(line)
        if "Write" in line and line not in ref_accesses: return 1

    return int(len(ref_accesses) != 0)

# First argument is directory of reference file, second is directory of test file
print(compare_files(sys.argv[1], sys.argv[2]))
