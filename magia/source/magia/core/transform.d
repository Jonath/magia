module magia.core.transform;

import gl3n.linalg;

/// Transform structure
struct Transform {
    private {
        /// Object position
        vec3 _position;

        /// Object rotation
        quat _rotation;

        /// Object scale
        vec3 _scale;

        /// Matrix model
        mat4 _model;
    }

    /// Constructor
    this(vec3 position, quat rotation = quat.identity, vec3 scale = vec3(1.0f, 1.0f, 1.0f), mat4 model = mat4.identity) {
        _position = position;
        _rotation = rotation;
        _scale = scale;
        _model = model;
    }

    @property {
        /// Setup internal quaternion given euler angles
        void rotationFromEuler(vec3 eulerAngles) {
            _rotation = quat.euler_rotation(eulerAngles.x, eulerAngles.y, eulerAngles.z);
        }

        /// Get euler rotation given a quaternion
        vec3 rotationToEuler() const {
            return vec3(_rotation.roll, _rotation.pitch, _rotation.yaw);
        }

        /// Position
        vec3 position() const {
            return _position;
        }

        /// Rotation
        quat rotation() const {
            return _rotation;
        }

        /// Scale
        vec3 scale() const {
            return _scale;
        }

        /// Model
        mat4 model() const {
            return _model;
        }
    }

    /// Default transform
    static @property Transform identity() {
        return Transform(
            vec3(0.0f, 0.0f, 0.0f),
            quat.identity,
            vec3(1.0f, 1.0f, 1.0f)
        );
    }
}