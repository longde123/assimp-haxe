package assimp.format;
import assimp.format.Material.AiTextureType;
class AiMatKeys {

    /// <summary>
    /// Material name (String)
    /// </summary>
    static public var NAME_BASE = "?mat.name";

/// <summary>
/// Material name (String)
/// </summary>
    static public var NAME = "?mat.name,0,0";

    /// <summary>
    /// Two sided property (boolean)
    /// </summary>
    static public var TWOSIDED_BASE = "$mat.twosided";

    /// <summary>
    /// Two sided property (boolean)
    /// </summary>
    static public var TWOSIDED = "$mat.twosided,0,0";

    /// <summary>
    /// Shading mode property (ShadingMode)
    /// </summary>
    static public var SHADING_MODEL_BASE = "$mat.shadingm";

    /// <summary>
    /// Shading mode property (ShadingMode)
    /// </summary>
    static public var SHADING_MODEL = "$mat.shadingm,0,0";

    /// <summary>
    /// Enable wireframe property (boolean)
    /// </summary>
    static public var ENABLE_WIREFRAME_BASE = "$mat.wireframe";

    /// <summary>
    /// Enable wireframe property (boolean)
    /// </summary>
    static public var ENABLE_WIREFRAME = "$mat.wireframe,0,0";

    /// <summary>
    /// Blending function (BlendMode)
    /// </summary>
    static public var BLEND_FUNC_BASE = "$mat.blend";

    /// <summary>
    /// Blending function (BlendMode)
    /// </summary>
    static public var BLEND_FUNC = "$mat.blend,0,0";

    /// <summary>
    /// Opacity (float)
    /// </summary>
    static public var OPACITY_BASE = "$mat.opacity";

    /// <summary>
    /// Opacity (float)
    /// </summary>
    static public var OPACITY = "$mat.opacity,0,0";

    /// <summary>
    /// Bumpscaling (float)
    /// </summary>
    static public var BUMPSCALING_BASE = "$mat.bumpscaling";

    /// <summary>
    /// Bumpscaling (float)
    /// </summary>
    static public var BUMPSCALING = "$mat.bumpscaling,0,0";

    /// <summary>
    /// Shininess (float)
    /// </summary>
    static public var SHININESS_BASE = "$mat.shininess";

    /// <summary>
    /// Shininess (float)
    /// </summary>
    static public var SHININESS = "$mat.shininess,0,0";

    /// <summary>
    /// Reflectivity (float)
    /// </summary>
    static public var REFLECTIVITY_BASE = "$mat.reflectivity";

    /// <summary>
    /// Reflectivity (float)
    /// </summary>
    static public var REFLECTIVITY = "$mat.reflectivity,0,0";

    /// <summary>
    /// Shininess strength (float)
    /// </summary>
    static public var SHININESS_STRENGTH_BASE = "$mat.shinpercent";

    /// <summary>
    /// Shininess strength (float)
    /// </summary>
    static public var SHININESS_STRENGTH = "$mat.shinpercent,0,0";

    /// <summary>
    /// Refracti (float)
    /// </summary>
    static public var REFRACTI_BASE = "$mat.refracti";

    /// <summary>
    /// Refracti (float)
    /// </summary>
    static public var REFRACTI = "$mat.refracti,0,0";

    /// <summary>
    /// Diffuse color (Color4D)
    /// </summary>
    static public var COLOR_DIFFUSE_BASE = "$clr.diffuse";

    /// <summary>
    /// Diffuse color (Color4D)
    /// </summary>
    static public var COLOR_DIFFUSE = "$clr.diffuse,0,0";

    /// <summary>
    /// Ambient color (Color4D)
    /// </summary>
    static public var COLOR_AMBIENT_BASE = "$clr.ambient";

    /// <summary>
    /// Ambient color (Color4D)
    /// </summary>
    static public var COLOR_AMBIENT = "$clr.ambient,0,0";

    /// <summary>
    /// Specular color (Color4D)
    /// </summary>
    static public var COLOR_SPECULAR_BASE = "$clr.specular";

    /// <summary>
    /// Specular color (Color4D)
    /// </summary>
    static public var COLOR_SPECULAR = "$clr.specular,0,0";

    /// <summary>
    /// Emissive color (Color4D)
    /// </summary>
    static public var COLOR_EMISSIVE_BASE = "$clr.emissive";

    /// <summary>
    /// Emissive color (Color4D)
    /// </summary>
    static public var COLOR_EMISSIVE = "$clr.emissive,0,0";

    /// <summary>
    /// Transparent color (Color4D)
    /// </summary>
    static public var COLOR_TRANSPARENT_BASE = "$clr.transparent";

    /// <summary>
    /// Transparent color (Color4D)
    /// </summary>
    static public var COLOR_TRANSPARENT = "$clr.transparent,0,0";

    /// <summary>
    /// Reflective color (Color4D)
    /// </summary>
    static public var COLOR_REFLECTIVE_BASE = "$clr.reflective";

    /// <summary>
    /// Reflective color (Color4D)
    /// </summary>
    static public var COLOR_REFLECTIVE = "$clr.reflective,0,0";

    /// <summary>
    /// Background image (String)
    /// </summary>
    static public var GLOBAL_BACKGROUND_IMAGE_BASE = "?bg.global";

    /// <summary>
    /// Background image (String)
    /// </summary>
    static public var GLOBAL_BACKGROUND_IMAGE = "?bg.global,0,0";

