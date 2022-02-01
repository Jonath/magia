module magia.render.fbo;

import bindbc.opengl;
import magia.render.texture;

/// Class holding a Frame Buffer Object
class FBO {
    /// Index
    GLuint id;

    private {
        Texture _texture;
    }

    /// Constructor
    this(uint width, uint height) {
        assert(width == height, "FBO with different dimensions");

        glGenFramebuffers(1, &id);
        glBindFramebuffer(GL_FRAMEBUFFER, id);

        _texture = new Texture(width, height);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, _texture.target, _texture.id, 0);
    }

    /// Bind FBO
    void bind() {
        glBindFramebuffer(GL_FRAMEBUFFER, id);
    }

    /// Unbind FBO
    void unbind() {
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }

    /// Delete FBO
    void remove() {
        glDeleteFramebuffers(1, &id);
    }

    /// Bind attached texture
    void bindTexture() {
        _texture.bind();
    }
}