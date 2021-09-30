module magia.render.model;

import std.algorithm;
import std.conv;
import std.file;
import std.json;
import std.stdio;

import bindbc.opengl;
import gl3n.linalg;

import magia.core.json;
import magia.render.camera;
import magia.render.mesh;
import magia.render.shader;
import magia.render.texture;
import magia.render.vertex;

/// Class handling model loading
class Model {
    private {
        // JSON data
        ubyte[] _data;
        JSONValue _json;

        // Texture data
        string[] _loadedTextureNames;
        Texture[] _loadedTextures;

        // Mesh data
        Mesh[] _meshes;

        // Transformations
        vec3[] _translations;
        quat[] _rotations;
        vec3[] _scales;
        mat4[] _transforms;

        static const uint uintType = 5125;
        static const uint ushortType = 5123;
        static const uint shortType = 5122;
    }

    /// Constructor
    this(string fileName) {
        _json = parseJSON(readText("model/" ~ fileName));
        _data = getData();
        traverseNode(0);
    }

    /// Get data
    ubyte[] getData() {
        string uri = _json["buffers"][0]["uri"].get!string;
        return cast(ubyte[]) read("model/" ~ uri);
    }

    /// Get all floats from a JSONValue accessor
    float[] getFloats(JSONValue accessor) {
        const uint bufferViewId = getJsonInt(accessor, "bufferView", 1);
        const uint count = getJsonInt(accessor, "count");
        const uint byteOffset = getJsonInt(accessor, "byteOffset", 0);
        const string type = getJsonStr(accessor, "type");

        JSONValue bufferView = _json["bufferViews"][bufferViewId];
        const uint accessorByteOffset = getJsonInt(bufferView, "byteOffset");

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

        float[] values;
        for (uint dataId = dataStart; dataId < dataStart + dataLength; dataId) {
            ubyte[] bytes = [
                _data[dataId++],
                _data[dataId++],
                _data[dataId++],
                _data[dataId++]
            ];

            // Cast data to float
            values ~= *cast(float*)bytes.ptr;
        }

        return values;
    }

    GLuint[] getIndices(JSONValue accessor) {
        const uint bufferViewId = getJsonInt(accessor, "bufferView", 0);
        const uint count = getJsonInt(accessor, "count");
        const uint byteOffset = getJsonInt(accessor, "byteOffset", 0);
        const uint componentType = getJsonInt(accessor, "componentType");

        JSONValue bufferView = _json["bufferViews"][bufferViewId];
        const uint accessorByteOffset = getJsonInt(bufferView, "byteOffset");

        const uint dataStart = byteOffset + accessorByteOffset;

        GLuint[] values;
        if (componentType == uintType) {
            const uint dataLength = count * 4;

            for (uint dataId = dataStart; dataId < dataStart + dataLength; dataId) {
                ubyte[] bytes = [
                    _data[dataId++],
                    _data[dataId++],
                    _data[dataId++],
                    _data[dataId++]
                ];

                // Cast data to uint, then GLuint
                uint value = *cast(uint*)bytes.ptr;
                values ~= cast(GLuint) value;
            }
        } else if (componentType == ushortType) {
            const uint dataLength = count * 2;

            for (uint dataId = dataStart; dataId < dataStart + dataLength; dataId) {
                ubyte[] bytes = [
                    _data[dataId++],
                    _data[dataId++]
                ];

                // Cast data to ushort, then GLuint
                ushort value = *cast(ushort*)bytes.ptr;
                values ~= cast(GLuint) value;
            }
        } else if (componentType == shortType) {
            const uint dataLength = count * 2;

            for (uint dataId = dataStart; dataId < dataStart + dataLength; dataId) {
                ubyte[] bytes = [
                    _data[dataId++],
                    _data[dataId++]
                ];

                // Cast data to short, then GLuint
                short value = *cast(short*)bytes.ptr;
                values ~= cast(GLuint) value;
            }
        } else {
            throw new Exception("Unsupported indice data type " ~ to!string(componentType));
        }
        
        return values;
    }

    /// Group given float array as a vec2
    vec2[] groupFloatsVec2(float[] floats) {
        vec2[] values;
        for (uint i = 0; i < floats.length; i) {
            values ~= vec2(floats[i++], floats[i++]);
        }
        return values;
    }

    /// Group given float array as a vec3
    vec3[] groupFloatsVec3(float[] floats) {
        vec3[] values;
        for (uint i = 0; i < floats.length; i) {
            values ~= vec3(floats[i++], floats[i++], floats[i++]);
        }
        return values;
    }

    /// Group given float array as a vec4
    vec4[] groupFloatsVec4(float[] floats) {
        vec4[] values;
        for (uint i = 0; i < floats.length; i) {
            values ~= vec4(floats[i++], floats[i++], floats[i++], floats[i++]);
        }
        return values;
    }

    /// Assemble all vertices
    Vertex[] assembleVertices(vec3[] positions, vec3[] normals, vec2[] texUVs) {
        Vertex[] vertices;
        for (uint i = 0; i < positions.length; ++i) {
            Vertex vertex = { positions[i], normals[i], vec3(1.0f, 1.0f, 1.0f), texUVs[i] };
            vertices ~= vertex;
        }
        return vertices;
    }

