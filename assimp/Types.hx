package assimp;
class Types {
/**
 * Created by elect on 16/11/2016.
 */

/** Maximum dimension for strings, ASSIMP strings are zero terminated. */
    public static var MAXLEN = 1024;
}


/** Standard return type for some library functions.
 *  Rarely used, and if, mostly in the C API.
 */
@:enum abstract AiReturn(Int) from Int to Int {
    /** Indicates that a function was successful */
    var SUCCESS = (0x0);
    /** Indicates that a function failed */
    var FAILURE = (-0x1);
    /** Indicates that not enough memory was available to perform the requested operation */
    var OUTOFMEMORY = (-0x3);
}

class AiMemoryInfo {
    /** Storage allocated for texture data */
    static var textures = 0;
    /** Storage allocated for material data  */
    static var materials = 0;
    /** Storage allocated for mesh data */
    static var meshes = 0;
    /** Storage allocated for node data */
    static var nodes = 0;
    /** Storage allocated for animation data */
    static var animations = 0;
    /** Storage allocated for camera data */
    static var cameras = 0;
    /** Storage allocated for light data */
    static var lights = 0;
    /** Total storage allocated for the full import. */
    static var total = 0;
}
