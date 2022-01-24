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
import magia.render.light;

/// Renders a **Quad** with its own properties.
final class Quad : Drawable3D {
    private {
        Mesh _quadMesh;

        Camera _camera;
        Shader _shaderProgram;
        GLuint _scaleId;

        float _rotation;

        mat4 _quadModel;
    }

    /// Constructor
    this(Camera camera, Light light) {
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

        string pathPrefix = "assets/texture/";

        Texture[] textures = [
            new Texture(pathPrefix ~ "planks.png", "diffuse", 0),
            new Texture(pathPrefix ~ "planksSpec.png", "specular", 1)
        ];

        _quadMesh = new Mesh(vertices, indices, textures);
        _shaderProgram = new Shader("default.vert", "default.frag");

        vec3 quadPos = vec3(0.0f, 0.0f, 0.0f);
	    _quadModel = mat4.identity;
	    _quadModel = _quadModel.translate(quadPos);

        _shaderProgram.activate();
        glUniform4f(glGetUniformLocation(_shaderProgram.id, "lightColor"),
                                         light.color.x, light.color.y, light.color.z, light.color.w);
        glUniform3f(glGetUniformLocation(_shaderProgram.id, "lightPos"),
                                         light.position.x, light.position.y, light.position.z);

        _camera = camera;
    }

    /// Unload
    void unload() {
        _shaderProgram.remove();
    }

    /// Render the quad
    override void draw() {
        _quadMesh.draw(_shaderProgram, _camera, _quadModel);
    }
}