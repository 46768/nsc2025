import sys
import numpy as np

print("Hello world! from server.py!")
print("This is another line!")
print(f"This server is using {sys.argv[2]} binary")
print(f"This server is running on port {sys.argv[1]}")
print(np.arange(10))
