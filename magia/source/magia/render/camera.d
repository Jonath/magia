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

        /// Speed at which the camera moves (uniform across all axis so far)
        float _speed = 0.1f;

        /// How well the speed of the camera scales up when it moves continuously
        float _sensitivity = 20f;

        /// To avoid the camera jumping around while holding down the left mouse button
        bool firstClick = false;
    }

    @property {
        /// Gets position
        vec3 position() {
            return _position;
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
        glUniformMatrix4fv(glGetUniformLocation(shader.id, uniform), 1, GL_TRUE, _cameraMatrix.value_ptr);
    }

    /// Camera movement handler
    void processInputs() {
        const vec3 lookRight = cross(_orientation, _cameraUp).normalized;

        /// Forward along X axis
        if (isButtonDown(KeyButton.a)) {
            _position += _speed * -lookRight; 
        }

        /// Backwards along X axis
        if (isButtonDown(KeyButton.d)) {
            _position += _speed * lookRight; 
        }

        /// Backwards along X axis
        if (isButtonDown(KeyButton.w)) {
            _position += _speed * _cameraUp; 
        }

        /// Forward along Y axis
        if (isButtonDown(KeyButton.s)) {
            _position += _speed * -_cameraUp; 
        }

        /// Forward along Z axis
        if (isButtonDown(KeyButton.e)) {
            _position += _speed * _orientation; 
        }

        /// Backwards along Z axis
        if (isButtonDown(KeyButton.q)) {
            _position += _speed * -_orientation; 
        }

        if (isButtonDown(MouseButton.left)) {
            SDL_ShowCursor(SDL_DISABLE);
             
            if (firstClick) {
                SDL_WarpMouseInWindow(window, screenWidth / 2, screenHeight / 2);
                firstClick = false;
            }

            const Vec2f mousePos = getMousePos();

            const float rotX = _sensitivity * (mousePos.y - (_height / 2)) / _height;
            const float rotY = _sensitivity * (mousePos.x - (_width / 2)) / _width;

            const vec3 newOrientation = rotate(_orientation, -rotX * degToRad, lookRight);

            const float limitRotX = 5f * degToRad;
            
            const float angleUp   = angle(newOrientation, _cameraUp);
            const float angleDown = angle(newOrientation, -_cameraUp);

            if (!(angleUp <= limitRotX || angleDown <= limitRotX)) {                
                _orientation = newOrientation;
            }

            _orientation = rotate(_orientation, -rotY * degToRad, _cameraUp);
            firstClick = false;
        } else {
            SDL_ShowCursor(SDL_ENABLE);
            firstClick = true;
        }
    }

    alias Quaternionf = Quaternion!(float);

    /// Returns the angle between two vectors
    float angle(vec3 a, vec3 b) {
        return acos(dot(a.normalized, b.normalized));
    }

    /// Rotates p around axis r by angle
    vec3 rotate(vec3 p, float angle, vec3 r) {
        const float halfAngle = angle / 2;

        const float cosRot = cos(halfAngle);
        const float sinRot = sin(halfAngle);

        const Quaternionf q1 = Quaternionf(0f, p.x, p.y, p.z);
        const Quaternionf q2 = Quaternionf(cosRot, r.x * sinRot, r.y * sinRot, r.z * sinRot);
        const Quaternionf q3 = q2 * q1 * q2.conjugated;

        return vec3(q3.x, q3.y, q3.z);
    }

    /// Update the camera
    void update() {
        processInputs();
        updateMatrix(45f, 0.1f, 100f);
    }
}