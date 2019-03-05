package assimp.postProcess;
import Lambda;
import assimp.Types;
import Lambda;
using assimp.StringUtil;
import assimp.format.Anim.AiNodeAnim;
import assimp.format.Camera.AiCamera;
import assimp.format.Defs;
import assimp.format.Defs;
import assimp.format.Light.AiLight;
import assimp.format.Light.AiLightSourceType;
import assimp.format.Material.AiTexture;
import assimp.format.Material.AiMaterial;
import assimp.format.Anim.AiAnimation;
import assimp.format.Mesh;
import assimp.format.Mesh.AiPrimitiveType;
import assimp.format.Mesh.AiMesh;
import assimp.format.Scene;
import assimp.Assimp;
import assimp.format.Scene.AiScene;
import assimp.AiPostProcessStep as Pps;
import assimp.format.Material.AiShadingMode as Sm;
class ValidateDSProcess extends BaseProcess {
    public function new() {
        super();
    }

    var scene:AiScene;

    /** Report a validation error. This will throw an exception, control won't return.
     *  @param msg Format string for sprintf().*/
    function reportError(msg:String, ?args:Array<Any>) {
        throw ("Validation failed: $msg $args");

    }
    /** Report a validation warning. This won't throw an exception, control will return to the caller.
     * @param msg Format string for sprintf().*/
    function reportWarning(msg:String, ? args:Array<Any>) {
        trace("Validation warning: $msg $args");
    }

    /** Returns whether the processing step is present in the given flag field. */
    override public function isActive(flags:Int) return flags & Pps.ValidateDataStructure != 0;

/** Executes the post processing step on the given imported data.   */
    override public function execute(scene:AiScene) {
        this.scene = scene;
        trace("ValidateDataStructureProcess begin");
        // validate the node graph of the scene
        validateAiNode(scene.rootNode);
        // validate all meshes
        if (scene.numMeshes != 0)
            doValidation(scene.meshes, scene.numMeshes, "meshes", "numMeshes");
        else if (scene.flags & Scene.AI_SCENE_FLAGS_INCOMPLETE == 0)
            reportError("AiScene.numMeshes is 0. At least one mesh must be there");
        else if (!Lambda.empty(scene.meshes))
            reportError("AiScene.meshes is not empty although there are no meshes");

        // validate all animations
        if (scene.numAnimations != 0)
            doValidation(scene.animations, scene.numAnimations, "animations", "numAnimations");
        else if (!Lambda.empty(scene.animations))
            reportError("AiScene.animations is not empty although there are no animations");

        // validate all cameras
        if (scene.numCameras != 0)
            doValidationWithNameCheck(scene.cameras, scene.numCameras, "cameras", "numCameras");
        else if (!Lambda.empty(scene.cameras))
            reportError("AiScene.cameras is not empty although there are no cameras");

        // validate all lights
        if (scene.numLights > 0)
            doValidationWithNameCheck(scene.lights, scene.numLights, "lights", "numLights");
        else if (!Lambda.empty(scene.lights))
            reportError("AiScene.lights is not empty although there are no lights");

        // validate all textures
        if (scene.numTextures > 0) {
            doValidation(Lambda.array(scene.textures), scene.numTextures, "textures", "numTextures");
        }

        else if (!Lambda.empty(scene.textures))
            reportError("AiScene.textures is not empty although there are no textures");

        // validate all materials
        if (scene.numMaterials > 0)
            doValidation(scene.materials, scene.numMaterials, "materials", "numMaterials");
        else if (!Lambda.empty(scene.materials))
            reportError("AiScene.materials is not empty although there are no materials");

        trace("ValidateDataStructureProcess end");
    }

