package assimp;
class Assimp {

    static public var DEBUG = true;

    static public var BLENDER_DEBUG = false;

    static public var BLENDER_NO_STATS = false;
    static public var NO = new No();
    static public var PROCESS = new Process();

    public function new() {
    }
}

class Process {
    public function new() {

    }

    public var MAKELEFTHANDED:Bool;
    public var FLIPUVS:Bool;
    public var FLIPWINDINGORDER:Bool;
    public var REMOVEVC:Bool;
    public var REMOVE_REDUNDANTMATERIALS:Bool;
    public var EMBEDTEXTURES:Bool;
    public var FINDINSTANCES:Bool;
    public var OPTIMIZEGRAPH:Bool;
    public var FINDDEGENERATES:Bool;
    public var GENUVCOORDS:Bool;
    public var TRANSFORMTEXCOORDS:Bool;
    public var PRETRANSFORMVERTICES:Bool;
    public var TRIANGULATE:Bool;
    public var SORTBYPTYPE:Bool;
    public var FINDINVALIDDATA:Bool;
    public var OPTIMIZEMESHES:Bool;
    public var FIXINFACINGNORMALS:Bool;
    public var SPLITBYBONECOUNT:Bool;
    public var SPLITLARGEMESHES:Bool;
    public var GENFACENORMALS:Bool;
}

class No {
    public function new() {
        VALIDATEDS_PROCESS = true;

    }
    public var VALIDATEDS_PROCESS:Bool;

    public var X_IMPORTER:Bool;
    public var OBJ_IMPORTER:Bool;
    public var AMF_IMPORTER:Bool;
    public var _3DS_IMPORTER:Bool;
    public var MD3_IMPORTER:Bool;
    public var MD2_IMPORTER:Bool;
    public var PLY_IMPORTER:Bool;
    public var MDL_IMPORTER:Bool;
    public var ASE_IMPORTER:Bool;
    public var HMP_IMPORTER:Bool;
    public var SMD_IMPORTER:Bool;
    public var MDC_IMPORTER:Bool;
    public var MD5_IMPORTER:Bool;
    public var STL_IMPORTER:Bool;
    public var LWO_IMPORTER:Bool;
    public var DXF_IMPORTER:Bool;
    public var NFF_IMPORTER:Bool;
    public var RAW_IMPORTER:Bool;
    public var SIB_IMPORTER:Bool;
    public var OFF_IMPORTER:Bool;
    public var AC_IMPORTER:Bool;
    public var BVH_IMPORTER:Bool;
    public var IRRMESH_IMPORTER:Bool;
    public var IRR_IMPORTER:Bool;
    public var Q3D_IMPORTER:Bool;
    public var B3D_IMPORTER:Bool;
    public var COLLADA_IMPORTER:Bool;
    public var TERRAGEN_IMPORTER:Bool;
    public var CSM_IMPORTER:Bool;
    public var _3D_IMPORTER:Bool;
    public var LWS_IMPORTER:Bool;
    public var OGRE_IMPORTER:Bool;
    public var OPENGEX_IMPORTER:Bool;
    public var MS3D_IMPORTER:Bool;
    public var COB_IMPORTER:Bool;
    public var BLEND_IMPORTER:Bool;
    public var Q3BSP_IMPORTER:Bool;
    public var NDO_IMPORTER:Bool;
    public var IFC_IMPORTER:Bool;
    public var XGL_IMPORTER:Bool;
    public var FBX_IMPORTER:Bool;
    public var ASSBIN_IMPORTER:Bool;
    public var GLTF_IMPORTER:Bool;
    public var C4D_IMPORTER:Bool;
    public var _3MF_IMPORTER:Bool;
    public var X3D_IMPORTER:Bool;

}
