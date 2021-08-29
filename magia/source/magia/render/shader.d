module magia.render.shader;

import std.file, std.string;

import bindbc.opengl;

import magia.render.window;

/// Class holding a shader
class Shader {
    /// Index
    GLuint id;

    /// Ctr
    this(string vertexFile, string fragmentFile) {
        const char* vertexSource = toStringz(readText("assets/shader/" ~ vertexFile));
        const char* fragmentSource = toStringz(readText("assets/shader/" ~ fragmentFile));

        // Setup shader program
        GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(vertexShader, 1, &vertexSource, null);
        glCompileShader(vertexShader);

        GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(fragmentShader, 1, &fragmentSource, null);
        glCompileShader(fragmentShader);

        id = glCreateProgram();
        glAttachShader(id, vertexShader);
        glAttachShader(id, fragmentShader);
        glLinkProgram(id);
    }

    /// Shader turned on
    void activate() {
        setShaderProgram(id);
    }

    /// Shader turned off
    void remove() {
        glDeleteProgram(id);
    }
}