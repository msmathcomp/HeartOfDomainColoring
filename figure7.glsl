// =======================================================================
//  Domain coloring Shader implementing Figure 7
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


// Steer how long the hearts stand still (smaller values
#define K 10.

vec2 f(vec2 z) {
    //return z;
    float t = 0.;
    float modTime = mod(iTime, 2. * PI);
    
    // Remain at 0 for one kth of the full circle.
    if (modTime < (1./K)*PI){
        t = PI/2.;
    }
    else if (modTime < PI){
        t = (K/(K-1.))*modTime - PI/(K-1.) + PI/2.;
    }
    else if (modTime < PI + (1./K)*PI){
        t = 3.*PI/2.;
    }
    else {
        t = (K/(K-1.))*modTime + (K - 5.)*PI/(2.*(K - 1.));
    }
    
    return
            cdiv(
                sqrt(2.)*cmul(cmul(cexp(cmul(vec2(t,0.),vec2(0.,1.))),cpow(z,vec2(2.,0)))-cexp(vec2(0.,-0.6666*PI)),
                cmul(cexp(cmul(vec2(t,0.),vec2(0.,1.))),cpow(z,vec2(2.,0.)))-cexp(vec2(0.,0.6666*PI)))
                ,
                cmul(z,cmul(cexp(cmul(vec2(t,0.),vec2(0.,1.))),cpow(z,vec2(2.,0)))+vec2(1.,0))
            )
        ;
}

#define VIEW_RADIUS 1.5

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
