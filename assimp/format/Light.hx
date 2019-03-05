package assimp.format;

/**
 * Created by elect on 29/01/2017.
 */

// ---------------------------------------------------------------------------
/** Enumerates all supported types of light sources.
 */

import assimp.format.Defs.AiColor3D;
import assimp.format.Defs.AiVector3D;
import assimp.format.Defs.AiColor3D;
import assimp.format.Defs.AiVector2D;
@:enum abstract AiLightSourceType(Int) from Int to Int {
    var UNDEFINED = (0x0);

    //! A directional light source has a well-defined direction
    //! but is infinitely far away. That's quite a good
    //! approximation for sun light.
    var DIRECTIONAL = (0x1);

    //! A point light source has a well-defined position
    //! in space but no direction - it emits light in all
    //! directions. A normal bulb is a point light.
    var POINT = (0x2);

    //! A spot light source emits light in a specific
    //! angle. It has a position and a direction it is pointing to.
    //! A good example for a spot light is a light spot in
    //! sport arenas.
    var SPOT = (0x3);

    //! The generic light level of the world, including the bounces
    //! of all other light sources.
    //! Typically, there's at most one ambient light in a scene.
    //! This light type doesn't have a valid position, direction, or
    //! other properties, just a color.
    var AMBIENT = (0x4);

    //! An area light is a rectangle with predefined size that uniformly
    //! emits light from one of its sides. The position is center of the
    //! rectangle and direction is its normal vector.
    var AREA = (0x5);

}

// ---------------------------------------------------------------------------
/** Helper structure to describe a light source.
 *
 *  Assimp supports multiple sorts of light sources, including
 *  directional, point and spot lights. All of them are defined with just
 *  a single structure and distinguished by their parameters.
 *  Note - some file formats (such as 3DS, ASE) export a "target point" -
 *  the point a spot light is looking at (it can even be animated). Assimp
 *  writes the target point as a subnode of a spotlights's main node,
 *  called "<spotName>.Target". However, this is just additional information
 *  then, the transformation tracks of the main node make the
 *  spot light already point in the right direction.
 */
class AiLight {

/** The name of the light source.
         *
         *  There must be a node in the scenegraph with the same name.
         *  This node specifies the position of the light in the scene
         *  hierarchy and can be animated.
         */
    public var name:String ;

    /** The type of the light source.
         *
         * aiLightSource_UNDEFINED is not a valid value for this member.
         */
    public var type:AiLightSourceType ;

    /** Position of the light source in space. Relative to the
         *  transformation of the node corresponding to the light.
         *
         *  The position is undefined for directional lights.
         */
    public var position:AiVector3D ;

    /** Direction of the light source in space. Relative to the
         *  transformation of the node corresponding to the light.
         *
         *  The direction is undefined for point lights. The vector
         *  may be normalized, but it needn't.
         */
    public var direction:AiVector3D ;

    /** Up direction of the light source in space. Relative to the
         *  transformation of the node corresponding to the light.
         *
         *  The direction is undefined for point lights. The vector
         *  may be normalized, but it needn't.
         */
    public var up:AiVector3D ;

    /** Constant light attenuation factor.
         *
         *  The intensity of the light source at a given distance 'd' from
         *  the light's position is
         *  @code
         *  Atten = 1/( att0 + att1 * d + att2 * d*d)
         *  @endcode
         *  This member corresponds to the att0 variable in the equation.
         *  Naturally undefined for directional lights.
         */
    public var attenuationConstant:Float ;

    /** Linear light attenuation factor.
         *
         *  The intensity of the light source at a given distance 'd' from
         *  the light's position is
         *  @code
         *  Atten = 1/( att0 + att1 * d + att2 * d*d)
         *  @endcode
         *  This member corresponds to the att1 variable in the equation.
         *  Naturally undefined for directional lights.
         */
    public var attenuationLinear:Float ;

    /** Quadratic light attenuation factor.
         *
         *  The intensity of the light source at a given distance 'd' from
         *  the light's position is
         *  @code
         *  Atten = 1/( att0 + att1 * d + att2 * d*d)
         *  @endcode
         *  This member corresponds to the att2 variable in the equation.
         *  Naturally undefined for directional lights.
         */
    public var attenuationQuadratic:Float ;

    /** Diffuse color of the light source
         *
         *  The diffuse light color is multiplied with the diffuse
         *  material color to obtain the final color that contributes
         *  to the diffuse shading term.
         */
    public var colorDiffuse:AiColor3D ;

    /** Specular color of the light source
         *
         *  The specular light color is multiplied with the specular
         *  material color to obtain the final color that contributes
         *  to the specular shading term.
         */
    public var colorSpecular:AiColor3D ;

    /** Ambient color of the light source
         *
         *  The ambient light color is multiplied with the ambient
         *  material color to obtain the final color that contributes
         *  to the ambient shading term. Most renderers will ignore
         *  this value it, is just a remaining of the fixed-function pipeline
         *  that is still supported by quite many file formats.
         */
    public var colorAmbient:AiColor3D ;

    /** Inner angle of a spot light's light cone.
         *
         *  The spot light has maximum influence on objects inside this
         *  angle. The angle is given in radians. It is 2PI for point
         *  lights and undefined for directional lights.
         */
    public var angleInnerCone:Float ;

    /** Outer angle of a spot light's light cone.
         *
         *  The spot light does not affect objects outside this angle.
         *  The angle is given in radians. It is 2PI for point lights and
         *  undefined for directional lights. The outer angle must be
         *  greater than or equal to the inner angle.
         *  It is assumed that the application uses a smooth
         *  interpolation between the inner and the outer cone of the
         *  spot light.
         */
    public var angleOuterCone:Float ;

    /** Size of area light source. */
    public var size:AiVector2D ;

    public function new() {
        this.name = "";
        this.type = AiLightSourceType.UNDEFINED;
        this.position = new AiVector3D();
        this.direction = new AiVector3D();
        this.up = new AiVector3D();
        this.attenuationConstant = 0;
        this.attenuationLinear = 1;
        this.attenuationQuadratic = 0;
        this.colorDiffuse = new AiColor3D();
        this.colorSpecular = new AiColor3D();
        this.colorAmbient = new AiColor3D();
        this.angleInnerCone = Defs.AI_MATH_TWO_PIf;
        this.angleOuterCone = Defs.AI_MATH_TWO_PIf;
        this.size = new AiVector2D();
    }
}