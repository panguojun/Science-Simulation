// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ShaderTemplate2D" { 
    Properties{
        iMouse ("Mouse Pos", Vector) = (100, 100, 0, 0)
		iCamPos ("iCamPos", Vector) = (0, 0, 0, 0)
		iCamForward ("iCamForward", Vector) = (0, 0, 0, 0)
		iCamRight ("iCamRight", Vector) = (0, 0, 0, 0)
		iCamTop ("iCamTop", Vector) = (0, 0, 0, 0)
		iDate ("iDate", Vector) = (100, 100, 0, 0)
    }
 
    CGINCLUDE    
    #include "UnityCG.cginc"   
    #pragma target 3.0      
 
    #define vec2 float2
    #define vec3 float3
    #define vec4 float4
    #define mat2 float2x2
    #define mat3 float3x3
    #define mat4 float4x4
    #define iTime _Time.y+20.0
    #define mod fmod
    #define mix lerp
    #define fract frac
    #define texture2D tex2D
    #define iResolution _ScreenParams
    #define gl_FragCoord ((_iParam.scrPos.xy/_iParam.scrPos.w) * _ScreenParams.xy)
 
    #define PI2 6.28318530718
    #define pi 3.14159265358979
    #define halfpi (pi * 0.5)
    #define oneoverpi (1.0 / pi)
	#define ROT(p, a) p=cos(a)*p+sin(a)*vec2(p.y, -p.x)
	#define ROT1(p, a) p=cos(a)*vec2(p.x * 0.5, p.y)+sin(a)*vec2(p.y, -p.x * 0.5)
	#define ROT2(p, a) p=cos(a)*vec2(p.x, p.y * 0.5)+sin(a)*vec2(p.y * 0.5, -p.x)
	
    fixed4 iMouse;
	fixed4 iCamPos;
	fixed4 iCamForward;
	fixed4 iCamRight;
	fixed4 iCamTop;
	fixed4 iDate;
	
    struct v2f {    
        float4 pos : SV_POSITION;    
        float4 scrPos : TEXCOORD0;   
    };              
 
    v2f vert(appdata_base v) {  
        v2f o;
        o.pos = UnityObjectToClipPos (v.vertex);
        o.scrPos = v.texcoord;
        return o;
    }  
	vec4 main(vec2 fragCoord);
 
    fixed4 frag(v2f _iParam) : COLOR0 { 
        return main(_iParam.scrPos.xy);
    }  
	
    vec4 main(vec2 fragCoord) {
		// Normalized pixel coordinates (from 0 to 1)
		vec2 uv = fragCoord;
		
		vec3 col = vec3(0.,0.,0.);

		return vec4(col, 1.0);
    }
 
    ENDCG    
 
    SubShader {    
        Pass {    
            CGPROGRAM 
            #pragma vertex vert    
            #pragma fragment frag    
            #pragma fragmentoption ARB_precision_hint_fastest     
 
            ENDCG    
        }    
    }     
    FallBack Off    
}