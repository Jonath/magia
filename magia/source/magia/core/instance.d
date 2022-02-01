module magia.core.instance;

import magia.core.transform;

/// Instance class
abstract class Instance3D {
    /// Transform stating where the instance is located
    Transform transform;

    /// Update the object
    void update(float) {}
}