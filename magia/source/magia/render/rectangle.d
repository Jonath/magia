module magia.render.rectangle;

import std.string;
import std.stdio;

import bindbc.opengl;

import magia.core;
import magia.render.window, magia.render.drawable;
import magia.render.vao, magia.render.vbo, magia.render.ebo, magia.render.shader, magia.render.texture;

/// Renders a **Rectangle** with its own properties.
final class Rectangle : Drawable {
    private {
        VAO _vao;
        VBO _vbo;
        EBO _ebo;

        Shader  _shaderProgram;
        Texture _texture;
        GLuint  _scaleId;
    }

    /// Ctr
    this() {
        _shaderProgram = new Shader("default.vert", "default.frag");

        // Rectangle vertices
        GLfloat[] vertices = [
            //         COORDINATES      /      COLORS        /  TEXCOORD
            -0.5f,     -0.5f,     0.0f,   1.0f, 0.0f,  0.0f,   0.0f, 0.0f, // Lower left
            -0.5f,      0.5f,     0.0f,   0.0f, 1.0f,  0.0f,   0.0f, 1.0f, // Upper left
             0.5f,      0.5f,     0.0f,   0.0f, 0.0f,  1.0f,   1.0f, 1.0f, // Upper right
             0.5f,     -0.5f,     0.0f,   1.0f, 1.0f,  1.0f,   1.0f, 0.0f  // Lower right
        ];

        // Rectangle indices
        GLuint[] indices = [
            0, 2, 1,
            0, 3, 2
        ];

        _vao = new VAO();
        _vao.bind();

        _vbo = new VBO(vertices);
        _ebo = new EBO(indices);

        _vao.linkAttributes(_vbo, 0, 3, GL_FLOAT, 8 * float.sizeof, null);
        _vao.linkAttributes(_vbo, 1, 3, GL_FLOAT, 8 * float.sizeof, cast(void *)(3 * float.sizeof));
        _vao.linkAttributes(_vbo, 2, 2, GL_FLOAT, 8 * float.sizeof, cast(void *)(6 * float.sizeof));

        _vbo.unbind();
        _vao.unbind();
        _ebo.unbind();

        _scaleId = glGetUniformLocation(_shaderProgram.id, "scale");

        _texture = new Texture("yinyang.png", GL_TEXTURE_2D, GL_TEXTURE0, GL_RGBA, GL_UNSIGNED_BYTE);
        _texture.forwardToShader(_shaderProgram, "tex0", 0);
    }

    /// Unload
    void unload() {
        _vao.remove();
        _vbo.remove();
        _ebo.remove();
        _texture.remove();
        _shaderProgram.remove();
    }

    /// Render the rectangle
    override void draw(const Vec2f position) {
        _shaderProgram.activate();
        glUniform1f(_scaleId, 0.5f);
        _texture.bind();
        _vao.bind();
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, null);
    }
}
