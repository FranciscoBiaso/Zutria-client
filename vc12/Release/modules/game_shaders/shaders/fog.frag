uniform sampler2D u_Tex0;
uniform vec4 u_Color;
uniform float u_Opacity;
uniform vec2 u_Resolution;

out vec4 color;
in vec2 v_TexCoord;

vec4 calculatePixel() {
    return texture2D(u_Tex0, v_TexCoord) * u_Color;
}

vec3 normal = vec3(0,0,-1);
vec3 lightDir = vec3(5,-5,10);
vec3 eyeVec;
vec3 spotDir = vec3(0,0,1);
float spotCutOff = 0.85;
float shininess = 60.0;

vec4 DiffuseProduct = vec4(0.8, 0.8, 0.8, 1.0);
vec4 AmbientProduct = vec4(0.3, 0.3, 0.3, 1.0);
vec4 SpecularProduct = vec4(0.6, 0.6, 0.6, 1.0);

const float cos_outer_cone_angle = 0.8; // 36 degrees


void main (void)
{  

  eyeVec = vec3(0.0,0.0,-3.0);

    // calculate the distance to the center of the screen
    //float dist = sqrt(dir.x*dir.x + dir.y*dir.y);

  vec4 final_color = AmbientProduct;
  
	vec3 L = normalize(lightDir);
	vec3 D = normalize(spotDir);

	float cos_cur_angle = dot(-L, D);

	float cos_inner_cone_angle = spotCutOff;

	float cos_inner_minus_outer_angle = 
	      cos_inner_cone_angle - cos_outer_cone_angle;
	
	//****************************************************
	// Don't need dynamic branching at all, precompute 
	// falloff(i will call it spot)
	float spot = 0.0;
	spot = clamp((cos_cur_angle - cos_outer_cone_angle) / 
	       cos_inner_minus_outer_angle, 0.0, 1.0);
	//****************************************************

	vec3 N = normalize(normal);

	float lambertTerm = max( dot(N,L), 0.0);
	if(lambertTerm > 0.0)
	{
		final_color += DiffuseProduct *
			lambertTerm * spot;

		vec3 E = normalize(eyeVec);
		vec3 R = reflect(-L, N);

		float specular = pow( max(dot(R, E), 0.0), shininess );

		final_color += SpecularProduct *
			specular * spot;
	}
  
    color =  final_color * calculatePixel();
    color.a *= u_Opacity;    
}
