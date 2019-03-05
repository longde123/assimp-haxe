package assimp;
class Hash {
    public static function superFastHash(key:String, len:Int = 0, hash:Int = 0):Int {
        if (len == 0) {
            len = key.length;
        }

        inline function get16bits(key:String, index:Int) {
            return (key.charCodeAt(index) | (key.charCodeAt(index + 1) << 8));
        }
        var length = len;
        var hash = length;
        var tmp = 0;
        var rem = 0;

        rem = length & 3;
        length >>= 2;

        // Mix function, iterates through input string in 4 byte chunks.
        var i = 0;
        while (i < length) {
            hash += get16bits(key, i);
            tmp = (get16bits(key, i + 2) << 11) ^ hash;
            hash = (hash << 16) ^ tmp;
            hash += hash >> 11;
            i += 4;
        }

        switch (rem) {
            case 3:
                hash += get16bits(key, i);
                hash ^= hash << 16;
                hash ^= key.charCodeAt(i + 1);
                hash += hash >> 11;

            case 2:
                hash += get16bits(key, i);
                hash ^= hash << 11;
                hash += hash >> 17;
            case 1:
                hash += key.charCodeAt(i);
                hash ^= hash << 10;
                hash += hash >> 1;
        }

        /* Force "avalanching" of final 127 bits */
        hash ^= hash << 3;
        hash += hash >> 5;
        hash ^= hash << 4;
        hash += hash >> 17;
        hash ^= hash << 25;
        hash += hash >> 6;

        return hash;
    }

}
