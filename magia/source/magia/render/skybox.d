module magia.render.skybox;

import std.stdio;

import bindbc.opengl;
import gl3n.linalg;

import magia.render.camera;
import magia.render.shader;
import magia.render.texture;
import magia.render.ebo;
import magia.render.vao;
import magia.render.vbo;
import magia.render.vertex;

/// Class handling skybox data and draw call
final class Skybox {
    private {
        /// Vertices
        float[] _vertices = [
            // Coordinates
            -1.0f, -1.0f,  1.0f,   //      7---------6
             1.0f, -1.0f,  1.0f,   //     /|        /|
             1.0f, -1.0f, -1.0f,   //    4---------5 |
            -1.0f, -1.0f, -1.0f,   //    | |       | |
            -1.0f,  1.0f,  1.0f,   //    | 3-------|-2
             1.0f,  1.0f,  1.0f,   //    |/        |/
             1.0f,  1.0f, -1.0f,   //    0---------1
            -1.0f,  1.0f, -1.0f    //
        ];

        /// Indices
        GLuint[] _indices = [
            // Right
            1, 2, 6,
            6, 5, 1,
            // Left
            0, 4, 7,
            7, 3, 0,
            // Top
            4, 5, 6,
            6, 7, 4,
            // Bottom
            0, 3, 2,
            2, 1, 0,
            // Back
            0, 1, 5,
            5, 4, 0,
            // Front
            3, 7, 6,
            6, 2, 3 
        ];
        
        Camera _camera;
        Shader _shader;
        Texture _texture;
        
        VAO _VAO;
        VBO _VBO;
        EBO _EBO;
    }

    /// Constructor
    this(Camera camera) {
        _camera = camera;
        _shader = new Shader("skybox.vert", "skybox.frag");
        _shader.activate();
        glUniform1i(glGetUniformLocation(_shader.id, "skybox"), 0);

        _VAO = new VAO();
        _VBO = new VBO(_vertices);
        _EBO = new EBO(_indices);
        _VAO.linkAttributes(_VBO, 0, 3, GL_FLOAT, 3 * float.sizeof, null);

        _VAO.unbind();
        _VBO.unbind();
        _EBO.unbind();

        string[6] faceCubemaps = [
            "right.png",
            "left.png",
            "top.png",
            "bottom.png",
            "back.png",
            "front.png"
        ];

        _texture = new Texture(faceCubemaps);
        _texture.forwardToShader(_shader, _texture.type, 0);
    }

    /// Draw call
    void draw() {
        glDepthFunc(GL_LEQUAL);
        
        _shader.activate();
        _camera.passToShader(_shader, "camMatrix");

        _VAO.bind();
        _texture.bind();
        glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_INT, null);

        glDepthFunc(GL_LESS);
    }
}