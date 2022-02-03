module magia.render.ebo;

import bindbc.opengl;

/// Class holding a Element Buffer Object
class EBO {
    /// Index
    GLuint id;

    /// Constructor
    this(GLuint[] indices) {
        glGenBuffers(1, &id);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, id);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length * GLuint.sizeof, indices.ptr, GL_STATIC_DRAW);
    }

    /// Bind VBO
    void bind() {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, id);
    }

    /// Unbind VBO
    static void unbind() {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    }

    /// Delete VBO
    void remove() {
        glDeleteBuffers(1, &id);
    }
}