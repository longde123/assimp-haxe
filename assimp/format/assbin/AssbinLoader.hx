package assimp.format.assbin;
import haxe.io.Bytes;
import assimp.format.Camera.AiCamera;
import assimp.format.Light.AiLightSourceType;
import assimp.format.Light.AiLight;
import haxe.io.Bytes;
import assimp.format.Material.AiTexture;
import assimp.format.Anim.AiAnimation;
import assimp.format.Anim.AiQuatKey;
import assimp.format.Anim.AiVectorKey;
import assimp.format.Anim.AiNodeAnim;
import assimp.format.Material.AiMaterial;
import assimp.format.Material.AiMaterialProperty;
import assimp.format.Mesh.AiFace;
import assimp.format.Defs.AiColor4D;
import assimp.format.Defs.AiVector3D;
import assimp.format.Mesh.AiMesh;
import assimp.IOStreamUtil;
import assimp.format.Mesh.AiVertexWeight;
import assimp.format.Mesh.AiBone;
import assimp.format.MetaData.AiMetadataEntry;
import assimp.format.MetaData.AiMetadataType;
import assimp.format.MetaData.AiMetadata;
import assimp.format.Scene.AiNode;
import assimp.IOSystem.MemoryIOStream;
import assimp.format.Scene.AiScene;
import assimp.IOSystem.IOStream;
import assimp.ImporterDesc.AiImporterFlags;
import assimp.ImporterDesc.AiImporterDesc;
using assimp.IOStreamUtil;
class AssbinLoader extends BaseImporter {
    private static var ASSBIN_VERSION_MINOR = 0;
    private static var ASSBIN_VERSION_MAJOR = 0;
    private static var ASSBIN_HEADER_LENGTH = 512;

// these are the magic chunk identifiers for the binary ASS file format
    private static var ASSBIN_CHUNK_AICAMERA = 0x1234;
    private static var ASSBIN_CHUNK_AILIGHT = 0x1235;
    private static var ASSBIN_CHUNK_AITEXTURE = 0x1236;
    private static var ASSBIN_CHUNK_AIMESH = 0x1237;
    private static var ASSBIN_CHUNK_AINODEANIM = 0x1238;
    private static var ASSBIN_CHUNK_AISCENE = 0x1239;
    private static var ASSBIN_CHUNK_AIBONE = 0x123a;
    private static var ASSBIN_CHUNK_AIANIMATION = 0x123b;
    private static var ASSBIN_CHUNK_AINODE = 0x123c;
    private static var ASSBIN_CHUNK_AIMATERIAL = 0x123d;
    private static var ASSBIN_CHUNK_AIMATERIALPROPERTY = 0x123e;

    private static var ASSBIN_MESH_HAS_POSITIONS = 0x1;
    private static var ASSBIN_MESH_HAS_NORMALS = 0x2;
    private static var ASSBIN_MESH_HAS_TANGENTS_AND_BITANGENTS = 0x4;
    private static var ASSBIN_MESH_HAS_TEXCOORD_BASE = 0x100;
    private static var ASSBIN_MESH_HAS_COLOR_BASE = 0x10000;

    private static function ASSBIN_MESH_HAS_TEXCOORD(n:Int) return ASSBIN_MESH_HAS_TEXCOORD_BASE << n;

    private static function ASSBIN_MESH_HAS_COLOR(n:Int) return ASSBIN_MESH_HAS_COLOR_BASE << n;

    var shortened:Bool;
    var compressed:Bool;

    public function new() {
        super();
        info = new AiImporterDesc();
        info.name = ".assbin Importer";
        info.comments = "Gargaj / Conspiracy";
        info.flags = AiImporterFlags.SupportBinaryFlavour | AiImporterFlags.SupportCompressedFlavour;
        info.fileExtensions = ["assbin"];
        shortened = false;
        compressed = false;
    }


    override public function canRead(file:String, ioSystem:IOSystem, checkSig:Bool):Bool {
        var ioStream:IOStream = ioSystem.open(file);
        var s = ioStream.readString(32) ;
        ioSystem.close(ioStream);
        return s == "ASSIMP.binary-dump." ;
    }

