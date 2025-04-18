from schema import Schema
import textwrap


file_ext = "txt"


def format_schema(schema_data: Schema):
    table = []
    table.append("Title: " + schema_data.title)
    table.append("Description: " + schema_data.description)
    table.append("Type: " + schema_data.object_type)

    if len(schema_data.properties) == 0:
        return (file_ext, '\n'.join(table))

    table_keys = schema_data.properties[0].field_keys

    header_lengths = {k: len(k) for k in table_keys}
    header_max_lengths = {k: 5 * len(k) for k in table_keys}

    for field in schema_data.properties:
        field_data = field.englishify()

        for key in table_keys:
            header_lengths[key] = min(header_max_lengths[key],
                                      max(len(field_data[key]),
                                          header_lengths[key]))

    table_datas = []
    for field in schema_data.properties:
        field_data = field.englishify()
        table_data = {
                k: textwrap.wrap(field_data[k], header_lengths[k])
                for k in table_keys}

        table_datas.append(table_data)

    table_divider = ('+'
                     + '+'.join(
                         ['-' * (header_lengths[k]+2) for k in table_keys])
                     + '+')

    table.append(table_divider)
    table.append('|'
                 + '|'.join(
                     [k.center(header_lengths[k]+2) for k in table_keys])
                 + '|')
    table.append(table_divider.replace('-', '='))

    for data in table_datas:
        i = 0
        can_push = True

        while can_push:
            can_push = False

            push_data = []
            for key in table_keys:
                if i < len(data[key]):
                    can_push = True
                    push_data.append(
                            data[key][i].center(header_lengths[key]+2))
                else:
                    push_data.append(' ' * (header_lengths[key] + 2))

            if can_push:
                table.append('|'+'|'.join(push_data)+'|')
            i += 1

        table.append(table_divider)

    return (file_ext, '\n'.join(table))
