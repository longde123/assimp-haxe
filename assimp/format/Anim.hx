package assimp.format;

/**
 * Created by elect on 29/01/2017.
 */

// ---------------------------------------------------------------------------
/** A time-value pair specifying a certain 3D vector for the given time. */
import assimp.format.Defs.AiQuaternion;
import assimp.format.Defs.AiVector3D;
class AiVectorKey {
/** The time of this key */
    public var time:Float ;

    /** The value of this key */
    public var value:AiVector3D ;

    public function new(?t:Float, ?v:AiVector3D) {
        this.time = t;
        this.value = v != null ? v : new AiVector3D();
    }

}


// ---------------------------------------------------------------------------
/** A time-value pair specifying a rotation for the given time.
 *  Rotations are expressed with quaternions. */
class AiQuatKey {
/** The time of this key */
    public var time:Float ;

    /** The value of this key */
    public var value:AiQuaternion ;

    public function new(t:Float = 0, v = null) {
        this.time = t;
        this.value = v != null ? v : new AiQuaternion();
    }

}


// ---------------------------------------------------------------------------
/** Binds a anim mesh to a specific point in time. */
class AiMeshKey {
    /** The time of this key */
    public var mTime:Float;

    /** Index into the aiMesh::mAnimMeshes array of the mesh corresponding to the #aiMeshAnim hosting this key frame. The referenced anim mesh is evaluated
         *  according to the rules defined in the docs for #aiAnimMesh.*/
    public var mValue:Int ;

    public function new() {
        this.mTime = 0;
        this.mValue = 0;
    }
}
/** Binds a morph anim mesh to a specific point in time. */
class AiMeshMorphKey {
/** The time of this key */
    public var time:Float;
    /** The values and weights at the time of this key */
    public var values:Array<Int>;
    public var weights:Array<Float>;
/** The number of values and weights */
    public var numValuesAndWeights:Int;

    public function new() {

    }
}

// ---------------------------------------------------------------------------
/** Defines how an animation channel behaves outside the defined time
 *  range. This corresponds to aiNodeAnim::preState and
 *  aiNodeAnim::postState.*/
@:enum abstract AiAnimBehaviour(Int) from Int to Int {
    /** The value from the default node transformation is taken*/
    var DEFAULT = (0x0);

    /** The nearest key value is used without interpolation */
    var CONSTANT = (0x1);

    /** The value of the nearest two keys is linearly
     *  extrapolated for the current time value.*/
    var LINEAR = (0x2);

    /** The animation is repeated.
     *
     *  If the animation key go from n to m and the current
     *  time is t, use the value at (t-n) % (|m-n|).*/
    var REPEAT = (0x3);


}


// ---------------------------------------------------------------------------
/** Describes the animation of a single node. The name specifies the
 *  bone/node which is affected by this animation channel. The keyframes
 *  are given in three separate series of values, one each for position,
 *  rotation and scaling. The transformation matrix computed from these
 *  values replaces the node's original transformation matrix at a
 *  specific time.
 *  This means all keys are absolute and not relative to the bone default pose.
 *  The order in which the transformations are applied is
 *  - as usual - scaling, rotation, translation.
 *
 *  @note All keys are returned in their correct, chronological order.
 *  Duplicate keys don't pass the validation step. Most likely there
 *  will be no negative time values, but they are not forbidden also ( so
 *  implementations need to cope with them! ) */
class AiNodeAnim {
/** The name of the node affected by this animation. The node
         *  must exist and it must be unique.*/
    public var nodeName:String ;

    /** The number of position keys */
    public var numPositionKeys:Int ;

    /** The position keys of this animation channel. Positions are
         * specified as 3D vector. The array is numPositionKeys in size.
         *
         * If there are position keys, there will also be at least one
         * scaling and one rotation key.*/
    public var positionKeys:Array<AiVectorKey>;

    /** The number of rotation keys */
    public var numRotationKeys:Int;

    /** The rotation keys of this animation channel. Rotations are
         *  given as quaternions,  which are 4D vectors. The array is
         *  numRotationKeys in size.
         *
         * If there are rotation keys, there will also be at least one
         * scaling and one position key. */
    public var rotationKeys:Array<AiQuatKey>;

    /** The number of scaling keys */
    public var numScalingKeys:Int ;

