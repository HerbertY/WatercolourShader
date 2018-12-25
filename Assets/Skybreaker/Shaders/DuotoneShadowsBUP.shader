// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/DuotoneShadowsBUP"
{
    Properties
    {
        //[NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        
		_Color ("Tint Color 1", Color) = (1,1,1,1)
		_Color2 ("Tint Color 2", Color) = (1,1,1,1)
		_InkCol ("Ink Color", Color) = (1,1,1,1)
		
		_BlotchTex ("Blotches (RGB)", 2D) = "white" {}
		_DetailTex ("Detail (RGB)", 2D) = "white" {}
		_PaperTex ("Paper (RGB)", 2D) = "white" {}
		_RampTex ("Ramp (RGB)", 2D) = "white" {}
		
		_TintScale ("Tint Scale", Range(2,32)) = 4
		_PaperStrength ("Paper Strength", Range(0,1)) = 1
		_BlotchMulti ("Blotch Multiply", Range(0,8)) = 4
		_BlotchSub ("Blotch Subtract", Range(0,8)) = 2
    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            // compile shader into multiple variants, with and without shadows
            // (we don't care about any lightmaps yet, so skip these variants)
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            // shadow helper functions and macros
            #include "AutoLight.cginc"            

            sampler2D _BlotchTex;
			sampler2D _DetailTex;
			sampler2D _PaperTex;
			sampler2D _RampTex;
			
            float4 _BlotchTex_ST;
			float4 _DetailTex_ST;
			float4 _PaperTex_ST;
			//float4 _RampTex_ST;
			half _Glossiness;
			half _Metallic;
			half _BlotchMulti;
			half _BlotchSub;
			half _TintScale;
			half _PaperStrength;
			fixed4 _Color;
			fixed4 _Color2;
			fixed4 _InkCol;

            struct v2f
            {
                //float2 uv : TEXCOORD0;
                SHADOW_COORDS(1) // put shadows data into TEXCOORD1
                fixed3 diff : COLOR0;
                fixed3 ambient : COLOR1;
                float4 pos : SV_POSITION;
                
				float2 uv_BlotchTex : TEXCOORD2;
				float2 uv_DetailTex : TEXCOORD3;
				float2 uv_PaperTex : TEXCOORD4;
            };
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv_BlotchTex = TRANSFORM_TEX(v.texcoord, _BlotchTex);
                o.uv_DetailTex = TRANSFORM_TEX(v.texcoord, _DetailTex);
                o.uv_PaperTex = TRANSFORM_TEX(v.texcoord, _PaperTex);
                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
                o.diff = nl * _LightColor0.rgb;
                o.ambient = ShadeSH9(half4(worldNormal,1));
                // compute shadows data
                TRANSFER_SHADOW(o)
                //TRANSFER_VERTEX_TO_FRAGMENT(o) // Seems to do the same thing!?
                return o;
            }
			
			fixed4 screen (fixed4 colA, fixed4 colB)
			{
				fixed4 white = (1,1,1,1);
				return white - (white-colA) * (white-colB);
			}
			fixed4 softlight (fixed4 colA, fixed4 colB)
			{
				fixed4 white = (1,1,1,1);
				return (white-2*colB)*pow(colA, 2) + 2*colB*colA;
			}

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col; // = tex2D(_MainTex, i.uv);
                
                
                fixed c = 0.5f*(tex2D (_DetailTex, i.uv_DetailTex).r + tex2D (_BlotchTex, i.uv_BlotchTex).r);	
				// compute shadow attenuation (1.0 = fully lit, 0.0 = fully shadowed)
                fixed shadow = SHADOW_ATTENUATION(i);
                fixed3 lighting = 1.0f - clamp (i.diff * shadow + i.ambient, 0.0, 1.0);
                c += (lighting-0.5)*3;
				
				//return c;				
				c = tex2D (_RampTex, half2(c, 0)).r;
				c = saturate(c);
				
				fixed4 tint = tex2D (_BlotchTex, i.uv_BlotchTex / _TintScale);	
				tint = lerp(_Color, _Color2, tint.r);
				
				fixed4 ink = screen(_InkCol, fixed4(c,c,c,1) );
				col = lerp(ink * tint, softlight(tex2D (_PaperTex, i.uv_PaperTex), ink * tint), _PaperStrength);
                
                return col;
            }
            ENDCG
        }

        // shadow casting support
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}