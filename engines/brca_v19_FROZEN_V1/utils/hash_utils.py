import hashlib

def file_sha256(path):
    h = hashlib.sha256()
    with open(path,'rb') as f:
        while True:
            b = f.read(8192)
            if not b:
                break
            h.update(b)
    return h.hexdigest()

def string_sha256(s):
    return hashlib.sha256(s.encode()).hexdigest()
