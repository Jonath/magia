/**
    Json

    Copyright: (c) Enalye 2017
    License: Zlib
    Authors: Enalye
*/

module magia.core.json;

public import std.json;
import std.conv;
import std.regex, std.path;
import std.stdio;

/// Transform your path in a system agnostic path.
string convertPathToExport(string path) {
    return replaceAll(path, regex(r"\\/|/|\\"), "/");
}

/// Transform the path in your path system.
string convertPathToImport(string path) {
    return replaceAll(path, regex(r"\\/|/|\\"), dirSeparator);
}

/// Does the node exist ?
bool hasJson(JSONValue json, string tag) {
    return ((tag in json.object) !is null);
}

/// Get the node
JSONValue getJson(JSONValue json, string tag) {
    if (!(tag in json.object)) {
        throw new Exception("JSON: \'" ~ tag ~ "\'' does not exist in JSON.");
    }

    return json.object[tag];
}

/// Get a JSONValue array associated to tag (throws if not found)
JSONValue[] getJsonArray(JSONValue json, string tag) {
    if (!(tag in json.object)) {
        //throw new Exception("JSON: \'" ~ tag ~ "\'' does not exist in JSON.");
        return [];
    }

    return json.object[tag].array;
}

/// Get a string array associated to tag (default if not found)
string[] getJsonArrayStr(JSONValue json, string tag, string[] defaultValue) {
    if (!(tag in json.object)) {
        return defaultValue;
    }

    string[] array;
    foreach (JSONValue value; json.object[tag].array) {
        writeln("value: ", value);
        array ~= value.str;
    }

    return array;
}

/// Get a int array associated to tag (throws if not found)
int[] getJsonArrayInt(JSONValue json, string tag) {
    if (!(tag in json.object)) {
        throw new Exception("JSON: \'" ~ tag ~ "\'' does not exist in JSON.");
    }

    int[] array;
    foreach (JSONValue value; json.object[tag].array) {
        if (value.type() == JSONType.integer) {
            array ~= cast(int) value.integer;
        } else {
            array ~= to!int(value.str);
        }
    }

    return array;
}

/// Get a int array associated to tag (default if not found)
int[] getJsonArrayInt(JSONValue json, string tag, int[] defaultValue) {
    if (!(tag in json.object)) {
        return defaultValue;
    }

    int[] array;
    foreach (JSONValue value; json.object[tag].array) {
        if (value.type() == JSONType.integer) {
            array ~= cast(int) value.integer;
        } else {
            array ~= to!int(value.str);
        }
    }

    return array;
}

/// Get a int array associated to tag (default if not found)
float[] getJsonArrayFloat(JSONValue json, string tag, float[] defaultValue) {
    if (!(tag in json.object)) {
        return defaultValue;
    }

    float[] array;
    foreach (JSONValue value; json.object[tag].array) {
        switch(value.type()) {
            case JSONType.string:
                array ~= to!float(value.str);
                break;
            case JSONType.integer:
                array ~= to!float(value.integer);
                break;
            case JSONType.float_:
                array ~= value.floating;
                break;
            default:
                break;
        }
    }

    return array;
}

/// Get a string associated to tag (throws if not found)
string getJsonStr(JSONValue json, string tag) {
    if (!(tag in json.object)) {
        throw new Exception("JSON: \'" ~ tag ~ "\'' does not exist in JSON.");
    }

    return json.object[tag].str;
}

/// Get a string associated to tag (default if not found)
string getJsonStr(JSONValue json, string tag, string defaultValue) {
    if (!(tag in json.object)) {
        return defaultValue;
    }

    return json.object[tag].str;
}

/// Get a int associated to tag (throws if not found)
int getJsonInt(JSONValue json, string tag) {
    if (!(tag in json.object)) {
        throw new Exception("JSON: \'" ~ tag ~ "\'' does not exist in JSON.");
    }

    JSONValue value = json.object[tag];
    switch (value.type()) with (JSONType) {
        case integer:
            return cast(int) value.integer;
        case uinteger:
            return cast(int) value.uinteger;
        case float_:
            return cast(int) value.floating;
        case string:
            return to!int(value.str);
        default:
            throw new Exception("JSON: No integer value in \'" ~ tag ~ "\'.");
    }
}

/// Get a int associated to tag (default if not found)
int getJsonInt(JSONValue json, string tag, int defaultValue) {
    if (!(tag in json.object)) {
        return defaultValue;
    }

    JSONValue value = json.object[tag];
    switch (value.type()) with (JSONType) {
        case integer:
            return cast(int) value.integer;
        case uinteger:
            return cast(int) value.uinteger;
        case float_:
            return cast(int) value.floating;
        case string:
            return to!int(value.str);
        default:
            throw new Exception("JSON: No integer value in \'" ~ tag ~ "\'.");
    }
}

/// Get a float associated to tag (throws if not found)
float getJsonFloat(JSONValue json, string tag) {
    if (!(tag in json.object)) {
        throw new Exception("JSON: \'" ~ tag ~ "\'' does not exist in JSON.");
    }

    JSONValue value = json.object[tag];
    switch (value.type()) with (JSONType) {
    case integer:
        return cast(float) value.integer;
    case uinteger:
        return cast(float) value.uinteger;
    case float_:
        return value.floating;
    case string:
        return to!float(value.str);
    default:
        throw new Exception("JSON: No floating value in \'" ~ tag ~ "\'.");
    }
}

/// Get a default associated to tag (default if not found)
float getJsonFloat(JSONValue json, string tag, float defaultValue) {
    if (!(tag in json.object)) {
        return defaultValue;
    }

    JSONValue value = json.object[tag];
    switch (value.type()) with (JSONType) {
    case integer:
        return cast(float) value.integer;
    case uinteger:
        return cast(float) value.uinteger;
    case float_:
        return value.floating;
    case string:
        return to!float(value.str);
    default:
        throw new Exception("JSON: No floating value in \'" ~ tag ~ "\'.");
    }
}

/// Get a bool associated to tag (throws if not found)
bool getJsonBool(JSONValue json, string tag) {
    if (!(tag in json.object)) {
        throw new Exception("JSON: \'" ~ tag ~ "\'' does not exist in JSON.");
    }

    JSONValue value = json.object[tag];
    if (value.type() == JSONType.true_) {
        return true;
    } else if (value.type() == JSONType.false_) {
        return false;
    } else {
        throw new Exception("JSON: \'" ~ tag ~ "\' is not a boolean value.");
    }
}

/// Get a bool associated to tag (default if not found)
bool getJsonBool(JSONValue json, string tag, bool defaultValue) {
    if (!(tag in json.object)) {
        return defaultValue;
    }

    JSONValue value = json.object[tag];
    if (value.type() == JSONType.true_) {
        return true;
    } else if (value.type() == JSONType.false_) {
        return false;
    } else {
        throw new Exception("JSON: \'" ~ tag ~ "\' is not a boolean value.");
    }
}
