import argparse
import networkx as nx
import matplotlib.pyplot as plt
import json
from matplotlib import patches

root_node_color = "#ff00ff"

cli_parser = argparse.ArgumentParser(prog="JSON Dependency Graph Builder",
                                     description="Converts JSON into a"
                                     + " dependency graph")
cli_parser.add_argument('JSONFilepath')

args = cli_parser.parse_args()

with open(args.JSONFilepath) as f:
    graph_data = json.loads(f.read())


DG = nx.DiGraph()

graph_groups = graph_data["groups"]
group_order = graph_data["group_order"]

legends = []
col = []

root_node = None

for group_name in group_order:
    group = graph_groups[group_name]

    legends.append(patches.Patch(color=group["color"], label=group_name))

    for node_name, node in group["nodes"].items():
        DG.add_node(node_name)

        if "root_node" in node and node["root_node"] is True:
            if root_node is not None:
                print("Error: multiple root node")
                exit(1)

            col.append(root_node_color)
            root_node = node_name
            legends.insert(0, patches.Patch(color=root_node_color,
                                            label="Root node"))
        else:
            col.append(group["color"])

        for dep in node["dependencies"]:
            DG.add_edge(dep, node_name)


fig, ax = plt.subplots()
pos = nx.nx_pydot.pydot_layout(DG, prog="sfdp", root=root_node)
pos = nx.arf_layout(DG, pos=pos, a=2, etol=10)

node_size = 1200
nx.draw_networkx_nodes(DG, pos=pos, ax=ax, node_size=node_size,
                       node_color=col, node_shape='o', label="e")
nx.draw_networkx_edges(DG, pos=pos, ax=ax, width=2, node_size=node_size,
                       arrows=True)
nx.draw_networkx_labels(DG, pos=pos, ax=ax, font_size=12, font_color="blue",
                        verticalalignment="center", font_weight="bold")

ax.legend(handles=legends)

plt.show()
