#if !defined(RAYMARCHING_ENTITY)
#define RAYMARCHING_ENTITY

struct RayMarchingEntity
{
    float4x4 inverseTransform;
    uint shape;
    half3 albedo;
    half roughness;
    float4 settings;
    float3 bboxScale;
    float3 bboxOffset;
};

StructuredBuffer<RayMarchingEntity> _RMEntities;

uint _RMEntitiesCount;

#endif