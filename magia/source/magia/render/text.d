module magia.render.text;

import std.conv : to;

import magia.core;
import magia.render.font;

/// Render text on screen
void drawText(string text, float x, float y, Font font = null) {
    if(!font)
        font = getDefaultFont();
    const _charScale = 1;
    Color color = Color.white;
    const alpha = 1f;
    const _charSpacing = 0;
    Vec2f pos = Vec2f(x, y);
    dchar prevChar;
    foreach (dchar ch; to!dstring(text)) {
        if (ch == '\n') {
            pos.x = x;
            pos.y += font.lineSkip * _charScale;
            prevChar = 0;
        }
        else {
            Glyph metrics = font.getMetrics(ch);
            pos.x += font.getKerning(prevChar, ch) * _charScale;
            Vec2f drawPos = Vec2f(pos.x + metrics.offsetX * _charScale,
                    pos.y - metrics.offsetY * _charScale);
            metrics.draw(drawPos, _charScale, color, alpha);
            pos.x += (metrics.advance + _charSpacing) * _charScale;
            prevChar = ch;
        }
    }
}
