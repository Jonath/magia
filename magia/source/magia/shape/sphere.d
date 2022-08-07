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
        Mesh[] _meshes;
    }

    this(int resolution) {
        transform = Transform.identity;

        string pathPrefix = "assets/texture/"; // @TODO factorize

        Texture[] textures;
        textures ~= new Texture(pathPrefix ~ "pixel.png", "diffuse", 0);

        vec3[] directions = [up, down, left, right, forward, back];

        for (int directionIdx = 0; directionIdx < directions.length; ++directionIdx) {
            generateFaceMesh(textures, directions[directionIdx], resolution);
        }
    }

    void generateFaceMesh(Texture[] textures, vec3 directionY, int resolution) {
        vec3 directionX = vec3(directionY.y, directionY.z, directionY.x);
        vec3 directionZ = directionX.cross(directionY);

        int nbVertices = resolution * resolution;
        Vertex[] vertices = new Vertex[nbVertices];

        int resolution2 = resolution - 1;
        float fResolution2 = cast(float)(resolution2); 

        int nbIndices = resolution2 * resolution2 * 6;
        GLuint[] indices = new uint[nbIndices];

        int indiceIdx = 0;
        for (int y = 0; y < resolution; ++y) {
            for (int x = 0; x < resolution; ++x) {
                float fx = cast(float)(x); 
                float fy = cast(float)(y);

                int vertexIdx = x + y * resolution;

                vec2 ratio = vec2(x, y) / resolution2;
                vec2 ratioScale = (ratio - vec2(0.5f, 0.5f)) * 2;
                vec3 surfacePoint = directionY + ratioScale.x * directionX + ratioScale.y * directionZ; 
                vertices[vertexIdx].position = surfacePoint.normalized;
                vertices[vertexIdx].texUV = vec2(fx / fResolution2, fy / fResolution2);

                if (x != resolution2 && y != resolution2) {
                    // Map first triangle
                    indices[indiceIdx]     = vertexIdx;
                    indices[indiceIdx + 1] = vertexIdx + resolution + 1;
                    indices[indiceIdx + 2] = vertexIdx + resolution;

                    // Map second triangle
                    indices[indiceIdx + 3] = vertexIdx;
                    indices[indiceIdx + 4] = vertexIdx + 1;
                    indices[indiceIdx + 5] = vertexIdx + resolution + 1;

                    // Increment indices counter
                    indiceIdx += 6;
                }
            }
        }

        _meshes ~= new Mesh(vertices, indices, textures);
    }

    /// Render the sphere
    void draw(Shader shader) {
        foreach(Mesh mesh; _meshes) {
            mesh.draw(shader, transform);
        }
    }
}