from schema import Schema
import util


def format_schema(schema_data: Schema):
    schema_format = schema_data.type
    parser = util.lazy_import("schema_parsers."+schema_format)
    table_keys = schema_data.properties[0].field_keys

    table_string = ""

    table_string += "Title: " + schema_data.title + '\n'
    table_string += "Description: " + schema_data.description + '\n'
    table_string += '\t'.join(table_keys) + '\n'

    for field in schema_data.properties:
        field_data = parser.englishify_field(field)
        table_string += '\t'.join(field_data) + '\n'

    table_string = table_string[:-1]

    return ("txt", table_string)
