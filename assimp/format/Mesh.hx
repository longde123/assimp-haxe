package assimp.format;

// ---------------------------------------------------------------------------
/** @brief A single face in a mesh, referring to multiple vertices.
 *
 * If mNumIndices is 3, we call the face 'triangle', for mNumIndices > 3
 * it's called 'polygon' (hey, that's just a definition!).
 * <br>
 * aiMesh::primitiveTypes can be queried to quickly examine which types of primitive are actually present in a mesh.
 * The #aiProcess_SortByPType flag executes a special post-processing algorithm which splits meshes with *different*
 * primitive types mixed up (e.g. lines and triangles) in several 'clean' submeshes. Furthermore there is a
 * configuration option ( #AI_CONFIG_PP_SBP_REMOVE) to force #aiProcess_SortByPType to remove specific kinds of
 * primitives from the imported scene, completely and forever.
 * In many cases you'll probably want to set this setting to
 * @code
 * aiPrimitiveType_LINE|aiPrimitiveType_POINT
 * @endcode
 * Together with the #aiProcess_Triangulate flag you can then be sure that #aiFace::mNumIndices is always 3.
 * @note Take a look at the @link data Data Structures page @endlink for more information on the layout and winding
 * order of a face.  */
//data class AiFace(
//        //! Number of indices defining this face.
//        //! The maximum value for this member is #AI_MAX_FACE_INDICES.
//        var mNumIndices: Int = 0,
//
//        //! Pointer to the indices array. Size of the array is given in numIndices.
//        var mIndices: MutableList<Int> = mutableListOf())
import assimp.format.Defs.AiVector3D;
import Lambda;
import Lambda;
import assimp.format.Defs.AiColor4D;
import assimp.format.Defs.AiVector3D;
import assimp.format.Defs.AiMatrix4x4;
class AiFace {
    public var numIndices:Int;
    public var indices:Array<Int>;

    public function new() {

    }
}

class Mesh {

/**
 * Created by elect on 13/11/2016.
 */

// TODO check long/int consts
/** @def AI_MAX_FACE_INDICES
 *  Maximum number of indices per face (polygon). */
    public static var AI_MAX_FACE_INDICES = 0x7fff;

/** @def AI_MAX_BONE_WEIGHTS
 *  Maximum number of indices per face (polygon). */
    public static var AI_MAX_BONE_WEIGHTS = 0x7fffffff;

/** @def AI_MAX_VERTICES
 *  Maximum number of vertices per mesh.  */
    public static var AI_MAX_VERTICES = 0x7fffffff;

/** @def AI_MAX_FACES
 *  Maximum number of faces per mesh. */
    public static var AI_MAX_FACES = 0x7fffffff;

/** @def AI_MAX_NUMBER_OF_COLOR_SETS
 *  Supported number of vertex color sets per mesh. */

    public static var AI_MAX_NUMBER_OF_COLOR_SETS = 0x8;

/** @def AI_MAX_NUMBER_OF_TEXTURECOORDS
 *  Supported number of texture coord sets (UV(W) channels) per mesh */
    public static var AI_MAX_NUMBER_OF_TEXTURECOORDS = 0x8;

    public static function AI_PRIMITIVE_TYPE_FOR_N_INDICES(n:Int) {
        return if (n > 3) AiPrimitiveType.POLYGON else (1 << (n - 1));
    }

    public function new() {
    }
}


// ---------------------------------------------------------------------------
/** @brief A single influence of a bone on a vertex.
 */
class AiVertexWeight {
//! Index of the vertex which is influenced by the bone.
    public var vertexId:Int ;

    //! The strength of the influence in the range (0...1).
    //! The influence from all bones at one vertex amounts to 1.
    public var weight:Float;

    public function new() {
        this.vertexId = 0;
        this.weight = 0;
    }
}

// ---------------------------------------------------------------------------
/** @brief A single bone of a mesh.
 *
 *  A bone has a name by which it can be found in the frame hierarchy and by which it can be addressed by animations.
 *  In addition it has a number of influences on vertices.
 */
class AiBone {
//! The name of the bone.
    public var name:String ;//= "",

