import hashlib


if __name__ == "__main__":
    msg = b"hello world"
    h = hashlib.sha256(msg).hexdigest()
    print(h)