    override public function internReadFile(pFile:String, pIOHandler:IOSystem, pScene:AiScene) {
        var stream:IOStream = pIOHandler.open(pFile);
        if (null == stream) {
            return;
        }
        // signature
        stream.seek(44);
        var versionMajor = stream.readInt32();
        var versionMinor = stream.readInt32();
        if (versionMinor != AssbinLoader.ASSBIN_VERSION_MINOR || versionMajor != AssbinLoader.ASSBIN_VERSION_MAJOR) {
            throw ( "Invalid version, data format not compatible!" );
        }
        var versionRevision = stream.readInt32();
        var compileFlags = stream.readInt32();
        shortened = stream.readUInt16() > 0;
        compressed = stream.readUInt16() > 0;
        if (shortened)
            throw ( "Shortened binaries are not supported!" );
        stream.seek(256); // original filename
        stream.seek(128); // options
        stream.seek(64); // padding
        if (compressed) {
            var uncompressedSize = stream.readInt32();
            var compressedSize = stream.length;
            var compressedData = Bytes.alloc(compressedSize);
            stream.readBytes(compressedData,stream.length,compressedSize);
            var io:MemoryIOStream = new MemoryIOStream(haxe.zip.Uncompress.run(compressedData));
            readBinaryScene(io, pScene);
        } else {
            readBinaryScene(stream, pScene);
        }
        pIOHandler.close(stream);
    }

// -----------------------------------------------------------------------------------
    function readBinaryNode(stream:IOStream, onode:AiNode, ?parent:AiNode = null) {
        if (stream.readInt32() != AssbinLoader.ASSBIN_CHUNK_AINODE)
            throw ("Magic chunk identifiers are wrong!");
        var size = stream.readInt32();

        var node:AiNode = onode;
        node.name = stream.readAiString();
        node.transformation = stream.readAiMatrix4x4();
        var numChildren = stream.readInt32();
        var numMeshes = stream.readInt32();
        var nb_metadata = stream.readInt32();

        if (parent != null) {
            node.parent = parent;
        }

        if (numMeshes > 0) {
            node.meshes = [for (i in 0... numMeshes) 0];// unsigned int[numMeshes];
            for (i in 0... numMeshes) {
                node.meshes[i] = stream.readInt32();
                node.numMeshes++;
            }
        }

        if (numChildren > 0) {
            node.children = [for (i in 0... numMeshes) new AiNode()];// aiNode*[numChildren];
            for (i in 0... numChildren) {
                readBinaryNode(stream, node.children[i], node);
                node.numChildren++;
            }
        }

        if (nb_metadata > 0) {
            node.metaData = new AiMetadata() ;// aiMetadata::Alloc(nb_metadata);
            for (i in 0... nb_metadata) {
                var mKeys = stream.readAiString();
                var mType:AiMetadataType = stream.readUInt16();
                var data:Any = null ;

                switch (mType) {
                    case AiMetadataType.BOOL:
                        data = stream.readByte() == 1;
                    case AiMetadataType.INT32:
                        data = stream.readInt32();
                    case AiMetadataType.UINT64:
                        data = stream.readDouble();
                    case AiMetadataType.FLOAT:
                        data = stream.readFloat();
                    case AiMetadataType.DOUBLE:
                        data = stream.readDouble();
                    case AiMetadataType.AISTRING:
                        data = stream.readAiString();
                    case AiMetadataType.AIVECTOR3D:
                        data = stream.readAiVector3D();
                    default: {

                    }
                }
                node.metaData.set(mKeys, new AiMetadataEntry(mType, data));
            }
        }
    }

// -----------------------------------------------------------------------------------
    function readBinaryBone(stream:IOStream, b:AiBone) {
        if (stream.readInt32() != AssbinLoader.ASSBIN_CHUNK_AIBONE)
            throw ("Magic chunk identifiers are wrong!");
        var size = stream.readInt32();
        b.name = stream.readAiString();
        b.numWeights = stream.readInt32();
        b.offsetMatrix = stream.readAiMatrix4x4();
        // for the moment we write dumb min/max values for the bones, too.
        // maybe I'll add a better, hash-like solution later
        if (shortened) {
            //AiVertexWeight size int float
            stream.readBounds(b.weights, b.numWeights);
        } else {
            // else write as usual
            b.weights = [for (i in 0...b.numWeights) new AiVertexWeight()];//new aiVertexWeight[b->mNumWeights];
            stream.readArray(IOStreamUtil.readAiVertexWeight, b.weights, b.numWeights);
        }
    }

// -----------------------------------------------------------------------------------
    static function fitsIntoUI16(mNumVertices) {
        return ( mNumVertices < (1 << 16) );
    }
// -----------------------------------------------------------------------------------
    function readBinaryMesh(stream:IOStream, mesh:AiMesh) {
        if (stream.readInt32() != AssbinLoader.ASSBIN_CHUNK_AIMESH)
            throw ("Magic chunk identifiers are wrong!");
        var size = stream.readInt32();

        mesh.primitiveTypes = stream.readInt32();
        mesh.numVertices = stream.readInt32();
        mesh.numFaces = stream.readInt32();
        mesh.numBones = stream.readInt32();
        mesh.materialIndex = stream.readInt32();

        // first of all, write bits for all existent vertex components
        var c = stream.readInt32();

        if (c & AssbinLoader.ASSBIN_MESH_HAS_POSITIONS != 0) {
            if (shortened) {
                stream.readBounds(mesh.vertices, mesh.numVertices);
            } else {
                // else write as usual
                mesh.vertices = [for (i in 0... mesh.numVertices) new AiVector3D()];// aiVector3D[mesh->mNumVertices];
                stream.readArray(IOStreamUtil.readAiVector3D, mesh.vertices, mesh.numVertices);
            }
        }
        if (c & AssbinLoader.ASSBIN_MESH_HAS_NORMALS != 0) {
            if (shortened) {
                stream.readBounds(mesh.normals, mesh.numVertices);
            } else {
                // else write as usual
                mesh.normals = [for (i in 0... mesh.numVertices) new AiVector3D()];//new aiVector3D[mesh->mNumVertices];
                stream.readArray(IOStreamUtil.readAiVector3D, mesh.normals, mesh.numVertices);
            }
        }
        if (c & AssbinLoader.ASSBIN_MESH_HAS_TANGENTS_AND_BITANGENTS != 0) {
            if (shortened) {
                stream.readBounds(mesh.tangents, mesh.numVertices);
                stream.readBounds(mesh.bitangents, mesh.numVertices);
            } else {
                // else write as usual
                mesh.tangents = [for (i in 0... mesh.numVertices) new AiVector3D()];// new aiVector3D[mesh->mNumVertices];
                stream.readArray(IOStreamUtil.readAiVector3D, mesh.tangents, mesh.numVertices);
                mesh.bitangents = [for (i in 0... mesh.numVertices) new AiVector3D()];//  new aiVector3D[mesh->mNumVertices];
                stream.readArray(IOStreamUtil.readAiVector3D, mesh.bitangents, mesh.numVertices);
            }
        }

        for (n in 0... Mesh.AI_MAX_NUMBER_OF_COLOR_SETS) {
            if ((c & AssbinLoader.ASSBIN_MESH_HAS_COLOR(n)) == 0) {
                break;
            }

            if (shortened) {
                stream.readBounds(mesh.colors[n], mesh.numVertices);
            } else {
                // else write as usual
                mesh.colors[n] = [for (i in 0... mesh.numVertices) new AiColor4D()];//new aiColor4D[mesh->mNumVertices];
                stream.readArray(IOStreamUtil.readAiColor4D, mesh.colors[n], mesh.numVertices);
            }
        }

        for (n in 0... Mesh.AI_MAX_NUMBER_OF_TEXTURECOORDS) {
            if ((c & AssbinLoader.ASSBIN_MESH_HAS_TEXCOORD(n)) == 0) {
                break;
            }

            // write number of UV components
            mesh.numUVComponents[n] = stream.readInt32();

            if (shortened) {
                stream.readBounds(mesh.textureCoords[n], mesh.numVertices);
            } else {
                // else write as usual
                mesh.textureCoords[n] = [for (i in 0... mesh.numVertices) new AiVector3D()];// new aiVector3D[mesh->mNumVertices];
                stream.readArray(IOStreamUtil.readAiVector3D, mesh.textureCoords[n], mesh.numVertices);
            }
        }

        // write faces. There are no floating-point calculations involved
        // in these, so we can write a simple hash over the face data
        // to the dump file. We generate a single 32 Bit hash for 512 faces
        // using Assimp's standard hashing function.
        if (shortened) {
//Read<unsigned int>(stream);
            stream.readInt32();
        } else {
            // else write as usual
            // if there are less than 2^16 vertices, we can simply use 16 bit integers ...
            mesh.faces = [for (i in 0... mesh.numVertices) new AiFace()];//new aiFace[mesh->mNumFaces];
            for (i in 0...mesh.numFaces) {
                var f = mesh.faces[i];

//static_assert(Mesh.AI_MAX_FACE_INDICES <= 0xffff, "AI_MAX_FACE_INDICES <= 0xffff");
                f.numIndices = stream.readUInt16();
                f.indices = [for (i in 0...f.numIndices) 0];//new unsigned int[f.mNumIndices];

                for (a in 0... f.numIndices) {
                    // Check if unsigned  short ( 16 bit  ) are big enought for the indices
                    if (fitsIntoUI16(mesh.numVertices)) {
                        f.indices[a] = stream.readUInt16();
                    } else {
                        f.indices[a] = stream.readInt32();
                    }
                }
            }
        }

        // write bones
        if (mesh.numBones > 0) {
            mesh.bones = [for (i in 0...mesh.numBones) new AiBone()];//new   aiBone*[mesh->mNumBones];
            for (a in 0...mesh.numBones) {
                mesh.bones[a] = new AiBone();
                readBinaryBone(stream, mesh.bones[a]);
            }
        }
    }

// -----------------------------------------------------------------------------------

