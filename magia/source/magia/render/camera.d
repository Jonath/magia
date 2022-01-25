module magia.render.camera;

import bindbc.sdl, bindbc.opengl;
import gl3n.linalg;
import std.math;
import std.stdio;
import magia.common.event;
import magia.core.vec2;
import magia.core.vec3;
import magia.render.shader;
import magia.render.window;

/// Camera handler class
class Camera {
    private {
        /// Where the camera is located
        vec3 _position;

        /// Where the camera looks (by default towards the Z axis away from the screen)
        vec3 _orientation = vec3(0.0f, 0.0f, -1.0f);

        /// Where is up? (by default the Y axis)
        vec3 _cameraUp = vec3(0.0f, 1.0f, 0.0f);

        /// Camera matrix
        mat4 _cameraMatrix = mat4.identity;

        /// Width of the camera viewport
        int _width;

        /// Height of the camera viewport
        int _height;
    }

    @property {
        /// Camera position
        vec3 position() {
            return _position;
        }
        /// Ditto
        vec3 position(vec3 position_) {
            return _position = position_;
        }

        vec3 right() const {
            return cross(_orientation, _cameraUp).normalized;
        }

        vec3 up() const {
            return _cameraUp;
        }

        /// The direction the camera is facing towards
        vec3 forward() const {
            return _orientation;
        }
        /// Ditto
        vec3 forward(vec3 forward_) {
            return _orientation = forward_;
        }
    }

    /// Constructor
    this(int width_, int height_, Vec3f position_) {
        _width = width_;
        _height = height_;
        _position = vec3(position_.x, position_.y, position_.z);
    }

    /// Setting up camera matrices operations
    void updateMatrix(float FOVdeg, float nearPlane, float farPlane) {
        mat4 view = mat4.identity;
        mat4 proj = mat4.identity;

        view = mat4.look_at(_position, _position + _orientation, _cameraUp);
        proj = mat4.perspective(_width, _height, FOVdeg, nearPlane, farPlane);

        _cameraMatrix = proj * view;
    }

    /// Sets camera matrix in shader
    void passToShader(Shader shader, const char* uniform) {
        glUniformMatrix4fv(glGetUniformLocation(shader.id, uniform), 1, GL_TRUE, _cameraMatrix
                .value_ptr);
    }

    /// Update the camera
    void update() {
        updateMatrix(45f, 0.1f, 100f);
    }
}
