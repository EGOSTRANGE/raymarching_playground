#if !defined(RaytracedShapes)
#define RaytracedShapes

#include "RayMarchingEntity.cginc"
#include "RayMarching.cginc"

#define vec2 float2
#define vec3 float3
#define vec4 float4

void BoxIntersection(vec3 p0, vec3 p1, vec3 rayOrigin, vec3 invRayDir, inout vec3 tMin, inout vec3 tMax){
    vec3 t0 = (p0 - rayOrigin) * invRayDir;
    vec3 t1 = (p1 - rayOrigin) * invRayDir;
    tMin = min(t0,t1);
    tMax = max(t0,t1);
}

//SDF_XYPlane, 0
//SDF_YZPlane, 1
//SDF_XZPlane, 2
//SDF_Sphere,  3
//SDF_Cube,    4
//SDF_RoundBox,5
//SDF_Cylinder,6
//SDF_Torus,   7


#endif