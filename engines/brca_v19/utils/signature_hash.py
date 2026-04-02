from utils.hash_utils import string_sha256
import json, sys

GENES = [
"ZNF707","HIF3A","TGFBR2","NCBP1","KIAA0831","RTN4RL2","ARTN","IL1RAPL2",
"GRINA","CAMK1","HAP1","CHST9","PHLDA3","SMAD7","SERPING1","LRRTM2",
"ITGA7","SLC46A1","ATP2A3","TCOF1","DENND4C","DENND4A","ZNF708",
"FGFR1OP2","ZC3H14"
]

sig = json.dumps(GENES, sort_keys=True)

print(string_sha256(sig))
