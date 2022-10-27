/*
                          .-''--.
                         _`>   `\.-'<
                      _.'     _     '._
                    .'   _.='   '=._   '.
                    >_   / /_\ /_\ \   _<
                      / (  \o/\\o/  ) \
                      >._\ .-,_)-. /_.<
                          /__/ \__\
                            '---'  
            
          “If I can’t picture it, I can’t understand it.”
*/
Shader "Custom/Field7" { 
    Properties{

    	iVec4 ("iView", Vector) = (1, 1, 0, 0)
		iVec4 ("iVec4", Vector) = (0, 0, 0, 0)
		
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

	#define real float
	#define ROT(p, a) p=cos(a)*p+sin(a)*vec2(p.y, -p.x)
	#define pi 3.1415926535
	#define deta_d 0.0001
	#define deta_t 0.01
	// ---------------------------------------------------------
	// Coordinate System:
	// A coordinate system in three-dimensional space 
	// consists of an origin plus three orientation axes
	// ---------------------------------------------------------
	struct coord3
	{
	    vec3 ux, uy, uz; // three axial unit vectors
	    vec3 o;        // origin
	};
	coord3 create_coord(vec3 _ux, vec3 _uy, vec3 _uz)
	{
	    coord3 c; c.ux = _ux; c.uy = _uy; c.uz = _uz;
	    return c;
	}
	// mul: define this vector in a coordinate system
	vec3 coord_mul(vec3 p, coord3 c)
	{
	    return c.ux * (p.x) + c.uy * (p.y) + c.uz * (p.z) + c.o;
	}
	// div: measure this vector in a coordinate system
	vec3 coord_div(vec3 p, coord3 c)
	{
	    vec3 v = p - c.o;
	    return vec3(dot(v, c.ux), dot(v, c.uy), dot(v, c.uz));
	}
	// axes's dot
	real coord_ax_dot(vec3 v, coord3 c)
	{
	    return dot(v, (c.ux + c.uy + c.uz));
	}
	// axes's cross
	vec3 coord_ax_cross(coord3 a, coord3 b)
	{
	    return vec3(
	        dot(a.uy, b.uz) - dot(a.uz, b.uy),
	        dot(a.uz, b.ux) - dot(a.ux, b.uz),
	        dot(a.ux, b.uy) - dot(a.uy, b.ux)
	    );
	}
	// flip x
	coord3 flipx_coord(coord3 c)
	{
	    c.ux = -c.ux;
	    return c;
	}
	// flip y
	coord3 flipy_coord(coord3 c)
	{
	    c.uy = -c.uy;
	    return c;
	}
	// flip z
	coord3 flipz_coord(coord3 c)
	{
	    c.uy = -c.uy;
	    return c;
	}
	coord3 default_coord;		// The Default Coordinate System

	// ---------------------------------------------------------
	// GRAD, DT
	// ---------------------------------------------------------
	#define GRAD_V(Fai, p, t) \
	        vec3((Fai(p + vec3(deta_d,0.0,0.0), t) - Fai(p, t)) / deta_d,\
	        (Fai(p + vec3(0.0,deta_d,0.0), t) - Fai(p, t)) / deta_d, \
	        (Fai(p + vec3(0.0,0.0,deta_d), t) - Fai(p, t)) / deta_d)

	#define GRAD_C(A, p, t) \
	    create_coord( \
	    (A(p + vec3(1.0,0.0,0.0) * deta_d, t) - A(p, t)) / deta_d, \
	    (A(p + vec3(0.0,1.0,0.0) * deta_d, t) - A(p, t)) / deta_d, \
	    (A(p + vec3(0.0,0.0,1.0) * deta_d, t) - A(p, t)) / deta_d)

	#define DT(A, p, t) (A(p,t + deta_t) - A(p, t)) / deta_t

	// ---------------------------------------------------------
	// Quaternion:
	// Quaternions are real mathematics numbers, 
	// meaning there is number theory behind them.
	// ---------------------------------------------------------
	struct quaternion
	{
	    real w, x, y, z;
	};
	quaternion angax_q(real ang, vec3 ax)
	{
	    quaternion q;
	    real halfang = 0.5 * ang;
	    real fsin = sin(halfang);
	    q.w = cos(halfang);
	    q.x = fsin * ax.x;
	    q.y = fsin * ax.y;
	    q.z = fsin * ax.z;
	    return q;
	}
	vec3 qmul(quaternion q, vec3 v)
	{
	    // nVidia SDK implementation
	    vec3 uv, uuv;
	    vec3 qvec = vec3(q.x, q.y, q.z);
	    uv = cross(qvec, v);
	    uuv = cross(qvec, uv);
	    uv = uv * (2.0f * q.w);
	    uuv = uuv * 2.0f;

	    return v + uv + uuv;
	}
	quaternion qmul(quaternion q1, quaternion q2)
	{
	    quaternion q;

	    q.w = q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z;
	    q.x = q1.w * q2.x + q1.x * q2.w + q1.y * q2.z - q1.z * q2.y;
	    q.y = q1.w * q2.y + q1.y * q2.w + q1.z * q2.x - q1.x * q2.z;
	    q.z = q1.w * q2.z + q1.z * q2.w + q1.x * q2.y - q1.y * q2.x;
	    return q;
	}


	// ---------------------------------------------------------
	// Dimension or Const:
	// Dimensions and constants define our physical world!
	// ---------------------------------------------------------
	#define PI 3.14156
	#define MET 1.0
	#define SEC 0.5
	// =========================================================
	// Electromagnetic Field And 3D Image
	// =========================================================
	#define resolution_3d	0.03 
	#define depth_of_field	50
	#define draw_strength_E	0.004
	#define draw_strength_B	0.004

	// ---------------------------------------------------------
	// Electromagnetic Field:
	// I define an electromagnetic force field in the Y-axis direction, 
	// its scalar part exhibits an inverse square distribution near the Zero Point.
	// Note: This field does not exist in reality!

	// I prefer the equations in Maxwell's original form:
	// Q = Fai + |A>
	// ---------------------------------------------------------
	// Eigen Electromagnetic Field Define

	// The Scalar Part
	float Fai(vec3 p, float t)
	{
	    float r = length(p);
	    if (r < 0.01)
	        r = 0.01;
	    return (0.5 / (r * r));
	}
	// The Vector Part
	vec3 A(vec3 p, float t) {
	    float r = length(p.xz);
	    if (r < 0.01)
	        r = 0.01;
	    return vec3(0.0, 1.0, 0.0) * (10.0 / (r));
	}

	// ---------------------------------------------------------
	// E/B Field in default coordinate system
	// ---------------------------------------------------------
	vec3 get_Efield(vec3 p, real t)
	{
	    return GRAD_V(Fai, p, t) - DT(A, p, t);
	}
	vec3 get_Bfield(vec3 p, real t)
	{
	    return coord_ax_cross(default_coord, GRAD_C(A, p, t));
	}


    #define freqP iView.y 		// 粒子化频道
    #define freqS (iView.x/10.) 	// 空间频道
    #define freqT iView.z 		// 时间频道

	#define decline 12. 		// 衰减率

	fixed4 iView;
	fixed4 iVec4;
 
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
        return main(gl_FragCoord);
    }  

    vec4 main(vec2 fragCoord) 
    {
		vec2 uv=fragCoord.xy/iResolution.xy;
		vec2 pp = (-iResolution.xy + 2.0 * fragCoord.xy) / iResolution.y;
	    float eyer = 0.5;
	    float eyea = -((0.) / iResolution.x) * PI * 2.0;
	    float eyef = ((0. / iResolution.y) - 0.24) * PI * 2.0;

	    vec3 cam = vec3(
	        eyer * cos(eyea) * sin(eyef),
	        eyer * cos(eyef),
	        eyer * sin(eyea) * sin(eyef));

	    ROT(cam.xz, (0.1) * (iTime + 5.0)); // auto rotation

	    vec3 front = normalize(-cam);
	    vec3 left = normalize(cross(normalize(vec3(0.0, 1, -0.001)), front));
	    vec3 up = normalize(cross(front, left));
	    vec3 v = normalize(front + left * pp.x + up * pp.y);

	    vec3 p = cam;

	    // Default Coordinate System
	    default_coord.ux = vec3(1.0, 0.0, 0.0);
	    default_coord.uy = vec3(0.0, 1.0, 0.0);
	    default_coord.uz = vec3(0.0, 0.0, 1.0);

	    float dt = resolution_3d;
	    vec3 cor1 = vec3(0.0,0.0,0.0);

	    float t = 0.0;
	    for (int i = 0; i < depth_of_field; i++)
	    {
	        float r = length(p);
	        quaternion qx = angax_q(PI * sin(r * 10.1 + PI / 3.), vec3(1., 0., 0.));
	        quaternion qy = angax_q(PI * sin(r * 10.1 + PI * 2. / 3.), vec3(1., 0., 0.));
	        quaternion qz = angax_q(PI * sin(r * 10.1), vec3(1., 0., 0.));
	        vec3 pp = qmul(qmul(qmul(qx, qy), qz), p);
	        cor1 += (get_Efield(pp - vec3(-0.25, 0., 0.), t) - get_Efield(pp - vec3(0.25, 0., 0.), t)) * draw_strength_B;

	        p += v * dt;
	    }

	    return vec4(
	        sin(cor1* freqS - freqT * iTime),	// MAKE it pretty!
	        1.0);
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