class Field:
    field_keys = ["name", "type", "required", "description"]

    def __init__(self):
        self.name = ""
        self.type = ""
        self.required = False
        self.description = "-"
        self.extra = {}

    def set_name(self, name: str):
        self.name = name
        return self

    def set_type(self, field_type: str):
        self.type = field_type
        return self

    def set_required(self, is_required: bool):
        self.required = is_required
        return self

    def set_description(self, description: str):
        self.description = description
        return self

    def add_extra_property(self, extra_property: str, value=None):
        self.extra[extra_property] = value
        return self

    def remove_extra_property(self, extra_property: str):
        try:
            self.extra.pop(extra_property)
        except KeyError:
            pass

        return self

    def englishify(self):
        field_name = self.name
        field_type = self.type
        field_required = 'Y' if self.required else 'N'
        field_desc = self.description
        field_extras = self.extra

        if "regex_field" in field_extras:
            field_name = "Matches `" + field_name + "` Regex"

        # (name, type, required, description)
        return {"name": field_name,
                "type": field_type,
                "required": field_required,
                "description": field_desc}


class SchemaProperty:
    field_keys = ["name", "value", "description"]

    def __init__(self):
        self.name = ""
        self.description = ""
        self.value = None

    def set_name(self, name: str):
        self.name = name
        return self

    def set_description(self, description: str):
        self.description = description
        return self

    def set_value(self, value):
        self.value = value
        return self

    def englishify(self):
        field_name = self.name
        field_value = self.value
        field_desc = self.description

        return {"name": field_name,
                "value": str(field_value),
                "description": field_desc}


class Schema:
    def __init__(self,
                 title: str = "-",
                 description: str = "-",
                 schema_type: str = None):
        self.title = title
        self.description = description
        self.schema_type = schema_type
        self.object_type = ""
        self.properties = []
        self.sub_schema = []

    def add_property(self, field_class=Field):
        new_property = field_class()
        self.properties.append(new_property)
        return new_property
