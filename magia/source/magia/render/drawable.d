module magia.render.drawable;

import magia.core;

/// Renderable class
interface Drawable3D {
    /// Render on screen
    void draw();
}

/// Renderable class
interface Drawable2D {
    /// Render on screen
    void draw(const Vec2f position);
}