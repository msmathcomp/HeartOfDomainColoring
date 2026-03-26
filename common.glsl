// =======================================================================
//  Domain coloring Shader implementing Figure 5--9
//  from the paper:
//  
//  "Heart of Domain Coloring"
//  Ulrich Reitebuch, Henriette Lipschütz, 
//  Konrad Polthier, and Martin Skrodzki
//  Proceedings of Bridges 2024
//  https://archive.bridgesmathart.org/2024/bridges2024-115.html
//
//  The code is based on Steve Trettel's Domain
//  Coloring found here:
//  https://shaders.stevejtrettel.site/ihp-2026/functions/#domain-coloring
// =======================================================================

#define PI 3.14159265359

vec2 cmul(vec2 a, vec2 b) {
    return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x);
}

vec2 cdiv(vec2 a, vec2 b) {
    return vec2(a.x*b.x + a.y*b.y, a.y*b.x - a.x*b.y) / dot(b, b);
}

vec2 csqr(vec2 z) {
    return vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y);
}

vec2 cconj(vec2 z) {
    return vec2(z.x, -z.y);
}

vec2 cexp(vec2 z) {
    return exp(z.x) * vec2(cos(z.y), sin(z.y));
}

vec2 clog(vec2 z) {
    return vec2(log(length(z)), atan(z.y, z.x));
}

vec2 cpow(vec2 z, float n) {
    float r = length(z);
    float theta = atan(z.y, z.x);
    return pow(r, n) * vec2(cos(n*theta), sin(n*theta));
}

vec2 cpow(vec2 z, vec2 w) {
    return cexp(cmul(w, clog(z)));
}

vec2 csin(vec2 z) {
    return vec2(sin(z.x)*cosh(z.y), cos(z.x)*sinh(z.y));
}

vec2 ccos(vec2 z) {
    return vec2(cos(z.x)*cosh(z.y), -sin(z.x)*sinh(z.y));
}

vec2 csqrt(vec2 z) {
    float r = length(z);
    float theta = atan(z.y, z.x);
    return sqrt(r) * vec2(cos(theta/2.0), sin(theta/2.0));
}

vec2 cinv(vec2 z) {
    return cconj(z) / dot(z, z);
}

// Mobius transformation (az+b)/(cz+d)
vec2 mobius(vec2 a, vec2 b, vec2 c, vec2 d, vec2 z) {
    return cdiv(cmul(a, z) + b, cmul(c, z) + d);
}

// =============================================
// COLOR UTILITIES
// =============================================

vec3 colors[20] = vec3[](
    vec3(63,127,191),
    vec3(47,95,207),
    vec3(31,63,223),
    vec3(15,31,232),
    vec3(0,0,191),
    //
    vec3(63,127,255),
    vec3(63,151,223),
    vec3(63,175,191),
    vec3(63,199,159),
    vec3(63,223,127),
    //
    vec3(255,255,0),
    vec3(215,255,0),
    vec3(175,255,0),
    vec3(135,255,0),
    vec3(95,255,0),
    //
    vec3(0,191,95),
    vec3(15,207,103),
    vec3(31,223,111),
    vec3(47,239,119),
    vec3(63,255,127)
);

vec3 domainColor(vec2 z) {
    // Quadrant colors
    vec3 col;
    int colorIndex = int(20. * mod(atan(z.y, z.x), 2. * PI) / (2. * PI) );
    col = colors[colorIndex] / 255.;

    // White integer grid
    vec2 grid = abs(fract(z));
    float lineWidth = 0.05;
    float gridLine = step(min(grid.x, grid.y), lineWidth);
    col = mix(col, vec3(1.0), gridLine * 0.6);

    // Black coordinate axes
    float axisWidth = 0.05;
    float axis = step(min(abs(z.x), abs(z.y)), axisWidth);
    col = mix(col, vec3(0.0), axis);

    return col;
}
