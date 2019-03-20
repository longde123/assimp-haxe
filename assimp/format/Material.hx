package assimp.format;
import assimp.IOSystem.MemoryIOStream;
import assimp.format.Defs.AiColor4D;
import haxe.io.BytesInput;
import assimp.IOStreamUtil;
import minko.render.WrapMode;
import Lambda;
import Lambda;
import assimp.Types.AiReturn;
import Lambda;
import assimp.format.Defs.AiVector2D;
import assimp.format.Defs.AiVector3D;
import assimp.format.Defs.AiColor3D;
import assimp.format.Defs.AiVector3D;
import assimp.format.Defs.AiColor3D;
import assimp.format.Defs.AiVector2D;
import haxe.io.Bytes;

@:enum abstract PropertyType(Int) from Int to Int
{
    /// <summary>
    /// Array of single-precision (32 bit) floats.
    /// </summary>
    var AiFloat = 0x1;

/// <summary>
/// Property is a string.
/// </summary>
    var AiString = 0x3;

    /// <summary>
    /// Array of 32 bit integers.
    /// </summary>
    var AiInteger = 0x4;

    /// <summary>
    /// Byte buffer where the content is undefined.
    /// </summary>
    var AiBuffer = 0x5;
}
class AiMaterialProperty {
    public var mKey:String;
    public var mSemantic:Int;
    public var mIndex:Int;

    public var mDataLength:Int;
    public var mType:Int;
    public var mData:Bytes;
    public var fullyQualifiedName(get, null):String;

    function get_fullyQualifiedName() {
        return AiMaterial.createFullyQualifiedName(mKey, mSemantic, mIndex);
    }
    /// <returns>Float</returns>
    public function getFloatValue() {
        if (mType == PropertyType.AiFloat || mType == PropertyType.AiInteger)
            return new BytesInput(mData).readFloat();

        return 0;
    }

    public function getStringValue() {
        if (mType != PropertyType.AiString)
            return null;
        var stream = new MemoryIOStream(mData);
        return IOStreamUtil.readAiString(stream);
    }

    public function getIntegerValue() {
        if (mType == PropertyType.AiFloat || mType == PropertyType.AiInteger)
            return new BytesInput(mData).readInt32();

        return 0;
    }

    public function getColor4DValue():AiColor4D {
        if (mType != PropertyType.AiFloat || mData == null)
            return new AiColor4D();

        //We may have a Color that's RGB, so still read it and set alpha to 1.0


        if (mData.length >= 4 * 4) {
            var stream = new MemoryIOStream(mData);
            return IOStreamUtil.readAiColor4D(stream);
        }
        else if (mData.length >= 3 * 4) {
            var stream = new MemoryIOStream(mData);
            var color3D:AiColor3D = IOStreamUtil.readAiColor3D(stream);
            return new AiColor4D(color3D.r, color3D.g, color3D.b, 1.0);
        }

        return new AiColor4D();
    }

    public function new() {

    }
}


class AiTexture {

    /** Width of the texture, in pixels
     *
     * If height is zero the texture is compressed in a format like JPEG. In this case width specifies the size of the memory area pcData is pointing to, in bytes.     */
    public var width:Int;//= 0  // ColladaParser.findFilenameForEffectTexture lies on this to be 0 at start, if you have to change it, check it

    /** Height of the texture, in pixels
     *
     * If this value is zero, pcData points to an compressed texture in any format (e.g. JPEG).      */
    public var height:Int;//= 0

    /** A hint from the loader to make it easier for applications to determine the type of embedded textures.
     *
     * If height != 0 this member is show how data is packed. Hint will consist of two parts: channel order and channel bitness (count of the bits for every color
     * channel). For simple parsing by the viewer it's better to not omit absent color channel and just use 0 for bitness. For example:
     * 1. Image contain RGBA and 8 bit per channel, achFormatHint == "rgba8888";
     * 2. Image contain ARGB and 8 bit per channel, achFormatHint == "argb8888";
     * 3. Image contain RGB and 5 bit for R and B channels and 6 bit for G channel, achFormatHint == "rgba5650";
     * 4. One color image with B channel and 1 bit for it, achFormatHint == "rgba0010";
     * If height == 0 then achFormatHint is set set to '\\0\\0\\0\\0' if the loader has no additional information about the texture file format used OR the file
     * extension of the format without a trailing dot. If there are multiple file extensions for a format, the shortest extension is chosen (JPEG maps to 'jpg',
     * not to 'jpeg').
     * E.g. 'dds\\0', 'pcx\\0', 'jpg\\0'.  All characters are lower-case.
     * The fourth character will always be '\\0'.        */
    public var achFormatHint:String;// = ""// 8 for string + 1 for terminator.

