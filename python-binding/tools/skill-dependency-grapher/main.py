from xml.parsers import expat
import argparse
import copy
import json
import manim as ma


cli_parser = argparse.ArgumentParser(prog="XML Dependency Graph Builder",
                                     description="Converts XML into a"
                                     + " dependency graph")
cli_parser.add_argument('XMLFilepath')

args = cli_parser.parse_args()
xml_file = open(args.XMLFilepath)

xml_data = xml_file.read()


class GraphParser:
    def __init__(self):
        self.xml_parser = expat.ParserCreate()
        self.xml_parser.StartElementHandler = self.xml_start_handler
        self.xml_parser.EndElementHandler = self.xml_end_handler
        self.xml_parser.CharacterDataHandler = self.xml_body_handler

        self.groups = {'node_pool': {}}

        self.parsing_group = {'name': '', 'nodes': []}

        self.is_parsing_group = False

        self.parsing_node = {'name': '', 'dependencies': []}

        self.is_parsing_node = False
        self.data_is_name = False
        self.is_parsing_deps = False
        self.data_is_deps = False

    def xml_start_handler(self, name, attrs):
        if name == 'Node':
            self.is_parsing_node = True
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

        if 'isGroup' in attrs and attrs["isGroup"].lower() == "true":
            self.is_parsing_group = True
            self.parsing_group["name"] = name
            return

    def xml_end_handler(self, name):
        self.data_is_name = False
        self.data_is_deps = False

        if self.is_parsing_node and name == 'Node':
            self.groups["node_pool"][self.parsing_node["name"]] = (
                    copy.deepcopy(self.parsing_node))
            self.is_parsing_node = False
            self.parsing_node = {'name': '', 'dependencies': []}

        if self.is_parsing_node and name == 'Dependencies':
            self.is_parsing_deps = False

        if self.is_parsing_group and name == self.parsing_group["name"]:
            self.groups[self.parsing_group["name"]] = (
                    copy.deepcopy(self.parsing_group))
            self.is_parsing_group = False
            self.parsing_group = {'name': '', 'nodes': []}

    def xml_body_handler(self, data):
        data_str = str(data).strip()

        if self.data_is_name:
            self.parsing_node["name"] = data_str
            if self.is_parsing_group:
                self.parsing_group["nodes"].append(data_str)

        if self.data_is_deps:
            self.parsing_node["dependencies"].append(data_str)

    def parse_graph(self, xml):
        self.xml_parser.Parse(xml)


graph_parser = GraphParser()
graph_parser.parse_graph(xml_data)

print(json.dumps(graph_parser.groups, indent=4))


class GraphView(ma.Scene):
    def construct(self):
        circle = ma.Circle()  # create a circle
        circle.set_fill(ma.PINK, opacity=0.5)  # set color and transparency

        square = ma.Square()  # create a square
        square.flip(ma.RIGHT)  # flip horizontally
        square.rotate(-3 * ma.TAU / 8)  # rotate a certain amount

        self.play(ma.Create(square))  # animate the creation of the square
        self.play(ma.Transform(square, circle))  # interpolate the square into the circle
        self.play(ma.FadeOut(square))  # fade out animation
