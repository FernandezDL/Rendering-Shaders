Shader "Unlit/StandarSurface"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1) 
        _AmbientColor("Ambient Color", Color) = (1,1,1,1)
        _DiffuseInt("Diffuse Intensity", Range(0,1)) = 1.0
        _SpecColor2("Specular Color", Color) = (1,1,1,1)
        _Shininess("Shininess", Range(1,256)) = 32
        _SpecInt("Specular Intensity", Range(0,2)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags{ "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal_world : TEXTCOORD1;
                float3 worldPos : TEXTCOORD2;
                float3 viewDir : TEXTCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _AmbientColor;
            float _DiffuseInt;
            float _SpecInt;
            float _Shininess;
            float4 _SpecColor2;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.normal_world = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.viewDir = WorldSpaceViewDir(v.vertex);

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 L= normalize(_WorldSpaceLightPos0.xyz);
                float3 N = normalize(i.normal_world);

                float3 ambient = _AmbientColor.rgb;
                float NdotL = max(0.0, dot(N, L));
                float3 diffuse = NdotL * _DiffuseInt * _LightColor0.rgb;

                float3 H = normalize(L + i.viewDir);
                float NdotH = max(0.0, dot(N, H));
                float specular = pow(NdotH, _Shininess) * _SpecInt;

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                float3 specularColor = _LightColor0.rgb * _SpecColor2.rgb * specular;

                float3 lighting = ambient + diffuse + specularColor;
                col += float4(lighting, 0.0);
                // col.rgb += ambient;

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                 
                return col;
            }
            ENDCG
        }
    }
}
