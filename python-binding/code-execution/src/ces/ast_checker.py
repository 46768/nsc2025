"""AST security module

Provides analyzers for checking python
source code
"""

import ast
import yaml
import logging

logger = logging.getLogger(__name__)


def log_ast_issue(name, issue_dict):
    """Logs an issue with a source code

    Args:
        name (str): Name of the analyzer that found the issue
        issue_dict (dict): Dictionary containing
                the issues from an analyzer
    """

    logger.warning("""
Error with %s AST check:
    %s""", name, issue_dict)


class Analyzer(ast.NodeVisitor):
    """Base class for analyzers

    Provides a method to analyze an ast tree.
    Subclasses must provide their own node visitors
    to analyze the tree

    Attributes:
        name (str): Name of the analyzer
    """

    name = ""

    def analyze(self, tree, have_err, err_dict):
        """Analyze an AST tree, and place any error in the given error dict

        Args:
            tree (ast.Module): AST tree to analyze
            have_err (bool): Used for daisy chaining analyzers
            err_dict (dict): A dictionary to hold errors if there are one

        Returns:
            bool: True if there's error, or have_err is True, False otherwise
        """

        self.stats = err_dict
        self.visit(tree)
        for key, item in self.stats.items():
            if item:
                log_ast_issue(self.name, err_dict)
                return True
            else:
                # Returns True if already have error, otherwise returns False
                return have_err or False


class IllegalNodeAnalyzer(Analyzer):
    """Illegal node analyzer to detect illegal nodes

    Analyze a tree for illegal nodes defined in a .yaml/.yml
    file

    Args:
        illegal_nodes (dict): Dictionary containing illegal nodes list
    """

    name = "Illegal Nodes"

    def __init__(self, illegal_nodes):
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

    def visit_Call(self, node):
        self.stats.setdefault("function", [])
        if isinstance(node.func, ast.Attribute):
            if node.func.attr in self.illegal_nodes["function"]:
                self.stats["function"].append(node.func.attr)
        elif node.func.id in self.illegal_nodes["function"]:
            self.stats["function"].append(node.func.id)
        self.generic_visit(node)

    def visit_Assign(self, node):
        self.stats.setdefault("function_alias", [])
        if not isinstance(node.value, ast.Constant):
            if node.value.id in self.illegal_nodes["function"]:
                self.stats["function_alias"].append(node.value.id)
        for target in node.targets:
            if target.id in self.illegal_nodes["function"]:
                self.stats["function_alias"].append(target.id)
        self.generic_visit(node)


class ASTChecker:
    """Source code checker using ast module

    Checks source code for any errors using ast,
    usually dangerous code that can affect the
    user's machine

    Args:
        blacklist_file_path (str): File path to the yaml code blacklist file
    """

    def __init__(self, blacklist_file_path):
        with open(blacklist_file_path, 'rb') as f:
            yml_data = yaml.safe_load(f.read())
            self.blacklist = yml_data
            f.close()
        self.illegal_node_analyzer = IllegalNodeAnalyzer(self.blacklist)

    def check_source(self, src):
        """Checks source code for any errors from the analyzers

        Args:
            src (str): Source code to analyze for

        Returns:
            tuple: A tuple containing whether theres errors
            in the first element, and the errors in the second
            element
        """

        try:
            tree = ast.parse(src)
        except SyntaxError:
            return (True, {"syntax_err": True})

        have_err = False
        ret_dict = {}

        have_err = self.illegal_node_analyzer.analyze(tree, have_err, ret_dict)

        return (have_err, ret_dict)
