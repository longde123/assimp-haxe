package assimp;
class StringUtil {
    static public function formatString(s:String, d:Any) {
        return StringTools.replace(s, "%", d + "");
    }
}