    /** Data of the texture.
     *
     * Points to an array of width * height aiTexel's.
     * The format of the texture data is always ARGB8888 to
     * make the implementation for user of the library as easy
     * as possible. If height = 0 this is a pointer to a memory
     * buffer of size width containing the compressed texture
     * data. Good luck, have fun!
     */
    public var pcData:Null<Bytes>;

    public function new() {

    }
}
// ---------------------------------------------------------------------------
/** @brief Defines how the Nth texture of a specific Type is combined with the result of all previous layers.
     *
     *  Example (left: key, right: value): <br>
     *  @code
     *  DiffColor0     - gray
     *  DiffTextureOp0 - aiTextureOpMultiply
     *  DiffTexture0   - tex1.png
     *  DiffTextureOp0 - aiTextureOpAdd
     *  DiffTexture1   - tex2.png
     *  @endcode
     *  Written as equation, the final diffuse term for a specific pixel would be:
     *  @code
     *  diffFinal = DiffColor0 * sampleTex(DiffTexture0,UV0) + sampleTex(DiffTexture1,UV0) * diffContrib;
     *  @endcode
     *  where 'diffContrib' is the intensity of the incoming light for that pixel.
     */
@:enum abstract Op(Int) from Int to Int {

    /** T = T1 * T2 */
    var multiply = (0x0);

    /** T ( T1 + T2 */
    var add = (0x1);

    /** T ( T1 - T2 */
    var subtract = (0x2);

    /** T ( T1 / T2 */
    var divide = (0x3);

    /** T ( (T1 + T2) - (T1 * T2) */
    var smoothAdd = (0x4);

    /** T ( T1 + (T2-0.5) */
    var signedAdd = (0x5);


}

// ---------------------------------------------------------------------------
/** @brief Defines how UV coordinates outside the [0...1] range are handled.
     *
     *  Commonly referred to as 'wrapping mode'.
     */
@:enum abstract MapMode(Int) from Int to Int {

    /** A texture coordinate u|v is translated to u%1|v%1     */
    var wrap = (0x0);

    /** Texture coordinates outside [0...1]
         *  are clamped to the nearest valid value.     */
    var clamp = (0x1);

    /** If the texture coordinates for a pixel are outside [0...1]
         *  the texture is not applied to that pixel     */
    var decal = (0x3);

    /** A texture coordinate u|v becomes u%1|v%1 if (u-(u%1))%2 is zero and
         *  1-(u%1)|1-(v%1) otherwise     */
    var mirror = (0x2);

}

// ---------------------------------------------------------------------------
/** @brief Defines how the mapping coords for a texture are generated.
     *
     *  Real-time applications typically require full UV coordinates, so the use of the aiProcess_GenUVCoords step is highly
     *  recommended. It generates proper UV channels for non-UV mapped objects, as long as an accurate description how the
     *  mapping should look like (e.g spherical) is given.
     *  See the #AI_MATKEY_MAPPING property for more details.
     */
@:enum abstract Mapping(Int) from Int to Int {

    /** The mapping coordinates are taken from an UV channel.
         *
         *  The #AI_MATKEY_UVWSRC key specifies from which UV channel the texture coordinates are to be taken from
         *  (remember, meshes can have more than one UV channel).
         */
    var uv = (0x0);

    /** Spherical mapping */
    var sphere = (0x1);

    /** Cylindrical mapping */
    var cylinder = (0x2);

    /** Cubic mapping */
    var box = (0x3);

    /** Planar mapping */
    var plane = (0x4);

    /** Undefined mapping. Have fun. */
    var other = (0x5);

}

