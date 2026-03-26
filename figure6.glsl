// =======================================================================
//  Domain coloring Shader implementing Figure 6 from the paper:
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


// Steer how long the hearts stand still.
#define K 30.


// The complex function with a rotating pole.
vec2 f(vec2 z) {
    //return z;
    float tt = 0.;
    float modTime = mod(iTime, 2. * PI);
    
    // Remain at 0 for one kth of the full circle.
    if (modTime < (1./K)*2.*PI){
        tt = 0.;
    }
    else{
        tt = (K / (K-1.)) * (modTime - (2. * PI / K));
    }
 
    return 

    cdiv(
        cmul(z,cmul(cexp(cmul(vec2(tt,0),vec2(0,1.))),cpow(z,vec2(2.,0)))+vec2(0.,-1.)),
        cmul(cexp(cmul(vec2(tt,0),vec2(0,1.))),cpow(z,vec2(2.,0)) + vec2(0.,0.5))
        );
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {

   int AA = 16; 
   vec3 acc = vec3(0.0);

    // 3x3 subpixel grid centered on the pixel.
    for (int j = 0; j < AA; ++j) {
        for (int i = 0; i < AA; ++i) {

            vec2 offs = (vec2(float(i), float(j)) + 0.5) / float(AA) - 0.5;
            vec2 fc   = fragCoord + offs;
            vec2 uv = (2.0 * fc - iResolution.xy) / iResolution.y;
            vec2 w;
            
            w = f(uv);
            
            acc += domainColor(w);
        }
    }

    acc /= float(AA * AA);
    fragColor = vec4(acc, 1.0);
}