    /// Load textures
    Texture[] getTextures() {
        uint textureId = 0;
        const string[] textureFiles = getJsonArrayStr(_json, "images");
        for (uint i = 0; i < textureFiles.length; ++i) {
            string path = _json["images"][i]["uri"].get!string;

            if (!canFind(_loadedTextureNames, path)) {
                _loadedTextureNames ~= path;

                if (canFind(path, "baseColor")) {
                    Texture diffuse = new Texture(path, "diffuse", textureId);
                    _loadedTextures ~= diffuse;
                    ++textureId;
                } else if (canFind(path, "metallicRoughness")) {
                    Texture specular = new Texture(path, "specular", textureId);
                    _loadedTextures ~= specular;
                    ++textureId;
                } else {
                    writeln("Warning: texture of unknown type not loaded");
                }
            }
        }

        return _loadedTextures;
    }

    /// Load mesh (only supports one primitive and one texture per mesh for now)
    void loadMesh(uint meshId) {
        JSONValue jsonMesh = _json["bufferViews"][meshId];
        JSONValue jsonPrimitive = jsonMesh["primitives"][0];
        JSONValue jsonAttributes = jsonPrimitive["attributes"];

        const uint positionId = getJsonInt(jsonAttributes, "POSITION");
        const uint normalId = getJsonInt(jsonAttributes, "NORMAL");
        const uint texUVId = getJsonInt(jsonAttributes, "TEXCOORD_0");
        const uint indicesId = getJsonInt(jsonAttributes, "indices");

        vec3[] positions = groupFloatsVec3(getFloats(_json["accessors"][positionId]));
        vec3[] normals = groupFloatsVec3(getFloats(_json["accessors"][normalId]));
        vec2[] texUVs = groupFloatsVec2(getFloats(_json["accessors"][texUVId]));

        Vertex[] vertices = assembleVertices(positions, normals, texUVs);
        GLuint[] indices = getIndices(_json["accessors"][indicesId]);
        Texture[] textures = getTextures();

        _meshes ~= new Mesh(vertices, indices, textures);
    }

    /// Traverse given node
    void traverseNode(uint nextNode, mat4 matrix = mat4.identity) {
        JSONValue node = _json["nodes"][nextNode];

        vec3 translation = vec3(0.0f, 0.0f, 0.0f);
        quat rotation = quat.identity;
        vec3 scale = vec3(1.0f, 1.0f, 1.0f);
        mat4 matNode = mat4.identity;

        float[] translationArray = getJsonArrayFloat(node, "translation", []);
        if (translationArray.length == 3) {
            translation = vec3(translationArray[0], translationArray[1], translationArray[2]);
        }

        // Check standardisation!
        float[] rotationArray = getJsonArrayFloat(node, "rotation", []);
        if (rotationArray.length == 4) {
            rotation = quat(rotationArray[3], rotationArray[0], rotationArray[1], rotationArray[2]);
        }

        float[] scaleArray = getJsonArrayFloat(node, "scale", []);
        if (scaleArray.length == 3) {
            scale = vec3(scaleArray[0], scaleArray[1], scaleArray[2]);
        }

        float[] matrixArray = getJsonArrayFloat(node, "matrix", []);
        if (matrixArray.length == 16) {
            uint arrayId = 0;
            for (uint i = 0 ; i < 4; ++i) {
                for (uint j = 0 ; j < 4; ++j) {
                    matNode[i][j] = matrixArray[arrayId];
                    ++arrayId;
                }
            }
        }

        mat4 localTranslation = mat4.identity;
        mat4 localRotation = mat4.identity;
        mat4 localScale = mat4.identity;

        localTranslation = localTranslation.translate(translation);
        localRotation = rotation.to_matrix!(4, 4);
        localScale[0][0] = scale.x;
        localScale[1][1] = scale.y;
        localScale[2][2] = scale.z;

        mat4 matNextNode = matrix * matNode * localTranslation * localRotation * localScale;

        // Load current node mesh
        if (hasJson(node, "mesh")) {
            _translations ~= translation;
            _rotations ~= rotation;
            _scales ~= scale;
            _transforms ~= matNextNode;

            loadMesh(getJsonInt(node, "mesh"));
        }

        // Traverse children recursively
        if (hasJson(node, "children")) {
            const JSONValue[] children = getJsonArray(node, "children");

            for (uint i = 0; i < children.length; ++i) {
                const uint childrenId = children[i].get!uint;
                traverseNode(childrenId, matNextNode);
            }
        }
    }

    /// Load all meshes
    void load() {
        const JSONValue[] jsonMeshes = getJsonArray(_json, "meshes");
        for(uint i = 0; i < jsonMeshes.length; ++i) {
            loadMesh(i);
        }
    }

    /// Draw the model
    void draw(Shader shader, Camera camera) {
        for (uint i = 0; i < _meshes.length; ++i) {
            _meshes[i].draw(shader, camera, _transforms[i]);
        }
    }
}