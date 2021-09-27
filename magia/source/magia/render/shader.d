module magia.render.shader;

import std.file, std.string, std.stdio;

import bindbc.opengl;

import magia.render.window;

/// Class holding a shader
class Shader {
    /// Index
    GLuint id;

    /// Constructor
    this(string vertexFile, string fragmentFile) {
        const char* vertexSource = toStringz(readText("assets/shader/" ~ vertexFile));
        const char* fragmentSource = toStringz(readText("assets/shader/" ~ fragmentFile));

        // Setup shader program
        GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(vertexShader, 1, &vertexSource, null);
        glCompileShader(vertexShader);
        compileErrors(vertexShader, "VERTEX");

        GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(fragmentShader, 1, &fragmentSource, null);
        glCompileShader(fragmentShader);
        compileErrors(fragmentShader, "FRAGMENT");

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

    private {
        void compileErrors(GLuint shaderId, string type) {
            GLint hasCompiled;
            char[1024] infoLog;

            if (type != "PROGRAM") {
                glGetShaderiv(shaderId, GL_COMPILE_STATUS, &hasCompiled);

                if (hasCompiled == GL_FALSE) {
                    glGetShaderInfoLog(shaderId, 1024, null, infoLog.ptr);
                    writeln("SHADER COMPILER ERROR FOR: ", type);
                }
            } else {
                glGetProgramiv(shaderId, GL_COMPILE_STATUS, &hasCompiled);

                if (hasCompiled == GL_FALSE) {
                    glGetProgramInfoLog(shaderId, 1024, null, infoLog.ptr);
                    writeln("SHADER LINKING ERROR FOR: ", type);
                }
            }
        }
    }
}