    /** Validates a mesh
     *  @param mesh Input mesh*/
    function validateAiMesh(mesh:AiMesh) {
        // validate the material index of the mesh
        if (scene.numMaterials != 0 && mesh.materialIndex >= scene.numMaterials)
            reportError("AiMesh.materialIndex is invalid (value: ${mesh.materialIndex} maximum: ${scene.numMaterials - 1})");

        validateString(mesh.name);

        for (i in 0 ... mesh.numFaces) {
            var face = mesh.faces[i];
            if (mesh.primitiveTypes != 0)
                switch (face.numIndices) {
                    case 0 : reportError("AiMesh.faces[$i].numIndices is 0");
                    case 1 :{
                        if (mesh.primitiveTypes & AiPrimitiveType.POINT == 0)
                            reportError("AiMesh.faces[$i] is a POINT but AiMesh.primitiveTypes does not report the POINT flag");
                    }
                    case 2 : {
                        if (mesh.primitiveTypes & AiPrimitiveType.LINE == 0)
                            reportError("AiMesh.faces[$i] is a LINE but AiMesh.primitiveTypes does not report the LINE flag");
                    }
                    case 3 :{
                        if (mesh.primitiveTypes & AiPrimitiveType.TRIANGLE == 0)
                            reportError("AiMesh.faces[$i] is a TRIANGLE but AiMesh.primitiveTypes does not report the TRIANGLE flag");
                    }
                    default: {
                        if (mesh.primitiveTypes & AiPrimitiveType.POLYGON == 0)
                            reportError("AiMesh.faces[$i] is a POLYGON but AiMesh.primitiveTypes does not report the POLYGON flag");
                    }
                }
            if (face.numIndices == 0) reportError("AiMesh.faces[$i] is empty");
        }
        // positions must always be there ...
        if (mesh.numVertices == 0 || (Lambda.empty(mesh.vertices) && scene.flags == 0))
            reportError("The mesh contains no vertices");
        if (mesh.numVertices > Mesh.AI_MAX_VERTICES)
            reportError("Mesh has too many vertices: ${mesh.numVertices}, but the limit is $AI_MAX_VERTICES");
        if (mesh.numFaces > Mesh.AI_MAX_FACES)
            reportError("Mesh has too many faces: ${mesh.numFaces}, but the limit is $AI_MAX_FACES");
        // if tangents are there there must also be bitangent vectors ...
        if ((!Lambda.empty(mesh.tangents)) != (!Lambda.empty(mesh.bitangents)))
            reportError("If there are tangents, bitangent vectors must be present as well");
        // faces, too
        if (mesh.numFaces == 0 || (Lambda.empty(mesh.faces) && scene.flags == 0))
            reportError("Mesh contains no faces");
        // now check whether the face indexing layout is correct: unique vertices, pseudo-indexed.
        var abRefList = [for (i in 0...mesh.numVertices) false];//BooleanArray(mesh.numVertices);
        for (i in 0 ... mesh.numFaces) {
            var face = mesh.faces[i];
            if (face.numIndices > Mesh.AI_MAX_FACE_INDICES)
                reportError("Face $i has too many faces: ${face.size}, but the limit is $AI_MAX_FACE_INDICES");
            for (a in 0 ... face.numIndices) {
                if (face.indices[a] >= mesh.numVertices) reportError("AiMesh.faces[$i][$a] is out of range");
                abRefList[face.indices[a]] = true;
            }
        }
        // check whether there are vertices that aren't referenced by a face
        for (i in 0 ... mesh.numVertices) if (!abRefList[i]) reportWarning("There are unreferenced vertices");

        // texture channel 2 may not be set if channel 1 is zero ...
        {
            var i = 0;
            while (i < Mesh.AI_MAX_NUMBER_OF_TEXTURECOORDS) {
                if (!mesh.hasTextureCoords(i)) break;
                ++i;
            }
            while (i < Mesh.AI_MAX_NUMBER_OF_TEXTURECOORDS) {
                if (mesh.hasTextureCoords(i))
                    reportError("Texture coordinate channel $i exists although the previous channel didn't exist.");
                ++i;
            }
        }
        // the same for the vertex colors
        {


            var i = 0;
            while (i < Mesh.AI_MAX_NUMBER_OF_COLOR_SETS) {
                if (!mesh.hasVertexColors(i)) break;
                ++i;
            }
            while (i < Mesh.AI_MAX_NUMBER_OF_COLOR_SETS) {
                if (mesh.hasVertexColors(i))
                    reportError("Vertex color channel $i is exists although the previous channel didn't exist.");
                ++i;
            }
        }
        // now validate all bones
        if (mesh.numBones > 0) {
            if (Lambda.empty(mesh.bones))
                reportError("AiMesh.bones is empty (AiMesh.numBones is ${mesh.numBones})");
            var afSum = [for (i in 0...mesh.numVertices) 0.0];// FloatArray(mesh.numVertices);
            // check whether there are duplicate bone names
            for (i in 0 ... mesh.numBones) {
                var bone = mesh.bones[i];
                if (bone.numWeights > Mesh.AI_MAX_BONE_WEIGHTS)
                    reportError("Bone $i has too many weights: ${bone.numWeights}, but the limit is $Mesh.AI_MAX_BONE_WEIGHTS");
                if (i >= mesh.bones.length)
                    reportError("AiMesh.bones[$i] doesn't exist (AiMesh.numBones is ${mesh.numBones})");
                validateAiBone(mesh, mesh.bones[i], afSum);
                for (a in i + 1 ... mesh.numBones)
                    if (mesh.bones[i].name == mesh.bones[a].name)
                        reportError("AiMesh.bones[$i] has the same name as AiMesh.bones[$a]");
            }
            // check whether all bone weights for a vertex sum to 1.0 ...
            for (i in 0 ... mesh.numVertices)
                if (afSum[i] != 0 && (afSum[i] <= 0.94 || afSum[i] >= 1.05))
                    reportWarning("AiMesh.vertices[$i]: bone weight sum != 1f (sum is ${afSum[i]})");
        } else if (!Lambda.empty(mesh.bones))
            reportError("AiMesh.bones is no empty although there are no bones");
    }

