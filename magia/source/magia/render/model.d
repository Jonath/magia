module magia.render.model;

import std.json;

/// Class handling model loading
class Model {
    private {
        ubyte[] _data;
        JSONValue _json;
    }

    /// Constructor
    this(string fileName) {
        _json = parseJSON(readText("model/" ~ _fileName));
        _data = getData();
    }

    /// Get data
    ubyte[] getData() {
        string uri = _json["buffers"][0]["uri"];
        return read("model/" ~ uri);
    }

    float[] getFloats(JSONValue accessor) {
        const uint bufferViewId = accessor.value("bufferView", 1);
        const uint count = accessor["count"];
        const uint byteOffset = accessor.value("byteOffset", 0);

        const string type = accessor["type"];

        JSONValue bufferView = _json["bufferViews"][bufferViewId];
        const uint accessorByteOffset = bufferView["byteOffset"];

        uint nbBytesPerVertex;
        if (type == "SCALAR") {
            nbBytesPerVertex = 1;
        } else if (type == "VEC2") {
            nbBytesPerVertex = 2;
        } else if (type == "VEC3") {
            nbBytesPerVertex = 3;
        } else if (type == "VEC4") {
            nbBytesPerVertex = 4;
        }

        const uint dataStart = byteOffset + accessorByteOffset;
        const uint dataLength = count * 4 * nbBytesPerVertex;
        for (uint dataId = dataStart; dataId < dataStart + dataLength; dataId) {
            ubyte[] bytes = [
                data[dataId++],
                data[dataId++],
                data[dataId++],
                data[dataId++]
            ];

            float value = bytes;
        }
    }

    GLuint[] getIndices(JSONValue accessor) {

    }

    vec2[] groupFloatsVec2(float[] values) {

    }

    vec3[] groupFloatsVec3(float[] values) {

    }

    vec4[] groupFloatsVec3(float[] values) {

    }

    /// Draw the model
    void draw(Shader shader, Camera camera) {
        
    }
}