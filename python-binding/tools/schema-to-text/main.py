import argparse
import util

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

if not util.does_module_exists("schema_parsers."+schema_type):
    print(f"Error: Schema '{schema_type}' not found")
    exit(1)

if not util.does_module_exists("formatter."+output_format):
    print(f"Error: Format '{output_format}' not found")
    exit(1)


parser = util.lazy_import("schema_parsers."+schema_type)
formatter = util.lazy_import("formatter."+output_format)
schema = parser.parse_schema(schema_data)

file_ext, file_data = formatter.format_schema(schema)
with open("result."+file_ext, 'wb') as f:
    f.write(bytes(file_data, encoding="ascii"))
