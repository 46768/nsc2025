from schema import Schema, SchemaProperty
import json


def parse_array(json_schema, schema):
    prefix_items = schema.get("prefixItems", [])
    for i, item in enumerate(prefix_items):
        item_name = f"[{i}]"
        item_type = "item"

        if "type" in item:
            item_type = item["type"]
        elif "enum" in item:
            item_type = "enum" + str(item["enum"])

        (json_schema.add_property(SchemaProperty)
         .set_name(item_name)
         .set_value(item_type))

        for k, v in item.items():
            if k in ["type", "enum"]:
                continue
            (json_schema.add_property(SchemaProperty)
             .set_name(item_name+'/'+k)
             .set_value(str(v)))

    if schema["items"] is False:
        json_schema.object_type = "tuple"
    else:
        item_type = schema["items"]["type"]
        (json_schema.add_property(SchemaProperty)
         .set_name("Item type")
         .set_value(item_type)
         .set_description("Type of items within the array"
                          " (after the prefix items)"))

        if "minItems" in schema:
            (json_schema.add_property(SchemaProperty)
             .set_name("Minimum count of item")
             .set_value(schema["minItems"])
             .set_description("Minimum amount of items in the array"))
        if schema.get("uniqueItems", False) is True:
            (json_schema.add_property(SchemaProperty)
             .set_name("Unique items")
             .set_value("Y")
             .set_description("Ensure every items are unique"))


def parse_object(json_schema, schema):
    properties = schema["properties"]
    regex_properties = schema.get("patternProperties", {})
    requried_properties = schema["required"]

    def add_field(field_name, field_data):
        field = (json_schema.add_property()
                 .set_name(field_name)
                 .set_type(field_data["type"])
                 .set_required(field_name in requried_properties)
                 .set_description(field_data.get("description", "")))

        return field

    for field_name, field_data in properties.items():
        add_field(field_name, field_data)

    for field_name, field_data in regex_properties.items():
        field = add_field(field_name, field_data)
        field.add_extra_property("regex_field")


def format_schema(schema):
    json_schema = Schema()

    if "title" in schema:
        json_schema.title = schema["title"]

    if "description" in schema:
        json_schema.description = schema["description"]

    object_type = schema["type"]

    json_schema.schema_type = "json"
    json_schema.object_type = object_type

    if object_type == "array":
        parse_array(json_schema, schema)
    elif object_type == "object":
        parse_object(json_schema, schema)
    else:
        for k, v in schema.items():
            # Ignore metadata stuff
            if k in ["title", "description", "type"] or k.startswith('$'):
                continue

            (json_schema.add_property(SchemaProperty)
             .set_name(k)
             .set_value(str(v)))

    return json_schema


def parse_schema(json_data: str):
    return format_schema(json.loads(json_data))
