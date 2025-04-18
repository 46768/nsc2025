class Field:
    field_keys = ["name", "type", "required", "description"]

    def __init__(self):
        self.name = ""
        self.type = ""
        self.required = False
        self.description = "-"
        self.extra = set()

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

    def add_extra_property(self, extra_property: str):
        self.extra.add(extra_property)
        return self

    def remove_extra_property(self, extra_property: str):
        try:
            self.extra.remove(extra_property)
        except KeyError:
            pass

        return self


class Schema:
    def __init__(self,
                 title: str = "-",
                 description: str = "-",
                 schema_type: str = None):
        self.title = title
        self.description = description
        self.type = schema_type
        self.properties = []

    def add_property(self):
        new_property = Field()
        self.properties.append(new_property)
        return new_property
