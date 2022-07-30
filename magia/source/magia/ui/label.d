module magia.ui.label;

import std.algorithm.comparison : min;
import std.conv : to;
import magia.core, magia.render;
import magia.ui.element;

final class Label : UIElement {
    private {
        dstring _text;
        Font _font;
        float _charScale = 1f, _charSpacing = 0f;
    }

    @property {
        /// Texte affiché
        string text() const {
            return to!string(_text);
        }
        /// Ditto
        string text(string text_) {
            _text = to!dstring(text_);
            _reload();
            return text_;
        }

        /// La police de caractère utilisée
        Font font() const {
            return cast(Font) _font;
        }
        /// Ditto
        Font font(Font font_) {
            _font = font_;
            _reload();
            return _font;
        }

        /// Espacement additionnel entre chaque lettre
        float charSpacing() const {
            return _charSpacing;
        }
        /// Ditto
        float charSpacing(float charSpacing_) {
            return _charSpacing = charSpacing_;
        }
    }

    this(string text_ = "", Font font_ = getDefaultFont()) {
        _text = to!dstring(text_);
        _font = font_;
        _reload();
    }

    override void draw(mat4 transform) {
        Color color = getBaseColor();
        const alpha = getBaseAlpha();
        Vec2f pos = Vec2f(posX, posY);
        dchar prevChar;
        foreach (dchar ch; _text) {
            if (ch == '\n') {
                pos.x = posX;
                pos.y += _font.lineSkip * _charScale;
                prevChar = 0;
            }
            else {
                Glyph metrics = _font.getMetrics(ch);
                pos.x += _font.getKerning(prevChar, ch) * _charScale;
                float drawPosX = pos.x + metrics.offsetX * _charScale;
                float drawPosY = pos.y - metrics.offsetY * _charScale;
                metrics.draw(transform, drawPosX, drawPosY, _charScale, color, alpha);
                pos.x += (metrics.advance + _charSpacing) * _charScale;
                prevChar = ch;
            }
        }
    }

    private void _reload() {
        Vec2f totalSize_ = Vec2f(0f, _font.ascent - _font.descent) * _charScale;
        float lineWidth = 0f;
        dchar prevChar;
        foreach (dchar ch; _text) {
            if (ch == '\n') {
                lineWidth = 0f;
                totalSize_.y += _font.lineSkip * _charScale;
            }
            else {
                const Glyph metrics = _font.getMetrics(ch);
                lineWidth += _font.getKerning(prevChar, ch) * _charScale;
                lineWidth += metrics.advance * _charScale;
                if (lineWidth > totalSize_.x)
                    totalSize_.x = lineWidth;
                prevChar = ch;
            }
        }
        sizeX = totalSize_.x;
        sizeY = totalSize_.y;
    }
}
