#if !defined(SHADE)
#pragma exclude_renderers d3d11 gles
#define SHADE

#include "VectorCalc.cginc"
#include "Random.cginc"
#include "RayMarching.cginc"

float sdot(float3 x, float3 y, float f = 1.0f)
{
    return saturate(dot(x, y) * f);
}

float stuff(float3 normal){
    half t = rand();
    float z = t * t;
    float x = cos(t) * (1-z);
    float y = sin(t) * (1-z);
    return mul(float3(x,y,z), GetTangentSpace(normal));
}
float3 fibonacciFlower(float3 normal, float apperture){
    float t = rand();
    float inclination = acos(1-2*t);
    float azimuth = 2 * PI * apperture * 100 * t;
    float x = sin(inclination) * cos(azimuth);
    float y = sin(inclination) * sin(azimuth);
    float z = cos(inclination);
    return mul(float3(x,y,z), GetTangentSpace(normal));
}

float3 randommadnes (float3 normal, float madnessLevel){
    return normalize(normal+float3(rand(),rand(),rand())*madnessLevel);
}

float3 SampleHemisphere(float3 normal)
{
    // Uniformly sample hemisphere direction
    float cosTheta = rand();
    float sinTheta = sqrt(max(0.0f, 1.0f - cosTheta * cosTheta));
    float phi = 2 * PI * rand();
    float3 tangentSpaceDir = float3(cos(phi) * sinTheta, sin(phi) * sinTheta, cosTheta);
    // Transform direction to world space
    return mul(tangentSpaceDir, GetTangentSpace(normal));
}


float3 Shade(inout Ray ray, RayHit hit)
{
    if (hit.distance < MAX_DISTANCE)
    {
        float3 specular = float3(0.6f, 0.6f, 0.6f);
        float3 albedo = float3(0.8f, 0.8f, 0.8f);
        ray.direction = reflect(ray.direction,normalize(hit.normal + float3(rand(),rand(),rand())*0.1f));
        ray.energy = specular;

        return 0.0f;
        
        // Shadow test ray
        //bool shadow = false;
        //Ray shadowRay = CreateRay(hit.position + hit.normal * 0.001f, -1 * _DirectionalLight.xyz);
        //RayHit shadowHit = RayMarch(shadowRay);
        //if (shadowHit.distance < MAX_DISTANCE)
        //{
        //    return float3(0.0f, 0.0f, 0.0f);
        //}
        //// Return diffuse
        //return saturate(dot(hit.normal, _DirectionalLight.xyz) * -1) * _DirectionalLight.w * albedo;
    }
    else
    {
        // Erase the ray's energy - the sky doesn't reflect anything
        ray.energy = 0.0f;
        // Sample the skybox and write it
        float theta = acos(ray.direction.y) / -PI;
        float phi = atan2(ray.direction.x, -ray.direction.z) / -PI * 0.5f;
        return _SkyboxTexture.SampleLevel(sampler_SkyboxTexture, float2(phi, theta), 0).xyz;
    }
}
#endif