import os
import argparse

msg = "List directory contents"

parser = argparse.ArgumentParser(description = msg)
parser.add_argument("-d", "--dir", help = "Directory to be listed")
args = parser.parse_args()

if args.dir:
    if os.path.isdir(args.dir):
        print(f"Listing contents of {args.dir}.")
        print(f"-------------------------------\n")
        files = (os.listdir(args.dir))
        for file in files:
            print(file)
    elif os.path.isfile(args.dir):
        print(f"ERROR: {args.dir} is a file")
    else:
        print(f"ERROR: {args.dir} does not exist.")
else:
    path = os.getcwd()
    files = (os.listdir(path))
    print(f"Listing current directory {path}\n")
    for file in files:
        print(file)
