#if !defined(CAMERA)
#define CAMERA

float4x4 _Camera2World;
float4x4 _CameraInverseProjection;


struct Ray {
    float3 origin;
    half3 direction;
    float3 energy;
    
    float3 PointAtParameter(float t) {
      return origin + t * direction;
    }
};

Ray CreateRay(float3 origin, float3 direction){
    Ray ray;
    ray.origin = origin;
    ray.direction = direction;
    ray.energy = float3(1.f,1.f,1.f);
    return ray;
}


Ray CreateCameraRay(float2 uv)
{
    // Transform the camera origin to world space
    float3 origin = mul(_Camera2World, float4(0.0f, 0.0f, 0.0f, 1.0f)).xyz;
    
    // Invert the perspective projection of the view-space position
    float3 direction = mul(_CameraInverseProjection, float4(uv, 0.0f, 1.0f)).xyz;
    // Transform the direction from camera to world space and normalize
    direction = mul(_Camera2World, float4(direction, 0.0f)).xyz;
    direction = normalize(direction);
    return CreateRay(origin, direction);
}
#endif