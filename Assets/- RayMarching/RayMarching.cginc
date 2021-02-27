#if !defined(RAYMARCHING)
#define RAYMARCHING

#include "RayMarchingEntity.cginc"
#include "Random.cginc"
#include "SDF.cginc"
#include "RaytracedShapes.cginc"

static const uint MAX_BOUNCES = 8;
static const uint MAX_STEPS = 128;
static const float MAX_DISTANCE = 256;
static const float MIN_DISTANCE_TO_SURFACE = 0.01f;
static const float PI = 3.14159265f;

struct RayHit{
    float3 position;
    float3 normal;
    float distance;
    uint entityIndex;
};

float DistToEntitySurface(float3 p, inout uint entityIndex){
    
    RayMarchingEntity e = _RMEntities[entityIndex];

    float3 transf_p = mul(e.inverseTransform, float4(p, 1));

    if(e.shape == 1)//XY_PLANE
        return sdf_xyPlane(transf_p, e.settings.x);
    
    else if (e.shape == 2)//YZ_PLANE
        return sdf_yzPlane(transf_p, e.settings.x);
    
    else if (e.shape == 3)//XZ_PLANE
        return sdf_xzPlane(transf_p, e.settings.x);
    
    else if (e.shape == 4)//FREE_PLANE
        return sdf_plane(transf_p, e.settings);
    
    else if (e.shape == 5)//SPHERE
        return sdf_sphere(transf_p, e.settings.x);
      
      else if (e.shape == 6)//CUBE
          return sdf_box(transf_p, e.settings.x);
      
      else if (e.shape == 7)//ROUND_BOX
          return sdf_roundBox(transf_p, e.settings.xyz, e.settings.w);
      
      else if (e.shape == 8)//TORUS
          return sdf_torus(transf_p, e.settings.xy);
      
      else if (e.shape == 9)//CYLINDER
          return sdf_cylinder(transf_p, e.settings.xyz);
          
      else if (e.shape == 10)//CONE
          return sdf_cone(transf_p, e.settings.xy);
          
      else if (e.shape == 11)//HEX_PRISM
          return sdf_hexPrism(transf_p, e.settings.xy);
          
      else if (e.shape == 12)//TRIANGULAR_PRISM
          return sdf_triPrism(transf_p, e.settings.xy);
          
      //else if (e.shape == 13)//CAPSULE
      //    return sdf_capsule(transf_p, e.settings.xyz, e.settings.w);
          
      else if (e.shape == 14)//VERTICAL_CAPSULE
          return sdf_vertCapsule(transf_p, e.settings.x, e.settings.y);
          
      else if (e.shape == 15)//CAPPED_CYLINDER
          return sdf_cappedCylinder(transf_p, e.settings.xy);
          
      else if (e.shape == 16)//ROUNDED_CYLINDER
          return sdf_roundedCylinder(transf_p, e.settings.x, e.settings.y, e.settings.z);
      
      else if (e.shape == 17)//CAPPED_CONE
          return sdf_cappedCone(transf_p, e.settings.x, e.settings.y, e.settings.z);
      
      else if (e.shape == 18)//ROUND_CONE
          return sdf_roundCone(transf_p, e.settings.x, e.settings.y, e.settings.z);
      
      
      else if (e.shape == 19)//ELIPSOID
          return sdf_ellipsoid(transf_p, e.settings);
          
      else if (e.shape == 20)//OCTAHEDRON
          return sdf_octahedron(transf_p, e.settings.x);
          
      else if (e.shape == 21)//OCTAHEDRON_EXACT
          return sdf_octahedron_exact(transf_p, e.settings.x);
      
      //else if (e.shape == 22)//TRIANGLE-> UD -> weird stuff with too many values
          //return ud_triangle(transf_p, e.settings.x, e.settings.y);
      
      //else if (e.shape == 23)//QUAD-> UD -> weird stuff with too many values
          //return ud_quad(transf_p, e.settings.x, e.settings.y);
          
      else return MAX_DISTANCE;
}


half3 GetNormal(float3 p, uint entity){
    float d = DistToEntitySurface(p, entity);
    return normalize(half3(
        d-DistToEntitySurface(p - float3(MIN_DISTANCE_TO_SURFACE, 0, 0),entity),
        d-DistToEntitySurface(p - float3(0, MIN_DISTANCE_TO_SURFACE, 0),entity),
        d-DistToEntitySurface(p - float3(0, 0, MIN_DISTANCE_TO_SURFACE),entity)));
}

bool RayMarch(Ray ray, inout RayHit hit){
    float3 p = ray.origin;
    uint entityIndex;
    float min_d = MAX_DISTANCE;
    
    for(uint i = 0; i < MAX_STEPS; i++){
        float d;

        //min distance to entities
        for(uint j = 0; j < _RMEntitiesCount; j++) {
            d = DistToEntitySurface(p, j);
                        
            if(d < min_d) {
                min_d = d;
                entityIndex = j;
            }
        
        }
        
        if(min_d > MAX_DISTANCE)
                break;
                
        if(min_d < MIN_DISTANCE_TO_SURFACE) {
                hit.distance = min_d;
                hit.position = p - MIN_DISTANCE_TO_SURFACE * ray.direction;
                hit.normal = GetNormal(p, entityIndex);
                hit.entityIndex = entityIndex;
                return true;
        }
        
        p += min_d * ray.direction;
    }
    return false;
}

float3 TravelScene(Ray ray)
{
    float3 specular = float3(0.3f, 0.3f, 0.2f);
    float3 albedo = float3(0.8f, 0.8f, 0.8f);
    //float amplitude =.55f;
    
    float3 result = 0;
    RayHit hit;
    //for (uint i = 0; i < MAX_BOUNCES; i++)
    //{
    
        if (RayMarch(ray, hit)){ //collide with something
        
            ray.origin = hit.position + hit.normal * MIN_DISTANCE_TO_SURFACE*2.0f;
            ray.direction = (reflect(ray.direction,hit.normal));
            
            float spec = saturate((dot(ray.direction, _DirectionalLight)+1)/2);
            spec*=spec;
            result += spec;
            
            //diffuse contribution
            ray.direction = _DirectionalLight.xyz;
            
            if(!RayMarch(ray, hit)){
                float nDotL = max(0, dot(hit.normal, _DirectionalLight.xyz));
                result += float3(nDotL,nDotL,nDotL) * albedo;
            }
        }
        else //reached "sky"
        {
            float theta = acos(ray.direction.y) / - PI;
            float phi = atan2(ray.direction.x, - ray.direction.z) / -PI * 0.5f;
            result += ray.energy * _SkyboxTexture.SampleLevel(sampler_SkyboxTexture, float2(phi, theta), 0).xyz;
        }
    //}
    return result;
}

#endif