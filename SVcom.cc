/*
*           Visualization of Natural Phenomena
*
*   
*/

#define PI 3.14156
#define real float
#define imag float
#define quat quaternion
#define crd3 coord3

#define CSCREEN vec2(0.5,0.5)

#define BLACK vec3(0,0,0)
#define WHITE vec3(1,1,1)
#define RED vec3(1,0,0)
#define GREEN vec3(0,1,0)
#define BLUE vec3(0,0,1)
#define YELLOW vec3(1,1,0)
#define GREY vec3(0.5,0.5,0.5)

#define XYZ0 vec3(0,0,0)
#define UX vec3(1,0,0)
#define UY vec3(0,1,0)
#define UZ vec3(0,0,1)
#define UC crd3(UX, UY, UZ, XYZ0)

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
quaternion wv_q(real w, vec3 v)
{
   return quaternion(w, v.x,v.y,v.z);
}
// v x q
vec3 v_x_q(vec3 v, quaternion q)
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
// q x q
quaternion q_x_q(quaternion q1, quaternion q2)
{
    quaternion q;

    q.w = q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z;
    q.x = q1.w * q2.x + q1.x * q2.w + q1.y * q2.z - q1.z * q2.y;
    q.y = q1.w * q2.y + q1.y * q2.w + q1.z * q2.x - q1.x * q2.z;
    q.z = q1.w * q2.z + q1.z * q2.w + q1.x * q2.y - q1.y * q2.x;
    return q;
}
quaternion exp_q(quaternion q)
{
    vec3 v = vec3(q.x,q.y,q.z);
    real r = length(v);
    real tr = exp(q.w);
    return wv_q(tr * cos(r), normalize(v) * (tr*sin(r)));
}

// ---------------------------------------------------------
// Coordinate System:
// A coordinate system in three-dimensional space 
// consists of an origin plus three orientation axes
// c++ version : 
// https://github.com/panguojun/Coordinate-system-transformation
// ---------------------------------------------------------
struct coord3
{
    vec3 ux, uy, uz; // three axial unit vectors
    vec3 o;          // origin
};
coord3 uxyz_c(vec3 _ux, vec3 _uy, vec3 _uz)
{
    coord3 c;
    c.ux = _ux;
    c.uy = _uy;
    c.uz = _uz;
    c.o = XYZ0;
    return c;
}
coord3 uxy_c(vec3 _ux, vec3 _uy)
{
    coord3 c;
    c.ux = _ux;
    c.uy = _uy;
    c.uz = cross(_ux,_uy);
    c.o = XYZ0;
    return c;
}
coord3 norm_c(coord3 c)
{
    c.ux = normalize(c.ux);
    c.uy = normalize(c.uy);
    c.uz = normalize(c.uz);
    return c;
}
// p x c
vec3 p_x_c(vec3 p, coord3 c)
{
    return c.ux * p.x + c.uy * p.y + c.uz * p.z + c.o;
}
coord3 c_x_q(coord3 c, quat q)
{
    return coord3(
        v_x_q(c.ux, q), v_x_q(c.uy, q), v_x_q(c.uz, q),
        c.o);
}
// p / c
vec3 p_z_c(vec3 p, coord3 c)
{
    vec3 v = p - c.o;
    return vec3(dot(v, c.ux), dot(v, c.uy), dot(v, c.uz));
}
real c_ax_dot(vec3 v, coord3 c)
{
    return dot(v, c.ux + c.uy + c.uz);
}
vec3 c_ax_cross(coord3 a, coord3 b)
{
    return vec3(
        dot(a.uy, b.uz) - dot(a.uz, b.uy),
        dot(a.uz, b.ux) - dot(a.ux, b.uz),
        dot(a.ux, b.uy) - dot(a.uy, b.ux)
    );
}
coord3 c_flipx(coord3 c)
{
    c.ux = -c.ux;
    return c;
}
coord3 c_flipy(coord3 c)
{
    c.uy = -c.uy;
    return c;
}
coord3 c_flipz(coord3 c)
{
    c.uz = -c.uz;
    return c;
}

