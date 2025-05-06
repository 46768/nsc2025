from pathlib import Path
import argparse
import sys

cli_parser = argparse.ArgumentParser()
cli_parser.add_argument("-i", "--input",
                        help="Input CSV file",
                        required=True)
cli_parser.add_argument("-o", "--output",
                        help="Output TSV file",
                        default="out.tsv")
cli_parser.add_argument("-s", "--start",
                        help="Start ID",
                        required=True)
cli_parser.add_argument("-e", "--end",
                        help="End ID",
                        required=True)

args = cli_parser.parse_args()

if not Path(args.input).exists():
    print("Input file doesn't exists", file=sys.stderr)
    exit(1)

input_file = open(args.input)
output_file = open(args.output, mode='w')

task_data = [x.split(',') for x in input_file.read().rstrip().split('\n')]

task_ids = [t[0] for t in task_data]

if len(set(task_ids)) != len(task_ids):
    print("Tasks contains duplicate IDs")
    exit(2)

tasks = {t[0]: t[1:] for t in task_data}

# TaskID: (forward_edges, backward_edges)
edges = {}
for t in task_data:
    t_id = t[0]
    predecessors = t[4].split(',')
    if t_id not in edges:
        edges[t_id] = ([], predecessors if t[4] != '' else [])

    if t[4] != '':
        for p in predecessors:
            if p not in edges:
                edges[p] = ([], tasks[p][3].split(','))
            edges[p][0].append(t_id)

# Forward pass for earliest time estimates
ete = {t: [-1, -1] for t in task_ids}  # Earliest Time Estimates
ete[args.start] = [0, 0]

queue = [args.start]
while len(queue) > 0:
    pass
