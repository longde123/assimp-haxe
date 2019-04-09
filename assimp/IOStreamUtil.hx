package assimp;

import haxe.io.BytesOutput;
import haxe.io.Bytes;
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
    static public function writeAiColor4D(stream:BytesOutput ,c :AiColor4D) {

        stream.writeFloat( c.r );
        stream.writeFloat( c.g );
        stream.writeFloat( c.b  );
        stream.writeFloat( c.a  );
        return stream;
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

    static public function writeAiString(stream:BytesOutput,s:String):BytesOutput {
        var tmp=new BytesOutput();
        tmp.writeString(s);
        var len = tmp.length;
        stream.writeInt32(len);
        stream.writeString(s);
        return stream;
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
        /* aiMatrix4x4 m;
    for (unsigned int i = 0; i < 4;++i) {
        for (unsigned int i2 = 0; i2 < 4;++i2) {
            m[i][i2] = Read<float>(stream);
            cloum row
        }
    }*/

        // Assimp aiMatrix4x4 are row-major meanwhile

        var arr:Array<Float> = [for (i in 0...16) stream.readFloat()];
        // glm mat4 are column-major (so are OpenGL matrices)
//        var m:AiMatrix4x4 = new AiMatrix4x4(
//            arr[ 0], arr[ 1], arr[ 2], arr[3],
//            arr[ 4], arr[ 5], arr[ 6], arr[7],
//            arr[ 8], arr[ 9], arr[10], arr[11],
//            arr[ 12], arr[ 13], arr[14], arr[15]
//        );
        var m:AiMatrix4x4 =arr;
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