// ---------------------------------------------------------------------------
/** @brief Defines the purpose of a texture
     *
     *  This is a very difficult topic. Different 3D packages support different kinds of textures. For very common texture
     *  types, such as bumpmaps, the rendering results depend on implementation details in the rendering pipelines of these
     *  applications. Assimp loads all texture references from the model file and tries to determine which of the predefined
     *  texture types below is the best choice to match the original use of the texture as closely as possible.<br>
     *
     *  In content pipelines you'll usually define how textures have to be handled, and the artists working on models have
     *  to conform to this specification, regardless which 3D tool they're using. */
@:enum abstract AiTextureType(Int) from Int to Int {

    /** Dummy value.
         *
         *  No texture, but the value to be used as 'texture semantic' (#aiMaterialProperty::mSemantic) for all material
         *  properties *not* related to textures.     */
    var none = (0x0);


    /** The texture is combined with the result of the diffuse lighting equation.     */
    var diffuse = (0x1);

    /** The texture is combined with the result of the specular lighting equation.     */
    var specular = (0x2);

    /** The texture is combined with the result of the ambient lighting equation.     */
    var ambient = (0x3);

    /** The texture is added to the result of the lighting calculation. It isn't influenced by incoming light.     */
    var emissive = (0x4);

    /** The texture is a height map.
         *
         *  By convention, higher gray-scale values stand for higher elevations from the base height.     */
    var height = (0x5);

    /** The texture is a (tangent space) normal-map.
         *
         *  Again, there are several conventions for tangent-space normal maps. Assimp does (intentionally) not distinguish
         *  here.     */
    var normals = (0x6);

    /** The texture defines the glossiness of the material.
         *
         *  The glossiness is in fact the exponent of the specular (phong) lighting equation. Usually there is a conversion
         *  function defined to map the linear color values in the texture to a suitable exponent. Have fun.     */
    var shininess = (0x7);

    /** The texture defines per-pixel opacity.
         *
         *  Usually 'white' means opaque and 'black' means 'transparency'. Or quite the opposite. Have fun.     */
    var opacity = (0x8);

    /** Displacement texture
         *
         *  The exact purpose and format is application-dependent.
         *  Higher color values stand for higher vertex displacements.     */
    var displacement = (0x9);

    /** Lightmap texture (aka Ambient Occlusion)
         *
         *  Both 'Lightmaps' and dedicated 'ambient occlusion maps' are covered by this material property. The texture
         *  contains a scaling value for the final color value of a pixel. Its intensity is not affected by incoming light.     */
    var lightmap = (0xA);

    /** Reflection texture
         *
         * Contains the color of a perfect mirror reflection.
         * Rarely used, almost never for real-time applications.     */
    var reflection = (0xB);

    /** Unknown texture
         *
         *  A texture reference that does not match any of the definitions above is considered to be 'unknown'. It is still
         *  imported, but is excluded from any further postprocessing.     */
    var unknown = (0xC);
}

// ---------------------------------------------------------------------------
/** @brief Defines some mixed flags for a particular texture.
     *
     *  Usually you'll instruct your cg artists how textures have to look like ... and how they will be processed in your
     *  application. However, if you use Assimp for completely generic loading purposes you might also need to process these
     *  flags in order to display as many 'unknown' 3D models as possible correctly.
     *
     *  This corresponds to the #AI_MATKEY_TEXFLAGS property. */
@:enum abstract Flags(Int) from Int to Int {


    /** The texture's color values have to be inverted (componentwise 1-n)     */
    var invert = (0x1);

    /** Explicit request to the application to process the alpha channel of the texture.
         *
         *  Mutually exclusive with #aiTextureFlags_IgnoreAlpha. These flags are set if the library can say for sure that
         *  the alpha channel is used/is not used. If the model format does not define this, it is left to the application
         *  to decide whether the texture alpha channel - if any - is evaluated or not.     */
    var useAlpha = (0x2);

    /** Explicit request to the application to ignore the alpha channel of the texture.
         *
         *  Mutually exclusive with #aiTextureFlags_UseAlpha.     */
    var ignoreAlpha = (0x4);
}

