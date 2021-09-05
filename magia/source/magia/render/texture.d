module magia.render.texture;

import std.string, std.exception;
import bindbc.opengl, bindbc.sdl;
import magia.render.shader;

/// Class holding texture data
class Texture {
    /// Texture index
    GLuint id;

    /// Texture type
    GLenum type;

    private {
        /// Surface used to load the texture
        SDL_Surface* _surface = null;

        /// Teture image attributes
        int _width, _height;
    }

    /// Ctr
    this(string path, GLenum texType, GLenum slot, GLenum format, GLenum pixelType) {
        // Setup type
        type = texType;

        // Load from path
        _surface = IMG_Load(toStringz("assets/texture/" ~ path));
        enforce(_surface, "can't load image `" ~ path ~ "`");

        // Read data from handler
        _width = _surface.w;
        _height = _surface.h;

        // Generate texture and bind data
        glGenTextures(1, &id);
        glActiveTexture(slot);
        glBindTexture(texType, id);

        // Setup filters
        glTexParameteri(texType, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(texType, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

        // Setup wrap
        glTexParameteri(texType, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(texType, GL_TEXTURE_WRAP_T, GL_REPEAT);

        // Create texture
        glTexImage2D(texType, 0, GL_RGBA, _width, _height, 0, format, pixelType, _surface.pixels);

        // Generate mipmaps
        glGenerateMipmap(texType);

        // Free texture handler
        SDL_FreeSurface(_surface);
        _surface = null;

        // Unbind data
        glBindTexture(texType, 0);
    }

    /// Pass texture onto shader
    void forwardToShader(Shader shader, string uniform, GLuint unit) {
        GLuint tex0Uni = glGetUniformLocation(shader.id, toStringz(uniform));
        shader.activate();
        glUniform1i(tex0Uni, unit);
    }

    /// Bind texture
    void bind() {
        glBindTexture(type, id);
    }

    /// Unbind texture
    void unbind() {
        glBindTexture(type, 0);
    }

    /// Release texture
    void remove() {
        glDeleteTextures(1, &id);
    }
}