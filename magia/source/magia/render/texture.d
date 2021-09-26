module magia.render.texture;

import std.string, std.exception;
import bindbc.opengl, bindbc.sdl;
import magia.render.shader;
import std.stdio;

/// Class holding texture data
class Texture {
    /// Texture index
    GLuint id;

    private {
        /// Surface used to load the texture
        SDL_Surface* _surface = null;

        /// Teture image attributes
        int _width, _height;

        /// Texture type
        GLenum _type;

        /// Slot
        GLuint _slot;
    }

    /// Ctr
    this(string path, GLenum texType, GLuint slot, GLenum format, GLenum pixelType) {
        // Setup type
        _type = texType;

        // Setup slot
        _slot = slot;

        // Load from path
        _surface = IMG_Load(toStringz("assets/texture/" ~ path));
        enforce(_surface, "can't load image `" ~ path ~ "`");

        // Read data from handler
        _width = _surface.w;
        _height = _surface.h;

        // Generate texture and bind data
        glGenTextures(1, &id);
        glActiveTexture(GL_TEXTURE0 + _slot);
        glBindTexture(_type, id);

        // Setup filters
        glTexParameteri(_type, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(_type, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

        // Setup wrap
        glTexParameteri(_type, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(_type, GL_TEXTURE_WRAP_T, GL_REPEAT);

        // Create texture
        glTexImage2D(_type, 0, GL_RGBA, _width, _height, 0, format, pixelType, _surface.pixels);

        // Generate mipmaps
        glGenerateMipmap(_type);

        // Free texture handler
        SDL_FreeSurface(_surface);
        _surface = null;

        // Unbind data
        glBindTexture(_type, 0);
    }

    /// Pass texture onto shader
    void forwardToShader(Shader shader, string uniform, GLuint unit) {
        GLuint texUni = glGetUniformLocation(shader.id, toStringz(uniform));

        shader.activate();
        glUniform1i(texUni, unit);
    }

    /// Bind texture
    void bind() {
        glActiveTexture(GL_TEXTURE0 + _slot);
        glBindTexture(_type, id);
    }

    /// Unbind texture
    void unbind() {
        glBindTexture(_type, 0);
    }

    /// Release texture
    void remove() {
        glDeleteTextures(1, &id);
    }
}