# fill a file with a megabyte of text

import string
import random

with open("text.txt", mode='w') as fout:
    s = ""
    for _ in range(0, 2 ** 20):
        s += random.choice(string.ascii_letters + string.digits)
    fout.write(s)