    /** The scaling keys of this animation channel. Scalings are
         *  specified as 3D vector. The array is numScalingKeys in size.
         *
         * If there are scaling keys, there will also be at least one
         * position and one rotation key.*/
    public var scalingKeys:Array<AiVectorKey>;

    /** Defines how the animation behaves before the first
         *  key is encountered.
         *
         *  The default value is aiAnimBehaviour_DEFAULT (the original
         *  transformation matrix of the affected node is used).*/
    public var preState:AiAnimBehaviour ;

    /** Defines how the animation behaves after the last
         *  key was processed.
         *
         *  The default value is aiAnimBehaviour_DEFAULT (the original
         *  transformation matrix of the affected node is taken).*/
    public var postState:AiAnimBehaviour;

    public function new() {
        this.nodeName = "";
        this.numPositionKeys = 0;
        this.numRotationKeys = 0;
        this.numScalingKeys = 0;
        this.scalingKeys = [];
        this.positionKeys = [];
        this.rotationKeys = [];
        this.preState = AiAnimBehaviour.DEFAULT;
        this.postState = AiAnimBehaviour.DEFAULT;
    }
}

// ---------------------------------------------------------------------------
/** Describes vertex-based animations for a single mesh or a group of
 *  meshes. Meshes carry the animation data for each frame in their
 *  aiMesh::mAnimMeshes array. The purpose of aiMeshAnim is to
 *  define keyframes linking each mesh attachment to a particular
 *  point in time. */
class AiMeshAnim {
/** Name of the mesh to be animated. An empty string is not allowed,
         *  animated meshes need to be named (not necessarily uniquely,
         *  the name can basically serve as wild-card to select a group
         *  of meshes with similar animation setup)*/
    public var mName:String ;

    /** Size of the #keys array. Must be 1, at least. */
    public var mNumKeys:Int ;

    /** Key frames of the animation. May not be NULL. */
    public var mKeys:Array<AiMeshKey> ;

    public function new() {
        this.mKeys = [] ;
        this.mName = "";
        this.mNumKeys = 0;
    }
}


// ---------------------------------------------------------------------------
/** Describes a morphing animation of a given mesh. */
class AiMeshMorphAnim {
/** Name of the mesh to be animated. An empty string is not allowed, animated meshes need to be named
         *  (not necessarily uniquely, the name can basically serve as wildcard to select a group of meshes
         *  with similar animation setup)*/
    public var name:String ;
    /** Size of the #keys array. Must be 1, at least. */
    public var numKeys:Int;
    /** Key frames of the animation. May not be NULL. */
    public var keys:Array<AiMeshMorphKey> ;

    public function new() {
        this.name = "";
        this.numKeys = 0;
        this.keys = [];
    }

}

// ---------------------------------------------------------------------------
/** An animation consists of key-frame data for a number of nodes. For
 *  each node affected by the animation a separate series of data is given.*/
class AiAnimation {
/** The name of the animation. If the modeling package this data was exported from does support only
         *  a single animation channel, this name is usually empty (length is zero). */
    public var name:String ;
    /** Duration of the animation in ticks.  */
    public var duration:Float;
    /** Ticks per second. 0 if not specified in the imported file */
    public var ticksPerSecond:Float ;
    /** The number of bone animation channels. Each channel affects a single node. */
    public var numChannels:Int ;
    /** The node animation channels. Each channel affects a single node. The array is numChannels in size. */
    public var channels:Array<AiNodeAnim> ;
    /** The number of mesh animation channels. Each channel affects a single mesh and defines vertex-based animation. */
    public var mNumMeshChannels:Int ;
    /** The mesh animation channels. Each channel affects a single mesh. The array is mNumMeshChannels in size. */
    public var mMeshChannels:Array<Array<AiMeshAnim>> ;
    /** The number of mesh animation channels. Each channel affects a single mesh and defines morphing animation. */
    public var numMorphMeshChannels:Int ;
    /** The morph mesh animation channels. Each channel affects a single mesh. The array is numMorphMeshChannels in size. */
    public var morphMeshChannels:Array<AiMeshMorphAnim> ;

    public function new() {
        this.name = "";
        this.duration = -1.0;
        this.ticksPerSecond = 0;
        this.numChannels = 0;
        this.mNumMeshChannels = 0;
        this.numMorphMeshChannels = 0;
        this.channels = [];
        this.mMeshChannels = [[]];
        this.morphMeshChannels = [];
    }

}
