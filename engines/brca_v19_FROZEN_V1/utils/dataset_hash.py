import pandas as pd
import hashlib
import sys

f = sys.argv[1]

df = pd.read_csv(f, sep="\t")

# stable representation
content = df.sort_index(axis=1).to_csv(index=False)

h = hashlib.sha256(content.encode()).hexdigest()

print(h)