    /** Validates a bone
     *  @param mesh Input mesh
     *  @param bone Input bone  */
    public function validateAiBone(mesh:AiMesh, bone:AiBone, afSum:Array<Float>) {
        validateString(bone.name);
        if (bone.numWeights == 0) reportError("aiBone::mNumWeights is zero");
        // check whether all vertices affected by this bone are valid
        for (i in 0 ... bone.numWeights) {
            if (bone.weights[i].vertexId >= mesh.numVertices)
                reportError("AiBone.weights[$i].vertexId is out of range");
            else if (bone.weights[i].weight == 0 || bone.weights[i].weight > 1)
                reportWarning("AiBone.weights[$i].weight has an invalid value");
            afSum[bone.weights[i].vertexId] += bone.weights[i].weight;
        }
    }

    /** Validates an animation
     *  @param animation Input animation*/
    public function validateAiAnimation(animation:AiAnimation) {
        validateString(animation.name);
        // validate all materials
        if (animation.numChannels > 0) {
            if (Lambda.empty(animation.channels))
                reportError("AiAnimation.channels is empty (AiAnimation.numChannels is ${animation.numChannels})");
            for (i in 0 ... animation.numChannels) {
                if (i >= animation.channels.length)
                    reportError("AiAnimation.channels[$i] doesn't exist (AiAnimation.numChannels is ${animation.numChannels})");
                validateChannels(animation, animation.channels[i]);
            }
        } else reportError("aiAnimation::mNumChannels is 0. At least one node animation channel must be there.");
    }

    /** Validates a material
     *  @param material Input material*/
    public function validateAiMaterial(material:AiMaterial) {
        // make some more specific tests
        var temp = 0;
        if (material.shadingModel != null) {
            switch (material.shadingModel) {
                case Sm.blinn, Sm.cookTorrance, Sm.phong : {
                    if (material.shininess == null)
                        reportWarning("A specular shading model is specified but there is no Shininess key");

                    if (material.shininessStrength != null) {
                        if (material.shininessStrength == 0)
                            reportWarning("A specular shading model is specified but the value of the Shininess Strenght key is 0");
                    }
                }
                default:{

                }
            }
        }

        if (material.opacity != null) {
            if (material.opacity == 0 || material.opacity > 1.01)
                reportWarning("Invalid opacity value (must be 0 < opacity < 1f)");
        }

        // Check whether there are invalid texture keys
        // TODO: that's a relict of the past, where texture type and index were baked
        // into the material string ... we could do that in one single pass.
        searchForInvalidTextures(material) ;
    }

