"""
AST parsing for code security when running a script
"""
import ast
import yaml


class Analyzer(ast.NodeVisitor):
    name = ""

    def __init__(self, *args):
        self.init(*args)

    def analyze(self, tree, have_err, err_dict):
        self.stats = err_dict
        self.visit(tree)
        for key, item in self.stats.items():
            if item:
                return True
            else:
                # Returns True if already have error, otherwise returns False
                return have_err or False


class IllegalNodeAnalyzer(Analyzer):
    name = "illegal_nodes"

    def init(self, illegal_nodes):
        self.illegal_nodes = illegal_nodes

    def visit_Import(self, node):
        self.stats.setdefault("import", [])
        for alias in node.names:
            if alias.name in self.illegal_nodes["import"]:
                self.stats["import"].append(alias.name)
        self.generic_visit(node)

    def visit_ImportFrom(self, node):
        self.stats.setdefault("from", [])
        for alias in node.names:
            if alias.name in self.illegal_nodes["import"]:
                self.stats["from"].append(alias.name)
        self.generic_visit(node)


class ASTChecker:
    def __init__(self, blacklist_file_path):
        with open(blacklist_file_path, 'rb') as f:
            yml_data = yaml.safe_load(f.read())
            self.blacklist = yml_data
            f.close()
        self.illegal_node_analyzer = IllegalNodeAnalyzer(self.blacklist)

    def check_source(self, src):
        try:
            tree = ast.parse(src)
        except SyntaxError:
            return (True, {"syntax_err": True})

        have_err = False
        ret_dict = {}

        have_err = self.illegal_node_analyzer.analyze(tree, have_err, ret_dict)

        return (have_err, ret_dict)
