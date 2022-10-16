module magia.shape.planet;

import bindbc.opengl;
import gl3n.linalg;

import magia.core;

import magia.render.entity;
import magia.render.mesh;
import magia.render.shader;
import magia.render.texture;
import magia.render.vertex;
import magia.shape.sphere;

import std.stdio;

vec3 up      = vec3( 0,  1,  0);
vec3 down    = vec3( 0, -1,  0);
vec3 left    = vec3(-1,  0,  0);
vec3 right   = vec3( 1,  0,  0);
vec3 forward = vec3( 0,  0,  1);
vec3 back    = vec3( 0,  0, -1);

/// Instance of sphere
final class Planet : Sphere {
    // Noise parameters
    private {
        vec3 _noiseOffset;
        int _nbLayers;
        float _strength;
        float _roughness;
        float _persistence;
        float _minHeight;
    }

    this(int resolution, float radius, vec3 noiseOffset, int nbLayers,
        float strength, float roughness, float persistence, float minHeight) {
        _noiseOffset = noiseOffset;
        _nbLayers = nbLayers;
        _strength = strength;
        _roughness = roughness;
        _persistence = persistence;
        _minHeight = minHeight;

        super(resolution, radius);
    }

    // Generate a point on the planet's surface
    protected override vec3 generateSurfacePoint(vec3 directionX, vec3 directionY, vec3 directionZ,
                                                 int x, int y, int resolution) {
        vec3 surfacePoint = super.generateSurfacePoint(directionX, directionY, directionZ, x, y, resolution);
        return surfacePoint * sampleRandomHeight(surfacePoint);
    }

    // Sample random height given a sphere surface point, several layers of noise
    private float sampleRandomHeight(vec3 point) {
        float noiseValue = 0;
        float frequency = 1;
        float amplitude = 1;

        for (int layerId = 0; layerId < _nbLayers; ++layerId) {
            noiseValue = getNoiseHeight(point * frequency + _noiseOffset);
            frequency *= _roughness;
            amplitude *= _persistence;
        }

        noiseValue = max(0, noiseValue - _minHeight);
        return noiseValue * _strength;
    }

    // Sample random height given a sphere surface point for a single noise layer
    private float getNoiseHeight(vec3 point) {
        float elevation = noise(point.x, point.y, point.z) * _strength;
        return _radius * (1 + elevation);
    }
}