    //! The number of vertices affected by this bone
    //! The maximum value for this member is #AI_MAX_BONE_WEIGHTS.
    public var numWeights:Int ;//= 0,

    //! The vertices affected by this bone
    public var weights:Array<AiVertexWeight> ;//= mutableListOf(),

    //! Matrix that transforms from mesh space to bone space in bind pose
    public var offsetMatrix:AiMatrix4x4 ;//= AiMatrix4x4()

    public function new() {
        this.name = "";
        this.numWeights = 0;
        this.weights = new Array<AiVertexWeight>();
        this.offsetMatrix = new AiMatrix4x4();
    }
}

typedef AiPrimitiveTypeMask = Int
/** @brief Enumerates the types of geometric primitives supported by Assimp.
 * 1 1
 *  @see aiFace Face data structure
 *  @see aiProcess_SortByPType Per-primitive sorting of meshes
 *  @see aiProcess_Triangulate Automatic triangulation
 *  @see AI_CONFIG_PP_SBP_REMOVE Removal of specific primitive types.
 */

@:enum abstract AiPrimitiveType(Int) from Int to Int {
    /** A point primitive.
     *
     * This is just a single vertex in the virtual world, #aiFace contains just one index for such a primitive.     */
    var POINT = (0x1);

    /** A line primitive.
     *
     * This is a line defined through a start and an end position.
     * #aiFace contains exactly two indices for such a primitive.     */
    var LINE = (0x2);

    /** A triangular primitive.
     *
     * A triangle consists of three indices.     */
    var TRIANGLE = (0x4);

    /** A higher-level polygon with more than 3 edges.
     *
     * A triangle is a polygon, but polygon in this context means "all polygons that are not triangles". The
     * "Triangulate"-Step is provided for your convenience, it splits all polygons in triangles (which are much easier
     * to handle).     */
    var POLYGON = (0x8);

}

//infix fun AiPrimitiveType.or(other: AiPrimitiveType) = i or other.i
//infix fun Int.or(other: AiPrimitiveType) = or(other.i)  //|
//infix fun Int.wo(other: AiPrimitiveType) = and(other.i.inv())  //&~
//infix fun Int.has(other: AiPrimitiveType) = and(other.i) != 0  // &
//infix fun Int.hasnt(other: AiPrimitiveType) = and(other.i) == 0


class AiAnimMesh {
/** Weight of the AnimMesh. */
    var mWeight:Float ;

}

/** Enumerates the methods of mesh morphing supported by Assimp.    */
@:enum abstract AiMorphingMethod(Int) from Int to Int {
    /** Interpolation between morph targets */
    var VERTEX_BLEND = (0x1);

    /** Normalized morphing between morph targets  */
    var MORPH_NORMALIZED = (0x2);

    /** Relative morphing between morph targets  */
    var MORPH_RELATIVE = (0x3);
}

// ---------------------------------------------------------------------------
/** @brief A mesh represents a geometry or model with a single material.
 *
 * It usually consists of a number of vertices and a series of primitives/faces referencing the vertices. In addition
 * there might be a series of bones, each of them addressing a number of vertices with a certain weight. Vertex data is
 * presented in channels with each channel containing a single per-vertex information such as a set of texture coords or
 * a normal vector.
 * If a data pointer is non-null, the corresponding data stream is present.
 * From C++-programs you can also use the comfort functions Has*() to test for the presence of various data streams.
 *
 * A Mesh uses only a single material which is referenced by a material ID.
 * @note The mPositions member is usually not optional. However, vertex positions *could* be missing if the
 * #AI_SCENE_FLAGS_INCOMPLETE flag is set in
 * @code
 * aiScene::flags
 * @endcode */
class AiMesh {

/** Bitwise combination of the members of the #aiPrimitiveType enum.
         * This specifies which types of primitives are present in the mesh.
         * The "SortByPrimitiveType"-Step can be used to make sure the output meshes consist of one primitive Type each.         */
    public var primitiveTypes:AiPrimitiveTypeMask ;// = 0,

    /** The number of vertices in this mesh.
         * This is also the size of all of the per-vertex data arrays.
         * The maximum value for this member is #AI_MAX_VERTICES.         */
    public var numVertices:Int ;//= 0,

