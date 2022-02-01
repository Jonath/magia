module magia.render.fbo;

import bindbc.opengl;
import magia.render.texture;

/// Class holding a Frame Buffer Object
class FBO {
    /// Index
    GLuint id;

    this() {
        glGenFramebuffers(1, &id);
        glBindFramebuffer(GL_FRAMEBUFFER, id);
    }

    /// Bind VBO
    void bind() {
        glBindFramebuffer(GL_FRAMEBUFFER, id);
    }

    /// Unbind VBO
    void unbind() {
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }

    /// Delete VBO
    void remove() {
        glDeleteFramebuffers(1, &id);
    }

    /// Pass texture onto FBO (so far only 2D supported)
    void attachTexture(Texture texture) {
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, texture.target, texture.id, 0);
        glDrawBuffer(GL_NONE);
        glReadBuffer(GL_NONE);
    }
}