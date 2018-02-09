#version 300 es

precision highp float;

uniform vec2 u_Dimensions;

in vec4 fs_Pos;

out vec4 out_Col;

void main() {
	out_Col = vec4(vec3(1.f, 0.f, 0.f), 1.f);
}
