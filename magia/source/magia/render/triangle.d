module magia.render.triangle;

import std.string;
import std.stdio;

import bindbc.opengl;

import magia.core;
import magia.render.window, magia.render.drawable;
import magia.render.vao, magia.render.vbo, magia.render.ebo, magia.render.shader;

/// Renders a **Triangle** with its own properties.
final class Triangle : Drawable {
    private {
        VAO _vao;
        VBO _vbo;
        EBO _ebo;

        Shader _shaderProgram;
    }

    /// Ctr
    this() {
        _shaderProgram = new Shader("triangle.vert", "triangle.frag");

        // Triangle vertices
        GLfloat[] vertices = [
            -0.5f, -0.5f * sqrt(3f) / 3, 0.0f,
            0.5f, -0.5f * sqrt(3f) / 3, 0.0f,
            0.0f, 0.5f * sqrt(3f) * 2 / 3, 0.0f,
            -0.5f / 2, 0.5f * sqrt(3f) / 6, 0.0f,
            0.5f / 2, 0.5f * sqrt(3f) / 6, 0.0f,
            0.0f, -0.5f * sqrt(3f) / 3, 0.0f
        ];

        // Triangle indices
        GLuint[] indices = [
            0, 3, 5,
            3, 2, 4,
            5, 4, 1
        ];

        _vao = new VAO();
        _vao.bind();

        _vbo = new VBO(vertices);
        _ebo = new EBO(indices);

        _vao.linkVBO(_vbo, 0);

        _vbo.unbind();
        _vao.unbind();
        _ebo.unbind();
    }

    /// Unload
    void unload() {
        _vao.remove();
        _vbo.remove();
        _ebo.remove();
        _shaderProgram.remove();
    }

    /// Render the triangle
    override void draw(const Vec2f position) {
        _shaderProgram.activate();
        _vao.bind();
        glDrawElements(GL_TRIANGLES, 9, GL_UNSIGNED_INT, null);
    }
}
