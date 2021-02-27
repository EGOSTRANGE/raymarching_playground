Shader "Unlit/Raymarch"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
              
                return o;
            }

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

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                return col;
            }
            ENDCG
        }
    }
}
