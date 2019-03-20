package assimp.format;

/**
 * Created by elect on 13/11/2016.
 */

// -------------------------------------------------------------------------------
/**
 * A node in the imported hierarchy.
 *
 * Each node has name, a parent node (except for the root node), a transformation relative to its parent and possibly
 * several child nodes.
 * Simple file formats don't support hierarchical structures - for these formats the imported scene does consist of only
 * a single root node without children. */
// -------------------------------------------------------------------------------

import assimp.format.Material.AiTexture;
import assimp.format.Defs.AiMatrix4x4;
import assimp.format.MetaData.AiMetadata;
import assimp.format.Mesh.AiMesh;
import assimp.format.Camera.AiCamera;
import assimp.format.Light.AiLight;
import haxe.ds.StringMap;
import assimp.format.Anim.AiAnimation;
import assimp.format.Material.AiMaterial;
import assimp.format.Mesh.AiMesh;
import assimp.format.MetaData.AiMetadata;
import assimp.format.Defs.AiMatrix4x4;
class Scene {

// -------------------------------------------------------------------------------
/**
 * Specifies that the scene data structure that was imported is not complete.
 * This flag bypasses some internal validations and allows the import of animation skeletons, material libraries or
 * camera animation paths using Assimp. Most applications won't support such data. */
    public static var AI_SCENE_FLAGS_INCOMPLETE = 0x1;

/**
 * This flag is set by the validation postprocess-step (aiPostProcess_ValidateDS) if the validation is successful. In a
 * validated scene you can be sure that any cross references in the data structure (e.g. vertex indices) are valid. */
    public static var AI_SCENE_FLAGS_VALIDATED = 0x2;

/**
 * This flag is set by the validation postprocess-step (aiPostProcess_ValidateDS) if the validation is successful but
 * some issues have been found.
 * This can for example mean that a texture that does not exist is referenced by a material or that the bone weights for
 * a vertex don't sum to 1.0 ... .
 * In most cases you should still be able to use the import. This flag could be useful for applications which don't
 * capture Assimp's log output. */
    public static var AI_SCENE_FLAGS_VALIDATION_WARNING = 0x4;

/**
 * This flag is currently only set by the aiProcess_JoinIdenticalVertices step.
 * It indicates that the vertices of the output meshes aren't in the internal verbose format anymore. In the verbose
 * format all vertices are unique, no vertex is ever referenced by more than one face. */
    public static var AI_SCENE_FLAGS_NON_VERBOSE_FORMAT = 0x8;

/**
 * Denotes pure height-map terrain data. Pure terrains usually consist of quads, sometimes triangles, in a regular grid.
 * The x,y coordinates of all vertex positions refer to the x,y coordinates on the terrain height map, the z-axis stores
 * the elevation at a specific point.
 *
 * TER (Terragen) and HMP (3D Game Studio) are height map formats.
 * @note Assimp is probably not the best choice for loading *huge* terrains - fully triangulated data takes extremely
 * much free store and should be avoided as long as possible (typically you'll do the triangulation when you actually
 * need to render it). */
    public static var AI_SCENE_FLAGS_TERRAIN = 0x10;

/**
 * Specifies that the scene data can be shared between structures. For example: one vertex in few faces.
 * \ref AI_SCENE_FLAGS_NON_VERBOSE_FORMAT can not be used for this because \ref AI_SCENE_FLAGS_NON_VERBOSE_FORMAT has
 * internal meaning about postprocessing steps. */
    public static var AI_SCENE_FLAGS_ALLOW_SHARED = 0x20;
}
class AiNode {

    /** The name of the node.
         *
         * The name might be empty (length of zero) but all nodes which need to be referenced by either bones or
         * animations are named.
         * Multiple nodes may have the same name, except for nodes which are referenced by bones (see #aiBone and
         * #aiMesh::bones). Their names *must* be unique.
         *
         * Cameras and lights reference a specific node by name - if there are multiple nodes with this name, they are
         * assigned to each of them.
         * <br>
         * There are no limitations with regard to the characters contained in the name string as it is usually taken
         * directly from the source file.
         *
         * Implementations should be able to handle tokens such as whitespace, tabs, line feeds, quotation marks,
         * ampersands etc.
         *
         * Sometimes old introduces new nodes not present in the source file into the hierarchy (usually out of
         * necessity because sometimes the source hierarchy format is simply not compatible). Their names are surrounded
         * by @verbatim <> @endverbatim e.g.
         *  @verbatim<DummyRootNode> @endverbatim.         */
    public var name:String;

    /** The transformation relative to the node's parent. */
    public var transformation:AiMatrix4x4;// = AiMatrix4x4(),

    /** Parent node. NULL if this node is the root node. */
    public var parent:Null<AiNode>;// = null,

    /** The number of child nodes of this node. */
    public var numChildren:Int ;//= 0,

    /** The child nodes of this node. NULL if numChildren is 0. */
    public var children:Array<AiNode>;// = mutableListOf(),

    /** The number of meshes of this node. */
    public var numMeshes:Int;// = 0,

    /** The meshes of this node. Each entry is an index into the mesh list of the #aiScene.     */
    public var meshes:Array<Int>;// = intArrayOf(),

