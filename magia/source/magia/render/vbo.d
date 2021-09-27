module magia.render.vbo;

import bindbc.opengl;
import gl3n.linalg;

import magia.render.vertex;

/// Class holding a Vertex Buffer Object
class VBO {
    /// Index
    GLuint id;

    /// Constructor
    this(Vertex[] vertices) {
        glGenBuffers(1, &id);
        glBindBuffer(GL_ARRAY_BUFFER, id);
        glBufferData(GL_ARRAY_BUFFER, vertices.length * Vertex.sizeof, vertices.ptr, GL_STATIC_DRAW);
    }

    /// Bind VBO
    void bind() {
        glBindBuffer(GL_ARRAY_BUFFER, id);
    }

    /// Unbind VBO
    void unbind() {
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }

    /// Delete VBO
    void remove() {
        glDeleteBuffers(1, &id);
    }
}