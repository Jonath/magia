module magia.render.entity;

import magia.core.instance;
import magia.render.drawable;

/// Bind objects that can be instantiated, updated and drawn in a single abstract class
abstract class Entity3D : Instance3D, Drawable3D {}