// ---------------------------------------------------------------------------
/** @brief Defines all shading models supported by the library
 *
 *  The list of shading modes has been taken from Blender.
 *  See Blender documentation for more information. The API does not distinguish between "specular" and "diffuse"
 *  shaders (thus the specular term for diffuse shading models like Oren-Nayar remains undefined). <br>
 *  Again, this value is just a hint. Assimp tries to select the shader whose most common implementation matches the
 *  original rendering results of the 3D modeller which wrote a particular model as closely as possible.     */
@:enum abstract AiShadingMode(Int) from Int to Int {

    /** Flat shading. Shading is done on per-face base, diffuse only. Also known as 'faceted shading'.     */
    var flat = (0x1);

    /** Simple Gouraud shading.     */
    var gouraud = (0x2);

    /** Phong-Shading -     */
    var phong = (0x3);

    /** Phong-Blinn-Shading     */
    var blinn = (0x4);

    /** Toon-Shading per pixel
     *
     *  Also known as 'comic' shader.     */
    var toon = (0x5);

    /** OrenNayar-Shading per pixel
     *
     *  Extension to standard Lambertian shading, taking the roughness of the material into account     */
    var orenNayar = (0x6);

    /** Minnaert-Shading per pixel
     *
     *  Extension to standard Lambertian shading, taking the "darkness" of the material into account     */
    var minnaert = (0x7);

    /** CookTorrance-Shading per pixel
     *
     *  Special shader for metallic surfaces.     */
    var cookTorrance = (0x8);

    /** No shading at all. Constant light influence of 1.0.     */
    var noShading = (0x9);

    /** Fresnel shading     */
    var fresnel = (0xa);

}


// ---------------------------------------------------------------------------
/** @brief Defines alpha-blend flags.
 *
 *  If you're familiar with OpenGL or D3D, these flags aren't new to you.
 *  They define *how* the final color value of a pixel is computed, basing on the previous color at that pixel and the
 *  new color value from the material.
 *  The blend formula is:
 *  @code
 *    SourceColor * SourceBlend + DestColor * DestBlend
 *  @endcode
 *  where DestColor is the previous color in the framebuffer at this position and SourceColor is the material color
 *  before the transparency calculation.<br>
 *  This corresponds to the #AI_MATKEY_BLEND_FUNC property. */

@:enum abstract AiBlendMode(Int) {


    /**
     *  Formula:
     *  @code
     *  SourceColor*SourceAlpha + DestColor*(1-SourceAlpha)
     *  @endcode     */
    var alpha = 0;

    /** Additive blending
     *
     *  Formula:
     *  @code
     *  SourceColor*1 + DestColor*1
     *  @endcode     */
    var additive = 1;


    // we don't need more for the moment, but we might need them in future versions ...
}

// ---------------------------------------------------------------------------
/** @brief Defines how an UV channel is transformed.
 *
 *  This is just a helper structure for the #AI_MATKEY_UVTRANSFORM key.
 *  See its documentation for more details.
 *
 *  Typically you'll want to build a matrix of this information. However, we keep separate scaling/translation/rotation
 *  values to make it easier to process and optimize UV transformations internally.
 */
class AiUVTransform {

/** Translation on the u and v axes.
         *
         *  The default value is (0|0).         */
    public var translation:AiVector2D;// = AiVector2D(),

    /** Scaling on the u and v axes.
         *
         *  The default value is (1|1).         */
    public var scaling:AiVector2D;// = AiVector2D(),

    /** Rotation - in counter-clockwise direction.
         *
         *  The rotation angle is specified in radians. The rotation center is 0.5f|0.5f. The default value 0.f.         */
    public var rotation:Float;// = 0f
    public function new() {
        this.translation = new AiVector2D();
        this.scaling = new AiVector2D();
        this.rotation = 0;
    }
}
class AiString {
    public var data:String;

    public function new():Void {

    }
}

class Color {

    public var diffuse:Null<AiColor3D>;

