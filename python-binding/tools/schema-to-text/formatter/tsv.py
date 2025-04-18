from schema import Schema


file_ext = "tsv"


def format_schema(schema_data: Schema):

    table_string = ""

    table_string += "Title: " + schema_data.title + '\n'
    table_string += "Description: " + schema_data.description + '\n'
    table_string += "Type: " + schema_data.object_type + '\n'

    if len(schema_data.properties) == 0:
        return (file_ext, table_string)

    table_keys = schema_data.properties[0].field_keys

    table_string += '\t'.join(table_keys) + '\n'

    for field in schema_data.properties:
        field_data = field.englishify()
        table_string += '\t'.join([field_data[k] for k in table_keys]) + '\n'

    table_string = table_string[:-1]

    return (file_ext, table_string)
