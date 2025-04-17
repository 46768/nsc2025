import json

vowels = ['a', 'e', 'i', 'o', 'u']

headers = [
    {
        "name": "Field",
        "max_extra_spaces": 1000,
        "schema_map": lambda s, p, pk: pk
    },

    {
        "name": "Type",
        "max_extra_spaces": 10,
        "schema_map": lambda s, p, pk: p["type"]
    },

    {
        "name": "Required?",
        "max_extra_spaces": 10,
        "schema_map": lambda s, p, pk: ('Y'
                                        if (pk in s["required"]
                                            if "required" in s else False)
                                        else 'N')
    },

    {
        "name": "Description",
        "max_extra_spaces": 10,
        "center": False,
        "schema_map": lambda s, p, pk: (p["description"]
                                        if "description" in p else "")
    },
]


def clamp(x, min_v, max_v):
    return min(max_v, max(x, min_v))


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


def format_type(type_schema):
    starts_with_vowel = type_schema["type"][0].lower in vowels

    return ("An" if starts_with_vowel else "A") + ' ' + type_schema["type"]


def format_regex(regex_string):
    return "Matches `" + regex_string + "` regex"


def format_schema(schema):
    # Table headers: field, type, required, desc

    schema_header = ""
    table_text = ""

    if "title" in schema:
        schema_header += schema["title"] + ' JSON Schema\n'

    if "description" in schema:
        if "title" in schema:
            schema_header += '\n'
        schema_header += schema["description"] + '\n'

    schema_header += '\n'

    if schema["type"] == "array":
        table_text = format_array(schema)
    elif schema["type"] != "object":
        table_text = format_type(schema)
    else:  # Schema is 'object' type
        properties = schema["properties"]
        regex_properties = schema["patternProperties"]

        fields = []

        def get_field(field_name, field_data):
            return {k: v for (k, v) in [
                (f["name"], f["schema_map"](
                    schema, field_data, field_name)) for f in headers]}

        for field_name, field_data in properties.items():
            fields.append(get_field(field_name, field_data))

        for field_name, field_data in regex_properties.items():
            fields.append(get_field(field_name, field_data))

        headers_length = []

        for header in headers:
            header_name = header["name"]
            header_length = len(header_name)
            header_max_length = header_length + header["max_extra_spaces"]

            for field in fields:
                header_length = clamp(len(field[header_name]),
                                      header_length,
                                      header_max_length)

            headers_length.append(
                    {"name": header_name, "length": header_length})

        table_header = ""
        for header in headers_length:
            table_header += ("| "
                             + header["name"].center(header["length"])
                             + ' ')
        table_header += "|"
        table_hdivider = table_header.replace('|', '+')
        table_hdivider = ''.join(
                map(lambda x: x if x == '+' else '-', table_hdivider)) + '\n'

        table_text += (table_hdivider
                       + table_header + '\n'
                       + table_hdivider.replace('-', '='))

        for field in fields:
            for header in headers:
                pass

        table_text += table_hdivider[:-1]

    return schema_header + table_text


def parse_schema(json_data: str):
    print(format_schema(json.loads(json_data)))
