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
// =========================================================
#define resolution_3d	0.02 
#define depth_of_field	100
#define ROT(p, a) p=cos(a)*p+sin(a)*vec2(p.y, -p.x)

// =========================================================
real map(vec3 p) 
{
	float NebNoise = abs(NebulaNoise(p/0.5)*0.5);
    
	return max( NebNoise+0.03, 0.0 );
}

// vertical
float sdCylinder( vec3 p, vec2 h )
{
    vec2 d = abs(vec2(length(p.xz),p.y)) - h;
    return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}
float get_sd(vec3 p)
{
    return sdCylinder(p, vec2(0.1,1.));
}
vec3 get_norm( in vec3 p )
{
    // iq: inspired by tdhooper and klems - a way to prevent the compiler from inlining map() 4 times
    vec3 n = vec3(0.0);
    for( int i=0; i<4; i++ )
    {
        vec3 e = 0.5773*(2.0*vec3((((i+3)>>1)&1),((i>>1)&1),(i&1))-1.0);
        n += e*get_sd(p+0.0005*e);
    }
    return normalize(n);
}
// c is the sin/cos of the desired cone angle
float sdSolidAngle(vec3 pos, vec2 c, float ra)
{
    vec2 p = vec2( length(pos.xz), pos.y );
    float l = length(p) - ra;
	float m = length(p - c*clamp(dot(p,c),0.0,ra) );
    return max(l,m*sign(c.y*p.x-c.x*p.y));
}

// coordnate
crd3 crd_p(crd3 c0, vec3 p)
{
    vec3 ax = normalize(cross(p, UY));

    crd3 c = c_x_q(c0, angax_q(0.25*length(p.xz)*(0.2 + 2.5), ax));
    
    return c;
}
crd3 crd_p2(crd3 c0, vec3 p)
{
    vec3 ax = UX;

    crd3 c = c_x_q(c0, angax_q(1.25*length(p.xy), ax));
    
    return c;
}
// ---------------------------------------------------------
// 3D Image
// ---------------------------------------------------------
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{  
    vec2 pp = (-iResolution.xy + 2.0 * fragCoord.xy) / iResolution.y;
    float eyer = 1.0;
    float eyea = -((iMouse.x) / iResolution.x) * PI * 2.0;
    float eyef = ((iMouse.y / iResolution.y) - 0.24) * PI * 2.0;

    vec3 cam = vec3(
        eyer * cos(eyea) * sin(eyef),
        eyer * cos(eyef),
        eyer * sin(eyea) * sin(eyef));
        
    ROT(cam.xz, (0.5) * (iTime + 10.0)); // auto rotation

    vec3 front = normalize(-cam);
    vec3 left = normalize(cross(normalize(vec3(0.1, 1, -0.001)), front));
    vec3 up = normalize(cross(front, left));
    
    vec3 camd = normalize(front + left * pp.x + up * pp.y);
    
    coord3 c0 = uxy_c(UX, UY);
    
    vec3 p0 = cam;
    vec3 v0 = camd;
    
    float dt = 0.025;
    vec3 cor = vec3(0.0);
    float d = 0.0;
    
    for(int i = 0; i < depth_of_field; i ++)
    {
        coord3 c;
        vec3 p;
		
        {// parent
            c = crd_p(c0, p0);

            p = p_x_c(p0, c);

            d = min(d, sdCylinder(p, vec2(0.1,0.5)));
            
            {// child
                c = crd_p2(c, p);

                p = p_x_c(p, c);

                d = min(d, sdCylinder(p, vec2(0.3,0.1)));
            }
        }
        {// brother/sister
            c = crd_p(c0, p0);

            p = p_x_c(p0, c);

            d = min(d, sdCylinder(p, vec2(0.1,0.5)));
        }

        if( d < 0. )
        { 
            cor = 0.2 + 0.2 * (vec3(1.5,1.0,1.8)*get_norm(p) );
            break;
        }
        p0 += v0 * dt;
    }
    
    
    fragColor = vec4(cor,1.0);
}