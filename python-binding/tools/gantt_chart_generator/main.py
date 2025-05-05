from pathlib import Path
import argparse
import sys

cli_parser = argparse.ArgumentParser
cli_parser.add_argument("-i", "--input")
cli_parser.add_argument("-o", "--output")

args = cli_parser.parse_args()

if not Path(args.input).exists():
    print("Input file doesn't exists", file=sys.stderr)
    exit(1)

input_file = open(args.input)
output_file = open(args.output, mode='w')

tasks = []

task_data = [x.split(',') for x in input_file.read().split('\n')]

print(task_data)
