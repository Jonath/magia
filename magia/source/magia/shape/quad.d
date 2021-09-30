module magia.shape.quad;

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

/// Renders a **Quad** with its own properties.
final class Quad : Drawable3D {
    private {
        Mesh _quadMesh, _lightMesh;

        Camera _camera;
        Shader _shaderProgram, _lightShader;
        GLuint _scaleId;

        float _rotation;

        mat4 _quadModel;
        mat4 _lightModel;
    }

    /// Constructor
    this() {
        // Quad vertices
        Vertex[] vertices = [
            //     COORDINATES                /     NORMALS         /    COLORS        /    TexCoord   //
	        Vertex(vec3(-1.0f, 0.0f,  1.0f), vec3(0.0f, 1.0f, 0.0f), vec3(0.0f, 0.0f, 0.0f), vec2(0.0f, 0.0f)),
	        Vertex(vec3(-1.0f, 0.0f, -1.0f), vec3(0.0f, 1.0f, 0.0f), vec3(0.0f, 0.0f, 0.0f), vec2(0.0f, 1.0f)),
	        Vertex(vec3( 1.0f, 0.0f, -1.0f), vec3(0.0f, 1.0f, 0.0f), vec3(0.0f, 0.0f, 0.0f), vec2(1.0f, 1.0f)),
	        Vertex(vec3( 1.0f, 0.0f,  1.0f), vec3(0.0f, 1.0f, 0.0f), vec3(0.0f, 0.0f, 0.0f), vec2(1.0f, 0.0f))
        ];

        // Quad indices
        GLuint[] indices = [
            0, 1, 2,
            0, 2, 3
        ];

        // Quad light vertices
        Vertex[] lightVertices = [
            //  COORDINATES
            Vertex(vec3(-0.1f, -0.1f,  0.1f)),
            Vertex(vec3(-0.1f, -0.1f, -0.1f)),
            Vertex(vec3( 0.1f, -0.1f, -0.1f)),
            Vertex(vec3( 0.1f, -0.1f,  0.1f)),
            Vertex(vec3(-0.1f,  0.1f,  0.1f)),
            Vertex(vec3(-0.1f,  0.1f, -0.1f)),
            Vertex(vec3( 0.1f,  0.1f, -0.1f)),
            Vertex(vec3( 0.1f,  0.1f,  0.1f))
        ];

        // Quad light indices
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

        Texture[] textures = [
            new Texture("planks.png", "diffuse", 0),
            new Texture("planksSpec.png", "specular", 1)
        ];

        _quadMesh = new Mesh(vertices, indices, textures);
        _lightMesh = new Mesh(lightVertices, lightIndices);

        _shaderProgram = new Shader("default.vert", "default.frag");
        _lightShader = new Shader("light.vert", "light.frag");

        vec4 lightColor = vec4(1.0f, 1.0f, 1.0f, 1.0f);
        vec3 lightPos = vec3(0.5f, 0.5f, 0.5f);
        _lightModel = mat4.identity;
        _lightModel = _lightModel.translate(lightPos);

        vec3 quadPos = vec3(0.0f, 0.0f, 0.0f);
	    _quadModel = mat4.identity;
	    _quadModel = _quadModel.translate(quadPos);

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

    /// Render the quad
    override void draw() {
        _camera.processInputs();
        _camera.updateMatrix(45f, 0.1f, 100f);

        _quadMesh.draw(_shaderProgram, _camera, _quadModel);
        _lightMesh.draw(_lightShader, _camera, _lightModel);
    }
}