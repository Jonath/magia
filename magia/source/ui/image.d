/**
    Image

    Copyright: (c) Enalye 2017
    License: Zlib
    Authors: Enalye
*/

module ui.image;

import core, render, common;
import ui.gui_element;

/// Display a sprite on screen.
class Image : GuiElement {
    private Sprite _sprite;

    @property {
        /// The displayed sprite.
        Sprite sprite() {
            return _sprite;
        }
        /// Ditto
        Sprite sprite(Sprite newSprite) {
            _sprite = newSprite;
            size = _sprite.size;
            return _sprite;
        }
    }

    /// Ctor
    this(Sprite newSprite) {
        _sprite = newSprite;
        size = _sprite.size;
        isInteractable = false;
    }

    override void update(float deltaTime) {
        _sprite.angle = _currentState.angle;
        _sprite.size = size;
    }

    override void draw() {
        _sprite.draw(center);
    }
}
