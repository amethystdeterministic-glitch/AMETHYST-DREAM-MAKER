import numpy as np
def partition(scores):
    thresh = np.median(scores)
    return (scores > thresh).astype(int)
