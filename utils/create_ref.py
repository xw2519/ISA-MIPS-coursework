import sys
import os

def create_ref(self_dir, ref_dir):
    self_file = open(self_dir)
    ref_file = open(ref_dir,'w')
    self_lines = self_file.readlines()
    ref_lines = ["TB : Finished : active=0\n"]

    for line in self_lines:
        if "register_v0" in line: ref_lines.append(line)
        elif "Write to" in line: ref_lines.append(line)
        elif "Read from 0xbfc00000" in line:
            flag = False
            for i,element in enumerate(ref_lines):
                if "Read from 0xbfc00000" in element:
                    ref_lines[i] = line
                    flag = True
            if not flag: ref_lines.append(line)
        elif "Read from 0x00000000" in line:
            flag = False
            for i,element in enumerate(ref_lines):
                if "Read from 0x00000000" in element:
                    ref_lines[i] = line
                    flag = True
            if not flag: ref_lines.append(line)

    for line in ref_lines: ref_file.write(line)


for filename in os.listdir(sys.argv[1]):
    if filename.endswith(".stdout"):
        print(os.path.join(sys.argv[1], filename))
        create_ref(os.path.join(sys.argv[1], filename), os.path.join(sys.argv[2], filename.replace('stdout','txt')))
