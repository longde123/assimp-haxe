package assimp;

import assimp.format.Defs.AiColor3D;
import assimp.format.Anim.AiQuatKey;
import assimp.format.Anim.AiVectorKey;
import assimp.format.Defs.AiMatrix4x4;
import assimp.format.Mesh.AiVertexWeight;
import assimp.format.Defs.AiQuaternion;
import assimp.format.Defs.AiColor4D;
import assimp.format.Defs.AiVector3D;
import assimp.IOSystem.IOStream;
typedef Read<T> = IOStream -> T ;
class IOStreamUtil {

// -----------------------------------------------------------------------------------
    inline static public function readT<T>(stream:IOStream, r:Read<T>) {
        var t = r(stream);
        return t;
    }

// -----------------------------------------------------------------------------------
    static public function readAiVector3D(stream:IOStream) {
        var v = new AiVector3D();
        v.x = stream.readFloat();
        v.y = stream.readFloat();
        v.z = stream.readFloat();
        return v;
    }

    static public function readAiColor3D(stream:IOStream) {
        var c = new AiColor3D();
        c.r = stream.readFloat();
        c.g = stream.readFloat();
        c.b = stream.readFloat();
        return c;
    }
// -----------------------------------------------------------------------------------
    static public function readAiColor4D(stream:IOStream) {
        var c = new AiColor4D();
        c.r = stream.readFloat();
        c.g = stream.readFloat();
        c.b = stream.readFloat();
        c.a = stream.readFloat();
        return c;
    }

// -----------------------------------------------------------------------------------
    static public function readAiQuaternion(stream:IOStream) {
        var v = new AiQuaternion();
        v.w = stream.readFloat();
        v.x = stream.readFloat();
        v.y = stream.readFloat();
        v.z = stream.readFloat();
        return v;
    }

// -----------------------------------------------------------------------------------
    static public function readAiString(stream:IOStream):String {
        var len = stream.readInt32();
        if (len > 0) {
            var s = stream.readString(len);
            return s;
        }
        return null;
    }

// -----------------------------------------------------------------------------------
    static public function readAiVertexWeight(stream:IOStream) {
        var w:AiVertexWeight = new AiVertexWeight();
        w.vertexId = stream.readInt32(); //uint;
        w.weight = stream.readFloat();
        return w;
    }

// -----------------------------------------------------------------------------------
    static public function readAiMatrix4x4(stream:IOStream) {
        var tmp:Array<Float> = [for (i in 0...16) stream.readFloat()];
        var m:AiMatrix4x4 = tmp;
        return m;
    }

// -----------------------------------------------------------------------------------
    static public function readAiVectorKey(stream:IOStream) {
        var v:AiVectorKey = new AiVectorKey();
        v.time = stream.readDouble();
        v.value = readAiVector3D(stream);
        return v;
    }

// -----------------------------------------------------------------------------------
    static public function readAiQuatKey(stream:IOStream) {
        var v = new AiQuatKey();
        v.time = stream.readDouble();
        v.value = readAiQuaternion(stream);
        return v;
    }

// -----------------------------------------------------------------------------------
    static public function readArray<T>(stream:IOStream, r:Read<T>, out:Array<T>, size:Int) {
        for (i in 0...size) {
            out[i] = readT(stream, r);
        }
        return out;
    }

// -----------------------------------------------------------------------------------
    static public function readBounds(stream:IOStream, size:Any, n:Int) {
        // not sure what to do here, the data isn't really useful.
        //stream.seek(size * n);
    }
}
