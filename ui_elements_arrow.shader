float saturate(float x)
{
	return clamp(x, 0., 1.);
}
vec3 saturate(vec3 x)
{
	return clamp(x, vec3(0.), vec3(1.));
}

float Smooth(float x)
{
	return smoothstep(0., 1., saturate(x));
}

void Repeat(inout float p, float w)
{
	p = mod(p, w) - 0.5f * w;
}

float Circle(vec2 p, float r)
{
	return (length(p / r) - 1.) * r;
}

float Rectangle(vec2 p, vec2 b)
{
	vec2 d = abs(p) - b;
	return min(max(d.x, d.y), 0.) + length(max(d, 0.));
}

void Rotate(inout vec2 p, float a)
{
	p = cos(a) * p + sin(a) * vec2(p.y, -p.x);
}

float Capsule(vec2 p, float r, float c)
{
	return mix(length(p.x) - r, length(vec2(p.x, abs(p.y) - c)) - r, step(c, abs(p.y)));
}

float Arrow(vec2 p, float a, float l, float w)
{
	Rotate(p, a);
	p.y += l;

	float body = Capsule(p, w, l);
	p.y -= w;

	float tip = p.y + l;

	p.y += l + w;
	Rotate(p, +2.);
	tip = max(tip, p.y - 2. * w);
	Rotate(p, -4.);
	tip = max(tip, p.y - 2. * w);

	return min(body, tip);
}
void DrawMenuControls(inout vec3 color, vec2 p, in AppState s)
{
	p -= vec2(-110, 74);

	// radial
	float c2 = Capsule(p - vec2(0., -3.5), 3., 4.);
	float c1 = Circle(p + vec2(0., 7. - 7. * s.metal), 2.5);

	// roughness slider
	p.y += 15.;
	c1 = min(c1, Capsule(p.yx - vec2(0., 20.), 1., 20.));
	c1 = min(c1, Circle(p - vec2(40. * s.roughness, 0.), 2.5));

	p.y += 8.;
	c1 = min(c1, Rectangle(p - vec2(19.5, 0.), vec2(21.4, 4.)));
	color = mix(color, vec3(0.9), Smooth(-c2 * 2.));
	color = mix(color, vec3(0.3), Smooth(-c1 * 2.));

	for (int i = 0; i < 6; ++i)
	{
		vec2 o = vec2(i == int(s.baseColor) ? 2.5 : 3.5);
		color = mix(color, BASE_COLORS[i], Smooth(-2. * Rectangle(p - vec2(2. + float(i) * 7., 0.), o)));
	}
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xx;
     vec3 color = vec3(0., 0., 0.);
    {
        vec2 p = uv * 100.0;
        // refraction
        float r = 1e4;
        vec2 t = p - vec2(18., 15.);
        for (int i = 0; i < 3; ++i)
        {
            r = min(r, Arrow(t - vec2(-15. + float(i) * 15., 0.), -0.4, 7., .7));
        }
            r = min(r, Arrow(t - vec2(9., -15.), 2., 4., .7));
        r = min(r, Arrow(t - vec2(17., -10.), 3.8, 18., .7));
        r = min(r, Arrow(t - vec2(-6., -14.), 0.9, 3., .7));
        r = min(r, Arrow(t - vec2(1., -19.), 2.9, 18., .7));
        r = min(r, Arrow(t - vec2(-22., -15.), 4.5, 2., .7));
        r = min(r, Arrow(t - vec2(-28., -14.), 2.6, 14., .7));
        {
            color = mix(color, vec3(0.88, 0.65, 0.2), Smooth(-r * 2.));
            fragColor = vec4(color,1.0);
        }
    
    }
}