    //todo
    function readBinaryMaterialProperty(stream:IOStream, prop:AiMaterialProperty) {

        if (stream.readInt32() != AssbinLoader.ASSBIN_CHUNK_AIMATERIALPROPERTY)
            throw ("Magic chunk identifiers are wrong!");
        var size = stream.readInt32();

        prop.mKey = stream.readAiString();
        prop.mSemantic = stream.readInt32();
        prop.mIndex = stream.readInt32();

        prop.mDataLength = stream.readInt32();
        prop.mType = stream.readInt32();//(aiPropertyTypeInfo)Read<unsigned int>(stream);
        prop.mData = Bytes.alloc(prop.mDataLength);
        stream.readBytes(prop.mData, 0, prop.mDataLength);//todo
    }

// -----------------------------------------------------------------------------------
    function readBinaryMaterial(stream:IOStream, mat:AiMaterial) {
        if (stream.readInt32() != AssbinLoader.ASSBIN_CHUNK_AIMATERIAL)
            throw ("Magic chunk identifiers are wrong!");
        var size = stream.readInt32();

        mat.numAllocated = mat.numProperties = stream.readInt32();
        if (mat.numProperties > 0) {
            if (mat.properties != null) {
                mat.properties = [];
            }
            mat.properties = [for (i in 0...mat.numProperties) new AiMaterialProperty()];//new aiMaterialProperty*[mat->mNumProperties];
            for (i in 0...mat.numProperties) {
//mat.properties[i] = new AiMaterialProperty();
                readBinaryMaterialProperty(stream, mat.properties[i]);
            }
        }
    }

// -----------------------------------------------------------------------------------
    function readBinaryNodeAnim(stream:IOStream, nd:AiNodeAnim) {
        if (stream.readInt32() != AssbinLoader.ASSBIN_CHUNK_AINODEANIM)
            throw ("Magic chunk identifiers are wrong!");
        var size = stream.readInt32();

        nd.nodeName = stream.readAiString();
        nd.numPositionKeys = stream.readInt32();
        nd.numRotationKeys = stream.readInt32();
        nd.numScalingKeys = stream.readInt32();
        nd.preState = stream.readInt32();
        nd.postState = stream.readInt32();

        if (nd.numPositionKeys > 0) {
            if (shortened) {
                stream.readBounds(nd.positionKeys, nd.numPositionKeys);

            } // else write as usual
            else {
                nd.positionKeys = [for (i in 0...nd.numPositionKeys) new AiVectorKey()];//new aiVectorKey[nd->mNumPositionKeys];
                stream.readArray(IOStreamUtil.readAiVectorKey, nd.positionKeys, nd.numPositionKeys);
            }
        }
        if (nd.numRotationKeys > 0) {
            if (shortened) {
                stream.readBounds(nd.rotationKeys, nd.numRotationKeys);

            } else {
                // else write as usual
                nd.rotationKeys = [for (i in 0...nd.numRotationKeys) new AiQuatKey()];//new aiQuatKey[nd->mNumRotationKeys];
                stream.readArray(IOStreamUtil.readAiQuatKey, nd.rotationKeys, nd.numRotationKeys);
            }
        }
        if (nd.numScalingKeys > 0) {
            if (shortened) {
                stream.readBounds(nd.scalingKeys, nd.numScalingKeys);

            } else {
                // else write as usual
                nd.scalingKeys = [for (i in 0...nd.numScalingKeys) new AiVectorKey()];// new aiVectorKey[nd->mNumScalingKeys];
                stream.readArray(IOStreamUtil.readAiVectorKey, nd.scalingKeys, nd.numScalingKeys);
            }
        }
    }

// -----------------------------------------------------------------------------------
    function readBinaryAnim(stream:IOStream, anim:AiAnimation) {
        if (stream.readInt32() != AssbinLoader.ASSBIN_CHUNK_AIANIMATION)
            throw ("Magic chunk identifiers are wrong!");
        var size = stream.readInt32();
        anim.name = stream.readAiString();
        anim.duration = stream.readDouble();
        anim.ticksPerSecond = stream.readDouble();
        anim.numChannels = stream.readInt32();
        if (anim.numChannels > 0) {
            anim.channels = [for (i in 0...anim.numChannels) new AiNodeAnim()]; //new aiNodeAnim*[ anim->mNumChannels ];
            for (a in 0... anim.numChannels) {
                anim.channels[a] = new AiNodeAnim();
                readBinaryNodeAnim(stream, anim.channels[a]);
            }
        }
    }

// -----------------------------------------------------------------------------------
    function readBinaryTexture(stream:IOStream, tex:AiTexture) {
        if (stream.readInt32() != AssbinLoader.ASSBIN_CHUNK_AITEXTURE)
            throw ("Magic chunk identifiers are wrong!");
        var size = stream.readInt32();

        tex.width = stream.readInt32();
        tex.height = stream.readInt32();
        tex.achFormatHint = stream.readString(4); // stream->Read( tex->achFormatHint, sizeof(char), 4 );

        if (!shortened) {
            if (tex.height > 0) {
                tex.pcData = Bytes.alloc(tex.width * 4);//new aiTexel[ tex->mWidth ];
                stream.readBytes(tex.pcData, 0, tex.width * 4);
            } else {
                tex.pcData = Bytes.alloc(tex.width * tex.height * 4);//new aiTexel[ tex->mWidth*tex->mHeight ];
                stream.readBytes(tex.pcData, 0, tex.width * tex.height * 4);
            }
        }
    }

// -----------------------------------------------------------------------------------
    function readBinaryLight(stream:IOStream, l:AiLight) {
        if (stream.readInt32() != AssbinLoader.ASSBIN_CHUNK_AILIGHT)
            throw ("Magic chunk identifiers are wrong!");
        var size = stream.readInt32();

        l.name = stream.readAiString();
        l.type = stream.readInt32();

        if (l.type != AiLightSourceType.DIRECTIONAL) {
            l.attenuationConstant = stream.readFloat();
            l.attenuationLinear = stream.readFloat();
            l.attenuationQuadratic = stream.readFloat();
        }

        l.colorDiffuse = stream.readAiColor3D();
        l.colorSpecular = stream.readAiColor3D();
        l.colorAmbient = stream.readAiColor3D();

        if (l.type == AiLightSourceType.SPOT) {
            l.angleInnerCone = stream.readFloat();
            l.angleOuterCone = stream.readFloat();
        }
    }

// -----------------------------------------------------------------------------------
    function readBinaryCamera(stream:IOStream, cam:AiCamera) {
        if (stream.readInt32() != AssbinLoader.ASSBIN_CHUNK_AICAMERA)
            throw ("Magic chunk identifiers are wrong!");
        var size = stream.readInt32();

        cam.name = stream.readAiString();
        cam.position = stream.readAiVector3D();
        cam.lookAt = stream.readAiVector3D();
        cam.up = stream.readAiVector3D();
        cam.horizontalFOV = stream.readFloat();
        cam.clipPlaneNear = stream.readFloat();
        cam.clipPlaneFar = stream.readFloat();
        cam.aspect = stream.readFloat();
    }

// -----------------------------------------------------------------------------------
    function readBinaryScene(stream:IOStream, scene:AiScene) {
        if (stream.readInt32() != AssbinLoader.ASSBIN_CHUNK_AISCENE)
            throw ("Magic chunk identifiers are wrong!");
        var size = stream.readInt32();

        scene.flags = stream.readInt32();
        scene.numMeshes = stream.readInt32();
        scene.numMaterials = stream.readInt32();
        scene.numAnimations = stream.readInt32();
        scene.numTextures = stream.readInt32();
        scene.numLights = stream.readInt32();
        scene.numCameras = stream.readInt32();

        // Read node graph
        //scene->mRootNode = new aiNode[1];
        readBinaryNode(stream, scene.rootNode, null);

        // Read all meshes
        if (scene.numMeshes > 0) {
            scene.meshes = [for (i in 0...scene.numMeshes) new AiMesh()];//new aiMesh*[scene->mNumMeshes];
            for (i in 0...scene.numMeshes) {
                //  scene.meshes[i] = new AiMesh();
                readBinaryMesh(stream, scene.meshes[i]);
            }
        }

        // Read materials
        if (scene.numMaterials > 0) {
            scene.materials = [for (i in 0...scene.numMaterials) new AiMaterial()];// aiMaterial*[scene->mNumMaterials];
            for (i in 0...scene.numMaterials) {
//scene->mMaterials[i] = new aiMaterial();
                readBinaryMaterial(stream, scene.materials[i]);
            }
        }

        // Read all animations
        if (scene.numAnimations > 0) {
            scene.animations = [for (i in 0...scene.numAnimations) new AiAnimation()];//new aiAnimation*[scene->mNumAnimations];
            for (i in 0...scene.numAnimations) {
//scene->mAnimations[i] = new aiAnimation();

                readBinaryAnim(stream, scene.animations[i]);
            }
        }

        // Read all textures
        if (scene.numTextures > 0) {
            scene.textures = [for (i in 0...scene.numTextures) new AiTexture()];//new aiTexture*[scene->mNumTextures];
            for (i in 0... scene.numTextures) {
//scene->mTextures[i] = new aiTexture();
                readBinaryTexture(stream, scene.textures[i]);
            }
        }

        // Read lights
        if (scene.numLights > 0) {

            scene.lights = [for (i in 0...scene.numLights) new AiLight()];//new aiLight*[scene->mNumLights];
            for (i in 0...scene.numLights) {
//scene->mLights[i] = new aiLight();
                readBinaryLight(stream, scene.lights[i]);
            }
        }

        // Read cameras
        if (scene.numCameras > 0) {
            scene.cameras = [for (i in 0...scene.numCameras) new AiCamera()];//new aiCamera*[scene->mNumCameras];

            for (i in 0...scene.numCameras) {
//scene->mCameras[i] = new aiCamera();
                readBinaryCamera(stream, scene.cameras[i]);
            }
        }

    }

}
