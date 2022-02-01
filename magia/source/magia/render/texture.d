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
        /// Teture image attributes
        int _width, _height;

        /// Slot
        GLuint _slot;

        // Target
        GLenum _target;

        // Trace
        bool _trace = false;
    }

    @property {
        /// Get texture target
        GLenum target() const {
            return _target;
        }
    }

    /// Constructor for usual 2D texture
    this(string path, string texType, GLuint slot) {
        // Setup type
        type = texType;

        // Setup slot
        _slot = slot;

        // Setyp target
        _target = GL_TEXTURE_2D;

        SDL_Surface *surface = IMG_Load(toStringz(path));
        enforce(surface, "can't load image `" ~ path ~ "`");

        // Read data from handler
        _width = surface.w;
        _height = surface.h;

        // Generate texture and bind data
        glGenTextures(1, &id);
        glActiveTexture(GL_TEXTURE0 + _slot);
        glBindTexture(_target, id);

        // Setup filters
        glTexParameteri(_target, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(_target, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

        // Setup wrap
        glTexParameteri(_target, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(_target, GL_TEXTURE_WRAP_T, GL_REPEAT);

        const uint nbChannels = surface.format.BitsPerPixel / 8;

        if (_trace) {
            writeln("Loaded texture ", path, " with ", nbChannels, " channels");
        }

        // For now, consider diffuses as RGBA, speculars as R
        GLenum format;
        if (nbChannels == 4) {
            format = GL_RGBA;
        } else if (nbChannels == 3) {
            format = GL_RGB;
        } else if (nbChannels == 1) {
            format = GL_RED;
        } else {
            new Exception("Unsupported texture format for " ~ texType ~ " texture type");
        }

        glTexImage2D(_target, 0, GL_RGBA, _width, _height, 0, format, GL_UNSIGNED_BYTE, surface.pixels);

        // Generate mipmaps
        glGenerateMipmap(_target);

        // Free texture handler
        SDL_FreeSurface(surface);
        surface = null;

        // Unbind data
        glBindTexture(_target, 0);
    }

    /// Constructor for cubemap texture
    this(string[6] paths) {
        // Setup type
        type = "skybox";

        // Setup target
        _target = GL_TEXTURE_CUBE_MAP;

        // Setup slot
        _slot = 0;

        glGenTextures(1, &id);
        glBindTexture(_target, id);
        
        // Setup filters
        glTexParameteri(_target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(_target, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

        // Setup wrap
        glTexParameteri(_target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(_target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(_target, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);

        for (int i = 0; i < paths.length; ++i) {
            string path = "assets/skybox/" ~ paths[i];

            SDL_Surface *surface = IMG_Load(toStringz(path));
            enforce(surface, "can't load image `" ~ path ~ "`");

            // Read data from handler
            _width = surface.w;
            _height = surface.h;

            glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL_RGB, _width, _height, 0,
                         GL_RGB, GL_UNSIGNED_BYTE, surface.pixels);

            SDL_FreeSurface(surface);
        }
    }

    /// Default constructor for shadow texture
    this(uint width, uint height) {
        // Setup type
        type = "shadow";

        // Setup target
        _target = GL_TEXTURE_2D;

        // Setup slot
        _slot = 0;

        // Setup resolution
        _width = width;
        _height = height;

        // Generate and bind texture
        glGenTextures(1, &id);
        glBindTexture(_target, id);

        // Create texture
        glTexImage2D(_target, 0, GL_DEPTH_COMPONENT, _width, _height, 0, GL_DEPTH_COMPONENT, GL_FLOAT, null);
        
        // Setup filters
        glTexParameteri(_target, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(_target, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

        // Setup wrap
        glTexParameteri(_target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
        glTexParameteri(_target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);

        // Setup shadow color (black)
        float[] clampColor = [1.0, 1.0, 1.0, 1.0];
        glTexParameterfv(_target, GL_TEXTURE_BORDER_COLOR, clampColor.ptr);
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
        glBindTexture(_target, id);
    }

    /// Unbind texture
    void unbind() {
        glBindTexture(_target, 0);
    }

    /// Release texture
    void remove() {
        glDeleteTextures(1, &id);
    }
}