    /** Search the material data structure for invalid or corrupt texture keys.
     *  @param material Input material  */
    function searchForInvalidTextures(material:AiMaterial) {
        var index = 0;
        // Now check whether all UV indices are valid ...
        var noSpecified = true;
        for (texture in material.textures)
            if (texture.uvwsrc != null) {
                var it = texture.uvwsrc;
                noSpecified = false;
                // Ignore UV indices for texture channels that are not there ...
                // Get the value
                index = it;
                // Check whether there is a mesh using this material which has not enough UV channels ...
                for (a in 0 ... scene.numMeshes) {
                    var mesh = scene.meshes[a];
                    if (mesh.materialIndex == scene.materials.indexOf(material)) {
                        var channels = 0;
                        while (mesh.hasTextureCoords(channels)) ++channels;
                        if (it >= channels)
                            reportWarning("Invalid UV index: $it (key uvwsrc). Mesh $a has only $channels UV channels");
                    }
                }
            }
        if (noSpecified)
            for (a in 0 ... scene.numMeshes) { // Assume that all textures are using the first UV channel
                var mesh = scene.meshes[a];
                if (mesh.materialIndex == index && Lambda.empty(mesh.textureCoords[0]))
                    // This is a special case ... it could be that the original mesh format intended the use of a special mapping here.
                    reportWarning("UV-mapped texture, but there are no UV coords");
            }
    }

    /** Validates a texture
     *  @param texture Input texture*/
    public function validateAiTexture(texture:AiTexture) {
        // the data section may NEVER be NULL
        if (null == (texture.pcData))
            reportError("AiTexture.pcData is empty");
        if (texture.height > 0 && texture.width == 0)
            reportError("AiTexture.width is zero (AiTexture.height is ${texture.height}, uncompressed texture)");
        else {
            if (texture.width == 0)
                reportError("AiTexture.width is zero (compressed texture)");
            else if ('.' == texture.achFormatHint.charAt(0))
                reportWarning("AiTexture.achFormatHint should contain a file extension  without a leading dot (format hint: ${texture.achFormatHint}).");
        }
        if (texture.achFormatHint.toLowerCase() != texture.achFormatHint)
            reportError("AiTexture.achFormatHint contains non-lowercase letters");
    }

    /** Validates a light source
     *  @param light Input light
     */
    public function validateAiLight(light:AiLight) {
        if (light.type == AiLightSourceType.UNDEFINED)
            reportWarning("AiLight.type is undefined");
        if (light.attenuationConstant == 0 && light.attenuationLinear == 0 && light.attenuationQuadratic == 0)
            reportWarning("AiLight.attenuation* - all are zero");
        if (light.angleInnerCone > light.angleOuterCone)
            reportError("AiLight.angleInnerCone is larger than AiLight.angleOuterCone");
        if (Defs.isBlack(light.colorDiffuse) && Defs.isBlack(light.colorAmbient) && Defs.isBlack(light.colorSpecular))
            reportWarning("AiLight.color* - all are black and won't have any influence");
    }

    /** Validates a camera
     *  @param camera Input camera*/
    public function validateAiCamera(camera:AiCamera) {
        if (camera.clipPlaneFar <= camera.clipPlaneNear)
            reportError("AiCamera.clipPlaneFar must be >= AiCamera.clipPlaneNear");
        // FIX: there are many 3ds files with invalid FOVs. No reason to reject them at all ... a warning is appropriate.
        if (camera.horizontalFOV == 0 || camera.horizontalFOV >= Math.PI)
            reportWarning("${camera.horizontalFOV} is not a valid value for AiCamera.horizontalFOV");
    }

