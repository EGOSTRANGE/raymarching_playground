#if !defined(RAYMARCHING)
#define RAYMARCHING

#include "RayMarchingEntity.cginc"
#include "Random.cginc"
#include "SDF.cginc"

static const uint MAX_BOUNCES = 8;
static const uint MAX_STEPS = 128;
static const float MAX_DISTANCE = 128;
static const float MIN_DISTANCE_TO_SURFACE = 0.001f;
static const float PI = 3.14159265f;

struct RayHit{
    float3 position;
    float3 normal;
    float distance;
    uint entityIndex;
};

float DistToScene(float3 p, inout uint entityIndex){
    float min_d = MAX_DISTANCE;
    float3 temp_p;
    float temp_d;
    entityIndex = -1;
    
    for(int i = 0; i < _RMEntitiesCount; i++) {
        
        RayMarchingEntity e = _RMEntities[i];
        if(e.shape == 0)
            break;
        
        temp_p = mul(e.inverseTransform, float4(p,1));
        
        if(e.shape == 1)//XY_PLANE
            temp_d = sdf_xyPlane(temp_p, e.settings.x);

        else if (e.shape == 2)//YZ_PLANE
            temp_d = sdf_yzPlane(temp_p, e.settings.x);

        else if (e.shape == 3)//XZ_PLANE
            temp_d = sdf_xzPlane(temp_p, e.settings.x);

        else if (e.shape == 4)//FREE_PLANE
            temp_d = sdf_plane(temp_p, e.settings);

        else if (e.shape == 5)//SPHERE
            temp_d = sdf_sphere(temp_p, e.settings.x);

        else if (e.shape == 6)//CUBE
            temp_d = sdf_box(temp_p, e.settings.x);

        else if (e.shape == 7)//ROUND_BOX
            temp_d = sdf_roundBox(temp_p, e.settings.xyz, e.settings.w);
        
        else if (e.shape == 8)//TORUS
            temp_d = sdf_torus(temp_p, e.settings.xy);
            
        else if (e.shape == 9)//CYLINDER
            temp_d = sdf_cylinder(temp_p, e.settings.xyz);
            
        else if (e.shape == 10)//CONE
            temp_d = sdf_cone(temp_p, e.settings.xy);
            
        else if (e.shape == 11)//HEX_PRISM
            temp_d = sdf_hexPrism(temp_p, e.settings.xy);
            
        else if (e.shape == 12)//TRIANGULAR_PRISM
            temp_d = sdf_triPrism(temp_p, e.settings.xy);
            
        //else if (e.shape == 13)//CAPSULE
        //    temp_d = sdf_capsule(temp_p, e.settings.xyz, e.settings.w);
            
        else if (e.shape == 14)//VERTICAL_CAPSULE
            temp_d = sdf_vertCapsule(temp_p, e.settings.x, e.settings.y);
            
        else if (e.shape == 15)//CAPPED_CYLINDER
            temp_d = sdf_cappedCylinder(temp_p, e.settings.xy);
            
        else if (e.shape == 16)//ROUNDED_CYLINDER
            temp_d = sdf_roundedCylinder(temp_p, e.settings.x, e.settings.y, e.settings.z);
        
        else if (e.shape == 17)//CAPPED_CONE
            temp_d = sdf_cappedCone(temp_p, e.settings.x, e.settings.y, e.settings.z);
        
        else if (e.shape == 18)//ROUND_CONE
            temp_d = sdf_roundCone(temp_p, e.settings.x, e.settings.y, e.settings.z);
        
        
        else if (e.shape == 19)//ELIPSOID
            temp_d = sdf_ellipsoid(temp_p, e.settings);
            
        else if (e.shape == 20)//OCTAHEDRON
            temp_d = sdf_octahedron(temp_p, e.settings.x);
            
        else if (e.shape == 21)//OCTAHEDRON_EXACT
            temp_d = sdf_octahedron_exact(temp_p, e.settings.x);
        
        //else if (e.shape == 22)//TRIANGLE-> UD -> weird stuff with too many values
            //temp_d = ud_triangle(temp_p, e.settings.x, e.settings.y);
        
        //else if (e.shape == 23)//QUAD-> UD -> weird stuff with too many values
            //temp_d = ud_quad(temp_p, e.settings.x, e.settings.y);
        
        if(temp_d < min_d) {
            min_d = temp_d;
            entityIndex = i;
        }
    }

    return min_d;
}


half3 GetNormal(float3 p){
uint _;
    float d = DistToScene(p,_);
    return normalize(half3(
        d-DistToScene(p - float3(MIN_DISTANCE_TO_SURFACE, 0, 0),_),
        d-DistToScene(p - float3(0, MIN_DISTANCE_TO_SURFACE, 0),_),
        d-DistToScene(p - float3(0, 0, MIN_DISTANCE_TO_SURFACE),_)));
}

bool RayMarch(Ray ray, inout RayHit hit){
    float distance = 0;
    float3 p = ray.origin;
    uint entityIndex;
    
    for(uint i = 0.; i < MAX_STEPS; i++){
        float distanceToScene = DistToScene(p, entityIndex);
        distance += distanceToScene;
        
        if(distance > MAX_DISTANCE) break;
        
        if(distanceToScene < MIN_DISTANCE_TO_SURFACE) {
            hit.distance = distance;
            hit.position = p;
            hit.normal = GetNormal(p);
            hit.entityIndex = entityIndex;
            return true;
        }
        p += distanceToScene * ray.direction;
    }    
    return false;
}

float3 TravelScene(Ray ray)
{
    float3 specular = float3(0.3f, 0.3f, 0.2f);
    float3 albedo = float3(0.8f, 0.8f, 0.8f);
    float amplitude =.55f;
    
    float3 result = 0;
    RayHit hit;
    Ray shadowRay;
    for (int i = 0; i < MAX_BOUNCES; i++)
    {
        if (RayMarch(ray, hit)){ //collide with something
        
            ray.origin = hit.position + hit.normal * MIN_DISTANCE_TO_SURFACE*2.0f;
            ray.direction = (reflect(ray.direction,hit.normal));
            //ray.direction = reflect(ray.direction,normalize(hit.normal + float3(rand(),rand(),rand())*0.2f));
            
            
            //diffuse contribution
            shadowRay.origin = ray.origin;
            shadowRay.direction = _DirectionalLight.xyz;
            
            if(!RayMarch(shadowRay, hit)){
                float nDotL = max(0, dot(hit.normal, _DirectionalLight.xyz));
                //result += hit.normal;
                result += float3(nDotL,nDotL,nDotL) * albedo;
            }
            ray.energy *= specular;
        }
        else //reached "sky"
        {
            float theta = acos(ray.direction.y) / - PI;
            float phi = atan2(ray.direction.x, - ray.direction.z) / -PI * 0.5f;
            result += ray.energy * _SkyboxTexture.SampleLevel(sampler_SkyboxTexture, float2(phi, theta), 0).xyz;
            //break;
        }
    }
    return result;
}

#endif