import sys

inp = sys.argv[1]
out = sys.argv[2]

with open(inp) as f:
    lines = f.readlines()

data = []
for line in lines:
    if not line.startswith("!"):
        data.append(line)

with open(out,"w") as f:
    f.writelines(data)

print("[GEO → TSV]", out)
