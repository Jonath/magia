module magia.render.texture;

import std.string, std.exception;
import bindbc.opengl, bindbc.sdl;
import magia.render.shader;
import std.stdio;

/// Class holding texture data
class Texture {
    /// Texture index
    GLuint id;

    /// Texture type
    string type;

    private {
        /// Surface used to load the texture
        SDL_Surface* _surface = null;

        /// Teture image attributes
        int _width, _height;

        /// Slot
        GLuint _slot;
    }

    /// Constructor
    this(string path, string texType, GLuint slot) {
        // Setup type
        type = texType;

        // Setup slot
        _slot = slot;

        _surface = IMG_Load(toStringz(path));
        enforce(_surface, "can't load image `" ~ path ~ "`");

        // Read data from handler
        _width = _surface.w;
        _height = _surface.h;

        // Generate texture and bind data
        glGenTextures(1, &id);
        glActiveTexture(GL_TEXTURE0 + _slot);
        glBindTexture(GL_TEXTURE_2D, id);

        // Setup filters
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

        // Setup wrap
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

        // For now, consider diffuses as RGBA, speculars as R
        GLenum format;
        if (texType == "diffuse") {
            format = GL_RGB;
        } else if (texType == "specular") {
            format = GL_RED;
        } else {
            new Exception("Unsupported texture format for " ~ texType ~ " texture type");
        }

        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, format, GL_UNSIGNED_BYTE, _surface.pixels);

        // Generate mipmaps
        glGenerateMipmap(GL_TEXTURE_2D);

        // Free texture handler
        SDL_FreeSurface(_surface);
        _surface = null;

        // Unbind data
        glBindTexture(GL_TEXTURE_2D, 0);
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
        glBindTexture(GL_TEXTURE_2D, id);
    }

    /// Unbind texture
    void unbind() {
        glBindTexture(GL_TEXTURE_2D, 0);
    }

    /// Release texture
    void remove() {
        glDeleteTextures(1, &id);
    }
}