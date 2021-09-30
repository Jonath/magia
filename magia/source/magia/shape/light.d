module magia.shape.light;

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

/// Renders a **Light** with its own properties.
final class Light : Drawable3D {
    private {
        Mesh _mesh;
        Camera _camera;
        Shader _shader;
    }

    /// Constructor
    this() {
        // Quad light vertices
        Vertex[] vertices = [
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
        GLuint[] indices = [
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

        _mesh = new Mesh(vertices, indices);
        _shader = new Shader("default.vert", "light.frag");

        vec4 lightColor = vec4(1.0f, 1.0f, 1.0f, 1.0f);
        vec3 lightPos = vec3(0.5f, 0.5f, 0.5f);
        mat4 lightModel = mat4.identity;
        lightModel = lightModel.translate(lightPos);

        _shader.activate();
        glUniformMatrix4fv(glGetUniformLocation(_shader.id, "model"), 1, GL_TRUE, lightModel.value_ptr);
        glUniform4f(glGetUniformLocation(_shader.id, "lightColor"),
                                         lightColor.x, lightColor.y, lightColor.z, lightColor.w);

        // @TODO pass to all objects shaders
        /*glUniform4f(glGetUniformLocation(_shaderProgram.id, "lightColor"),
                                         lightColor.x, lightColor.y, lightColor.z, lightColor.w);
        glUniform3f(glGetUniformLocation(_shaderProgram.id, "lightPos"),
                                         lightPos.x, lightPos.y, lightPos.z);*/

        _camera = new Camera(screenWidth, screenHeight, Vec3f(0f, 0f, 2f));
    }

    /// Unload
    void unload() {
        _shader.remove();
    }

    /// Render the quad
    override void draw() {
        _camera.processInputs();
        _camera.updateMatrix(45f, 0.1f, 100f);
        _mesh.draw(_shader, _camera);
    }
}