import json

vowels = ['a', 'e', 'i', 'o', 'u']

field_name_header = "Field"
type_header = "Type"
required_header = "Required?"
description_header = "Description"

field_name_max_size = len(field_name_header) + 10
type_max_size = len(type_header) + 10
required_max_size = len(required_header) + 10
description_max_size = len(description_header) + 10


def parse_schema(json_data: str):
    def format_array(array_schema):
        array_text = "An array of "

        if "minItems" in array_schema:
            min_items = array_schema["minItems"]
            array_text += f"at least {min_items} "

        if ("uniqueItems" in array_schema
                and array_schema["uniqueItems"] is True):
            array_text += "unique "

        array_text += array_schema["items"]["type"]
        return array_text

    # Table headers: field, type, required, desc

    table_header = ""
    table_text = ""
    table_dim = [0, 0]  # (width, height)

    schema = json.loads(json_data)

    if "title" in schema:
        table_header += schema["title"] + ' JSON Schema\n'

    if "description" in schema:
        if "title" in schema:
            table_header += '\n'
        table_header += schema["description"] + '\n'

    table_header += '\n'

    if schema["type"] == "array":
        table_text = format_array(schema)
    elif schema["type"] != "object":
        table_text = (['A', 'An'][int(schema["type"][0].lower() in vowels)]
                      + ' ' + schema["type"])

    print(table_header + table_text)
