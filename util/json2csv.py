import sys
import json
import csv
from ordered_set import OrderedSet

""" Script to convert JSON file to CSV file """
""" we need to provide the JSONPath of an array in input file """
""" each item in this array will be a line in the CSV output file """


def flatten_item(map_column_flatitem, key_prefix, item, key_whitelist=None):
    """ Convert object tree in flat map of string key value """
    # Flatten list
    if type(item) is list:
        for i, sub_item in enumerate(item):
            flatten_item(map_column_flatitem, key_prefix + '_' + str(i), sub_item, key_whitelist)

    # Flatten dict
    elif type(item) is dict:
        sub_keys = item.keys()
        for sub_key in sub_keys:
            if key_whitelist and sub_key not in key_whitelist:
                continue
            flatten_item(map_column_flatitem, key_prefix + '_' + str(sub_key), item[sub_key], key_whitelist)

    # To string
    else:
        map_column_flatitem[str(key_prefix)] = str(item)


def jsonpath_get(root_dict: dict, path: str):
    """ Select the node identified by the simple JSONPath node/subnode/subsubnode """
    if path == "/":
        return root_dict
    elem = root_dict
    try:
        for x in path.strip("/").split("/"):
            elem = elem.get(x)
            if elem is None:
                return elem
    except AttributeError:
        pass

    return elem


class my_dialect(csv.Dialect):
    """ Describe the properties of generated CSV files. """
    delimiter = ','
    quotechar = '"'
    doublequote = True
    skipinitialspace = False
    lineterminator = '\n'
    quoting = csv.QUOTE_MINIMAL


def read_json_file(json_file_path: str):
    fp = open(json_file_path, 'r')
    json_text = fp.read()
    json_object = json.loads(json_text)
    fp.close()
    return json_object


def write_csv_file(json_array_to_convert, csv_file_path: str, key_whitelist: list):
    list_processed_data = []
    header = OrderedSet()
    for item in json_array_to_convert:
        map_column_flatitem = {}
        prefix = ""
        flatten_item(map_column_flatitem, prefix, item, key_whitelist)
        list_processed_data.append(map_column_flatitem)
        header.update(map_column_flatitem.keys())

    csv.register_dialect("my_dialect", my_dialect)
    with open(csv_file_path, 'w+') as f:  # https://stackoverflow.com/a/1170297
        #with open(csv_file_path, 'w+', newline='') as f: # prevents python to replace \n by \r\n on Windows
        writer = csv.DictWriter(f, header, dialect="my_dialect")
        writer.writeheader()
        for map_row in list_processed_data:
            writer.writerow(map_row)
            #print(map_row)

    print("[+] Completed writing CSV file with %d columns, %d lines" % (len(header), len(list_processed_data)))


def main():
    # Reading arguments
    array_path = sys.argv[1]
    json_file_path = sys.argv[2]
    csv_file_path = sys.argv[3]
    key_whitelist = None

    json_object = read_json_file(json_file_path)

    json_array_to_convert = jsonpath_get(json_object, array_path)
    if json_array_to_convert is None:
        sys.exit("[!] Array node [%s] not found" % array_path)

    write_csv_file(json_array_to_convert, csv_file_path, key_whitelist)


if __name__ == "__main__":

    if len(sys.argv) != 4:
        print("Usage: \npython json2csv.py <array_path> <input.json> <output.csv>\n")
        print("Example:\npython json2csv.py node/subnode/array_node input.json output.csv")
    else:
        main()
