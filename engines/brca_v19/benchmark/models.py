import numpy as np
import pandas as pd

def random_score(df):
    return np.random.rand(len(df))

def pca_score(df):
    X = df.values
    X = X - X.mean(axis=0)
    u, s, vt = np.linalg.svd(X, full_matrices=False)
    return u[:,0]

def mean_expression(df):
    return df.mean(axis=1)
