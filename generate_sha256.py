import hashlib
import random

with open("examples.txt","w") as f:
    for _ in range(100):
        msg = random.randbytes(64)
        h = hashlib.sha256(msg).hexdigest()
        f.write(msg.hex() + " " + h + "\n")