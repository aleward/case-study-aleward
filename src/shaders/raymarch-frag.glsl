#version 300 es

precision highp float;

uniform mat4 u_View;
uniform mat4 u_Project;
uniform vec3 u_Eye;
uniform vec2 u_Dimensions;
uniform float u_Time;

in vec4 fs_Pos;

out vec4 out_Col;


float EPSILON = 0.0001;
float CLIP = 100.f;
float PI = 3.14159265359;
bool eyeCol = false;
bool beakCol = false;
bool legCol = false;
bool shade = false;

// Smooth minimum from IQ
float smin( float a, float b, float k) {
    float res = exp(-k * a) + exp(-k * b);
    return -log(res) / k;
}

// Box from IQ
float box(vec3 p, vec3 b)
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

// Cylinder from IQ
float sdCappedCylinder(vec3 p, vec2 h) {
  	vec2 d = abs(vec2(length(p.xz), p.y)) - h;
  	return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}
// Triangular prism from IQ
float sdTriPrism( vec3 p, vec2 h )
{
    vec3 q = abs(p);
    return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}

// My duck SDF
float mySDF(vec3 pos) {

	// Adjusts initial duck angle:
	float cView = cos(radians(26.f));
	float sView = sin(radians(26.f));
	float cViewX = cos(radians(-26.f));
	float sViewX = sin(radians(-26.f));
	float cViewZ = cos(radians(5.f));
	float sViewZ = sin(radians(5.f));
	mat3 view = mat3(cViewZ,  sViewZ, 0.f, -sViewZ, cViewZ, 0.f, 0.f,   0.f,  1.f) *
			    mat3(1.f, 0.f, 0.f, 0.f, cViewX, sViewX, 0.f, -sViewX, cViewX) * 
				mat3(cView, 0.f, -sView, 0.f, 1.f, 0.f, sView, 0.f, cView);

	vec3 oldPos = view * pos;

	// ~~~~~BODY~~~~~

	// Motion:
	float bodC = cos(radians(7.f * sin(u_Time * 0.18)));
	float bodS = sin(radians(7.f * sin(u_Time * 0.18)));
	pos = mat3(bodC,  bodS, 0.f, 
			   -bodS, bodC, 0.f, 
			   0.f,   0.f,  1.f) * view * pos;

	// An x-axis rotation matrix used for elements of the body
	float c = cos(radians(-30.f));
    float s = sin(radians(-30.f));
    mat3  mX = mat3(1.f, 0.f, 0.f, 0.f, c, s, 0.f, -s, c);

	float bod = length(mX * pos * vec3(1.f, 1.f, 0.8) + vec3(0.f, 0.25f, 0.4f)) - 0.8f;

	float wing = length((mX * pos + vec3(-0.3f, 0.1f, 0.7f)) / vec3(0.9f, cos(pos.z / 1.4 - 0.5), 1.f)) - 0.69;
	float wing2 = length((mX * mX * pos + vec3(-0.2f, 0.7f, 0.5f)) / vec3(1.f, cos(pos.z / 1.4 - 0.5), 1.f)) - 0.69;
	float wing3 = length((mX * pos + vec3(0.3f, 0.1f, 0.7f)) / vec3(0.9f, cos(pos.z / 1.4 - 0.5), 1.f)) - 0.69;
	float wing4 = length((mX * mX * pos + vec3(0.2f, 0.7f, 0.5f)) / vec3(1.f, cos(pos.z / 1.4 - 0.5), 1.f)) - 0.69;
	wing = min(min(wing, wing2), min(wing3, wing4));

	float tailC = cos(radians(7.f * sin((u_Time + pos.z * 2.f) * 0.18) * pos.z));
	float tailS = sin(radians(7.f * sin((u_Time + pos.z * 2.f) * 0.18) * pos.z));
	vec3 tailPos = mat3(tailC, 0.f, -tailS, 0.f, 1.f, 0.f, tailS, 0.f, tailC) * pos;

	float tail = sdCappedCylinder(tailPos.xzy + vec3(0.f, 1.6f, (tailPos.z + 0.8f) - 0.05), 
								  vec2(0.8f * sin(tailPos.z + 1.95f), 0.7f));

	// Motion:
	float upC = cos(radians(4.f));
	float upS = sin(radians(4.f));
	vec3 upperTilt = mat3(bodC,  bodS, 0.f, 
			   			-bodS, bodC, 0.f, 
			   			0.f,   0.f,  1.f) * 
			   		 mat3(1.f,  0.f, 0.f, 
						  0.f,	upC, upS, 
						  0.f, -upS, upC) * oldPos;
	float neckC = cos(radians(4.f * sin(u_Time * 0.18) * pos.y));
	float neckS = sin(radians(4.f * sin(u_Time * 0.18) * pos.y));
	vec3 neckPos = mat3(neckC,  neckS, 0.f, 
						-neckS, neckC, 0.f, 
						0.f,   0.f,  1.f) * pos;

	float neck = sdCappedCylinder(neckPos - vec3(0.f, 0.7f, -0.1f), vec2(0.45, 0.7f));

	// Motion:
	float headC = cos(radians(6.f * sin(u_Time * 0.18)));
	float headS = sin(radians(6.f * sin(u_Time * 0.18)));
	vec3 headPos = mat3(headC,  headS, 0.f, 
						-headS, headC, 0.f, 
						0.f,   0.f,  1.f) * upperTilt;

	float head = length(headPos - vec3(0.f, 1.4f, 0.f)) - 0.5;

	float body = min(wing, smin(tail, smin(head, smin(neck, bod, 20.f), 20.f), 20.f));


	// ~~~~~FACIAL FEATURES~~~~~

	// Motion:
	float turnC = cos(radians(10.f * sin(u_Time * 0.18)));
	float turnS = sin(radians(10.f * sin(u_Time * 0.18)));
	vec3 turn = mat3(headC,  headS, 0.f, 
						-headS, headC, 0.f, 
						0.f,   0.f,  1.f) * 
				mat3(bodC,  bodS, 0.f, 
			   		 -bodS, bodC, 0.f, 
			   		 0.f,   0.f,  1.f) * 
			   	mat3(1.f, 0.f, 	0.f, 
					 0.f, upC, 	upS, 
					 0.f, -upS, upC) * 
				(vec3(0.f, 1.5f, 0.f) +
				mat3(turnC,  turnS, 0.f, 
			   		 -turnS, turnC, 0.f, 
			   		 0.f,   0.f,  1.f) * (oldPos + vec3(0.f, -1.5f, 0.f)));

	// An x-axis rotation matrix to angle the beak
	float c1 = cos(radians(-50.f));
    float s1 = sin(radians(-50.f));
    mat3  mBeakX = mat3(1.f, 0.f, 0.f, 0.f, c1, s1, 0.f, -s1, c1);

	float beak = sdTriPrism(mBeakX * (vec3(0.f, -3.5f, 0.1f) + 
							vec3(turn.x * 0.9, turn.y * 2.0 + 0.8 * cos(turn.x * 2.0), 1.2 * turn.z -  0.5 * cos(turn.x * 2.0))), 
							vec2(0.4f, 0.3f));

	float eyes = min(length(turn + vec3(-0.24, -1.53f, -0.43)) - 0.05, length(turn + vec3(0.24, -1.53f, -0.43)) - 0.05);

	float face = min(beak, eyes);


	// ~~~~~LEGS~~~~~

	// Rotation matrix to angle webbed feet
	mat3 footRot = // Y-axis rotation
				   mat3(cos(radians(45.f)), 0.f, -sin(radians(45.f)),
						0.f, 				1.f, 0.f, 
						sin(radians(45.f)), 0.f, cos(radians(45.f))) * 
				   // X-axis rotation
				   mat3(1.f, 0.f, 				  0.f, 
				   		0.f, cos(radians(60.f)),  sin(radians(60.f)), 
						0.f, -sin(radians(60.f)), cos(radians(60.f)));
	// Matrices to tilt legs
	mat3 mLeftZ  = mat3(cos(radians(10.f)),  sin(radians(10.f)), 0.f, 
						-sin(radians(10.f)), cos(radians(10.f)), 0.f, 
						0.f, 				 0.f, 				 1.f);
	mat3 mRightZ = mat3(cos(radians(-10.f)),  sin(radians(-10.f)), 0.f, 
						-sin(radians(-10.f)), cos(radians(-10.f)), 0.f, 
						0.f, 				  0.f, 				   1.f);

	// LEFT 
	// Movement:
	float xL = sin(u_Time * 0.18);
	float stepLC = cos(radians(60.f * xL + 20.f));
    float stepLS = sin(radians(60.f * xL + 20.f));
    vec3  stepLeft = vec3(0.f, -0.35f, -0.4f) + mat3(1.f, 0.f, 0.f, 0.f, stepLC, stepLS, 0.f, -stepLS, stepLC) * (pos + vec3(0.f, 0.35f, 0.4f));
	// Structure
	float leftStick = sdCappedCylinder(mLeftZ * (stepLeft + vec3(0.5f, 0.95f, 0.4f)), vec2(0.09, 0.35f));
	vec3 footPos = stepLeft + vec3(0.55, 2.f, -0.12f);
	float footLeft = smin(leftStick, box((footRot * (vec3(0.f, 0.f, cos(footPos.x * 2.f) - 0.5) + footPos)), vec3(0.5f, 0.5f, 0.5f)), 20.f);
	float leftLeg = max(-box(footPos + vec3(0.f, 0.9f, 0.f), vec3(1.3f, 1.3f, 1.5f)), footLeft);
	
	// RIGHT
	// Movement:
	float xR = sin(u_Time * 0.18 + PI);
	float stepRC = cos(radians(60.f * xR + 20.f));
    float stepRS = sin(radians(60.f * xR + 20.f));
    vec3  stepRight = vec3(0.f, -0.35f, -0.4f) + mat3(1.f, 0.f, 0.f, 0.f, stepRC, stepRS, 0.f, -stepRS, stepRC) * (pos + vec3(0.f, 0.35f, 0.4f));
	// Structure:
	float rightStick = sdCappedCylinder(mRightZ * (stepRight + vec3(-0.5f, 0.95f, 0.4f)), vec2(0.09, 0.35f));
	vec3 rfootPos = stepRight + vec3(-0.55, 2.f, -0.12f);
	float footRight = smin(rightStick, box((footRot * (vec3(0.f, 0.f, cos(rfootPos.x * 2.f) - 0.5) + rfootPos)), vec3(0.5f, 0.5f, 0.5f)), 20.f);
	float rightLeg = max(-box(rfootPos + vec3(0.f, 0.9f, 0.f), vec3(1.3f, 1.3f, 1.5f)), footRight);
	
	float legs = max(-box(oldPos + vec3(0.f, 2.8f, 0.f), vec3(3.f, 1.3f, 3.f)), min(leftLeg, rightLeg));

	// ~~~~~SHADOWS~~~~~
	float leftShad = length(vec3(footPos.x * (1.f - 0.3 * sin(u_Time * 0.18)), oldPos.y + 1.505f, pos.z - 0.5 * sin(u_Time * 0.18))) - 0.4f;
	float rightShad = length(vec3(rfootPos.x * (1.f - 0.3 * sin(u_Time * 0.18 + PI)), oldPos.y + 1.505f, pos.z - 0.5 * sin(u_Time * 0.18 + PI))) - 0.4f;
	float shad = max(abs(oldPos.y + 1.505f), min(min(leftShad, rightShad), length(vec3(-pos.x, oldPos.y + 1.505f, pos.z + 0.7f)) - 0.8f));

	float duck = min(shad, min(legs, min(face, body)));


	// Color picker

	if (duck < eyes + EPSILON && duck > eyes - EPSILON) {
		eyeCol = true;
		beakCol = false;
		legCol = false;
		shade = false;
	} else if (duck < beak + EPSILON && duck > beak - EPSILON) {
		eyeCol = false;
		beakCol = true;
		legCol = false;
		shade = false;
	} else if (duck < legs + EPSILON && duck > legs - EPSILON) {
		eyeCol = false;
		beakCol = false;
		legCol = true;
		shade = false;
	} else if (duck < shad + EPSILON && duck > shad - EPSILON) {
		eyeCol = false;
		beakCol = false;
		legCol = false;
		shade = true;
	} else {
		eyeCol = false;
		beakCol = false;
		legCol = false;
		shade = false;
	}

	return duck;
}

