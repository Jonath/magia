module magia.render.pyramid;

import std.string;
import std.stdio;

import bindbc.opengl;
import gl3n.linalg;

import magia.core;
import magia.render.window, magia.render.drawable, magia.render.camera;
import magia.render.vao, magia.render.vbo, magia.render.ebo, magia.render.shader, magia.render.texture;

/// Renders a **Pyramid** with its own properties.
final class Pyramid : Drawable {
    private {
        VAO _vao;
        VBO _vbo;
        EBO _ebo;

        Camera  _camera;
        Shader  _shaderProgram;
        Texture _texture;
        GLuint  _scaleId;

        GLuint[] _indices;

        float _rotation;
    }

    /// Ctr
    this() {
        _shaderProgram = new Shader("default.vert", "default.frag");

        // Pyramid vertices
        GLfloat[] vertices = [
            //         COORDINATES      /      COLORS        /  TEXCOORD
            -0.5f, 0.0f,  0.5f,     0.83f, 0.70f, 0.44f,	0.0f, 0.0f,
	        -0.5f, 0.0f, -0.5f,     0.83f, 0.70f, 0.44f,	1.0f, 0.0f,
	         0.5f, 0.0f, -0.5f,     0.83f, 0.70f, 0.44f,	0.0f, 0.0f,
	         0.5f, 0.0f,  0.5f,     0.83f, 0.70f, 0.44f,	1.0f, 0.0f,
	         0.0f, 0.8f,  0.0f,     0.92f, 0.86f, 0.76f,	0.5f, 1.0f
        ];

        // Pyramid indices
        _indices = [
	        0, 1, 2,
	        0, 2, 3,
	        0, 1, 4,
	        1, 2, 4,
	        2, 3, 4,
	        3, 0, 4
        ];

        _vao = new VAO();
        _vao.bind();

        _vbo = new VBO(vertices);
        _ebo = new EBO(_indices);

        _vao.linkAttributes(_vbo, 0, 3, GL_FLOAT, 8 * float.sizeof, null);
        _vao.linkAttributes(_vbo, 1, 3, GL_FLOAT, 8 * float.sizeof, cast(void *)(3 * float.sizeof));
        _vao.linkAttributes(_vbo, 2, 2, GL_FLOAT, 8 * float.sizeof, cast(void *)(6 * float.sizeof));

        _vbo.unbind();
        _vao.unbind();
        _ebo.unbind();

        _camera = new Camera(screenWidth, screenHeight, Vec3f(0f, 0f, 2f));

        _texture = new Texture("bricks.png", GL_TEXTURE_2D, GL_TEXTURE0, GL_RGBA, GL_UNSIGNED_BYTE);
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

    /// Render the pyramid
    override void draw(const Vec2f position) {
        _shaderProgram.activate();

        _camera.processInputs();
        _camera.matrix(45f, 0.1f, 100f, _shaderProgram, "camMatrix");

        glUniform1f(_scaleId, 0.5f);
        _texture.bind();
        _vao.bind();
        glDrawElements(GL_TRIANGLES, cast(int) _indices.length, GL_UNSIGNED_INT, null);
    }
}