    /** Validates a bone animation channel
     *  @param animation Animation channel.
     *  @param boneAnim Input bone animation */
    public function validateChannels(animation:AiAnimation, boneAnim:AiNodeAnim) {
        validateString(boneAnim.nodeName);
        if (boneAnim.numPositionKeys == 0 && Lambda.empty(boneAnim.scalingKeys) && boneAnim.numRotationKeys == 0)
            reportError("Empty node animation channel");
        // otherwise check whether one of the keys exceeds the total duration of the animation
        if (boneAnim.numPositionKeys > 0) {
            if (Lambda.empty(boneAnim.positionKeys))
                reportError("AiNodeAnim.positionKeys is empty (AiNodeAnim.numPositionKeys is ${boneAnim.numPositionKeys})");
            var last = -10e10;
            for (i in 0 ... boneAnim.numPositionKeys) {
                /*  ScenePreprocessor will compute the duration if still the default value
                    (Aramis) Add small epsilon, comparison tended to fail if max_time == duration, seems to be due
                    the compilers register usage/width. */
                if (animation.duration > 0 && boneAnim.positionKeys[i].time > animation.duration + 0.001) {
                    var t = boneAnim.positionKeys[i].time;
                    var d = "%.5f".formatString(animation.duration);
                    reportError("AiNodeAnim.positionKeys[$i].time ($t) is larger than AiAnimation.duration (which is $d)");
                }
                if (i > 0 && boneAnim.positionKeys[i].time <= last) {
                    var t = "%.5f".formatString(boneAnim.positionKeys[i].time);
                    var l = "%.5f".formatString(last);
                    reportWarning("AiNodeAnim.positionKeys[$i].time ($t) is smaller than AiAnimation.positionKeys[${i - 1}] (which is $l)");
                }
                last = boneAnim.positionKeys[i].time;
            }
        }
        // rotation keys
        if (boneAnim.numRotationKeys > 0) {
            if (Lambda.empty(boneAnim.rotationKeys))
                reportError("AiNodeAnim.rotationKeys is empty (AiNodeAnim.numRotationKeys is ${boneAnim.numRotationKeys})");
            var last = -10e10;
            for (i in 0 ... boneAnim.numRotationKeys) {
                if (animation.duration > 0 && boneAnim.rotationKeys[i].time > animation.duration + 0.001) {
                    var t = "%.5f".formatString(boneAnim.rotationKeys[i].time);
                    var d = "%.5f".formatString(animation.duration);
                    reportError("aiNodeAnim::mRotationKeys[$i].time ($t) is larger than AiAnimation.duration (which is $d)");
                }
                if (i > 0 && boneAnim.rotationKeys[i].time <= last) {
                    var t = "%.5f".formatString(boneAnim.rotationKeys[i].time);
                    var l = "%.5f".formatString(last);
                    reportWarning("AiNodeAnim.rotationKeys[$i].time ($t) is smaller than AiAnimation.rotationKeys[${i - 1}] (which is $l)");
                }
                last = boneAnim.rotationKeys[i].time;
            }
        }
        // scaling keys
        if (boneAnim.numScalingKeys > 0) {
            if (Lambda.empty(boneAnim.scalingKeys))
                reportError("AiNodeAnim.scalingKeys is empty (AiNodeAnim.numScalingKeys is ${boneAnim.numScalingKeys})");
            var last = -10e10;
            for (i in 0 ... boneAnim.numScalingKeys) {
                if (animation.duration > 0 && boneAnim.scalingKeys[i].time > animation.duration + 0.001) {
                    var t = boneAnim.scalingKeys[i].time;
                    var d = animation.duration;
                    reportError("AiNodeAnim.scalingKeys[$i].time ($t) is larger than AiAnimation.duration (which is $d)");
                }
                if (i > 0 && boneAnim.scalingKeys[i].time <= last) {
                    var t = "%.5f".formatString(boneAnim.scalingKeys[i].time);
                    var l = "%.5f".formatString(last);
                    reportWarning("AiNodeAnim.scalingKeys[$i].time ($t) is smaller than AiAnimation.scalingKeys[${i - 1}] (which is $l)");
                }
                last = boneAnim.scalingKeys[i].time;
            }
        }
        if (boneAnim.numScalingKeys == 0 && boneAnim.numRotationKeys == 0 && boneAnim.numPositionKeys == 0)
            reportError("A node animation channel must have at least one subtrack");
    }

