module magia.render.vbo;

import bindbc.opengl;
import gl3n.linalg;

import magia.render.vertex;

/// Class holding a Vertex Buffer Object
class VBO {
    /// Index
    GLuint id;

    /// Constructor given vertex buffer
    this(float[] vertices) {
        glGenBuffers(1, &id);
        glBindBuffer(GL_ARRAY_BUFFER, id);
        glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices.ptr, GL_STATIC_DRAW);
    }

    /// Constructor given vertex buffer
    this(Vertex[] vertices) {
        glGenBuffers(1, &id);
        glBindBuffer(GL_ARRAY_BUFFER, id);
        glBufferData(GL_ARRAY_BUFFER, vertices.length * Vertex.sizeof, vertices.ptr, GL_STATIC_DRAW);
    }

    /// Constructor given mat4 array
    this(mat4[] mat4s) {
        glGenBuffers(1, &id);
        glBindBuffer(GL_ARRAY_BUFFER, id);
        glBufferData(GL_ARRAY_BUFFER, mat4s.length * mat4.sizeof, mat4s.ptr, GL_STATIC_DRAW);
    }

    /// Bind VBO
    void bind() {
        glBindBuffer(GL_ARRAY_BUFFER, id);
    }

    /// Unbind VBO
    static void unbind() {
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }

    /// Delete VBO
    void remove() {
        glDeleteBuffers(1, &id);
    }
}