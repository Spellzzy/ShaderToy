Shader "Unlit/snow"
{
    Properties
    {
        _iMouse("Mouse Pos", Vector) = (0, 0, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

        Pass
        {

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

                
            //#define LIGHT_SNOW 
            #ifdef LIGHT_SNOW
                #define LAYERS 50
                #define DEPTH .5
                #define WIDTH .3
                #define SPEED .6
            #else // BLIZZARD
                #define LAYERS 200
                #define DEPTH .1
                #define WIDTH .8
                #define SPEED 1.5
            #endif

            #define iResolution _ScreenParams

            float4 _iMouse;

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


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                const float3x3 p = float3x3(
                    13.323122, 23.5112, 21.71123,
                    21.1212, 28.7312, 11.9312,
                    21.8112, 14.7212, 61.3934);

                /*vec2 uv = iMouse.xy / iResolution.xy + vec2(1., iResolution.y / iResolution.x) 
                    * fragCoord.xy / iResolution.xy;*/
                /*float2 uv = iMouse.xy / _ScreenParams.xy + 
                    float2(1.0, _ScreenParams.y / _ScreenParams.x) */
                fixed2 uv = _iMouse.xy + i.uv;
                float3 acc = float3(0.0, 0.0, 0.0);
                float dof = 5. * sin(_Time.y * .1);
                for (int i = 0; i < LAYERS; i++)
                {
                    float fi = float(i);
                    float2 q = uv * (1.0 + fi * DEPTH);
                    q += float2(q.y * (WIDTH * fmod(fi * 7.238917, 1.0) - WIDTH * 0.5), SPEED * _Time.y / (1.0 + fi * DEPTH * 0.3));
                    float3 n = float3(floor(q), 31.189 + fi);
                    float3 m = floor(n) * .00001 + frac(n);
                    float3 mp = (31415.9 + m) / frac(mul(p, m));
                    float3 r = frac(mp);
                    float2 s = abs(fmod(q, 1.0) - .5 + .9 * r.xy - .45);
                    s += .01 * abs(2. * frac(10. * q.yx) - 1.);
                    float d = .6 * max(s.x - s.y, s.x + s.y) + max(s.x, s.y) - .01;
                    float edge = .005 + .05 * min(.5 * abs(fi - 5. - dof), 1.);
                    float value = smoothstep(edge, -edge, d) * (r.x / (1. + .02 * fi * DEPTH));
                    acc += float3(value, value, value);
                }   

                return float4(acc, 1.0);
            }
            ENDCG
        }
    }
}
