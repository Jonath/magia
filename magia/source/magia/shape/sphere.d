module magia.shape.sphere;

import bindbc.opengl;
import gl3n.linalg;

import magia.core;

import magia.render.entity;
import magia.render.mesh;
import magia.render.shader;
import magia.render.texture;
import magia.render.vertex;

// @TODO remove
import magia.shape.line;
import magia.render.scene;

import std.stdio;

vec3 up      = vec3( 0,  1,  0);
vec3 down    = vec3( 0, -1,  0);
vec3 left    = vec3(-1,  0,  0);
vec3 right   = vec3( 1,  0,  0);
vec3 forward = vec3( 0,  0,  1);
vec3 back    = vec3( 0,  0, -1);

/// Instance of sphere
class Sphere : Entity3D {
    protected {
        Mesh[]    _meshes;
        Texture[] _textures;

        // Sphere parameters
        int   _resolution;
        float _radius;

        // Debug params
        bool _debug;
    }

    this(int resolution, float radius) {
        transform = Transform.identity;

        _resolution = resolution;
        _radius = radius;

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

                vertices[vertexIdx].position = generateSurfacePoint(directionX, directionY, directionZ, x, y, resolution2);
                vertices[vertexIdx].texUV = vec2(fx / fResolution2, fy / fResolution2);
                vertices[vertexIdx].color = vec3(1, 0, 0);
                vertices[vertexIdx].normal = computeNormal(vertices[vertexIdx].position);

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

        _meshes ~= new Mesh(vertices, indices, _textures);
    }

    /// Generate a point on the sphere's surface
    protected vec3 generateSurfacePoint(vec3 directionX, vec3 directionY, vec3 directionZ,
                                        int x, int y, int resolution) {
        vec2 ratio = vec2(x, y) / resolution;
        vec2 ratioScale = (ratio - vec2(0.5f, 0.5f)) * 2;
        vec3 surfacePoint = directionY + ratioScale.x * directionX + ratioScale.y * directionZ;
        return surfacePoint.normalized;
    }

    /// Get vertex id for position (x, y)
    protected int getVertexIdx(int x, int y) {
        return x + y * _resolution;
    }

    // Compute normals 
    private vec3 computeNormal(vec3 surfacePoint) {
        vec3 center = transform.position;
        vec3 normal = surfacePoint - center;
        normal.normalize();

        if (_debug) {
            addLine(new Line(surfacePoint, surfacePoint + normal * _radius / 100, vec3(0., 1., 0.)));
        }

        return normal;
    }

    /// Render the sphere
    void draw(Shader shader) {
        foreach(Mesh mesh; _meshes) {
            mesh.draw(shader, transform);
        }
    }
}