    /** Validates a node and all of its subnodes
     *  @param node Input node*/
    public function validateAiNode(node:AiNode) {
        if (node != scene.rootNode && node.parent == null)
            reportError("A node has no valid parent (AiNode.parent is null)");
        validateString(node.name);
        // validate all meshes
        if (node.numMeshes > 0) {
            if (Lambda.empty(node.meshes))
                reportError("AiNode.meshes is empty (AiNode.numMeshes is ${node.numMeshes})");
            var abHadMesh = [for (i in 0...scene.numMeshes) false];
            for (i in 0 ... node.numMeshes) {
                if (node.meshes[i] >= scene.numMeshes)
                    reportError("AiNode.meshes[${node.meshes[i]}] is out of range (maximum is ${scene.numMeshes - 1})");
                if (abHadMesh[node.meshes[i]])
                    reportError("AiNode.meshes[$i] is already referenced by this node (value: ${node.meshes[i]})");
                abHadMesh[node.meshes[i]] = true;
            }
        }
        if (node.numChildren > 0) {
            if (Lambda.empty(node.children))
                reportError("AiNode.children is empty (AiNode.numChildren is ${node.numChildren})");
            for (i in 0 ... node.numChildren)
                validateAiNode(node.children[i]);
        }
    }

    /** Validates a string
     *  @param string Input string*/
    public function validateString(string:String) {
        if (string.length > Types.MAXLEN)
            reportError("String.length is too large (${string.length}, maximum is $MAXLEN)");
        if (string.indexOf('\u0000') != -1)
            reportError("String data is invalid: it contains the terminal zero");
    }

    /** template to validate one of the AiScene::XXX arrays    */
    public function doValidation(array:Array<Dynamic>, size:Int, firstName:String, secondName:String) {
        // validate all entries
        if (size > 0) {
            if (Lambda.empty(array))
                reportError("AiScene.$firstName is empty (AiScene.$secondName is $size)");
            for (i in 0 ... size) {
                var element = array[i];
                if (Std.is(element, AiMesh)) validateAiMesh(cast element);
                if (Std.is(element, AiAnimation)) validateAiAnimation(cast element);
                if (Std.is(element, AiCamera)) validateAiCamera(cast element);
                if (Std.is(element, AiLight)) validateAiLight(cast element);
                if (Std.is(element, AiTexture)) validateAiTexture(cast element);
                if (Std.is(element, AiMaterial)) validateAiMesh(cast element);
            }
        }
    }

    /** extended version: checks whether T.name occurs twice   */
    public function doValidationEx(array:Array<Dynamic>, size:Int, firstName:String, secondName:String) {
        // validate all entries
        if (size > 0) {
            if (Lambda.empty(array))
                reportError("AiScene.$firstName is empty (AiScene.$secondName is $size)");
            for (i in 0 ... size) {
                var element = array[i];
                if (Std.is(element, AiMesh)) validateAiMesh(cast element);
                if (Std.is(element, AiAnimation)) validateAiAnimation(cast element);
                if (Std.is(element, AiCamera)) validateAiCamera(cast element);
                if (Std.is(element, AiLight)) validateAiLight(cast element);
                if (Std.is(element, AiTexture)) validateAiTexture(cast element);
                if (Std.is(element, AiMaterial)) validateAiMesh(cast element);

                // check whether there are duplicate names
///@Suppress("UNCHECKED_CAST")
                for (a in i + 1 ... size) {
                    var nameI = Reflect.field(element, "name");
                    var elementA = array[a] ;
                    var nameA = Reflect.field(elementA, "name");
                    if (nameI == nameA)
                        reportError("AiScene.$firstName[$i] has the same name as AiScene.$secondName[$a]");
                }
            }
        }
    }

    /** extension to the first template which does also search the nodegraph for an item with the same name */
    public function doValidationWithNameCheck(array:Array<Dynamic>, size:Int, firstName:String, secondName:String) {
        // validate all entries
        doValidationEx(array, size, firstName, secondName);
        for (i in 0 ... size) {
            var element = array[i];
            var name = Reflect.field(element, "name");
            var res = hasNameMatch(name, scene.rootNode);
            if (res == 0)
                reportError("AiScene$firstName[$i] has no corresponding node in the scene graph ($name)");
            else if (1 != res)
                reportError("AiScene.$firstName[$i]: there are more than one nodes with $name as name");
        }
    }

    function hasNameMatch(sIn:String, node:AiNode):Int {
        return (if (node.name == sIn) 1 else 0) + Lambda.fold(node.children, function(it, sum) return hasNameMatch(sIn, it) + sum, 0);
    }

}
