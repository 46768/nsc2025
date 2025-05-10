from pathlib import Path
import argparse
import sys
import math

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


def format_task(t):
    # Convert duration from hours to minutes for precision
    t[6] = math.ceil(float(t[6])*60)
    t[7] = math.ceil(float(t[7])*60)
    t[8] = math.ceil(float(t[8])*60)
    t[9] = math.ceil(float(t[9])*60)

    return t


tasks = {t[0]: format_task(t)[1:] for t in task_data}

# TaskID: (forward_edges, backward_edges)
edges = {}
for t in task_data:
    t_id = t[0]
    predecessors = t[5].split(';')
    if t_id not in edges:
        edges[t_id] = ([], predecessors if t[5] != '' else [])

    if t[5] != '':
        for p in predecessors:
            if p not in edges:
                edges[p] = ([], tasks[p][4].split(';'))
            edges[p][0].append(t_id)

# Forward pass for earliest time estimates
ete = {t: [-1, -1] for t in task_ids}  # Earliest Time Estimates
ete[args.start] = [0, 0]

queue = [args.start]
while len(queue) > 0:
    current = queue[0]
    queue = queue[1:]

    c_end = ete[current][1]

    for e in edges[current][0]:
        estimate = [c_end+1, tasks[e][8]+c_end]
        if ete[e][0] < estimate[0]:
            ete[e] = estimate
        queue.append(e)

# Forward pass for earliest time estimates
lte = {t: [2**64, 2**64] for t in task_ids}  # Earliest Time Estimates
lte[args.end] = ete[args.end][:]

queue = [args.end]
while len(queue) > 0:
    current = queue[0]
    queue = queue[1:]

    c_start = lte[current][0]

    for e in edges[current][1]:
        estimate = [c_start-tasks[e][8], c_start-1]
        if lte[e][0] > estimate[0]:
            lte[e] = estimate
        queue.append(e)
lte[args.start] = [0, 0]

floats = {t: lte[t][0]-ete[t][0] for t in task_ids}

print(ete)
print(lte)
print(floats)
