module magia.render.mesh;

import std.conv;

import bindbc.opengl;

import magia.render.vao;
import magia.render.vbo;
import magia.render.ebo;
import magia.render.camera;
import magia.render.texture;
import magia.render.shader;
import magia.render.vertex;

/// Class representing the mesh of a model
class Mesh {
    private {
        Vertex[] _vertices;
        GLuint[] _indices;
        Texture[] _textures;

        VAO _VAO;
        VBO _VBO;
        EBO _EBO;
    }

    /// Constructor
    this(Vertex[] vertices, GLuint[] indices, Texture[] textures = null) {
        _vertices = vertices;
        _indices = indices;

        if (textures) {
            _textures = textures;
        }

        _VAO = new VAO();
        _VAO.bind();

        _VBO = new VBO(_vertices);
        _EBO = new EBO(_indices);

        _VAO.linkAttributes(_VBO, 0, 3, GL_FLOAT, Vertex.sizeof, null);
        _VAO.linkAttributes(_VBO, 1, 3, GL_FLOAT, Vertex.sizeof, cast(void *)(3 * float.sizeof));
        _VAO.linkAttributes(_VBO, 2, 3, GL_FLOAT, Vertex.sizeof, cast(void *)(6 * float.sizeof));
        _VAO.linkAttributes(_VBO, 3, 2, GL_FLOAT, Vertex.sizeof, cast(void *)(9 * float.sizeof));

        _VAO.unbind();
        _VBO.unbind();
        _EBO.unbind();
    }

    /// Draw call
    void draw(Shader shader, Camera camera) {
        shader.activate();
        _VAO.bind();

        uint nbDiffuseTextures = 0;
        uint nbSpecularTextures = 0;
        
        uint textureId = 0;
        foreach(Texture texture; _textures) {
            const string type = texture.type;

            uint num;
            if (type == "diffuse") {
                ++nbDiffuseTextures;
                num = nbDiffuseTextures;
            } else if ("specular") {
                ++nbSpecularTextures;
                num = nbSpecularTextures;
            }

            texture.forwardToShader(shader, type ~ to!string(num), textureId);
            texture.bind();
            ++textureId;
        }

        glUniform3f(glGetUniformLocation(shader.id, "camPos"),
                    camera.position.x, camera.position.x, camera.position.z);
        camera.passToShader(shader, "camMatrix");

        glDrawElements(GL_TRIANGLES, cast(int) _indices.length, GL_UNSIGNED_INT, null);
    }
}