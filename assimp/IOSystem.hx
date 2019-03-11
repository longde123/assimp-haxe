package assimp;
import assimp.format.Defs.AiColor4D;
import assimp.IOSystem.IOStream;
import assimp.format.Defs.AiVector3D;
import haxe.io.BytesInput;
import haxe.io.Bytes;
class MemoryIOSystem extends IOSystem {
    public var filename:String;
    public var bytes:Bytes;

    public function new(filename:String, bytes:Bytes) {
        super();
        this.filename = filename;
        this.bytes = bytes;
    }
}
class MemoryIOStream extends IOStream {
    public function new(b:Bytes, ?pos:Int, ?len:Int) {
        super(b, pos, len);
    }
}
class IOStream extends BytesInput {
    public var path:String;
    public var filename:String;
    public var parentPath:String;

    public function new(b:Bytes, ?pos:Int, ?len:Int) {
        super(b, pos, len);
    }
    /**
     * length of the IOStream in bytes
     */

    /**
     * reads the ioStream into a byte buffer.
     * The byte order of the buffer is be [ByteOrder.nativeOrder].
     */
    public function seek(n:Int) {
        this.position += n;
    }
}
class IOSystem {
    public function exists(file:String):Bool {
        return false;
    }

    public function open(file:String):IOStream {
        return null;
    }

    public function close(stream:IOStream) {

    }

    public function new() {
    }
}