    /** Metadata associated with this node or empty if there is no metadata.
         *  Whether any metadata is generated depends on the source file format. See the @link importer_notes
         *  @endlink page for more information on every source file format. Importers that don't document any metadata
         *  don't write any.         */
    public var metaData:AiMetadata;// = AiMetadata()


    public function new() {
        name = "";
        transformation = new AiMatrix4x4();
        parent = null;
        numChildren = 0;
        children = [];
        numMeshes = 0;
        meshes = [];
        metaData = new AiMetadata();
    }

    public function findNode(name:String):Null<AiNode> {
        if (this.name == name) return this;
        var tmp = children.filter(function(it)return it.findNode(name) != null);
        if (tmp.length > 0)return tmp[0];
        return null;
    }

}


// -------------------------------------------------------------------------------
/** The root structure of the imported data.
 *
 *  Everything that was imported from the given file can be accessed from here.
 *  Objects of this class are generally maintained and owned by Assimp, not by the caller. You shouldn't want to
 *  instance it, nor should you ever try to delete a given scene on your own. */
// -------------------------------------------------------------------------------

class AiScene {

    /** Any combination of the AI_SCENE_FLAGS_XXX flags. By default this value is 0, no flags are set. Most
     * applications will want to reject all scenes with the AI_SCENE_FLAGS_INCOMPLETE bit set.         */
    public var flags:Int;// = 0

    /** The root node of the hierarchy.
     *
     * There will always be at least the root node if the import was successful (and no special flags have been set).
     * Presence of further nodes depends on the format and content of the imported file.         */
    public var rootNode:AiNode;//

    /** The number of meshes in the scene. */
    public var numMeshes:Int ;//= 0       // TODO shouldn't this just be a getter for `meshes.size`?, same for materials, lights, etc

    /** The array of meshes.
     *
     * Use the indices given in the aiNode structure to access this array. The array is numMeshes in size. If the
     * AI_SCENE_FLAGS_INCOMPLETE flag is not set there will always be at least ONE material.         */
    public var meshes:Array<AiMesh>;// = ArrayList()

    /** The number of materials in the scene. */
    public var numMaterials:Int ;//= 0

    /** The array of materials.
     *
     * Use the index given in each aiMesh structure to access this array. The array is numMaterials in size. If the
     * AI_SCENE_FLAGS_INCOMPLETE flag is not set there will always be at least ONE material.         */
    public var materials:Array<AiMaterial>;// = ArrayList()

    /** The number of animations in the scene. */
    public var numAnimations:Int ;// 0

    /** The array of animations.
     *
     * All animations imported from the given file are listed here.
     * The array is numAnimations in size.         */
    public var animations:Array<AiAnimation>;// = ArrayList()

    /** The number of textures embedded into the file */
    public var numTextures:Int;//= 0

    /** JVM ASSIMP CUSTOM, the array of the textures used in the scene.
     *
     * Not many file formats embed their textures into the file.
     * An example is Quake's MDL format (which is also used by some GameStudio versions)
     */
    public var textures:Array<AiTexture> ;//= mutableMapOf<String, gli_.Texture>()     // The index is the file name

    /** The number of light sources in the scene. Light sources are fully optional, in most cases this attribute
     * will be 0         */
    public var numLights:Int;//= 0

    /** The array of light sources.
     *
     * All light sources imported from the given file are listed here. The array is numLights in size.         */
    public var lights:Array<AiLight> ;//= ArrayList()

    /** The number of cameras in the scene. Cameras are fully optional, in most cases this attribute will be 0         */
    public var numCameras:Int;//= 0

    /** The array of cameras.
     *
     * All cameras imported from the given file are listed here.
     * The array is numCameras in size. The first camera in the array (if existing) is the default camera view into
     * the scene.         */
    public var cameras:Array<AiCamera>;// = ArrayList()

    /** The global metadata assigned to the scene itself.
     *
     *  This data contains global metadata which belongs to the scene like unit-conversions, versions, vendors or
     *  other model-specific data. This can be used to store format-specific metadata as well.     */
    public var metaData:AiMetadata;//

    public function new() {
        flags = 0;
        rootNode = new AiNode();
        numMeshes = 0 ;
        meshes = [];
        numMaterials = 0;
        materials = [];
        numAnimations = 0;
        animations = [];
        numTextures = 0;
        textures = [] ;// The index is the file name
        numLights = 0;
        lights = [];
        numCameras = 0;
        cameras = [];
        metaData = new AiMetadata();
    }
    /** Check whether the scene contains meshes
     *  Unless no special scene flags are set this will always be true. */
    public function hasMeshes() {
        return !Lambda.empty(meshes);
    }

    /** Check whether the scene contains materials
     *  Unless no special scene flags are set this will always be true. */
    public function hasMaterials() {
        return !Lambda.empty(materials);
    }

    /** Check whether the scene contains lights */
    public function hasLights() {
        return !Lambda.empty(lights);
    }

    /** Check whether the scene contains textures   */
    public function hasTextures() {
        return !Lambda.empty(textures);
    }

    /** Check whether the scene contains cameras    */
    public function hasCameras() {
        return !Lambda.empty(cameras);
    }

    /** Check whether the scene contains animations */
    public function hasAnimations() {
        return !Lambda.empty(animations);
    }

}
