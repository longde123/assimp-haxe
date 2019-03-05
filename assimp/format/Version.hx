package assimp.format;
class Version {

/** @brief Returns a string with legal copyright and licensing information about Assimp. The string may include multiple
 *  lines.
 *  @return Pointer to static string.
 */
    public static var legalString = "\"";
/*
    Open Asset Import Library (Assimp).
    A free C/C++ library to import various 3D file formats into applications

    (c) 2008-2017, assimp team
    License under the terms and conditions of the 3-clause BSD license
    http://assimp.sourceforge.net\n"""
*/
/** @brief Returns the current minor version number of Assimp.
 *  @return Minor version of the Assimp runtime the application was linked/built against
 */
    public static var versionMinor = 0;

/** @brief Returns the current major version number of Assimp.
 *  @return Major version of the Assimp runtime the application was linked/built against
 */
    public static var versionMajor = 4;

/** @brief Returns the repository revision of the Assimp runtime.
 *  @return SVN Repository revision number of the Assimp runtime the application was linked/built against.
 */
    public static var versionRevision = 0xee56ffa1;
    public static var branch = "master";

/** JVM custom */
    public static var build = 14;

/** @brief Returns assimp's compile flags
 *  @return Any bitwise combination of the ASSIMP_CFLAGS_xxx constants.
 */
    public static var compileFlags = Assimp.DEBUG;

/** JVM custom */
    public static var version = "$versionMajor.$versionMinor.$build";

    public function new() {
    }
}
