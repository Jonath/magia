module magia.render.camera;

import bindbc.opengl;
import gl3n.linalg;
import magia.core.vec3;
import magia.render.shader;

/// Camera handler class
class Camera {
    /// Where the camera is located
    Vec3f position;

    /// Where the camera looks (by default towards the Z axis away from the screen)
    Vec3f orientation = Vec3f(0.0f, 0.0f, -1.0f);

    /// Where is up? (by default the Y axis)
    Vec3f up = Vec3f(0.0f, 1.0f, 0.0f);

    /// Width of the camera viewport
    int width;

    /// Height of the camera viewport
    int height;

    /// Speed at which the camera moves (uniform across all axis so far)
    float speed = 0.1f;

    /// How well the speed of the camera scales up when it moves continuously
    float sensitivity = 100f; 

    /// Constructor
    this(int width_, int height_, Vec3f position_) {
        width = width_;
        height = height_;
        position = position_;
    }

    /// Setting up camera matrices operations
    void matrix(float FOVdeg, float nearPlane, float farPlane, Shader shader, const char* uniform) {
        mat4 view = mat4.identity;
        mat4 proj = mat4.identity;
        
        view = lookAt(position, position + orientation);
        proj = proj.perspective(width, height, FOVdeg, nearPlane, farPlane);

        glUniformMatrix4fv(glGetUniformLocation(shader.id, uniform), 1, GL_TRUE, (proj * view).value_ptr);
    }

    /// Camera movement handler
    void inputs() {

    }

    private mat4 lookAt(const Vec3f from, const Vec3f to) {
        const Vec3f lookForwardA = from - to; 
        const Vec3f lookForward = lookForwardA.normalized;

        const Vec3f lookRight = up.normalized.cross(lookForward);
        const Vec3f lookUp = lookForward.cross(lookRight);
 
        mat4 camToWorld; 
 
        camToWorld[0][0] = lookRight.x; 
        camToWorld[0][1] = lookRight.y; 
        camToWorld[0][2] = lookRight.z; 
        camToWorld[1][0] = lookUp.x; 
        camToWorld[1][1] = lookUp.y; 
        camToWorld[1][2] = lookUp.z; 
        camToWorld[2][0] = lookForward.x; 
        camToWorld[2][1] = lookForward.y; 
        camToWorld[2][2] = lookForward.z; 
 
        camToWorld[3][0] = from.x; 
        camToWorld[3][1] = from.y; 
        camToWorld[3][2] = from.z; 
 
        return camToWorld; 
    } 
}