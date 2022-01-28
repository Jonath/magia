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

    /// Matrix model
    mat4 model;

    /// Constructor
    this(vec3 position_, quat rotation_ = quat.identity, vec3 scale_ = vec3(1.0f, 1.0f, 1.0f)) {
        position = position_;
        rotation = rotation_;
        scale = scale_;
        model = combineModel(position_, rotation_, scale_);
    }

    /// Constructor (given model)
    this(mat4 model_, vec3 position_ = vec3(0.0f, 0.0f, 0.0f),
         quat rotation_ = quat.identity, vec3 scale_ = vec3(1.0f, 1.0f, 1.0f)) {
        model = model_;
        position = position_;
        rotation = rotation_;
        scale = scale_;
    }

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

    /// Default transform
    static @property Transform identity() {
        return Transform(
            vec3(0.0f, 0.0f, 0.0f)
        );
    }
}

/// Combine position, rotation and scale into model matrix
mat4 combineModel(vec3 position, quat rotation, vec3 scale) {
    mat4 localTranslation = mat4.identity;
    mat4 localRotation = mat4.identity;
    mat4 localScale = mat4.identity;

    localTranslation = localTranslation.translate(position);
    localRotation = rotation.to_matrix!(4, 4);
    localScale[0][0] = scale.x;
    localScale[1][1] = scale.y;
    localScale[2][2] = scale.z;

    return localTranslation * localRotation * localScale;
}

/// Combine model from transform position, rotation, scale
mat4 combineModel(Transform transform) {
    return combineModel(transform.position, transform.rotation, transform.scale);
}