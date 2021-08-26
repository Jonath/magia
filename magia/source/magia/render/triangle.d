module magia.render.triangle;

import std.string;
import std.stdio;

import bindbc.opengl;

import magia.core;
import magia.render.window, magia.render.drawable, magia.render.texture;

/// Renders a **Triangle** with its own properties.
final class Triangle : Drawable {
    private {
        GLfloat[] _vertices;

        GLuint _VAO;
        GLuint _shaderProgram, _vertexShader, _fragmentShader;
    }

    /// Ctr
    this() {
        // Triangle vertices
        _vertices = [
            -0.5f, -0.5f * sqrt(3f) / 3, 0.0f,
            0.5f, -0.5f * sqrt(3f) / 3, 0.0f,
            0.0f, 0.5f * sqrt(3f) * 2 / 3, 0.0f
        ];

        // Vertex shader code (pass on vertices)
        immutable char* vertexShaderSource = toStringz("
        #version 400
        layout (location = 0) in vec3 aPos;
        void main() {
            gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
        }
        ");

        // Fragment shader code (orange)
        immutable char* fragmentShaderSource = toStringz("
        #version 400
        out vec4 FragColor;
        void main() {
            FragColor = vec4(0.8f, 0.3f, 0.02f, 1.0f);
        }
        ");

        // Setup shader program
        _vertexShader = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(_vertexShader, 1, &vertexShaderSource, null);
        glCompileShader(_vertexShader);

        _fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(_fragmentShader, 1, &fragmentShaderSource, null);
        glCompileShader(_fragmentShader);

        _shaderProgram = glCreateProgram();
        glAttachShader(_shaderProgram, _vertexShader);
        glAttachShader(_shaderProgram, _fragmentShader);
        glLinkProgram(_shaderProgram);

        // Setup VBO data
        GLuint VBO = 0;
        glGenBuffers(1, &VBO);
        glBindBuffer(GL_ARRAY_BUFFER, VBO);
        glBufferData(GL_ARRAY_BUFFER, _vertices.length * float.sizeof, _vertices.ptr, GL_STATIC_DRAW);
        
        // Setup VAO data
        glGenVertexArrays(1, &_VAO);
        glBindVertexArray(_VAO);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * float.sizeof, null);
        glEnableVertexAttribArray(0);
    }

    /// Unload
    void unload() {
        glDeleteProgram(_shaderProgram);
        glDeleteShader(_fragmentShader);
        glDeleteShader(_vertexShader);
    }

    /// Render the triangle
    override void draw(const Vec2f position) {
        setShaderProgram(_shaderProgram);
        glBindVertexArray(_VAO);
        glDrawArrays(GL_TRIANGLES, 0, 3);
    }
}
