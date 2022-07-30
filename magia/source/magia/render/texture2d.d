module magia.render.texture2d;

import std.string, std.exception;
import bindbc.opengl, bindbc.sdl;
import gl3n.linalg;
import magia.core, magia.render.window;

/// Indicate if something is mirrored.
enum Flip {
    none,
    horizontal,
    vertical,
    both
}

/// Blending algorithm \
/// none: Paste everything without transparency \
/// modular: Multiply color value with the destination \
/// additive: Add color value with the destination \
/// alpha: Paste everything with transparency (Default one)
enum Blend {
    none,
    //modular,
    additive,
    alpha
}

/// Base rendering class.
final class Texture2D {
    private {
        GLuint _texId;
        GLuint _shaderProgram, _vertShader, _fragShader;
        GLuint _vao;
        GLint _clipUniform, _flipUniform, _colorUniform, _modelUniform;
        SDL_Surface* _surface = null;
        uint _width, _height;
        bool _isLoaded, _ownData;
    }

    @property {
        /// loaded ?
        bool isLoaded() const {
            return _isLoaded;
        }

        /// Width in texels.
        uint width() const {
            return _width;
        }
        /// Height in texels.
        uint height() const {
            return _height;
        }
    }

    /// Ctor
    this(const Texture2D texture) {
        _isLoaded = texture._isLoaded;
        _width = texture._width;
        _height = texture._height;
        _texId = texture._texId;
        _shaderProgram = texture._shaderProgram;
        _vertShader = texture._vertShader;
        _fragShader = texture._fragShader;
        _vao = texture._vao;
        _clipUniform = texture._clipUniform;
        _flipUniform = texture._flipUniform;
        _colorUniform = texture._colorUniform;
        _modelUniform = texture._modelUniform;
        _ownData = false;
    }

    /// Ctor
    this(SDL_Surface* surface, bool preload_ = false) {
        // Image data
        _surface = surface;
        enforce(_surface, "invalid surface");

        _width = _surface.w;
        _height = _surface.h;
        if (!preload_)
            postload();
    }

    /// Ctor
    this(string path, bool preload_ = false) {
        // Image data
        _surface = IMG_Load(toStringz(path));
        enforce(_surface, "can't load image `" ~ path ~ "`");

        _width = _surface.w;
        _height = _surface.h;
        _ownData = true;

        if (!preload_)
            postload();
    }

    ~this() {
        unload();
    }

    package void load(SDL_Surface* surface) {
        _width = surface.w;
        _height = surface.h;

        _isLoaded = true;
        _ownData = true;
    }

    /// Call it if you set the preload flag on ctor.
    void postload() {
        if (_isLoaded)
            return;
        glGenTextures(1, &_texId);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _texId);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, GL_RGBA,
            GL_UNSIGNED_BYTE, _surface.pixels);
        glGenerateMipmap(GL_TEXTURE_2D);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

        if (_ownData) {
            SDL_FreeSurface(_surface);
            _surface = null;
        }

        // Vertices
        immutable float[] points = [
            1f, 1f, -1f, 1f, 1f, -1f, -1f, -1f
        ];

        GLuint vbo = 0;
        glGenBuffers(1, &vbo);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, points.length * float.sizeof, points.ptr, GL_STATIC_DRAW);

        glGenVertexArrays(1, &_vao);
        glBindVertexArray(_vao);
        glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, null);
        glEnableVertexAttribArray(0);

        immutable char* vshader = toStringz("
            #version 400
            in vec2 vp;
            out vec2 st;
            uniform vec4 clip;
            uniform vec2 flip;
            uniform mat4 model;

            void main() {
                st = ((vp + 1.0) * 0.5);
                st.x = (1.0 - flip.x) * st.x + (1.0 - st.x) * flip.x;
                st.y = (1.0 - flip.y) * st.y + (1.0 - st.y) * flip.y;
                st.x = st.x * clip.z + (1.0 - st.x) * clip.x;
                st.y = (1.0 - st.y) * clip.w + st.y * clip.y;
                gl_Position = model * vec4(vp, 0.0, 1.0);
            }");

        immutable char* fshader = toStringz("
            #version 400
            in vec2 st;
            out vec4 frag_color;
            uniform sampler2D tex;
            uniform vec4 color;

            void main() {
                frag_color = texture(tex, st) * color;
                if(frag_color.a == 0.0)
                    discard;
            }");

        _vertShader = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(_vertShader, 1, &vshader, null);
        glCompileShader(_vertShader);
        _fragShader = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(_fragShader, 1, &fshader, null);
        glCompileShader(_fragShader);

        _shaderProgram = glCreateProgram();
        glAttachShader(_shaderProgram, _fragShader);
        glAttachShader(_shaderProgram, _vertShader);
        glLinkProgram(_shaderProgram);
        _clipUniform = glGetUniformLocation(_shaderProgram, "clip");
        _flipUniform = glGetUniformLocation(_shaderProgram, "flip");
        _colorUniform = glGetUniformLocation(_shaderProgram, "color");
        _modelUniform = glGetUniformLocation(_shaderProgram, "model");
    }

    /// Free image data
    void unload() {
        if (!_ownData)
            return;
        glDeleteProgram(_shaderProgram);
        glDeleteShader(_fragShader);
        glDeleteShader(_vertShader);
        glDeleteTextures(1, &_texId);
        _isLoaded = false;
    }

    void draw(mat4 transform, float posX, float posY, float sizeX, float sizeY,
        Vec4i clip, Flip flip = Flip.none,
        Blend blend = Blend.alpha, Color color = Color.white, float alpha = 1f) const {

        //@TODO: glUniform2f(_flipUniform, cast(float) (flip & 0x1), cast(float) (flip & 0x2));
        final switch (flip) with (Flip) {
        case none:
            glUniform2f(_flipUniform, 0f, 0f);
            break;
        case horizontal:
            glUniform2f(_flipUniform, 1f, 0f);
            break;
        case vertical:
            glUniform2f(_flipUniform, 0f, 1f);
            break;
        case both:
            glUniform2f(_flipUniform, 1f, 1f);
            break;
        }

        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _texId);
        setShaderProgram(_shaderProgram);

        const float clipX = cast(float) clip.x / cast(float) _width;
        const float clipY = cast(float) clip.y / cast(float) _height;
        const float clipW = clipX + (cast(float) clip.z / cast(float) _width);
        const float clipH = clipY + (cast(float) clip.w / cast(float) _height);

        glUniform4f(_clipUniform, clipX, clipY, clipW, clipH);
        glUniform4f(_colorUniform, color.r, color.g, color.b, alpha);

        mat4 local = mat4.identity;
        local.scale(sizeX, sizeY, 1f);
        local.translate(posX * 2f + sizeX, posY * 2f + sizeY, 0f);
        transform = transform * local;

        glUniform4f(_colorUniform, color.r, color.g, color.b, 1f);
        glUniformMatrix4fv(_modelUniform, 1, GL_TRUE, transform.value_ptr);

        glBindVertexArray(_vao);

        glEnable(GL_BLEND);
        final switch (blend) with (Blend) {
        case none:
            glBlendFuncSeparate(GL_SRC_COLOR, GL_ZERO, GL_ONE, GL_ZERO);
            glBlendEquation(GL_FUNC_ADD);
            break;
        case additive:
            glBlendFuncSeparate(GL_SRC_ALPHA, GL_DST_COLOR, GL_ZERO, GL_ONE);
            glBlendEquation(GL_FUNC_ADD);
            break;
        case alpha:
            glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ZERO);
            glBlendEquation(GL_FUNC_ADD);
            break;
        }
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 6);
    }
}
