module magia.render.vao;

import bindbc.opengl;

import magia.render.vbo;
import magia.render.ebo;

/// Class holding a Vertex Array Object
class VAO {
    /// Index
    GLuint id;

    /// Ctr
    this() {
        glGenVertexArrays(1, &id);
    }

    /// Link VAO to VBO
    void linkVBO(VBO vbo, GLuint layout) {
        vbo.bind();
        glVertexAttribPointer(layout, 3, GL_FLOAT, GL_FALSE, 3 * GLfloat.sizeof, null);
        glEnableVertexAttribArray(layout);
        vbo.unbind();
    }

    /// Bind VAO
    void bind() {
        glBindVertexArray(id);
    }

    /// Unbind VAO
    void unbind() {
        glBindVertexArray(0);
    }

    /// Delete VAO
    void remove() {
        glDeleteBuffers(1, &id);
    }
}