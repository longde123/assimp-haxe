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
        super();
        bytesInput=new BytesInput(b,pos,len);
    }
}
class IOStream    {
    public var path:String;
    public var filename:String;
    public var parentPath:String;
    /** The length of the stream in bytes. */
    public var length(get,never) : Int;

    public var position(get,set) : Int;

    public var bytesInput:BytesInput;
    public function new() {
    }

    inline function get_length() : Int {
        return bytesInput.length;

    }
    inline function get_position() : Int {

        return bytesInput.position;
    }

    inline   function set_position( p : Int ) : Int {

        return  bytesInput.position =p;
    }
    inline public function seek(n:Int) {
        bytesInput.position += n;
    }

    inline public   function readByte() : Int {
         return bytesInput.readByte();
    }
    inline public   function readBytes( buf : Bytes, pos, len ) : Int {
        return bytesInput.readBytes( buf , pos, len);
    }
    inline public function readFloat() {
		return bytesInput.readFloat() ;
	}
    inline public function readDouble() {
		return bytesInput.readDouble()  ;
	}
    inline public function readInt8() {
		return bytesInput.readInt8() ;
	}
    inline public function readInt16() {
		return bytesInput.readInt16();
	}
    inline public function readUInt16() : Int {
		return bytesInput.readUInt16()  ;
	}
    inline public function readInt32() : Int {
		return bytesInput.readInt32() ;
	}
    inline public function readString( len : Int ) {
		return bytesInput.readString(len)  ;
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
