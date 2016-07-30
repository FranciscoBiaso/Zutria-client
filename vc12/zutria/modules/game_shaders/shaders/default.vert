uniform mat3 u_TransformMatrix;
uniform mat3 u_ProjectionMatrix;
uniform mat3 u_TextureMatrix;
uniform vec2 u_Resolution;
uniform float u_Time;

in vec3 a_Vertex;
in vec2 a_TexCoord;

out vec2 v_TexCoord;

vec4 calculatePosition() {

  return vec4(u_ProjectionMatrix *  u_TransformMatrix * vec3(a_Vertex.xy, 1.0), 1.0);
}

void main()
{    
    gl_Position = calculatePosition();  
    
    v_TexCoord = (u_TextureMatrix * vec3(a_TexCoord,1.0)).xy;
}