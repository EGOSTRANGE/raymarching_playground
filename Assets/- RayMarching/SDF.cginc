#if !defined(SDFS)
#define SDFS

#define vec2 float2
#define vec3 float3
#define vec4 float4

float dot2( in vec3 v ) {
    return dot(v,v);
}

float dot2(vec2 v){
    return dot(v,v);
}

//SDF_XYPlane, 0
//SDF_YZPlane, 1
//SDF_XZPlane, 2
//SDF_Sphere,  3
//SDF_Cube,    4
//SDF_RoundBox,5
//SDF_Cylinder,6
//SDF_Torus,   7

//0
float sdf_xyPlane(float3 p, float offset){
    return p.z-offset;
}

//1
float sdf_yzPlane(float3 p, float offset){
    return p.x-offset;
}

//2
float sdf_xzPlane(float3 p, float offset){
    return p.y-offset;
}

//3
float sdf_plane( vec3 p, vec4 n ) {
// n must be normalized
    return dot(p,n.xyz) + n.w;
}

//4
float sdf_sphere( float3 p, float r ) {
    return length(p)-r;
}

//5
float sdf_box( float3 p, float3 b ) {
    float3 d = abs(p) - b;
    return length(max(d,0.0)) + min(max(d.x,max(d.y,d.z)),0.0);
    // remove this line for an only partially signed sdf
}

//6
float sdf_roundBox( float3 p, float3 b, float r ) {
    float3 d = abs(p) - b;
    return length(max(d,0.0)) - r + min(max(d.x,max(d.y,d.z)),0.0);
    // remove this line for an only partially signed sdf
}

//7
float sdf_torus( float3 p, float2 t ) {
    float2 q = float2(length(p.xz)-t.x,p.y);
    return length(q)-t.y;
}

//8
float sdf_cylinder( float3 p, float3 c ) {
    return length(p.xz-c.xy)-c.z;
}

//9
float sdf_cone( float3 p, float2 c ) {
    // c must be normalized
    float q = length(p.xy);
    return dot(c,float2(q,p.z));
}

//10
float sdf_hexPrism( vec3 p, vec2 h ) {
    const vec3 k = vec3(-0.8660254, 0.5, 0.57735);
    p = abs(p); p.xy -= 2.0*min(dot(k.xy, p.xy), 0.0)*k.xy;
    vec2 d = vec2( length(p.xy-vec2(clamp(p.x,-k.z*h.x,k.z*h.x), h.x))*sign(p.y-h.x), p.z-h.y );
    return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

//11
float sdf_triPrism( vec3 p, vec2 h ) {
    vec3 q = abs(p);
    return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}

//12
float sdf_capsule( vec3 p, vec3 a, vec3 b, float r ) {
    vec3 pa = p - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h ) - r;
}

//13
float sdf_vertCapsule( vec3 p, float h, float r ) {
    p.y -= clamp( p.y, 0.0, h ); return length( p ) - r;
}

//14
float sdf_cappedCylinder( vec3 p, vec2 h ) {
    vec2 d = abs(vec2(length(p.xz),p.y)) - h;
    return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

//15
float sdf_roundedCylinder( vec3 p, float ra, float rb, float h ) {
    vec2 d = vec2( length(p.xz)-2.0*ra+rb, abs(p.y) - h );
    return min(max(d.x,d.y),0.0) + length(max(d,0.0)) - rb;
} 

//16
float sdf_cappedCone( in vec3 p, in float h, in float r1, in float r2 ) {
    vec2 q = vec2( length(p.xz), p.y );
    vec2 k1 = vec2(r2,h);
    vec2 k2 = vec2(r2-r1,2.0*h);
    vec2 ca = vec2(q.x-min(q.x,(q.y < 0.0)?r1:r2), abs(q.y)-h);
    vec2 cb = q - k1 + k2*clamp( dot(k1-q,k2)/dot2(k2), 0.0, 1.0 );
    float s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0;
    return s*sqrt( min(dot2(ca),dot2(cb)) );
}

//17
float sdf_roundCone( in vec3 p, in float r1, float r2, float h ) {
    vec2 q = vec2( length(p.xz), p.y );
    float b = (r1-r2)/h; float a = sqrt(1.0-b*b);
    float k = dot(q,vec2(-b,a));
    if( k < 0.0 ) return length(q) - r1;
    if( k > a*h ) return length(q-vec2(0.0,h)) - r2;
    return dot(q, vec2(a,b) ) - r1;
}

//18
float sdf_ellipsoid( in vec3 p, in vec3 r ) {
    float k0 = length(p/r);
    float k1 = length(p/(r*r));
    return k0*(k0-1.0)/k1;
}

//19
float sdf_octahedron_exact( in vec3 p, in float s) {
 	p = abs(p); float m = p.x+p.y+p.z-s;
 	vec3 q; if( 3.0*p.x < m ) q = p.xyz;
 	else if( 3.0*p.y < m ) q = p.yzx;
 	else if( 3.0*p.z < m ) q = p.zxy;
 	else return m*0.57735027;
 	float k = clamp(0.5*(q.z-q.y+s),0.0,s);
 	return length(vec3(q.x,q.y-s+k,q.z-k));
} 

//20
float sdf_octahedron( in vec3 p, in float s) {
    p = abs(p);
    return (p.x+p.y+p.z-s)*0.57735027;
} 

//21


float ud_triangle( vec3 p, vec3 a, vec3 b, vec3 c ) {
vec3 ba = b - a;
vec3 pa = p - a;
vec3 cb = c - b;
vec3 pb = p - b;
vec3 ac = a - c;
vec3 pc = p - c;
vec3 nor = cross( ba, ac );
return sqrt( (sign(dot(cross(ba,nor),pa))
    + sign(dot(cross(cb,nor),pb))
    + sign(dot(cross(ac,nor),pc))<2.0)
        ? min( min( dot2(ba*clamp(dot(ba,pa)/dot2(ba),0.0,1.0)-pa),
            dot2(cb*clamp(dot(cb,pb)/dot2(cb),0.0,1.0)-pb) ),
            dot2(ac*clamp(dot(ac,pc)/dot2(ac),0.0,1.0)-pc) )
            : dot(nor,pa)*dot(nor,pa)/dot2(nor) );
}

//22
float ud_quad( vec3 p, vec3 a, vec3 b, vec3 c, vec3 d ) {
    vec3 ba = b - a;
    vec3 pa = p - a;
    vec3 cb = c - b;
    vec3 pb = p - b;
    vec3 dc = d - c;
    vec3 pc = p - c;
    vec3 ad = a - d;
    vec3 pd = p - d;
    vec3 nor = cross( ba, ad );
    return sqrt( (sign(dot(cross(ba,nor),pa))
        + sign(dot(cross(cb,nor),pb))
        + sign(dot(cross(dc,nor),pc))
        + sign(dot(cross(ad,nor),pd))<3.0)
            ? min( min( min( dot2(ba*clamp(dot(ba,pa)/dot2(ba),0.0,1.0)-pa),
                dot2(cb*clamp(dot(cb,pb)/dot2(cb),0.0,1.0)-pb) ),
                dot2(dc*clamp(dot(dc,pc)/dot2(dc),0.0,1.0)-pc) ),
                dot2(ad*clamp(dot(ad,pd)/dot2(ad),0.0,1.0)-pd) )
                : dot(nor,pa)*dot(nor,pa)/dot2(nor) );
}

#endif