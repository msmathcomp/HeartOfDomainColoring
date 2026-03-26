//  ======================================================================
//  Domain coloring Shader implementing Figure 9 from the paper:
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
//
//  Thanks to shadertoy user aladin for suggesting the
//  addition of anti-aliasing code to improve the
//  visual output quality.
//  ======================================================================

// First function
// Note that this implements the image from the paper,
// but does not coincide with the function as given in the paper,
// there was a typo in the paper.
vec2 f1(vec2 z) {
    // Scale the image to a specific view radius (and flip it)
    z *= -3.;
    // Compute the actual function
    return cdiv(
        cmul( 
            vec2(0,1), 
            cpow(
                ccos(
                    cmul(
                        vec2(1,-1),
                        z
                    )
                ),
                vec2(2.,0)
            )
        ),
        ccos(
            cmul(
                vec2(1,-1),
                z - vec2(0,-0.28)
            )
        )
    );
}

// Second function
vec2 f2(vec2 z) {
    // Scale the image to a specific view radius
    z *= 2.;
    // Compute the actual function
    return cdiv(
        cmul(
            z,
            cmul(
                z + vec2(0,1),
                z + vec2(0,1)
            )
        ),
        cmul(
            z - vec2(0,1),
            z - vec2(0,1)
        )
    );
}

// Third function
vec2 f3(vec2 z) {
    // Scale the image to a specific view radius
    z *= 4.2;
    // Compute the actual function
    return cdiv(
        cmul(
            vec2(-1.1,1.1),
            cpow(
                csin(
                    cmul(
                        vec2(0,1),
                        z
                    )
                ),
                vec2(2.,0)
            )
        ),
        csin(
            cmul(
                vec2(0,1),
                z
            )
            + vec2(sqrt(2.)/2.,0)
        )
    );
}

// Fourth function
vec2 f4(vec2 z){
    // Scale the image to a specific view radius
    z *= 2.;
    // Compute the actual function
    return cdiv(
        sqrt(2.) * (
            vec2(1.,0) - cmul(vec2(0,1.), cpow(z,vec2(2.,0))) - cpow(z, vec2(4.,0))
        ),
        cmul(
            z,
            vec2(1.,0) - cmul(vec2(0,1.), cpow(z,vec2(2.,0)))
        )
    );
}

// Fifth function
// Note that this implements the image from the paper,
// but does not coincide with the function as given in the paper,
// there was a typo in the paper.
vec2 f5(vec2 z){
    // Scale the image to a specific view radius
    z *= 2.;
    // Compute the actual function
    return cdiv(
        cmul(
            z,
            cmul(
                z + vec2(1.,1.),
                z - vec2(1.,1.)
            )
        ),
        cpow(z,vec2(2.,0)) + vec2(0,0.8)
    );
}

// Sixth function
vec2 f6(vec2 z){
    // Scale the image to a specific view radius
    z *= 1.5;
    // Compute the actual function
    return cdiv(
        cmul(
            vec2(-1.,1.),
            cmul(
                1.5 * cpow(z,vec2(10.,0)) - 2. * cpow(z,vec2(5.0,0)) + vec2(6.,0),
                cpow(z,vec2(5.,0)) - vec2(1.2,0)
            )
        ),
        4. * (
            0.5 * cpow(z,vec2(10.,0)) - 2. * cpow(z,vec2(5.,0)) + vec2(0.7,0)
        )
    );
}

// Seventh function
// Note that this implements the image from the paper,
// but does not coincide with the function as given in the paper,
// there was a typo in the paper.
vec2 f7(vec2 z){
    // Scale the image to a specific view radius
    z *= 2.5;
    // Compute the actual function
    return cdiv(
        cmul(
            cmul(
                vec2(1.,0.3),
                csin(z)
            ),
            cmul(
                csin(z + vec2(0.5,0.5)),
                csin(z - vec2(0.5,0.5))
            )
        ),
        cpow(csin(z),vec2(2.,0)) + vec2(0,0.2)
    );
}

// Eigth function
vec2 f8(vec2 z){
    // Scale the image to a specific view radius
    z *= 2.5;
    // Compute the actual function
    return cdiv(
        sqrt(2.) * (
            vec2(1.,0) - cmul(vec2(0,4.),cpow(csin(z),vec2(2.0,0))) - 16. * cpow(csin(z),vec2(4.0,0))
        ),
        2. * csin(z) - cmul(vec2(0,9.), cpow(csin(z),vec2(3.0,0)))
    );
}

// Ninth function
vec2 f9(vec2 z){
    // Scale the image to a specific view radius
    z *= 3.;
    // Compute the actual function
    return cdiv(
        cmul(
            cpow(z,vec2(2.,0)),
            cmul(
                cpow(vec2(1.,-1.),vec2(2.,0)),
                cmul(z,vec2(1.,-1.)) - vec2(1.,1.)
            )
        ),
        cpow(
            cmul(z,vec2(1.,-1.)) - vec2(2.,2.),
            vec2(2.,0)
        )
    );
}

// =============================================
//  VISUALIZATION (nothing below needs editing)
// =============================================

#define IMAGE_DURATION 2.

void mainImage(out vec4 fragColor, in vec2 fragCoord) {

   int AA = 16; 
   vec3 acc = vec3(0.0);

    // 3x3 subpixel grid centered on the pixel
    for (int j = 0; j < AA; ++j) {
        for (int i = 0; i < AA; ++i) {

            vec2 offs = (vec2(float(i), float(j)) + 0.5) / float(AA) - 0.5; // [-0.5..0.5]
            vec2 fc   = fragCoord + offs;

            vec2 uv = (2.0 * fc - iResolution.xy) / iResolution.y;

            vec2 w;
            float modTime = mod(iTime, 18.);
            if (modTime < IMAGE_DURATION) {
                w = f1(uv);
            } else if (modTime < 2. * IMAGE_DURATION) {
                w = f2(uv);
            } else if (modTime < 3. * IMAGE_DURATION) {
                w = f3(uv);
            } else if (modTime < 4. * IMAGE_DURATION) {
                w = f4(uv);
            } else if (modTime < 5. * IMAGE_DURATION) {
                w = f5(uv);
            } else if (modTime < 6. * IMAGE_DURATION) {
                w = f6(uv);
            } else if (modTime < 7. * IMAGE_DURATION) {
                w = f7(uv);
            } else if (modTime < 8. * IMAGE_DURATION) {
                w = f8(uv);
            } else { // 9 * IMAGE_DURATION
                w = f9(uv);
            }

            acc += domainColor(w);
        }
    }

    acc /= float(AA * AA);
    fragColor = vec4(acc, 1.0);
}
