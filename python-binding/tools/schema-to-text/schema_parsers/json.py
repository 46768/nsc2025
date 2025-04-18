from schema import Schema, Field
import json


# Englishifier

def englishify_field(field: Field):
    field_name = field.name
    field_type = field.type
    field_required = 'Y' if field.required else 'N'
    field_desc = field.description
    field_extras = field.extra

    if "regex_field" in field_extras:
        field_name = "Matches `" + field_name + "` Regex"

    # (name, type, required, description)
    return {"name": field_name,
            "type": field_type,
            "required": field_required,
            "description": field_desc}


# Schema Parser

def format_schema(schema):
    json_schema = Schema()

    if "title" in schema:
        json_schema.title = schema["title"]

    if "description" in schema:
        json_schema.description = schema["description"]

    json_schema.type = "json"
    properties = schema["properties"]
    regex_properties = schema["patternProperties"]
    requried_properties = schema["required"]

    def add_field(field_name, field_data):
        field = json_schema.add_property()
        field.name = field_name
        field.type = field_data["type"]
        field.required = field_name in requried_properties
        field.description = field_data.get("description", "")

        return field

    for field_name, field_data in properties.items():
        add_field(field_name, field_data)

    for field_name, field_data in regex_properties.items():
        field = add_field(field_name, field_data)
        field.extra.add("regex_field")

    return json_schema


def parse_schema(json_data: str):
    return format_schema(json.loads(json_data))
