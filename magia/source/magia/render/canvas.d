module magia.render.canvas;

import std.string;
import bindbc.opengl, bindbc.sdl;
import magia.core, magia.render.window;

/// Base rendering class.
final class Canvas {
    /// Indicate if something is mirrored.
    enum Flip {
        none,
        horizontal,
        vertical,
        both
    }

    /// Blending algorithm \
    /// none: Paste everything without transparency \
    /// additive: Add color value with the destination \
    /// alpha: Paste everything with transparency (Default one)
    enum Blend {
        none,
        additive,
        alpha
    }

    private {
        GLuint _texId;
        GLuint _sp2;
        GLuint _vao;
        GLint _sizeUniform, _positionUniform, _clipUniform, _rotUniform,
            _flipUniform, _colorUniform;
        uint _width, _height;
        Vec2u _renderSize;
    }

    package(magia.render) {
        GLuint _frameId;
        bool _isTargetOnStack;
    }

    @property {
        /// Width in texels.
        uint width() const {
            return _width;
        }
        /// Height in texels.
        uint height() const {
            return _height;
        }

        /// The size (in texels) of the surface to be rendered on.
        /// Changing that value allocate a new texture, so don't do it everytime.
        Vec2u renderSize() const {
            return _renderSize;
        }
        /// Ditto
        Vec2u renderSize(Vec2u newRenderSize) {
            return _renderSize;
        }
    }

    /// The view position inside the canvas.
    Vec2f position = Vec2f.zero, /// The size of the view inside of the canvas.
        size = Vec2f.zero;
    /// Is the Canvas rendered from its center or from the top left corner ? \
    /// (only change the render position, not the view).
    bool isCentered = true;
    /// The base color when nothing is rendered.
    Color color = Color.black;
    /// The base opacity when nothing is rendered.
    float alpha = 0f;
    /// Mirroring property.
    Flip flip = Flip.none;
    /// Blending algorithm.
    Blend blend = Blend.alpha;

    this(uint width_, uint height_) {
        if (width_ >= 2048u || height_ >= 2048u)
            throw new Exception("Canvas render size exceeds limits.");
        _renderSize = Vec2u(width_, height_);
        _width = width_;
        _height = height_;
        size = cast(Vec2f) _renderSize;
        load();
    }

    ~this() {
        glDeleteTextures(1, &_texId);
    }

    private void load() {
        // Image data
        glGenTextures(1, &_texId);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _texId);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, GL_RGBA,
                GL_UNSIGNED_BYTE, null);
        glGenerateMipmap(GL_TEXTURE_2D);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

        glGenFramebuffers(1, &_frameId);
        pushCanvas(this, false);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texId, 0);
        GLenum[1] drawBuff = [GL_COLOR_ATTACHMENT0];
        glDrawBuffers(1, drawBuff.ptr);
        popCanvas();

        // Vertices
        immutable float[] points = [
            -1, 1f, 1f, -1f, -1f, -1f, -1f, 1f, 1, 1f, 1f, -1f,
        ];

        GLuint vbo = 0;
        glGenBuffers(1, &vbo);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, points.length * float.sizeof, points.ptr, GL_STATIC_DRAW);

        glGenVertexArrays(1, &_vao);
        glBindVertexArray(_vao);
        glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, null);
        glEnableVertexAttribArray(0);

        {
            immutable char* vshader = toStringz("
            #version 400
            layout (location = 0) in vec2 vp;
            out vec2 st;
            uniform vec2 size;
            uniform vec2 position;
            uniform vec4 clip;
            uniform vec2 rot;
            uniform vec2 flip;
            void main() {
                vec2 rotated = vec2(vp.x * rot.x - vp.y * rot.y, vp.x * rot.y + vp.y * rot.x);
                rotated = (rotated + 1.0) * 0.5;
                gl_Position = vec4((position + (rotated * size)) * 2.0 - 1.0, 0.0, 1.0);
                st = ((vp + 1.0) * 0.5);
                st.x = (1.0 - flip.x) * st.x + (1.0 - st.x) * flip.x;
                st.y = (1.0 - flip.y) * st.y + (1.0 - st.y) * flip.y;
                st.x = st.x * clip.z + (1.0 - st.x) * clip.x;
                st.y = st.y * clip.w + (1.0 - st.y) * clip.y;
            }
            ");

            immutable char* fshader = toStringz("
            #version 400
            in vec2 st;
            out vec4 frag_color;
            uniform sampler2D tex;
            uniform vec4 color;
            void main() {
                frag_color = texture(tex, st) * color;
            }
            ");

            GLuint vs = glCreateShader(GL_VERTEX_SHADER);
            glShaderSource(vs, 1, &vshader, null);
            glCompileShader(vs);
            GLuint fs = glCreateShader(GL_FRAGMENT_SHADER);
            glShaderSource(fs, 1, &fshader, null);
            glCompileShader(fs);

            _sp2 = glCreateProgram();
            glAttachShader(_sp2, fs);
            glAttachShader(_sp2, vs);
            glLinkProgram(_sp2);
            _sizeUniform = glGetUniformLocation(_sp2, "size");
            _positionUniform = glGetUniformLocation(_sp2, "position");
            _clipUniform = glGetUniformLocation(_sp2, "clip");
            _rotUniform = glGetUniformLocation(_sp2, "rot");
            _flipUniform = glGetUniformLocation(_sp2, "flip");
            _colorUniform = glGetUniformLocation(_sp2, "color");
        }
    }

    package(magia.render) void clear() {
        glClearColor(1f, 0f, 1f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
    }

    void draw(Vec2f renderPosition, Vec2f renderSize_, Vec4i clip, float angle,
            Vec2f anchor = Vec2f.half) const {

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
        glUseProgram(_sp2);
        renderSize_ = (transformScale() * renderSize_) / screenSize(); //Replace with transform canvas space
        renderPosition = transformRenderSpace(renderPosition) / screenSize(); //Replace with transform canvas space
        renderPosition -= anchor * renderSize_;
        glUniform2f(_sizeUniform, renderSize_.x, renderSize_.y);
        glUniform2f(_positionUniform, renderPosition.x, renderPosition.y);

        const float clipX = cast(float) clip.x / cast(float) _width;
        const float clipY = cast(float) clip.y / cast(float) _height;
        const float clipW = clipX + (cast(float) clip.z / cast(float) _width);
        const float clipH = clipY + (cast(float) clip.w / cast(float) _height);

        glUniform4f(_clipUniform, clipX, clipY, clipW, clipH);
        glUniform4f(_colorUniform, color.r, color.g, color.b, alpha);

        const float radians = -angle * degToRad;
        const float c = std.math.cos(radians);
        const float s = std.math.sin(radians);
        glUniform2f(_rotUniform, c, s);
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
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }
}
