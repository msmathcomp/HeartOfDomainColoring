// =======================================================================
//  Domain coloring Shader implementing Figure 8 from the paper:
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


// Steer how long the hearts stand still (smaller values
#define K 2.


// The complex function with a rotating pole
vec2 f(vec2 z) {
    //return z;
    float t = 0.;
    float modTime = mod(iTime, 2. * PI);
    
    // Remain at 0 for one kth of the quarter circle.
    if (modTime < (1. / K) * (PI / 2.)) {
          t = 0.;
    // Run through the rest of the quarter circle correspondingly faster.
    } else if (modTime < PI / 2.) {
          t = ((K / (K-1.)) * (modTime - PI / (2. * K)));
    // Remain at PI / 2. for one kth of the quarter circle.
    } else if (modTime < (PI / 2.) + (1. / K) * (PI / 2.)) {
          t = (PI / 2.);
    // Run through the rest of the quarter circle correspondingly faster.
    } else  if (modTime < PI) {
          t = (PI / 2.) + ((K / (K-1.)) * (modTime - (PI / 2.) - PI / (2. * K)));
    // Remain at PI for one kth of the quarter circle
    } else if (modTime < PI + (1. / K) * (PI / 2.)) {
          t = (PI);
    // Run through the rest of the quarter circle correspondingly faster.
    } else if (modTime < 3. * PI / 2.) {
          t = PI + ((K / (K-1.)) * (modTime - PI - PI / (2. * K)));
    // Remain at 3 PI / 2 for one kth of the quarter circle.
    } else if (modTime < (3. * PI / 2.) + (1. / K) * (PI / 2.)) {
          t = 3. * PI / 2.;
    // Run through the rest of the quarter circle correspondingly faster.
    } else if (modTime < 2. * PI) {
        t = (3. * PI / 2.) + ((K / (K-1.)) * (modTime - (3. * PI / 2.) - PI / (2. * K)));
    }
    
    return
        cdiv(
            cmul(cpow(z,vec2(2.,0.)),cmul(z,cexp(cmul(vec2(t,0.),vec2(0.,1.)))) - vec2(1.,0.)),
            cmul(cmul(z,cexp(cmul(vec2(t,0.),vec2(0.,1.)))) - vec2(2.,0),
            cmul(z,cexp(cmul(vec2(t,0.),vec2(0.,1.)))) - vec2(2.,0.))
        );
}

#define VIEW_RADIUS   4.0

void mainImage(out vec4 fragColor, in vec2 fragCoord) {

   int AA = 16; 
   vec3 acc = vec3(0.0);

    // 3x3 subpixel grid centered on the pixel.
    for (int j = 0; j < AA; ++j) {
        for (int i = 0; i < AA; ++i) {

            vec2 offs = (vec2(float(i), float(j)) + 0.5) / float(AA) - 0.5;
            vec2 fc   = fragCoord + offs;
            vec2 uv = (2.0 * fc - iResolution.xy) / iResolution.y;
            uv *= VIEW_RADIUS;
            vec2 w;
            
            w = f(uv);
            
            acc += domainColor(w);
        }
    }

    acc /= float(AA * AA);
    fragColor = vec4(acc, 1.0);
}
