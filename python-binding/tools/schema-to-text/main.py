import argparse
import util
import pkgutil
import schema_parsers as prsers
import formatter as fmter

parsers = []
formatters = []

epilogue = ""

epilogue += "Parsers:\n"
for submod in pkgutil.iter_modules(prsers.__path__):
    parsers.append(submod.name)
    epilogue += '\t' + submod.name + '\n'

epilogue += "\nFormatters:\n"
for submod in pkgutil.iter_modules(fmter.__path__):
    formatters.append(submod.name)
    epilogue += '\t' + submod.name + '\n'

cli_parser = argparse.ArgumentParser(prog="schema2text",
                                     formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description="Converts schemas to human"
                                     " readable text",
                                     epilog=epilogue)
cli_parser.add_argument("-f", "--format", help="Input format", choices=parsers)
cli_parser.add_argument("-F", "--oformat", help="Output format", choices=formatters)
cli_parser.add_argument("-o", "--output", help="Output file",
                        default="result.{ext}", type=str)
cli_parser.add_argument("schemaFile", help="Schema file to convert", type=str)

args = cli_parser.parse_args()
schema_type = args.format
output_format = args.oformat
output_file = args.output
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
with open(output_file.format(ext=file_ext), 'wb') as f:
    f.write(bytes(file_data, encoding="ascii"))
