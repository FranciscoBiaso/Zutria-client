uniform mat4 u_TransformMatrix;
uniform mat4 u_ProjectionMatrix;
uniform mat3 u_TextureMatrix;

in vec3 a_Vertex;
in vec2 a_TexCoord;

out vec2 v_TexCoord;
    
vec4 calculatePosition() {   
  return u_ProjectionMatrix * u_TransformMatrix * vec4(a_Vertex.xyz, 1.0);
}

void main()
{   
    gl_Position = calculatePosition();
    v_TexCoord = (u_TextureMatrix * vec3(a_TexCoord,1.0)).xy;

}