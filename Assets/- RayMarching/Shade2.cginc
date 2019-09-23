#if !defined(SHADE_2)
#pragma exclude_renderers d3d11 gles
#define SHADE_2

#include "VectorCalc.cginc"
#include "Random.cginc"
#include "RayMarching.cginc"

float3 Sample(Ray ray, RayHit hit){
    if (hit.distance < MAX_DISTANCE)
    {
        float3 specular = float3(0.6f, 0.6f, 0.6f);
        float3 albedo = float3(0.8f, 0.8f, 0.8f);
        ray.energy = specular;
        return 0.0f;
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

float3 BounceLight(Ray ray, float3 normal, float amplitude){
    ray.direction = reflect(ray.direction,normalize(hit.normal + float3(rand(),rand(),rand())*amplitude));
}

#endif