    public var ambient:Null<AiColor3D>;
    public var specular:Null<AiColor3D>;

    public var emissive:Null<AiColor3D>;

    public var transparent:Null<AiColor3D>;

    public var reflective:Null<AiColor3D>;
    // TODO unsure
    public function new() {

    }
}

class AiMaterialTexture {

    public var type:Null<AiTextureType>;
    public var textureIndex:Int;
    public var file:Null<String>; // HINT this is used as the index to reference textures in AiScene.textures

    public var blend:Null<Float>;

    public var op:Null<Op>;

    public var mapping:Null<Mapping>;

    public var uvwsrc:Null<Int>;

    public var mapModeU:Null<MapMode>;

    public var mapModeV:Null<MapMode>;

    public var mapAxis:Null<AiVector3D>;

    public var flags:Null<Int>;

    public var uvTrafo:Null<AiUVTransform>;

    public function new():Void {

    }

}


class AiMaterial {

/**
 * Created by elect on 17/11/2016.
 */


    public var name:Null<String>;

    public var twoSided:Null<Bool>;

    public var shadingModel:Null<AiShadingMode>;

    public var wireframe:Null<Bool>;

    public var blendFunc:Null<AiBlendMode>;

    public var opacity:Null<Float>;

    public var bumpScaling:Null<Float>;// TODO unsure

    public var shininess:Null<Float>;

    public var reflectivity:Null<Float>; // TODO unsure

    public var shininessStrength:Null<Float>;

    public var refracti:Null<Float>;

    public var color:Null<Color>;

    public var displacementScaling:Null<Float>;

    public var textures:Array< AiMaterialTexture>;
    public var numAllocated:Int;
    public var numProperties:Int;
    public var properties:Array<AiMaterialProperty>;

    public function new() {

    }

    /// <summary>
    /// Helper method to construct a fully qualified name from the input parameters. All the input parameters are combined into the fully qualified name: {baseName},{texType},{texIndex}. E.g.
    /// "$clr.diffuse,0,0" or "$tex.file,1,0". This is the name that is used as the material dictionary key.
    /// </summary>
    /// <param name="baseName">Key basename, this must not be null or empty</param>
    /// <param name="texType">Texture type; non-texture properties should leave this <see cref="TextureType.None"/></param>
    /// <param name="texIndex">Texture index; non-texture properties should leave this zero.</param>
    /// <returns>The fully qualified name</returns>
    public static function createFullyQualifiedName(baseName:String, texType:Int, texIndex:Int) {
        if (null == (baseName))
            return null;

        return baseName+","+texType+","+texIndex ;
    }

    /// <summary>
    /// Gets the non-texture properties contained in this Material. The name should be
    /// the "base name", as in it should not contain texture type/texture index information. E.g. "$clr.diffuse" rather than "$clr.diffuse,0,0". The extra
    /// data will be filled in automatically.
    /// </summary>
    /// <param name="baseName">Key basename</param>
    /// <returns>The material property, if it exists</returns>
    public function getNonTextureProperty(baseName) {
        if (null == (baseName)) {
            return null;
        }
        var fullyQualifiedName = createFullyQualifiedName(baseName, AiTextureType.none, 0);
        return getProperty(fullyQualifiedName);
    }

    /// <summary>
    /// Gets the material property. All the input parameters are combined into the fully qualified name: {baseName},{texType},{texIndex}. E.g.
    /// "$clr.diffuse,0,0" or "$tex.file,1,0".
    /// </summary>
    /// <param name="baseName">Key basename</param>
    /// <param name="texType">Texture type; non-texture properties should leave this <see cref="TextureType.None"/></param>
    /// <param name="texIndex">Texture index; non-texture properties should leave this zero.</param>
    /// <returns>The material property, if it exists</returns>
    public function getMaterialProperty(baseName, texType, texIndex) {
        if (null == (baseName)) {
            return null;
        }
        var fullyQualifiedName = createFullyQualifiedName(baseName, texType, texIndex);
        return getProperty(fullyQualifiedName);
    }

