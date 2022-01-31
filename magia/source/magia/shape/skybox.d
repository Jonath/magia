module magia.shape.skybox;

import bindbc.opengl;

import magia.render.ebo;
import magia.render.vao;
import magia.render.vbo;
import magia.render.vertex;

/// Packs a skybox mesh and shader
final class SkyboxGroup {
    private {
        /// Vertices
        float[] _vertices = [
            // Coordinates
            -1.0f, -1.0f,  1.0f,    //      7---------6
            1.0f, -1.0f,  1.0f,    //     /|        /|
            1.0f, -1.0f, -1.0f,    //    4---------5 |
            -1.0f, -1.0f, -1.0f,    //    | |       | |
            -1.0f,  1.0f,  1.0f,    //    | 3-------|-2
            1.0f,  1.0f,  1.0f,    //    |/        |/
            1.0f,  1.0f, -1.0f,    //    0---------1
            -1.0f,  1.0f, -1.0f     //
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
        
        VAO _VAO;
        VBO _VBO;
        EBO _EBO;
    }

    /// Constructor
    this() {
        _VAO = new VAO();
        _VBO = new VBO(_vertices);
        _EBO = new EBO(_indices);

        string[6] faceCubemaps = [
            "skybox/right.jpg",
            "skybox/left.jpg",
            "skybox/top.jpg",
            "skybox/bottom.jpg",
            "skybox/back.jpg",
            "skybox/front.jpg"
        ];

        
    }
}