package assimp;
import assimp.format.Defs.AiVector3D;
import assimp.format.Anim.AiVectorKey;
import assimp.format.Anim.AiQuatKey;
import assimp.format.Defs;
import assimp.format.Scene.AiNode;
import assimp.format.Defs.AiQuaternion;
import assimp.format.Defs.AiVector3D;
import assimp.format.Anim.AiAnimation;
import glm.Vec3;
import Lambda;
import assimp.format.Mesh.AiPrimitiveType;
import assimp.format.Mesh.AiMesh;
import assimp.format.Material;
import assimp.format.Defs.AiColor3D;
import assimp.format.Material.Color;
import assimp.format.Material.AiMaterial;
import assimp.format.Scene.AiScene;
class ScenePreprocessor {
    /** Scene we're currently working on    */
    var scene:AiScene;

    public function new() {

    }
    /** Preprocess the current scene     */
    public function processScene(scene:AiScene) {

        // scene cant be null
        this.scene = scene;

        // Process all meshes
        for (it in scene.meshes) {
            AiMesh_process(it);
        }

        // - nothing to do for nodes for the moment
        // - nothing to do for textures for the moment
        // - nothing to do for lights for the moment
        // - nothing to do for cameras for the moment

        // Process all animations
        for (it in scene.animations) { AiAnimation_process(it); }

        // Generate a default material if none was specified
        if (scene.numMaterials == 0 && scene.numMeshes > 0) {
            var tmp = new AiMaterial();
            tmp.color = new Color();
            tmp.color.diffuse = new AiColor3D(0.6);
            // setup the default name to make this material identifiable
            tmp.name = Material.AI_DEFAULT_MATERIAL_NAME;
            scene.materials.push(tmp);
            trace("ScenePreprocessor: Adding default material '$ Material.AI_DEFAULT_MATERIAL_NAME'");

            for (it in scene.meshes) { it.materialIndex = scene.numMaterials; }

            scene.numMaterials++;
        }
    }

    function AiMesh_process(this1:AiMesh) {

        // TODO change -> for in textureCoords
        for (it in this1.textureCoords) {
            // If aiMesh::mNumUVComponents is *not* set assign the default value of 2
            for (i in 0...it.length)
                if (Lambda.empty(it[i]))
                    it[i] = new AiVector3D(0, 0, 0);
            //todo

            /*  Ensure unsued components are zeroed. This will make 1D texture channels work as if they were 2D channels..
                just in case an application doesn't handle this case    */
//            if (it[0].size == 2)
//                for (uv in it)
//                    uv[2] = 0f
//            else if (it[0].size == 1)
//                for (uv in it) {
//                    uv[2] = 0f
//                    uv[1] = 0f
//                }
//            else if (it[0].size == 3) {
//                // Really 3D coordinates? Check whether the third coordinate is != 0 for at least one element
//                var coord3d = false
//                for (uv in it)
//                    if (uv[2] != 0f)
//                        coord3d = true
//                if (!coord3d) {
//                    logger.warn { "ScenePreprocessor: UVs are declared to be 3D but they're obviously not. Reverting to 2D." }
//                    for (i in 0 until it.size)
//                        it[i] = FloatArray(2)
//                }
//            }
        }

        // If the information which primitive types are there in the mesh is currently not available, compute it.
        if (this1.primitiveTypes == 0)
            for (it in this1.faces) {
                this1.primitiveTypes = switch (it.numIndices) {
                    case 3 : this1.primitiveTypes | AiPrimitiveType.TRIANGLE;
                    case 2 : this1.primitiveTypes | AiPrimitiveType.LINE;
                    case 1 : this1.primitiveTypes | AiPrimitiveType.POINT;
                    default: this1.primitiveTypes | AiPrimitiveType.POLYGON;
                }
            }

        // If tangents and normals are given but no bitangents compute them
        if (!Lambda.empty(this1.tangents) && !Lambda.empty(this1.normals) && Lambda.empty(this1.bitangents)) {
            this1.bitangents = [for (i in 0...this1.numVertices) new AiVector3D()];
            for (i in 0...this1.numVertices) {
                Vec3.cross(this1.normals[i], this1.tangents[i], this1.bitangents[i]);
            }
        }
    }

    function AiAnimation_process(this1:AiAnimation) {
        var first = 10e10;
        var last = -10e10;
        for (channel in this1.channels) {

            //  If the exact duration of the animation is not given compute it now.
            if (this1.duration == -1.0) {
                for (it in channel.positionKeys) {
                    // Position keys
                    first = Math.min(first, it.time);
                    last = Math.max(last, it.time);
                }
                for (it in channel.scalingKeys) {
                    // Scaling keys
                    first = Math.min(first, it.time);
                    last = Math.max(last, it.time);
                }
                for (it in channel.rotationKeys) {
                    // Rotation keys
                    first = Math.min(first, it.time);
                    last = Math.max(last, it.time);
                }
            }
            /*  Check whether the animation channel has no rotation or position tracks. In this case we generate a dummy
             *  track from the information we have in the transformation matrix of the corresponding node.  */
            if (channel.numRotationKeys == 0 || channel.numPositionKeys == 0 || channel.numScalingKeys == 0) {
                // Find the node that belongs to this animation
                var it:AiNode = scene.rootNode.findNode(channel.nodeName);
                if (it != null) {
                    // ValidateDS will complain later if 'node' is NULL
                    // Decompose the transformation matrix of the node
                    var scaling = new AiVector3D();
                    var position = new AiVector3D();
                    var rotation = new AiQuaternion();
                    Defs.decompose(it.transformation, scaling, rotation, position);

                    if (channel.numRotationKeys == 0) { // No rotation keys? Generate a dummy track
                        channel.numRotationKeys = 1;
                        channel.rotationKeys = [new AiQuatKey(0.0, rotation)];
                        trace("ScenePreprocessor: Dummy rotation track has been generated");
                    }
                    if (channel.numScalingKeys == 0) { // No scaling keys? Generate a dummy track
                        channel.numScalingKeys = 1;
                        channel.scalingKeys = [new AiVectorKey(0.0, scaling)];
                        trace("ScenePreprocessor: Dummy scaling track has been generated");
                    }
                    if (channel.numPositionKeys == 0) { // No position keys? Generate a dummy track
                        channel.numPositionKeys = 1;
                        channel.positionKeys = [new AiVectorKey(0.0, position)];
                        trace("ScenePreprocessor: Dummy position track has been generated");
                    }
                }
            }
        }
        if (this1.duration == -1.0) {
            trace("ScenePreprocessor: Setting animation duration");
            this1.duration = last - Math.min(first, 0.0);
        }
    }
}
