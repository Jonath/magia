module magia.render.light;

import std.string;
import std.stdio;

import bindbc.opengl;
import gl3n.linalg;

import magia.core;

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
        Shader _shader;

        mat4 _model;
        vec4 _color;
        vec3 _position;
    }

    @property {
        /// Gets position
        vec4 color() {
            return _color;
        }

        /// Gets position
        vec3 position() {
            return _position;
        }
    }

    /// Constructor
    this() {
        // Quad light vertices
        Vertex[] vertices = [
            //  COORDINATES
            Vertex(vec3(-0.01f, -0.01f,  0.1f)),
            Vertex(vec3(-0.01f, -0.01f, -0.01f)),
            Vertex(vec3( 0.1f, -0.01f, -0.01f)),
            Vertex(vec3( 0.1f, -0.01f,  0.1f)),
            Vertex(vec3(-0.01f,  0.1f,  0.1f)),
            Vertex(vec3(-0.01f,  0.1f, -0.01f)),
            Vertex(vec3( 0.1f,  0.1f, -0.01f)),
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
        _shader = new Shader("light.vert", "light.frag");

        _color = vec4(1.0f, 1.0f, 1.0f, 1.0f);
        _position = vec3(0f, 10f, 0f);
        _model = mat4.identity;
        _model = _model.translate(_position);

        _shader.activate();
        glUniform4f(glGetUniformLocation(_shader.id, "lightColor"),
                                         _color.x, _color.y, _color.z, _color.w);
    }

    /// Unload
    void unload() {
        _shader.remove();
    }

    /// Render the quad
    override void draw() {
        _mesh.draw(_shader, _model);
    }
}