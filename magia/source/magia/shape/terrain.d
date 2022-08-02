module magia.shape.terrain;

import bindbc.opengl;
import gl3n.linalg;

import magia.core;

import magia.render.entity;
import magia.render.mesh;
import magia.render.shader;
import magia.render.texture;
import magia.render.vertex;

import std.stdio;

/// Instance of terrain
final class TerrainInstance : Entity3D {
    private {
        Mesh _mesh;
        vec2 _gridPos;
    }

    this(vec2 gridPos, vec2 size, int nbVertices, int tiling, string[] textureFilePaths) {
        transform = Transform.identity;

        _gridPos = gridPos;

        string pathPrefix = "assets/texture/"; // @TODO factorize

        Texture[] textures;
        foreach (string textureFilePath; textureFilePaths) {
            textures ~= new Texture(pathPrefix ~ textureFilePath, "diffuse", 0);
        }

        int count = nbVertices * nbVertices;
        Vertex[] vertices = new Vertex[count];

        int   nbRemaining  = nbVertices - 1;
        float fNbRemaining = cast(float)(nbRemaining); 

        int vertexIdx = 0;
        for (int x = 0; x < nbVertices; ++x) {
            for (int y = 0; y < nbVertices; ++y) {
                float fx = cast(float)(x); 
                float fy = cast(float)(y);

                // Vertices are mapped around xz plane
                vec3 vertex = vec3(fx / fNbRemaining * size.x, 0, fy / fNbRemaining * size.y);

                // Normal goes up along y axis
                vec3 normal = vec3(0.0f, 1.0f, 0.0f);

                // Texture coordinates
                vec2 uvs = vec2(fx / fNbRemaining, fy / fNbRemaining) * tiling;

                // Pack it up (no color for now)
                vertices[vertexIdx] = Vertex(vertex, normal, vec3(0.0f, 0.0f, 0.0f), uvs);
                ++vertexIdx;
            }
        }

        int count2 = (nbVertices - 1) * (nbVertices - 1);
        GLuint[] indices = new uint[count2 * 6];

        // Counter-clockwise indice mapping 
        int indiceIdx = 0;
        for(int x = 0; x < nbRemaining; ++x) {
            for (int y = 0; y < nbRemaining; ++y) {
                int topLeft     = x * nbVertices + y;
                int topRight    = topLeft + 1;
                int bottomLeft  = (x + 1) * nbVertices + y;
                int bottomRight = bottomLeft + 1;

                // Left square triangle
                indices[indiceIdx++] = topLeft;
                indices[indiceIdx++] = bottomLeft;
                indices[indiceIdx++] = topRight;

                // Right square triangle
                indices[indiceIdx++] = topRight;
                indices[indiceIdx++] = bottomLeft;
                indices[indiceIdx++] = bottomRight;
            }
        }

        _mesh = new Mesh(vertices, indices, textures);
    }

    /// Render the terrain
    void draw(Shader shader) {
        _mesh.draw(shader, transform);
    }
}