module magia.render.drawable;

import magia.core;

/// Interface for objects drawable in 3D
interface Drawable3D {
    /// Render on screen
    void draw();
}

/// Interface for objects drawable in 2D
interface Drawable2D {
    /// Render on screen
    void draw(const Vec2f position);
}