    /// <summary>
    /// Gets the material property by its fully qualified name. The format is: {baseName},{texType},{texIndex}. E.g.
    /// "$clr.diffuse,0,0" or "$tex.file,1,0".
    /// </summary>
    /// <param name="fullyQualifiedName">Fully qualified name of the property</param>
    /// <returns>The material property, if it exists</returns>
    public function getProperty(fullyQualifiedName):AiMaterialProperty {
        if (null == (fullyQualifiedName)) {
            return null;
        }
        return Lambda.find(properties, function(p:AiMaterialProperty)return p.fullyQualifiedName == fullyQualifiedName);
    }

    /// <summary>
    /// Checks if the material has the specified non-texture property. The name should be
    /// the "base name", as in it should not contain texture type/texture index information. E.g. "$clr.diffuse" rather than "$clr.diffuse,0,0". The extra
    /// data will be filled in automatically.
    /// </summary>
    /// <param name="baseName">Key basename</param>
    /// <returns>True if the property exists, false otherwise.</returns>
    public function hasNonTextureProperty(baseName) {
        if (null == (baseName)) {
            return false;
        }
        var fullyQualifiedName = createFullyQualifiedName(baseName, AiTextureType.none, 0);
        return hasProperty(fullyQualifiedName);
    }

    /// <summary>
    /// Checks if the material has the specified property. All the input parameters are combined into the fully qualified name: {baseName},{texType},{texIndex}. E.g.
    /// "$clr.diffuse,0,0" or "$tex.file,1,0".
    /// </summary>
    /// <param name="baseName">Key basename</param>
    /// <param name="texType">Texture type; non-texture properties should leave this <see cref="TextureType.None"/></param>
    /// <param name="texIndex">Texture index; non-texture properties should leave this zero.</param>
    /// <returns>True if the property exists, false otherwise.</returns>
    public function hasMaterialProperty(baseName, texType, texIndex) {
        if (null == (baseName)) {
            return false;
        }

        var fullyQualifiedName = createFullyQualifiedName(baseName, texType, texIndex);
        return hasProperty(fullyQualifiedName);
    }

    /// <summary>
    /// Checks if the material has the specified property by looking up its fully qualified name. The format is: {baseName},{texType},{texIndex}. E.g.
    /// "$clr.diffuse,0,0" or "$tex.file,1,0".
    /// </summary>
    /// <param name="fullyQualifiedName">Fully qualified name of the property</param>
    /// <returns>True if the property exists, false otherwise.</returns>
    public function hasProperty(fullyQualifiedName):Bool {
        if (null == (fullyQualifiedName)) {
            return false;
        }
        return Lambda.exists(properties, function(p:AiMaterialProperty) {
            return p.fullyQualifiedName == fullyQualifiedName;
        });
    }

    /// <summary>
    /// Adds a property to this material.
    /// </summary>
    /// <param name="matProp">Material property</param>
    /// <returns>True if the property was successfully added, false otherwise (e.g. null or key already present).</returns>
    public function addProperty(matProp:AiMaterialProperty) {
        if (matProp == null)
            return false;

        if (hasProperty(matProp.fullyQualifiedName))
            return false;

        properties.push(matProp);

        return true;
    }

    /// <summary>
    /// Removes a non-texture property from the material.
    /// </summary>
    /// <param name="baseName">Property name</param>
    /// <returns>True if the property was removed, false otherwise</returns>
    public function removeNonTextureProperty(baseName) {
        if (null == (baseName))
            return false;

        return removeProperty(createFullyQualifiedName(baseName, AiTextureType.none, 0));
    }

    /// <summary>
    /// Removes a property from the material.
    /// </summary>
    /// <param name="baseName">Name of the property</param>
    /// <param name="texType">Property texture type</param>
    /// <param name="texIndex">Property texture index</param>
    /// <returns>True if the property was removed, false otherwise</returns>
    public function removeMaterialProperty(baseName, texType, texIndex) {
        if (null == (baseName))
            return false;

        return removeProperty(createFullyQualifiedName(baseName, texType, texIndex));
    }

