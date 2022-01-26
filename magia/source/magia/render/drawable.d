module magia.render.drawable;

import magia.core;

/// Renderable class
abstract class Drawable3D {
    protected {
        Transform _transform;
    }

    
    @property {
        /// Position
        void transform(Transform transform) {
            _transform = transform;
        }
    }

    /// Render on screen
    void draw();
}

/// Renderable class
abstract class Drawable2D {
    /// Render on screen
    void draw(const Vec2f position);
}