module magia.shape.sphere;

import bindbc.opengl;
import gl3n.linalg;

import magia.core;

import magia.render.entity;
import magia.render.mesh;
import magia.render.shader;
import magia.render.texture;
import magia.render.vertex;

import std.stdio;

vec3 up      = vec3( 0,  1,  0);
vec3 down    = vec3( 0, -1,  0);
vec3 left    = vec3(-1,  0,  0);
vec3 right   = vec3( 1,  0,  0);
vec3 forward = vec3( 0,  0,  1);
vec3 back    = vec3( 0,  0, -1);

/// Instance of sphere
final class Sphere : Entity3D {
    private {
        Mesh[]    _meshes;
        Texture[] _textures;

        // Sphere parameters
        int   _resolution;
        float _radius;

        // Noise parameters
        vec3 _noiseOffset;
        int _nbLayers;
        float _strength;
        float _roughness;
        float _persistence;
        float _minHeight;
    }

    this(int resolution, float radius, vec3 noiseOffset, int nbLayers,
        float strength, float roughness, float persistence, float minHeight) {
        transform = Transform.identity;

        _resolution = resolution;
        _radius = radius;

        _noiseOffset = noiseOffset;
        _nbLayers = nbLayers;
        _strength = strength;
        _roughness = roughness;
        _persistence = persistence;
        _minHeight = minHeight;

        string pathPrefix = "assets/texture/"; // @TODO factorize

        _textures ~= new Texture(pathPrefix ~ "pixel.png", "diffuse", 0);

        vec3[] directions = [up, down, left, right, forward, back];

        for (int directionIdx = 0; directionIdx < directions.length; ++directionIdx) {
            generateFaceMesh(directions[directionIdx]);
        }
    }

    private void generateFaceMesh(vec3 directionY) {
        vec3 directionX = vec3(directionY.y, directionY.z, directionY.x);
        vec3 directionZ = directionX.cross(directionY);

        int nbVertices = _resolution * _resolution;
        Vertex[] vertices = new Vertex[nbVertices];

        int resolution2 = _resolution - 1;
        float fResolution2 = cast(float)(resolution2); 

        int nbIndices = resolution2 * resolution2 * 6;
        GLuint[] indices = new uint[nbIndices];

        int indiceIdx = 0;
        for (int y = 0; y < _resolution; ++y) {
            for (int x = 0; x < _resolution; ++x) {
                float fx = cast(float)(x); 
                float fy = cast(float)(y);

                int vertexIdx = getVertexIdx(x, y);

                vec2 ratio = vec2(x, y) / resolution2;
                vec2 ratioScale = (ratio - vec2(0.5f, 0.5f)) * 2;
                vec3 surfacePoint = directionY + ratioScale.x * directionX + ratioScale.y * directionZ; 
                vertices[vertexIdx].position = generateSpherePoint(surfacePoint.normalized);
                vertices[vertexIdx].texUV = vec2(fx / fResolution2, fy / fResolution2);
                vertices[vertexIdx].color = vec3(1, 0, 0);

                if (x != resolution2 && y != resolution2) {
                    // Map first triangle
                    indices[indiceIdx]     = vertexIdx;
                    indices[indiceIdx + 1] = vertexIdx + _resolution + 1;
                    indices[indiceIdx + 2] = vertexIdx + _resolution;

                    // Map second triangle
                    indices[indiceIdx + 3] = vertexIdx;
                    indices[indiceIdx + 4] = vertexIdx + 1;
                    indices[indiceIdx + 5] = vertexIdx + _resolution + 1;

                    // Increment indices counter
                    indiceIdx += 6;
                }
            }
        }

        for (int y = 0; y < _resolution; ++y) {
            for (int x = 0; x < _resolution; ++x) {
                int vertexIdx = getVertexIdx(x, y);
                vertices[vertexIdx].normal = computeNormals(x, y, vertices);
            }
        }

        _meshes ~= new Mesh(vertices, indices, _textures);
    }

    private int getVertexIdx(int x, int y) {
        return x + y * _resolution;
    }

    private vec3 computeNormals(int x, int y, Vertex[] vertices) {
        int xa = x + 1 < _resolution ? x + 1 : 0;
        int xb = x - 1 > 0 ? x - 1 : _resolution - 1;

        int ya = y + 1 < _resolution ? y + 1 : 0;
        int yb = y - 1 > 0 ? y - 1 : _resolution - 1;

        int leftIdx = getVertexIdx(xb, y);
        int rightIdx = getVertexIdx(xa, y);
        int downIdx = getVertexIdx(x, yb);
        int upIdx = getVertexIdx(x, ya);

        float heightL = getHeight(vertices[leftIdx].position);
        float heightR = getHeight(vertices[rightIdx].position);
        float heightD = getHeight(vertices[downIdx].position);
        float heightU = getHeight(vertices[upIdx].position);

        vec3 normal = vec3(heightL - heightR, 2f, heightD - heightU);
        normal.normalize();
        return normal;
    }

    private vec3 generateSpherePoint(vec3 surfacePoint) {
        return surfacePoint * evaluate(surfacePoint);
    }

    private float evaluate(vec3 point) {
        float noiseValue = 0;
        float frequency = 1;
        float amplitude = 1;

        for (int layerId = 0; layerId < _nbLayers; ++layerId) {
            noiseValue = getHeight(point * frequency + _noiseOffset);
            frequency *= _roughness;
            amplitude *= _persistence;
        }

        noiseValue = max(0, noiseValue - _minHeight);
        return noiseValue * _strength;
    }
    
    private float getHeight(vec3 point) {
        float elevation = noise(point.x, point.y, point.z) * _strength;
        return _radius * (1 + elevation);
    }

    /// Render the sphere
    void draw(Shader shader) {
        foreach(Mesh mesh; _meshes) {
            mesh.draw(shader, transform);
        }
    }
}