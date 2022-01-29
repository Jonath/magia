module magia.render.drawable;

import magia.core;

/// Renderable class
abstract class Drawable3D {
    /// Transform
    public Transform transform;

    /// Render on screen
    void draw();
}

/// Renderable class
abstract class Drawable2D {
    /// Render on screen
    void draw(const Vec2f position);
}