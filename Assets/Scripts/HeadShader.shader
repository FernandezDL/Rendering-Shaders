Shader "Unlit/HeadShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Period ("Period", Range(0.0, 100.0)) = 1.0 
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Period;

            v2f vert (appdata v)
            {
                v2f o;

                v.vertex.y += cos(_Time.y + v.vertex.x * _Period);
                v.vertex.z += sin(_Time.y + v.vertex.x * _Period);
                v.vertex.x += atan(_Time.y + v.vertex.x * _Period);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                col.r += cos(i.uv.x * 150.0 + _Time.y);
                col.g += sin(150.0 + _Time.y);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