    /** The number of primitives (triangles, polygons, lines) in this  mesh.
         * This is also the size of the faces array.
         * The maximum value for this member is #AI_MAX_FACES.         */
    public var numFaces:Int;// = 0,

    /** Vertex positions.
         * This array is always present in a mesh. The array is numVertices in size.         */
    public var vertices:Array<AiVector3D> ;//= ArrayList(),

    /** Vertex normals.
         * The array contains normalized vectors, NULL if not present.
         * The array is numVertices in size. Normals are undefined for point and line primitives. A mesh consisting of
         * points and lines only may not have normal vectors. Meshes with mixed primitive types (i.e. lines and
         * triangles) may have normals, but the normals for vertices that are only referenced by point or line
         * primitives are undefined and set to QNaN (WARN: qNaN compares to inequal to *everything*, even to qNaN
         * itself.
         * Using code like this to check whether a field is qnan is:
         * @code
         * #define IS_QNAN(f) (f != f)
         * @endcode
         * still dangerous because even 1.f == 1.f could evaluate to false! ( remember the subtleties of IEEE754
         * artithmetics). Use stuff like @c fpclassify instead.
         * @note Normal vectors computed by Assimp are always unit-length.
         * However, this needn't apply for normals that have been taken directly from the model file.         */
    public var normals:Array<AiVector3D> ;//== ArrayList(),

    /** Vertex tangents.
         * The tangent of a vertex points in the direction of the positive X texture axis. The array contains normalized
         * vectors, NULL if not present. The array is numVertices in size. A mesh consisting of points and lines only
         * may not have normal vectors. Meshes with mixed primitive types (i.e. lines and triangles) may have normals,
         * but the normals for vertices that are only referenced by point or line primitives are undefined and set to
         * qNaN.  See the #normals member for a detailed discussion of qNaNs.
         * @note If the mesh contains tangents, it automatically also contains bitangents.         */
    public var tangents:Array<AiVector3D>;// = ArrayList(),

    /** Vertex bitangents.
         * The bitangent of a vertex points in the direction of the positive Y texture axis. The array contains
         * normalized vectors, NULL if not present. The array is numVertices in size.
         * @note If the mesh contains tangents, it automatically also contains bitangents.         */
    public var bitangents:Array<AiVector3D> ;// = mutableListOf(),

    /** Vertex color sets.
         * A mesh may contain 0 to #AI_MAX_NUMBER_OF_COLOR_SETS vertex colors per vertex. NULL if not present. Each
         * array is numVertices in size if present.         */
    public var colors:Array<Array<AiColor4D>>;//  = mutableListOf(),

    /** Vertex texture coords, also known as UV channels.
         * A mesh may contain 0 to AI_MAX_NUMBER_OF_TEXTURECOORDS per vertex. NULL if not present. The array is
         * numVertices in size. mNumUVComponents is not used.
         * This is the order:
         * [texture coordinate id][vertex][texture coordinate components]*/
    public var textureCoords:Array<Array<AiVector3D>> ;//= mutableListOf(),

    /** Specifies the number of components for a given UV channel.
         * Up to three channels are supported (UVW, for accessing volume or cube maps). If the value is 2 for a given
         * channel n, the component p.z of textureCoords[n][p] is set to 0.0f.
         * If the value is 1 for a given channel, p.y is set to 0.0f, too.
         * @note 4D coords are not supported         */
    public var numUVComponents:Array<Int> ;//= IntArray(AI_MAX_NUMBER_OF_TEXTURECOORDS),

    /** The faces the mesh is constructed from.
         * Each face refers to a number of vertices by their indices.
         * This array is always present in a mesh, its size is given in numFaces.
         * If the #AI_SCENE_FLAGS_NON_VERBOSE_FORMAT is NOT set each face references an unique set of vertices.         */
    public var faces:Array<AiFace> ;//= mutableListOf(),

    /** The number of bones this mesh contains.
         * Can be 0, in which case the bones array is NULL.
         */
    public var numBones:Int ;// = 0,

    /** The bones of this mesh.
         * A bone consists of a name by which it can be found in the frame hierarchy and a set of vertex weights.         */
    public var bones:Array<AiBone> ;//= mutableListOf(),

