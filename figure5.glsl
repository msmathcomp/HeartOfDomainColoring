// =======================================================================
//  Domain coloring Shader implementing Figure 5 from the paper:
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
    
    // Remain at 0 for one kth of the quarter circle
    if (modTime < (1. / K) * (PI / 2.)) {
        t = PI / 4.;
        
    // Run through the rest of the quarter circle correspondingly faster
    } else if (modTime < PI / 2.) {
        t = (PI / 4.) + ((K / (K-1.)) * (modTime - PI / (2. * K)));
        
    // Remain at PI / 2. for one kth of the quarter circle
    } else if (modTime < (PI / 2.) + (1. / K) * (PI / 2.)) {
        t = (PI / 4.) + (PI / 2.);
        
    // Run through the rest of the quarter circle correspondingly faster
    } else  if (modTime < PI) {
        t = (PI / 2.) + (PI / 4.) + ((K / (K-1.)) * (modTime - (PI / 2.) - PI / (2. * K)));
        
    // Remain at PI for one kth of the quarter circle
    } else if (modTime < PI + (1. / K) * (PI / 2.)) {
        t = (PI / 4.) + (PI);
        
    // Run through the rest of the quarter circle correspondingly faster
    } else if (modTime < 3. * PI / 2.) {
        t = PI + (PI / 4.) + ((K / (K-1.)) * (modTime - PI - PI / (2. * K)));
        
    // Remain at 3 PI / 2 for one kth of the quarter circle
    } else if (modTime < (3. * PI / 2.) + (1. / K) * (PI / 2.)) {
        t = 3. * PI / 2. + PI / 4.;
        
    // Run through the rest of the quarter circle correspondingly faster
    } else if (modTime < 2. * PI) {
        t = (3. * PI / 2.) + (PI / 4.) + ((K / (K-1.)) * (modTime - (3. * PI / 2.) - PI / (2. * K)));
    }
    
    return 
        cdiv(
            cmul(z,z),
            z - (2. * cexp(
                cmul(vec2(t, 0), vec2(0,1))
            ))
        );
}

#define VIEW_RADIUS   4.0

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (2.0 * fragCoord - iResolution.xy) / iResolution.y;
    uv *= VIEW_RADIUS;

    vec2 w = f(uv);
    
    fragColor = vec4(domainColor(w), 1.0);
}
