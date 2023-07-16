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

          ¡°If I can¡¯t picture it, I can¡¯t understand it.¡±
*/
// =========================================================
#define resolution_3d	0.02 
#define depth_of_field	30
#define ROT(p, a) p=cos(a)*p+sin(a)*vec2(p.y, -p.x)
// =========================================================
float map(vec3 p) 
{ 
    float NebNoise = abs(NebulaNoise(p/0.5)*0.5);
    
    return NebNoise+0.03;
}

// assign color to the media
vec3 computeColor( float density, float radius )
{
	// color based on density alone, gives impression of occlusion within
	// the media
	vec3 result = mix( vec3(1.0,0.9,0.8), vec3(0.4,0.15,0.1), density );
	
	// color added to the media
	vec3 colCenter = 7.*vec3(0.8,1.0,1.0);
	vec3 colEdge = 1.5*vec3(0.48,0.53,0.5);
	result *= mix( colCenter, colEdge, min( (radius+.05)/.9, 1.15 ) );
	
	return result;
}

// ---------------------------------------------------------
// 3D Image
// ---------------------------------------------------------
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{  
    vec2 pp = (-iResolution.xy + 2.0 * fragCoord.xy) / iResolution.y;
    float eyer = 3.5;
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
    
    coord3 crd0 = uxy_c(UX, UY);
    
    // star
    vec3 star_pos = vec3(0.0);
    vec3 star_cor = vec3(1.0,0.5,0.25);
    
    float t = 0.0;
    
	float td = 0.; // density
    
    const float h = 0.58;
   
    vec4 cor = vec4(0.0);
    
    for (int i = 0; i < depth_of_field; i++)
    {
        vec3 p = cam + camd * 0.5 + t * camd;
        
        float rxz = max(0.01, length(p.xz));
        
        {// the coordnate system
            coord3 crd = c_x_q(crd0, angax_q(1.5 / rxz, UY));
            //crd.o.y += mix(0., 1., rxz*rxz / 10.);
            
            p = p_x_c(p, crd);
        }
        
        float d = max(map(p), 0.08);

        if(cor.a > 0.99)
            break;

        float dis = max(length((star_pos - p)), 0.001);

        float beta = exp(-0.5 / (0.01+rxz) + abs(p.y) * 5.5 );
        
        cor.rgb += (star_cor/((dis))/ 5./ beta);

        if (d < h) 
        {  
            td += (0.2 - td) * (h - d);

            vec4 cloud_cor = vec4(computeColor(td,dis), td);
            cloud_cor.a *= 0.158;
            cloud_cor.rgb *= cloud_cor.a;
           
            cor = cor + cloud_cor * (1.0 - cor.a) / beta;  
        }
        t += max(d * 0.1 * max(min(length(dis),length(cam)),1.0), 0.02);
    }
    
    cor = clamp( cor, 0.0, 1.0 );

    cor.xyz = cor.xyz*cor.xyz*(3.0-2.0*cor.xyz);
    
    fragColor = vec4(cor.xyz,1.0);
}