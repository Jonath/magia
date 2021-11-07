module magia.shape.pyramid;

import std.string;
import std.stdio;

import bindbc.opengl;
import gl3n.linalg;

import magia.core;

import magia.render.camera;
import magia.render.drawable;
import magia.render.mesh;
import magia.render.shader;
import magia.render.texture;
import magia.render.vertex;
import magia.render.window;

/// Renders a **Pyramid** with its own properties.
final class Pyramid : Drawable3D {
    private {
        Mesh _pyramidMesh, _lightMesh;

        Camera _camera;
        Shader _shaderProgram, _lightShader;
        GLuint _scaleId;

        float _rotation;

        mat4 _pyramidModel;
        mat4 _lightModel;
    }

    /// Constructor
    this() {
        // Pyramid vertices
        Vertex[] vertices = [
            //          COORDINATES           /        NORMALS          /           COLORS          /   TEXCOORDS   //
            Vertex(vec3(-0.5f, 0.0f,  0.5f),   vec3(0.0f,  -1.0f, 0.0f),  vec3(0.83f, 0.70f, 0.44f),  vec2(0.0f, 0.0f)), // Bottom side
            Vertex(vec3(-0.5f, 0.0f, -0.5f),   vec3(0.0f,  -1.0f, 0.0f),  vec3(0.83f, 0.70f, 0.44f),  vec2(0.0f, 2.5f)), // Bottom side
            Vertex(vec3( 0.5f, 0.0f, -0.5f),   vec3(0.0f,  -1.0f, 0.0f),  vec3(0.83f, 0.70f, 0.44f),  vec2(2.5f, 2.5f)), // Bottom side
            Vertex(vec3( 0.5f, 0.0f,  0.5f),   vec3(0.0f,  -1.0f, 0.0f),  vec3(0.83f, 0.70f, 0.44f),  vec2(2.5f, 0.0f)), // Bottom side

            Vertex(vec3(-0.5f, 0.0f,  0.5f),   vec3(0.83f, 0.70f, 0.44f), vec3(-0.8f, 0.5f,  0.0f),   vec2(0.0f,  0.0f)), // Left Side
            Vertex(vec3(-0.5f, 0.0f, -0.5f),   vec3(0.83f, 0.70f, 0.44f), vec3(-0.8f, 0.5f,  0.0f),	  vec2(2.5f,  0.0f)), // Left Side
            Vertex(vec3( 0.0f, 0.8f,  0.0f),   vec3(0.92f, 0.86f, 0.76f), vec3(-0.8f, 0.5f,  0.0f),	  vec2(1.25f, 2.5f)), // Left Side

            Vertex(vec3(-0.5f, 0.0f, -0.5f),   vec3(0.83f, 0.70f, 0.44f), vec3( 0.0f, 0.5f, -0.8f),   vec2(2.5f,  0.0f)), // Non-facing side
            Vertex(vec3( 0.5f, 0.0f, -0.5f),   vec3(0.83f, 0.70f, 0.44f), vec3( 0.0f, 0.5f, -0.8f),   vec2(0.0f,  0.0f)), // Non-facing side
            Vertex(vec3( 0.0f, 0.8f,  0.0f),   vec3(0.92f, 0.86f, 0.76f), vec3( 0.0f, 0.5f, -0.8f),	  vec2(1.25f, 2.5f)), // Non-facing side

            Vertex(vec3( 0.5f, 0.0f, -0.5f),   vec3(0.83f, 0.70f, 0.44f), vec3( 0.8f, 0.5f,  0.0f),	  vec2(0.0f,  0.0f)), // Right side
            Vertex(vec3( 0.5f, 0.0f,  0.5f),   vec3(0.83f, 0.70f, 0.44f), vec3( 0.8f, 0.5f,  0.0f),	  vec2(2.5f,  0.0f)), // Right side
            Vertex(vec3( 0.0f, 0.8f,  0.0f),   vec3(0.92f, 0.86f, 0.76f), vec3( 0.8f, 0.5f,  0.0f),	  vec2(1.25f, 2.5f)), // Right side

            Vertex(vec3( 0.5f, 0.0f,  0.5f),   vec3(0.83f, 0.70f, 0.44f), vec3( 0.0f, 0.5f,  0.8f),	  vec2(2.5f,  0.0f)), // Facing side
            Vertex(vec3(-0.5f, 0.0f,  0.5f),   vec3(0.83f, 0.70f, 0.44f), vec3( 0.0f, 0.5f,  0.8f),   vec2(0.0f,  0.0f)), // Facing side
            Vertex(vec3( 0.0f, 0.8f,  0.0f),   vec3(0.92f, 0.86f, 0.76f), vec3( 0.0f, 0.5f,  0.8f),   vec2(1.25f, 2.5f))  // Facing side
        ];

        // Pyramid indices
        GLuint[] indices = [
            0, 1, 2, // Bottom side
            0, 2, 3, // Bottom side
            4, 6, 5, // Left side
            7, 9, 8, // Non-facing side
            10, 12, 11, // Right side
            13, 15, 14 // Facing side
        ];

        // Pyramid light vertices
        Vertex[] lightVertices = [
            //  COORDINATES
            Vertex(vec3(-0.01f, -0.01f,  0.01f)),
            Vertex(vec3(-0.01f, -0.01f, -0.01f)),
            Vertex(vec3( 0.01f, -0.01f, -0.01f)),
            Vertex(vec3( 0.01f, -0.01f,  0.01f)),
            Vertex(vec3(-0.01f,  0.01f,  0.01f)),
            Vertex(vec3(-0.01f,  0.01f, -0.01f)),
            Vertex(vec3( 0.01f,  0.01f, -0.01f)),
            Vertex(vec3( 0.01f,  0.01f,  0.01f)),
        ];

        // Pyramid light indices
        GLuint[] lightIndices = [
            0, 1, 2,
            0, 2, 3,
            0, 4, 7,
            0, 7, 3,
            3, 7, 6,
            3, 6, 2,
            2, 6, 5,
            2, 5, 1,
            1, 5, 4,
            1, 4, 0,
            4, 5, 6,
            4, 6, 7
        ];

        // Was bricks.png
        Texture[] textures = [
            new Texture("assets/texture/bricks.png", "diffuse", 0)
        ];

        _pyramidMesh = new Mesh(vertices, indices, textures);
        _lightMesh = new Mesh(lightVertices, lightIndices);
        
        _shaderProgram = new Shader("default.vert", "default.frag");
        _lightShader = new Shader("light.vert", "light.frag");

        vec4 lightColor = vec4(1.0f, 1.0f, 1.0f, 1.0f);
        vec3 lightPos = vec3(0.5f, 0.5f, 0.5f);
        _lightModel = mat4.identity;
        _lightModel = _lightModel.translate(lightPos);

        vec3 pyramidPos = vec3(0.0f, 0.0f, 0.0f);
	    _pyramidModel = mat4.identity;
	    _pyramidModel = _pyramidModel.translate(pyramidPos);

        _lightShader.activate();
        glUniform4f(glGetUniformLocation(_lightShader.id, "lightColor"),
                                         lightColor.x, lightColor.y, lightColor.z, lightColor.w);

        _shaderProgram.activate();
        glUniform4f(glGetUniformLocation(_shaderProgram.id, "lightColor"),
                                         lightColor.x, lightColor.y, lightColor.z, lightColor.w);
        glUniform3f(glGetUniformLocation(_shaderProgram.id, "lightPos"),
                                         lightPos.x, lightPos.y, lightPos.z);

        _camera = new Camera(screenWidth, screenHeight, Vec3f(0f, 0f, 2f));
    }

    /// Unload
    void unload() {
        _shaderProgram.remove();
        _lightShader.remove();
    }

    /// Render the pyramid
    override void draw() {
        _camera.processInputs();
        _camera.updateMatrix(45f, 0.1f, 100f);

        _pyramidMesh.draw(_shaderProgram, _camera, _pyramidModel);
        _lightMesh.draw(_lightShader, _camera, _lightModel);
    }
}