    /// <summary>
    /// Removes a property from the material.
    /// </summary>
    /// <param name="fullyQualifiedName">Fully qualified name of the property ({basename},{texType},{texIndex})</param>
    /// <returns>True if the property was removed, false otherwise</returns>
    public function removeProperty(fullyQualifiedName) {
        if (null == (fullyQualifiedName))
            return false;

        properties = properties.filter(function(p:AiMaterialProperty) return p.fullyQualifiedName != fullyQualifiedName);
        return true;
    }

    /// <summary>
    /// Removes all properties from the material;
    /// </summary>
    public function clear() {
        properties = [];
    }

    /// <summary>
    /// Gets -all- properties contained in the Material.
    /// </summary>
    /// <returns>All properties in the material property map.</returns>
    public function getAllProperties() {


        return properties.copy();
    }

    /// <summary>
    /// Gets all the number of textures that are of the specified texture type.
    /// </summary>
    /// <param name="texType">Texture type</param>
    /// <returns>Texture count</returns>
    public function getMaterialTextureCount(texType) {
        var count = 0;
        for (matProp in properties) {


            if ( matProp.mKey==AiMatKeys.TEXTURE_BASE && matProp.mSemantic == texType) {
                count = Math.floor( Math.max(count,matProp.mIndex+1));
            }
        }

        return count;
    }

    /// <summary>
    /// Gets a texture that corresponds to the type/index.
    /// </summary>
    /// <param name="texType">Texture type</param>
    /// <param name="texIndex">Texture index</param>
    /// <param name="texture">Texture description</param>
    /// <returns>True if the texture was found in the material</returns>
    public function getMaterialTexture(texType, texIndex, texture:AiMaterialTexture) {

        var texName = createFullyQualifiedName(AiMatKeys.TEXTURE_BASE, texType, texIndex);

        var texNameProp = getProperty(texName);

        //This one is necessary, the rest are optional
        if (texNameProp == null)
            return false;

        var mappingName = createFullyQualifiedName(AiMatKeys.MAPPING_BASE, texType, texIndex);
        var uvIndexName = createFullyQualifiedName(AiMatKeys.UVWSRC_BASE, texType, texIndex);
        var blendFactorName = createFullyQualifiedName(AiMatKeys.TEXBLEND_BASE, texType, texIndex);
        var texOpName = createFullyQualifiedName(AiMatKeys.TEXOP_BASE, texType, texIndex);
        var uMapModeName = createFullyQualifiedName(AiMatKeys.MAPPINGMODE_U_BASE, texType, texIndex);
        var vMapModeName = createFullyQualifiedName(AiMatKeys.MAPPINGMODE_V_BASE, texType, texIndex);
        var texFlagsName = createFullyQualifiedName(AiMatKeys.TEXFLAGS_BASE, texType, texIndex);

        var mappingNameProp = getProperty(mappingName);
        var uvIndexNameProp = getProperty(uvIndexName);
        var blendFactorNameProp = getProperty(blendFactorName);
        var texOpNameProp = getProperty(texOpName);
        var uMapModeNameProp = getProperty(uMapModeName);
        var vMapModeNameProp = getProperty(vMapModeName);
        var texFlagsNameProp = getProperty(texFlagsName);

        texture.file = texNameProp.getStringValue();
        texture.type = texType;
        texture.textureIndex = texIndex;
        texture.mapping = (mappingNameProp != null) ? mappingNameProp.getIntegerValue() : Mapping.uv;
        texture.uvwsrc = (uvIndexNameProp != null) ? uvIndexNameProp.getIntegerValue() : 0;
        texture.blend = (blendFactorNameProp != null) ? blendFactorNameProp.getFloatValue() : 0.0 ;
        texture.op = (texOpNameProp != null) ? texOpNameProp.getIntegerValue() : 0;
        texture.mapModeU = (uMapModeNameProp != null) ? uMapModeNameProp.getIntegerValue() : MapMode.wrap;
        texture.mapModeV = (vMapModeNameProp != null) ? vMapModeNameProp.getIntegerValue() : MapMode.wrap;
        texture.flags = (texFlagsNameProp != null) ? texFlagsNameProp.getIntegerValue() : 0;

        return true;
    }

}