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
        GLuint[] _indices;

        GLuint _VAO, _VBO, _EBO;
        GLuint _shaderProgram, _vertexShader, _fragmentShader;
    }

    /// Ctr
    this() {
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

        // Triangle vertices
        _vertices = [
            -0.5f, -0.5f * sqrt(3f) / 3, 0.0f,
            0.5f, -0.5f * sqrt(3f) / 3, 0.0f,
            0.0f, 0.5f * sqrt(3f) * 2 / 3, 0.0f,
            -0.5f / 2, 0.5f * sqrt(3f) / 6, 0.0f,
            0.5f / 2, 0.5f * sqrt(3f) / 6, 0.0f,
            0.0f, -0.5f * sqrt(3f) / 3, 0.0f
        ];

        // Triangle indices
        _indices = [
            0, 3, 5,
            3, 2, 4,
            5, 4, 1
        ];

        // Generate buffers
        glGenVertexArrays(1, &_VAO);
        glGenBuffers(1, &_VBO);
        glGenBuffers(1, &_EBO);

        // Bind buffers and feed them data
        glBindVertexArray(_VAO);
        glBindBuffer(GL_ARRAY_BUFFER, _VBO);
        glBufferData(GL_ARRAY_BUFFER, _vertices.length * GLfloat.sizeof, _vertices.ptr, GL_STATIC_DRAW);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _EBO); 
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, _indices.length * GLuint.sizeof, _indices.ptr, GL_STATIC_DRAW);

        // Configure VAO so that to render data from VBO, EBO and enable it
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * GLfloat.sizeof, null);
        glEnableVertexAttribArray(0);

        // Unbind Bind VBO, VAO, EBO to 0 so that we don't modify them
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindVertexArray(0);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    }

    /// Unload
    void unload() {
        glDeleteProgram(_shaderProgram);
        glDeleteShader(_fragmentShader);
        glDeleteShader(_vertexShader);
        glDeleteBuffers(1, &_VAO);
        glDeleteBuffers(1, &_VBO);
        glDeleteBuffers(1, &_EBO);
    }

    /// Render the triangle
    override void draw(const Vec2f position) {
        setShaderProgram(_shaderProgram);
        glBindVertexArray(_VAO);
        //glDrawArrays(GL_TRIANGLES, 0, 3);
        glDrawElements(GL_TRIANGLES, 9, GL_UNSIGNED_INT, null);
    }
}
