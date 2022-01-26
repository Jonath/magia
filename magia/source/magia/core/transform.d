module magia.core.transform;

import gl3n.linalg;

/// Transform structure
struct Transform {
    /// Object position
    vec3 position;

    /// Object rotation
    quat rotation;

    /// Object scale
    vec3 scale;

    @property {
        /// Setup internal quaternion given euler angles
        void rotationFromEuler(vec3 eulerAngles) {
            rotation = quat.euler_rotation(eulerAngles.x, eulerAngles.y, eulerAngles.z);
        }

        /// Get euler rotation given a quaternion
        vec3 rotationToEuler() const {
            return vec3(rotation.roll, rotation.pitch, rotation.yaw);
        }
    }
}