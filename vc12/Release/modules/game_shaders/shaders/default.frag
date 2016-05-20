in vec2 v_TexCoord;

uniform vec4 u_Color;
uniform sampler2D u_Tex0;
uniform float u_Opacity;

vec4 calculatePixel() {
    return texture2D(u_Tex0, v_TexCoord) * u_Color;
}

void main()
{
    gl_FragColor = calculatePixel();
    
    gl_FragColor.a *= u_Opacity;
}