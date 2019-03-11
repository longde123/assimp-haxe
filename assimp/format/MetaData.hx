package assimp.format;

/** Enum used to distinguish data types */
import assimp.format.Defs.AiVector3D;
import Lambda;
import haxe.ds.StringMap;
@:enum abstract AiMetadataType(Int) from Int to Int {
    var BOOL = 0;
    var INT32 = 1;
    var UINT64 = 2;
    var FLOAT = 3;
    var DOUBLE = 4;
    var AISTRING = 5;
    var AIVECTOR3D = 6;
}

/**
 * Metadata entry
 *
 * The type field uniquely identifies the underlying type of the data field
 */
class AiMetadataEntry<T> {
    public var type:AiMetadataType;
    public var data:T;

    public function new(t:AiMetadataType, value:T):Void {
        this.data = value;
        this.type = t;

    }

}


/**
 * Container for holding metadata.
 *
 * Metadata is a key-value store using string keys and values.
 */
class AiMetadata {
    /** Arrays of keys, may not be NULL. Entries in this array may not be NULL as well.
         *  Arrays of values, may not be NULL. Entries in this array may be NULL if the corresponding property key has no
         *  assigned value. => JVM map  */
    public var map:StringMap<AiMetadataEntry< Any>> ;

    public function new():Void {
        this.map = new StringMap<AiMetadataEntry< Any>>();
    }
    /** Length of the mKeys and mValues arrays, respectively */
    public function numProperties() {
        return Lambda.count(map);
    }

    public function keys() {
        return map.keys();
    }

    public function set(key:String, value:AiMetadataEntry<Any>) {
        // Ensure that we have a valid key.
        return if (key == null) {
            false;
        }
        else {
            // Set metadata key
            map.set(key, value);
            true;
        };
    }

    public function clear() {
        this.map = new StringMap<AiMetadataEntry< Any>>();
    }

    public function isEmpty() {
        return Lambda.empty(map);
    }

    public function isNotEmpty() {
        return !Lambda.empty(map);
    }

    public function get(key:String):AiMetadataEntry< Any> {
        return map.exists(key) ? map.get(key) : null;
    }
}

