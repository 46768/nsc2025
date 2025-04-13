from xml.parsers import expat
import argparse
import copy
import networkx as nx
import matplotlib.pyplot as plt
from matplotlib import patches


cli_parser = argparse.ArgumentParser(prog="XML Dependency Graph Builder",
                                     description="Converts XML into a"
                                     + " dependency graph")
cli_parser.add_argument('XMLFilepath')

args = cli_parser.parse_args()

with open(args.XMLFilepath) as f:
    xml_data = f.read()


class GraphParser:
    def __init__(self):
        self.xml_parser = expat.ParserCreate()
        self.xml_parser.StartElementHandler = self.xml_start_handler
        self.xml_parser.EndElementHandler = self.xml_end_handler
        self.xml_parser.CharacterDataHandler = self.xml_body_handler

        self.groups = {'node_pool': {}}
        self.group_order = []
        self.root_node = None

        self.have_root_node = False

        self.parsing_group = {'name': '', 'color': '0.75', 'nodes': []}

        self.is_parsing_group = False

        self.parsing_node = {'name': '', 'group': None, 'dependencies': []}

        self.is_parsing_node = False
        self.data_is_name = False
        self.is_parsing_deps = False
        self.data_is_deps = False

        self.is_parsing_order = False
        self.data_is_order = False

    def xml_start_handler(self, name, attrs):
        if name == 'Node':
            self.is_parsing_node = True

            if self.is_parsing_group:
                self.parsing_node["group"] = self.parsing_group["name"]
            return

        if self.is_parsing_node and name == 'Name':
            self.data_is_name = True
            return

        if self.is_parsing_deps and name == 'Dependency':
            self.data_is_deps = True
            return

        if self.is_parsing_node and name == 'Dependencies':
            self.is_parsing_deps = True
            return

        if self.is_parsing_node and name == "IsRoot":
            if self.root_node is not None:
                print("Error: multiple root nodes")
                exit(1)

            self.root_node = self.parsing_node

        if 'isGroup' in attrs and attrs["isGroup"].lower() == "true":
            self.is_parsing_group = True
            self.parsing_group["name"] = name

            if 'groupColor' in attrs:
                self.parsing_group["color"] = attrs["groupColor"]
            return

        if name == "GroupOrder":
            self.is_parsing_order = True
            return

        if self.is_parsing_order and name == "Order":
            self.data_is_order = True

    def xml_end_handler(self, name):
        self.data_is_name = False
        self.data_is_deps = False
        self.data_is_order = False

        if self.is_parsing_node and name == 'Node':
            self.groups["node_pool"][self.parsing_node["name"]] = (
                    copy.deepcopy(self.parsing_node))

            if self.root_node is not None and not self.have_root_node:
                self.root_node = copy.deepcopy(self.parsing_node)
                self.have_root_node = True

            self.is_parsing_node = False
            self.parsing_node = {'name': '', 'group': None, 'dependencies': []}
            return

        if self.is_parsing_node and name == 'Dependencies':
            self.is_parsing_deps = False
            return

        if self.is_parsing_group and name == self.parsing_group["name"]:
            self.groups[self.parsing_group["name"]] = (
                    copy.deepcopy(self.parsing_group))
            self.is_parsing_group = False
            self.parsing_group = {'name': '', 'color': "0.75", 'nodes': []}
            return

        if self.is_parsing_order and name == "GroupOrder":
            self.is_parsing_order = False
            return

    def xml_body_handler(self, data):
        data_str = str(data).strip()

        if self.data_is_name:
            self.parsing_node["name"] = data_str
            if self.is_parsing_group:
                self.parsing_group["nodes"].append(data_str)

        if self.data_is_deps:
            self.parsing_node["dependencies"].append(data_str)

        if self.data_is_order:
            self.group_order.append(data_str)

    def parse_graph(self, xml):
        self.xml_parser.Parse(xml)

    def get_graph(self):
        return {
            "groups": self.groups,
            "group_order": self.group_order,
            "root_node": self.root_node["name"] if (
                self.root_node is not None) else None,
        }


graph_parser = GraphParser()
graph_parser.parse_graph(xml_data)
graph_data = graph_parser.get_graph()

print(graph_data)

DG = nx.DiGraph()

graph_groups = graph_data["groups"]

DG.add_nodes_from(graph_groups["node_pool"].keys())
for node_name in graph_groups["node_pool"].keys():
    node = graph_groups["node_pool"][node_name]
    for deps_name in node["dependencies"]:
        DG.add_edge(deps_name, node_name)

fig, ax = plt.subplots()
pos = nx.nx_pydot.pydot_layout(DG, prog="sfdp", root=graph_data["root_node"])
pos = nx.arf_layout(DG, pos=pos, a=2, etol=10)

col = []
legends = []

for group in graph_groups.keys():
    if group == "node_pool":
        continue

    legends.append(patches.Patch(color=graph_groups[group]["color"],
                                 label=group))

root_node_color = "#ff00ff"
for node in DG:
    g_node = graph_groups["node_pool"][node]
    if node == graph_data["root_node"]:
        col.append(root_node_color)
        legends.append(patches.Patch(color=root_node_color, label="Root"))
    elif g_node["group"] is not None:
        col.append(graph_groups[g_node["group"]]["color"])
    else:
        col.append("0.75")

node_size = 1200
nx.draw_networkx_nodes(DG, pos=pos, ax=ax, node_size=node_size,
                       node_color=col, node_shape='o', label="e")
nx.draw_networkx_edges(DG, pos=pos, ax=ax, width=2, node_size=node_size,
                       arrows=True)
nx.draw_networkx_labels(DG, pos=pos, ax=ax, font_size=12, font_color="blue",
                        verticalalignment="center", font_weight="bold")

ax.legend(handles=legends)

plt.show()
