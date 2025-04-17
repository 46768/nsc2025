import argparse
import importlib.util
import sys

cli_parser = argparse.ArgumentParser(prog="schematotext",
                                     description="Converts schemas to human "
                                     + "readable text")
cli_parser.add_argument("schemaType")
cli_parser.add_argument("outputFormat")
cli_parser.add_argument("schemaFile")

args = cli_parser.parse_args()
schema_type = args.schemaType
output_format = args.outputFormat
schema_file = args.schemaFile

with open(schema_file) as f:
    schema_data = f.read()

try:
    importlib.util.find_spec("schema_parsers."+schema_type)
except ImportError:
    print(f"Error: Schema '{schema_type}' not found")
    exit(1)


def lazy_import(name):
    spec = importlib.util.find_spec(name)
    loader = importlib.util.LazyLoader(spec.loader)
    spec.loader = loader
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    loader.exec_module(module)
    return module


parser = lazy_import("schema_parsers."+schema_type)
formatter = lazy_import("formatter."+output_format)
schema = parser.parse_schema(schema_data)
print(formatter.format_schema(schema))
