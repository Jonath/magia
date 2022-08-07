module magia.render.skybox;

import std.stdio;

import bindbc.opengl;
import gl3n.linalg;

import magia.render.camera;
import magia.render.postprocess;
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
            6, 5, 1,
            1, 2, 6,
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

        string[6] faceCubemaps = [
            "night/right.png",
            "night/left.png",
            "night/top.png",
            "night/bottom.png",
            "night/front.png",
            "night/back.png"
        ];

        _texture = new Texture(faceCubemaps);
        _texture.forwardToShader(_shader, _texture.type, 0);

        // Generate and bind VAO
        _VAO = new VAO();
        _VAO.bind();

        // Generate and bind VBO, EBO
        _VBO = new VBO(_vertices);
        _EBO = new EBO(_indices);

        // Link VBO attributes
        _VAO.linkAttributes(_VBO, 0, 3, GL_FLOAT, 3 * float.sizeof, null);

        // Unbind all objects
        VAO.unbind();
        VBO.unbind();
        EBO.unbind();
    }

    /// Draw call
    void draw() {
        glDepthFunc(GL_LEQUAL);
        
        _shader.activate();
        _camera.passToSkyboxShader(_shader);
        glUniform1f(glGetUniformLocation(_shader.id, "gamma"), gamma);

        _VAO.bind();
        _texture.bind();
        glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_INT, null);

        glDepthFunc(GL_LESS);
    }
}