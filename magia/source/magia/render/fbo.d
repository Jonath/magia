module magia.render.fbo;

import std.stdio;

import bindbc.opengl;
import magia.render.texture;

enum FBOType {
    Multisample,
    Postprocess,
    Shadowmap,
}

/// Class holding a Frame Buffer Object
class FBO {
    /// Index
    GLuint id;

    private {
        Texture _texture;
    }

    /// Constructor
    this(FBOType type, uint width, uint height, uint nbSamples = 0) {
        assert(width == height, "FBO with different dimensions");

        glGenFramebuffers(1, &id);
        glBindFramebuffer(GL_FRAMEBUFFER, id);

        if (type == FBOType.Postprocess) {
            _texture = new PostProcessTexture(width, height);
        } else if(type == FBOType.Multisample) {
            _texture = new MultiSampleTexture(width, height, nbSamples);
        } else {
            _texture = new ShadowmapTexture(width, height);
        }
    }

    /// Bind FBO
    void bind() {
        glBindFramebuffer(GL_FRAMEBUFFER, id);
    }

    /// Bind FBO in read mode
    void bindRead() {
        glBindFramebuffer(GL_READ_FRAMEBUFFER, id);
    }

    /// Bind FBO in draw mode
    void bindDraw() {
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER, id);
    }

    /// Unbind FBO (bind to default FBO)
    static void unbind() {
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }

    /// Blit frame buffer
    static void blit(uint width, uint height) {
        glBlitFramebuffer(0, 0, width, height, 0, 0, width, height, GL_COLOR_BUFFER_BIT, GL_NEAREST);
    }

    /// Delete FBO
    void remove() {
        glDeleteFramebuffers(1, &id);
    }

    /// Bind attached texture
    void bindTexture() {
        _texture.bind();
    }

    /// Check FBO status
    static void check(string name) {
        GLenum FBOStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (FBOStatus != GL_FRAMEBUFFER_COMPLETE) {
            writeln("Framebuffer ", name, " error: ", FBOStatus);
        }
    }
}