// From Jamie Wong's Ray Marching and Signed Distance Functions webpage:
vec3 estimateNormal(vec3 p) { 
	return normalize(vec3( 
		mySDF(vec3(p.x + EPSILON, p.y, p.z)) - mySDF(vec3(p.x - EPSILON, p.y, p.z)), 
		mySDF(vec3(p.x, p.y + EPSILON, p.z)) - mySDF(vec3(p.x, p.y - EPSILON, p.z)), 
		mySDF(vec3(p.x, p.y, p.z + EPSILON)) - mySDF(vec3(p.x, p.y, p.z - EPSILON)) )); 
}

void main() {
	// TODO: make a Raymarcher!

	vec3 pos = u_Eye;

	// Finds the furthest point in the background, used to compute rays
	float x = (gl_FragCoord.x / u_Dimensions.x) * 2.f - 1.f;
	float y = 1.f - (gl_FragCoord.y / u_Dimensions.y) * 2.f;
	vec4 bg = inverse(u_View) * inverse(u_Project) * vec4(x * -1000.f, y * -1000.f, 1000.f, 1000.f);

	vec3 dir = normalize(vec3(bg.x, bg.y, bg.z) - u_Eye);

	bool geo = false;

	float maxLoops = 0.f; // Ensures program doesn't crash

	float minT = mySDF(pos);

	float t = mySDF(pos);
	float dist = t;

	while (t < CLIP && maxLoops < 100.f) {
		pos += t * dir;
		float i = mySDF(pos);
		dist += i;
		if (i < EPSILON && i > -0.-EPSILON) { //
			geo = true;
			break;
		}
		t = i;
		minT = min(t, minT);
		maxLoops++;
	}

	if (geo) {
		vec3 lightVec = u_Eye - pos;

		vec3 color;

		float scale = 1.f;

		if (beakCol) {
			lightVec = pos - vec3(0.f, 7.f, 0.f);
			color = vec3(254.f / 255.f, 203.f / 255.f, 47.f / 255.f);
		} else if (eyeCol) {
			color = vec3(0.f, 0.f, 0.f);
		} else if (legCol) {
			color = vec3(252.f / 255.f, 102.f / 255.f, 33.f / 255.f);
			scale = 0.5;
		} else {
			color = vec3(1.f, 1.f, 1.f);
		}

		float diffuse = dot(estimateNormal(pos), normalize(lightVec));
		diffuse *= (diffuse + 0.2) * 3.f * scale;
		float noLine = 1.f;
		if (beakCol) {
			diffuse = 1.f - diffuse;
		}
		if (diffuse < 0.5) {
			noLine = 0.f;
		}

		if (shade) {
			color = vec3(0.2f, 0.2f, 0.2f);
			noLine = 1.f;
		}

		out_Col = vec4(color * noLine, 1.0);
	} else {
		out_Col = vec4(vec3(1.f, 1.f, 1.f), 1.f);
	}



}
