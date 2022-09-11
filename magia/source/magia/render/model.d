module magia.render.model;

import std.algorithm;
import std.conv;
import std.file;
import std.json;
import std.stdio;
import std.typecons;

import bindbc.opengl;
import gl3n.linalg;

import magia.core.json;
import magia.core.transform;
import magia.render.mesh;
import magia.render.shader;
import magia.render.texture;
import magia.render.vertex;

/// Class handling model data and draw call
final class Model : Renderable {
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
        Transform[] _transforms;

        // Instancing
        mat4[] _instanceMatrices;
        uint _instances;

        // Trace
        bool _trace = false;
        bool _traceDeep = false;

        // File directory
        string _fileDirectory;

        static const uint uintType = 5125;
        static const uint ushortType = 5123;
        static const uint shortType = 5122;
    }

    /// Constructor
    this(string fileName, uint instances = 1, mat4[] instanceMatrices = [mat4.identity]) {
        auto split = fileName.findSplitAfter("/");
        _fileDirectory = "assets/model/" ~ split[0];
        string filePath = _fileDirectory ~ split[1] ~ ".gltf";

        if (_trace) {
            writeln("Loading model ", filePath);
        }

        _json = parseJSON(readText(filePath));
        _data = getData();

        _instances = instances;
        _instanceMatrices = instanceMatrices;

        // Traverse all nodes
        traverseNode(0);
    }

    /// Get data
    ubyte[] getData() {
        string uri = _json["buffers"][0]["uri"].get!string;
        return cast(ubyte[]) read(_fileDirectory ~ uri);
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

        if (_trace) {
            writeln("Load indices with bufferViewId ", bufferViewId, " count ", count,
                    " byteOffset ", byteOffset, " componentType ", componentType);
        }

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
        if (_trace) {
            writeln("Vertices size: ", positions.count);
            writeln("Normals size: ", positions.count);
            writeln("UVs size: ", positions.count);
        }

        Vertex[] vertices;
        for (uint i = 0; i < positions.length; ++i) {
            if (_traceDeep) {
                writeln("Assembling vertex with",
                        " position ", positions[i],
                        " normal ", normals[i],
                        " texture UV ", texUVs[i]);
            }

            Vertex vertex = { positions[i], normals[i], vec3(1.0f, 1.0f, 1.0f), texUVs[i] };
            vertices ~= vertex;
        }
        return vertices;
    }

    /// Load textures
    Texture[] getTextures() {
        uint textureId = 0;

        const JSONValue[] jsonTextures = getJsonArray(_json, "images");

        // @TODO handle case where the jsonTextures array is empty by using default texture

        foreach (const JSONValue jsonTexture; jsonTextures) {
            const string path = _fileDirectory ~ getJsonStr(jsonTexture, "uri");

            if (!canFind(_loadedTextureNames, path)) {
                _loadedTextureNames ~= path;

                if (canFind(path, "baseColor") || canFind(path, "diffuse")) {
                    Texture diffuse = new Texture(path, "diffuse", textureId);
                    _loadedTextures ~= diffuse;
                    ++textureId;
                } else if (canFind(path, "metallicRoughness") || canFind(path, "specular")) {
                    Texture specular = new Texture(path, "specular", textureId);
                    _loadedTextures ~= specular;
                    ++textureId;
                } else if (_trace) {
                    writeln("Warning: unknown texture type ", path ,", not loaded");
                }
            }
        }

        return _loadedTextures;
    }

    /// Load mesh (only supports one primitive and one texture per mesh for now)
    void loadMesh(uint meshId) {
        if (_trace) {
            writeln("Mesh load");
        }

        JSONValue jsonMesh = _json["meshes"][meshId];
        JSONValue jsonPrimitive = jsonMesh["primitives"][0];
        JSONValue jsonAttributes = jsonPrimitive["attributes"];

        const uint positionId = getJsonInt(jsonAttributes, "POSITION");
        const uint normalId = getJsonInt(jsonAttributes, "NORMAL");
        const uint texUVId = getJsonInt(jsonAttributes, "TEXCOORD_0");
        const uint indicesId = getJsonInt(jsonPrimitive, "indices");

        vec3[] positions = groupFloatsVec3(getFloats(_json["accessors"][positionId]));
        vec3[] normals = groupFloatsVec3(getFloats(_json["accessors"][normalId]));
        vec2[] texUVs = groupFloatsVec2(getFloats(_json["accessors"][texUVId]));
        
        Vertex[] vertices = assembleVertices(positions, normals, texUVs);
        GLuint[] indices = getIndices(_json["accessors"][indicesId]);
        Texture[] textures = getTextures();

        _meshes ~= new Mesh(vertices, indices, textures, _instances, _instanceMatrices);
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

            if (_trace) {
                writeln("Translation: ", translation);
            }
        }

        float[] rotationArray = getJsonArrayFloat(node, "rotation", []);
        if (rotationArray.length == 4) {
            rotation = quat(rotationArray[3], rotationArray[0], rotationArray[1], rotationArray[2]);

            if (_trace) {
                writeln("Rotation: ", rotation);
            }
        }

        float[] scaleArray = getJsonArrayFloat(node, "scale", []);
        if (scaleArray.length == 3) {
            scale = vec3(scaleArray[0], scaleArray[1], scaleArray[2]);

            if (_trace) {
                writeln("Scale: ", scale);
            }
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

            if (_trace) {
                writeln("Matrix: ", matNode);
            }
        }

        const mat4 combinedTransform = combineModel(translation, rotation, scale);

        mat4 matNextNode = matrix * matNode * combinedTransform;

        // Load current node mesh
        if (hasJson(node, "mesh")) {
            if (_trace) {
                writeln("Load current mesh");
            }

            _transforms ~= Transform(matNextNode, translation, rotation, scale);
            loadMesh(getJsonInt(node, "mesh"));
        }

        // Traverse children recursively
        if (hasJson(node, "children")) {
            const JSONValue[] children = getJsonArray(node, "children");

            if (_trace) {
                writeln("Load children ", children);
            }

            for (uint i = 0; i < children.length; ++i) {
                const uint childrenId = children[i].get!uint;
                traverseNode(childrenId, matNextNode);
            }
        }
    }

    /// Draw the model
    void draw(Shader shader, Transform transform) {
        // Model culling is the opposite of usual objects
        glCullFace(GL_BACK);

        mat4 transformModel = combineModel(transform);

        for (uint i = 0; i < _meshes.length; ++i) {
            Transform finalTransform = Transform(_transforms[i].model * transformModel);
            _meshes[i].draw(shader, finalTransform);
        }

        // Revert to usual culling
        glCullFace(GL_FRONT);
    }
}