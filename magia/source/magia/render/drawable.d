module magia.render.drawable;

import magia.core;

/// Renderable class
abstract class Drawable {
    /// Render on screen
    void draw(const Vec2f position);
}