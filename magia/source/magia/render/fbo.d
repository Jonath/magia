module magia.render.fbo;

import bindbc.opengl;
import magia.render.texture;

enum FBOType {
    Postprocess,
    Shadowmap
}

/// Class holding a Frame Buffer Object
class FBO {
    /// Index
    GLuint id;

    private {
        Texture _texture;
    }

    /// Constructor
    this(FBOType type, uint width, uint height) {
        assert(width == height, "FBO with different dimensions");

        glGenFramebuffers(1, &id);
        glBindFramebuffer(GL_FRAMEBUFFER, id);

        if (type == FBOType.Postprocess) {
            _texture = new PostProcessTexture(width, height);
        } else {
            _texture = new ShadowmapTexture(width, height);
        }
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