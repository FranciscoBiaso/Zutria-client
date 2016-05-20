uniform mat4 u_TransformMatrix;
uniform mat4 u_ProjectionMatrix;
uniform mat3 u_TextureMatrix;
uniform vec2 u_Resolution;
uniform float u_Time;

in vec3 a_Vertex;
in vec2 a_TexCoord;

out vec2 v_TexCoord;

vec4 calculatePosition() {

  float rad = radians(0.0);
  mat4 rot = mat4(          1.0, 0.0,      0.0,       0.0,
                            0.0, cos(rad), -sin(rad), 0.0,
                            0.0, sin(rad), cos(rad),  0.0,
                            0.0, 0.0,      0.0,       1.0
  );

  mat4 trans = mat4(        1.0, 0.0, 0.0, 0.0,
                            0.0, 1.0, 0.0, 0.0,
                            0.0, 0.0, 1.0, 0.0,
                            -u_Resolution.x/2, -u_Resolution.y/2, 3, 1.0
  );
  
  mat4 transR = mat4(       1.0, 0.0, 0.0, 0.0,
                            0.0, 1.0, 0.0, 0.0,
                            0.0, 0.0, 1.0, 0.0,
                            u_Resolution.x/2, u_Resolution.y/2, -3, 1.0
  );
 
 
  mat4 p = mat4(        2.0/u_Resolution.x, 0.0, 0.0, 0.0,
                            0.0, -2.0/u_Resolution.y, 0.0, 0.0,
                            0.0, 0.0, -2.0/2.0, 0.0,
                            -1.0, 1.0, 0.0, 1.0
  ); 
  return p *  u_TransformMatrix * transR * rot * trans * vec4(a_Vertex.xyz, 1.0);
}

void main()
{    
    gl_Position = calculatePosition();  
    
    v_TexCoord = (u_TextureMatrix * vec3(a_TexCoord,1.0)).xy;
}