// ---------------------------------------------------------
// GRAD, DT
// ---------------------------------------------------------
#define delta_d 0.001
#define delta_t 0.001

#define GRAD_V(Fai, p, t) \
        vec3((Fai(p + vec3(delta_d,0.0,0.0), t) - Fai(p, t)) / delta_d,\
        (Fai(p + vec3(0.0,delta_d,0.0), t) - Fai(p, t)) / delta_d, \
        (Fai(p + vec3(0.0,0.0,delta_d), t) - Fai(p, t)) / delta_d)

#define GRAD_C(A, p, t) \
        uxyz_c( \
        (A(p + vec3(1.0,0.0,0.0) * delta_d, t) - A(p, t)) / delta_d, \
        (A(p + vec3(0.0,1.0,0.0) * delta_d, t) - A(p, t)) / delta_d, \
        (A(p + vec3(0.0,0.0,1.0) * delta_d, t) - A(p, t)) / delta_d)

#define DT(A, p, t) (A(p,t + delta_t) - A(p, t)) / delta_t

// ---------------------------------------------------------
// Space-Time Vector:
// ---------------------------------------------------------
struct time
{
    float tr;          // real time（Expansion time）
    float ti;          // imagine time（Phase time）
};
struct space_time
{
    vec3 n;
    time t;
};
vec3 space_time_v(space_time st)
{
    return st.n * exp(st.t.tr) * cos(st.t.ti);
}

// ---------------------------------------------------------
// Vector Math
// ---------------------------------------------------------
vec3 crossdot(vec3 v1, vec3 v2) {
    vec3 result;
    result.x = v1.y * v2.z - v1.z * v2.y;
    result.y = v1.z * v2.x - v1.x * v2.z;
    result.z = v1.x * v2.y - v1.y * v2.x;
    return result;
}

// ---------------------------------------------------------
// random
// ---------------------------------------------------------
// iq's
float hash(float n) { return fract(sin(n)*753.5453123); }
float noise(vec3 x)
{
	vec3 p = floor(x);
	vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	float n = p.x + p.y*157.0 + 113.0*p.z;
	return mix(mix(mix(hash(n+0.0), hash(n+1.0),f.x),
		mix(hash(n+157.0), hash(n+158.0),f.x),f.y),
		mix(mix(hash(n+113.0), hash(n+114.0),f.x),
			mix(hash(n+270.0), hash(n+271.0),f.x),f.y),f.z);
}

float rrnd(vec2 co)
{
	return fract(sin(dot(co*0.123,vec2(12.9898,78.233))) * 43758.5453);
}

// otaviogood's noise from https://www.shadertoy.com/view/ld2SzK

const float nudge = 0.739513;
float normalizer = 1.0 / sqrt(1.0 + nudge*nudge);
float SpiralNoiseC(vec3 p)
{
	float n = 0.0;
	float iter = 1.0;
	for (int i = 0; i < 8; i++)
	{
		n += -abs(sin(p.y*iter) + cos(p.x*iter)) / iter;
		p.xy += vec2(p.y, -p.x) * nudge;
		p.xy *= normalizer;
		p.xz += vec2(p.z, -p.x) * nudge;
		p.xz *= normalizer;
		iter *= 1.733733;
	}
	return n;
}

float SpiralNoise3D(vec3 p)
{
	float n = 0.0;
	float iter = 1.0;
	for (int i = 0; i < 5; i++)
	{
		n += (sin(p.y*iter*2.0) + cos(p.x*iter)) / iter;
		p.xz += vec2(p.z, -p.x) * nudge;
		p.xz *= normalizer;
		iter *= 1.33733;
	}
	return n;
}

float NebulaNoise(vec3 p)
{
	float final = p.y + 2.5;
	final -= SpiralNoiseC(p.xyz*2.0);   // 中等噪声
	final += SpiralNoiseC(p.zxy*0.5123+100.0)*2.0;   // 大尺度特征
	final -= SpiralNoise3D(p);   // 更多大尺度特征，但是是3D的

	return final;
}