    /** The material used by this mesh.
         * A mesh uses only a single material. If an imported model uses multiple materials, the import splits up the
         * mesh. Use this value as index into the scene's material list.         */
    public var materialIndex:Int ;//= 0,

    /** Name of the mesh. Meshes can be named, but this is not a requirement and leaving this field empty is totally
         * fine.
         * There are mainly three uses for mesh names:
         *   - some formats name nodes and meshes independently.
         *   - importers tend to split meshes up to meet the one-material-per-mesh requirement. Assigning the same
         *      (dummy) name to each of the result meshes aids the caller at recovering the original mesh partitioning.
         *   - Vertex animations refer to meshes by their names.         **/
    public var name:String ;//= "",

    /** The number of attachment meshes. Note! Currently only works with Collada loader. */
    public var mNumAnimMeshes:Int ;//= 0,

    /** Attachment meshes for this mesh, for vertex-based animation.
         *  Attachment meshes carry replacement data for some of the mesh'es vertex components (usually positions, normals).
         *  Note! Currently only works with Collada loader.*/
    public var mAnimMeshes:Array<AiAnimMesh>;// = mutableListOf(),

    /** Method of morphing when animeshes are specified. */
    public var mMethod:Int ;//= 0    // TODO to enum AiMorphingMethod?

    public function new():Void {
        this.primitiveTypes = 0;
        this.numVertices = 0;
        this.numFaces = 0;

        this.vertices = [];
        this.normals = [];
        this.tangents = [];

        this.bitangents = [];
        this.colors = [];
        this.textureCoords = [];//:Array<Array<Array<Float>>>

        this.faces = [];
        this.numBones = 0;
        this.bones = [];
        this.materialIndex = 0;
        this.name = "";

        this.mNumAnimMeshes = 0;
        this.mAnimMeshes = [];
        this.mMethod = 0 ; // TODO to enum AiMorphingMethod?
        this.numUVComponents = [];
    }
    //! Check whether the mesh contains positions. Provided no special
    //! scene flags are set, this will always be true
    public function hasPositions() {
        return numVertices > 0;
    }

    //! Check whether the mesh contains faces. If no special scene flags
    //! are set this should always return true
    public function hasFaces() {
        return numFaces > 0;
    }

    //! Check whether the mesh contains normal vectors
    public function hasNormals() {
        return !Lambda.empty(normals) && numVertices > 0;
    }

    //! Check whether the mesh contains tangent and bitangent vectors
    //! It is not possible that it contains tangents and no bitangents
    //! (or the other way round). The existence of one of them
    //! implies that the second is there, too.
    public function hasTangentsAndBitangents() {
        return !Lambda.empty(tangents) && !Lambda.empty(bitangents) && numVertices > 0;
    }

    //! Check whether the mesh contains a vertex color set
    //! \param index Index of the vertex color set
    public function hasVertexColors(index:Int) {
        return if (index >= Mesh.AI_MAX_NUMBER_OF_COLOR_SETS) {
            false;
        } else {
            index < colors.length && numVertices > 0;
        }
    }
    //! Check whether the mesh contains a texture coordinate set
    //! \param index Index of the texture coordinates set
    public function hasTextureCoords(index:Int) {
        return if (index >= Mesh.AI_MAX_NUMBER_OF_TEXTURECOORDS || index >= textureCoords.length) {
            false;
        } else {
            !Lambda.empty(textureCoords[index]) && numVertices > 0;
        }

    }
    //! Get the number of UV channels the mesh contains
    public function getNumUVChannels():Int {
        var n = 0;
        while (n < Mesh.AI_MAX_NUMBER_OF_TEXTURECOORDS && n < textureCoords.length && !Lambda.empty(textureCoords[n]))
            ++n;
        return n;
    }

    //! Get the number of vertex color channels the mesh contains
    public function getNumColorChannels():Int {
        var n = 0;
        while (n < Mesh.AI_MAX_NUMBER_OF_COLOR_SETS && n < colors.length)
            ++n;
        return n;
    }

    //! Check whether the mesh contains bones
    public function hasBones() {
        return !Lambda.empty(bones) && numBones > 0;
    }

}
