Shader "Custom/ElectricityShader"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (0.02, 0.02, 0.08, 1)
        _ElectricColor("Electric Color", Color) = (0.5, 0.5, 1, 1)
        _EdgeColor("Edge Color", Color) = (1, 1, 1, 1)

        _MainTex ("Pattern Texture", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "gray" {}

        _ElectricStrength ("Electric Strength", Range(0, 10)) = 2.5
        _EmissionStrength ("Emission Strength", Range(0, 10)) = 1.5

        _ScrollX ("Scroll Speed X", Range(-5, 5)) = 0.5
        _ScrollY ("Scroll Speed Y", Range(-5, 5)) = 0.35

        _NoiseDistortion ("Noise Distortion", Range(0, 1)) = 0.08
        _NoiseSpeedX ("Noise Speed X", Range(-5, 5)) = -0.3
        _NoiseSpeedY ("Noise Speed Y", Range(-5, 5)) = 0.4

        _Glossiness ("Smoothness", Range(0,1)) = 0.3
        _Metallic ("Metallic", Range(0,1)) = 0.0

    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        LOD 300

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uvNoise : TEXCOORD1;
                float3 position: TEXCOORD2;
                float3 normal : TEXCOORD3;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_NoiseTex);
            SAMPLER(sampler_NoiseTex);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                half4 _ElectricColor;
                half4 _EdgeColor;

                half _ElectricStrength;
                half _EmissionStrength;
                half _ScrollX;
                half _ScrollY;
                half _NoiseDistortion;
                half _NoiseSpeedX;
                half _NoiseSpeedY;
                half _Glossiness;
                half _Metallic;

                float4 _NoiseTex_ST;
                float4 _MainTex_ST;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS);

                OUT.positionHCS = positionInputs.positionCS;
                OUT.position = positionInputs.positionWS;
                OUT.normal = normalize(normalInputs.normalWS);

                OUT.uv= TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.uvNoise = TRANSFORM_TEX(IN.uv, _NoiseTex);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float t = _Time.y;

                float electricUV = IN.uv.x + float2(_ScrollX, _ScrollY) * t;
                float2 noiseUV = IN.uvNoise + float2(_NoiseSpeedX, _NoiseSpeedY) * t;

                float2 noiseSample = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, noiseUV).rg * 2 - 1;
                
                electricUV += noiseSample * _NoiseDistortion;
                
                float electricMask = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, electricUV).r;
                electricMask  = smoothstep(0.5, 0.7, electricMask) * _ElectricStrength;

                float electricIntensity = electricMask * _ElectricStrength;

                float3 baseColor = _BaseColor.rgb;
                float3 electricColor = _ElectricColor.rgb * electricIntensity;
                float3 edgeColor = _EdgeColor.rgb * electricIntensity;

                float3 finalColor = baseColor + (electricColor * 0.5) + (edgeColor * 0.35);
                finalColor += pow(electricIntensity, 2.0) * _EmissionStrength;

                half4 color = half4(finalColor, 1.0);
                return color;
            }
            ENDHLSL
        }
    }
}