    /// <summary>
    /// Texture base name
    /// </summary>
    static public var TEXTURE_BASE = "$tex.file";

    /// <summary>
    /// UVWSRC base name
    /// </summary>
    static public var UVWSRC_BASE = "$tex.uvwsrc";

    /// <summary>
    /// Texture op base name
    /// </summary>
    static public var TEXOP_BASE = "$tex.op";

    /// <summary>
    /// Mapping base name
    /// </summary>
    static public var MAPPING_BASE = "$tex.mapping";

    /// <summary>
    /// Texture blend base name.
    /// </summary>
    static public var TEXBLEND_BASE = "$tex.blend";

    /// <summary>
    /// Mapping mode U base name
    /// </summary>
    static public var MAPPINGMODE_U_BASE = "$tex.mapmodeu";

    /// <summary>
    /// Mapping mode V base name
    /// </summary>
    static public var MAPPINGMODE_V_BASE = "$tex.mapmodev";

    /// <summary>
    /// Texture map axis base name
    /// </summary>
    static public var TEXMAP_AXIS_BASE = "$tex.mapaxis";

    /// <summary>
    /// UV transform base name
    /// </summary>
    static public var UVTRANSFORM_BASE = "$tex.uvtrafo";

    /// <summary>
    /// Texture flags base name
    /// </summary>
    static public var TEXFLAGS_BASE = "$tex.flags";

    /// <summary>
    /// Helper function to get the fully qualified name of a texture property type name. Takes
    /// in a base name constant, a texture type, and a texture index and outputs the name in the format:
    /// <para>"baseName,TextureType,texIndex"</para>
    /// </summary>
    /// <param name="baseName">Base name</param>
    /// <param name="texType">Texture type</param>
    /// <param name="texIndex">Texture index</param>
    /// <returns>Fully qualified texture name</returns>
    public static function getFullTextureName(baseName:String, texType:AiTextureType, texIndex:Int) {
        return "{$baseName},{$texType},{$texIndex}" ;
    }

    /// <summary>
    /// Helper function to get the base name from a fully qualified name of a material property type name. The format
    /// of such a string is:
    /// <para>"baseName,TextureType,texIndex"</para>
    /// </summary>
    /// <param name="fullyQualifiedName">Fully qualified material property name.</param>
    /// <returns>Base name of the property type.</returns>
    public static function getBaseName(fullyQualifiedName:String) {
        if (fullyQualifiedName == null)
            return "";

        var substrings = fullyQualifiedName.split(',');
        if (substrings != null && substrings.length == 3)
            return substrings[0];

        return "";
    }

    public function new() {
    }
}
class AiPbrmaterial{
    static public var GLTF_PBRMETALLICROUGHNESS_BASE_COLOR_FACTOR= "$mat.gltf.pbrMetallicRoughness.baseColorFactor, 0, 0";
    static public var GLTF_PBRMETALLICROUGHNESS_METALLIC_FACTOR ="$mat.gltf.pbrMetallicRoughness.metallicFactor, 0, 0";
    static public var GLTF_PBRMETALLICROUGHNESS_ROUGHNESS_FACTOR= "$mat.gltf.pbrMetallicRoughness.roughnessFactor, 0, 0";
    static public var GLTF_PBRMETALLICROUGHNESS_BASE_COLOR_TEXTURE = AiTextureType.diffuse;//+", 1";
    static public var GLTF_PBRMETALLICROUGHNESS_METALLICROUGHNESS_TEXTURE= AiTextureType.unknown;//+", 0";
    static public var GLTF_ALPHAMODE ="$mat.gltf.alphaMode, 0, 0";
    static public var GLTF_ALPHACUTOFF ="$mat.gltf.alphaCutoff, 0, 0";
    static public var GLTF_PBRSPECULARGLOSSINESS= "$mat.gltf.pbrSpecularGlossiness, 0, 0";
    static public var GLTF_PBRSPECULARGLOSSINESS_GLOSSINESS_FACTOR= "$mat.gltf.pbrMetallicRoughness.glossinessFactor, 0, 0";
    static public var GLTF_UNLIT ="$mat.gltf.unlit, 0, 0";
    static public var _GLTF_TEXTURE_TEXCOORD_BASE= "$tex.file.texCoord";
    static public var _GLTF_MAPPINGNAME_BASE ="$tex.mappingname";
    static public var _GLTF_MAPPINGID_BASE ="$tex.mappingid";
    static public var _GLTF_MAPPINGFILTER_MAG_BASE ="$tex.mappingfiltermag";
    static public var _GLTF_MAPPINGFILTER_MIN_BASE ="$tex.mappingfiltermin";
    static public var _GLTF_SCALE_BASE= "$tex.scale";
    static public var _GLTF_STRENGTH_BASE ="$tex.strength";

    static public var GLTF_TEXTURE_TEXCOORD= _GLTF_TEXTURE_TEXCOORD_BASE;
    static public var GLTF_MAPPINGNAME= _GLTF_MAPPINGNAME_BASE ;
    static public var GLTF_MAPPINGID= _GLTF_MAPPINGID_BASE ;
    static public var GLTF_MAPPINGFILTER_MAG= _GLTF_MAPPINGFILTER_MAG_BASE;
    static public var GLTF_MAPPINGFILTER_MIN=_GLTF_MAPPINGFILTER_MIN_BASE;
    static public var GLTF_TEXTURE_SCALE = _GLTF_SCALE_BASE;
    static public var GLTF_TEXTURE_STRENGTH= _GLTF_STRENGTH_BASE;
}