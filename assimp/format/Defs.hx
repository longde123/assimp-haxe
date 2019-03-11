package assimp.format;
/**
         * Created by elect on 14/11/2016.
         */

import glm.Mat4;
import glm.Quat;
import glm.Vec2;
import glm.Mat4;
import glm.Mat3;
import glm.Vec4;
import glm.Vec3;
typedef Ai_real = Float;
typedef AiVector3D = Vec3;
typedef AiColor3D = Vec3;
typedef AiColor4D = Vec4;
typedef AiVector2D = Vec2;
typedef AiQuaternion = Quat;
typedef AiMatrix4x4 = Mat4;
typedef AiMatrix3x3 = Mat3;
/*
*

			_r0c0:Float = 0, _r0c1:Float = 0, _r0c2:Float = 0,
            _r1c0:Float = 0, _r1c1:Float = 0, _r1c2:Float = 0,
            _r2c0:Float = 0, _r2c1:Float = 0, _r2c2:Float = 0

            bone.offsetMatrix.a0,bone.offsetMatrix.b0,bone.offsetMatrix.c0,bone.offsetMatrix.d0,
            bone.offsetMatrix.a1,bone.offsetMatrix.b1,bone.offsetMatrix.c1,bone.offsetMatrix.d1,
            bone.offsetMatrix.a2,bone.offsetMatrix.b2,bone.offsetMatrix.c2,bone.offsetMatrix.d2,
            bone.offsetMatrix.a3,bone.offsetMatrix.b3,bone.offsetMatrix.c3,bone.offsetMatrix.d3
            */
class AiDefines {

/// <summary>
/// Default value for <see cref="AiConfigs.AI_CONFIG_PP_SLM_TRIANGLE_LIMIT"/>.
/// </summary>
    public static var AI_SLM_DEFAULT_MAX_TRIANGLES = 1000000;

    /// <summary>
    /// Default value for <see cref="AiConfigs.AI_CONFIG_PP_SLM_VERTEX_LIMIT"/>.
    /// </summary>
    public static var AI_SLM_DEFAULT_MAX_VERTICES = 1000000;

    /// <summary>
    /// Default value for <see cref="AiConfigs.AI_CONFIG_PP_LBW_MAX_WEIGHTS"/>.
    /// </summary>
    public static var AI_LBW_MAX_WEIGHTS = 0x4;

    /// <summary>
    /// Default value for <see cref="AiConfigs.AI_CONFIG_PP_ICL_PTCACHE_SIZE"/>.
    /// </summary>
    public static var PP_ICL_PTCACHE_SIZE = 12;

    /// <summary>
    /// Default value for <see cref="AiConfigs.AI_CONFIG_PP_TUV_EVALUATE"/>
    /// </summary>
//todo
// public const int AI_UVTRAFO_ALL = (int) (UVTransformFlags.Rotation | UVTransformFlags.Scaling | UVTransformFlags.Translation);


    /// <summary>
    /// Defines the maximum number of indices per face (polygon).
    /// </summary>
    public static var AI_MAX_FACE_INDICES = 0x7fff;

    /// <summary>
    /// Defines the maximum number of bone weights.
    /// </summary>
    public static var AI_MAX_BONE_WEIGHTS = 0x7fffffff;

    /// <summary>
    /// Defines the maximum number of vertices per mesh.
    /// </summary>
    public static var AI_MAX_VERTICES = 0x7fffffff;

    /// <summary>
    /// Defines the maximum number of faces per mesh.
    /// </summary>
    public static var AI_MAX_FACES = 0x7fffffff;

    /// <summary>
    /// Defines the maximum number of vertex color sets per mesh.
    /// </summary>
    public static var AI_MAX_NUMBER_OF_COLOR_SETS = 0x8;

    /// <summary>
    /// Defines the maximum number of texture coordinate sets (UV(W) channels) per mesh.
    /// </summary>
    public static var AI_MAX_NUMBER_OF_TEXTURECOORDS = 0x8;

    /// <summary>
    /// Defines the default bone count limit.
    /// </summary>
    public static var AI_SBBC_DEFAULT_MAX_BONES = 60;

    /// <summary>
    /// Defines the deboning threshold.
    /// </summary>
    public static var AI_DEBONE_THRESHOLD = 1.0;


    /// <summary>
    /// Defines the maximum length of a string used in AiString.
    /// </summary>
    public static var MAX_LENGTH = 1024;


    /// <summary>
    /// Defines the default color material.
    /// </summary>
    public static var AI_DEFAULT_MATERIAL_NAME = "DefaultMaterial";

    /// <summary>
    /// Defines the default textured material (if the meshes have UV coords).
    /// </summary>
    public static var AI_DEFAULT_TEXTURED_MATERIAL_NAME = "TexturedDefaultMaterial";

}
class Defs {


/* To avoid running out of memory
 * This can be adjusted for specific use cases
 * It's NOT a total limit, just a limit for individual allocations
 */
    public static function AI_MAX_ALLOC(size:Int) return (256 * 1024 * 1024) / size;
/** Consider using extension property Float.rad */
    public static function AI_DEG_TO_RAD(x:Float) return ((x) * 0.0174532925);
/** Consider using extension property Float.deg */
    public static function AI_RAD_TO_DEG(x:Float) return ((x) * 57.2957795);

    public static function is_special_float(f:Float):Bool {
        return f == (1 << 8) - 1;
    }

    public static function distance(this1:Vec3, other:Vec3):Float {
        return Math.sqrt(Math.pow(this1.x + other.x, 2.0)
        + Math.pow(this1.y + other.y, 2.0)
        + Math.pow(this1.z + other.z, 2.0));
    }

    public static function squareLength(this1:Vec3) {
        return Math.sqrt(Math.pow(this1.x, 2.0)
        + Math.pow(this1.y, 2.0)
        + Math.pow(this1.z, 2.0));
    }

/* This is PI. Hi PI. */
    public static var AI_MATH_TWO_PI = Math.PI * 2;
    public static var AI_MATH_TWO_PIf = Math.PI * 2;
    public static var AI_MATH_HALF_PI = Math.PI;


    /// <summary>
    /// Constructs a new Quaternion from a rotation matrix.
    /// </summary>
    /// <param name="matrix">Rotation matrix to create the Quaternion from.</param>
    public static function toQuaternion(matrix:AiMatrix3x3) {
        var trace1 = matrix.r0c0 + matrix.r1c1 + matrix.r2c2;
        var X = 0.0;
        var Y = 0.0;
        var Z = 0.0;
        var W = 0.0;
//        float trace = matrix.A1 + matrix.B2 + matrix.C3;
//


        //        if(trace > 0)
//        {
//            float s = (float) Math.Sqrt(trace + 1.0f) * 2.0f;
//            W = .25f * s;
//            X = (matrix.C2 - matrix.B3) / s;
//            Y = (matrix.A3 - matrix.C1) / s;
//            Z = (matrix.B1 - matrix.A2) / s;
//        }
        if (trace1 > 0) {
            var s = Math.sqrt(trace1 + 1.0) * 2.0;
            W = .25 * s;
            X = (matrix.r1c2 - matrix.r2c1) / s;
            Y = (matrix.r2c0 - matrix.r0c2) / s;
            Z = (matrix.r0c1 - matrix.r1c0) / s;
        }

//        else if((matrix.A1 > matrix.B2) && (matrix.A1 > matrix.C3))
//        {
//            float s = (float) Math.Sqrt(((1.0 + matrix.A1) - matrix.B2) - matrix.C3) * 2.0f;
//            W = (matrix.C2 - matrix.B3) / s;
//            X = .25f * s;
//            Y = (matrix.A2 + matrix.B1) / s;
//            Z = (matrix.A3 + matrix.C1) / s;
//        }
        else if ((matrix.r0c0 > matrix.r1c1) && (matrix.r0c0 > matrix.r2c2)) {
            var s = Math.sqrt(((1.0 + matrix.r0c0) - matrix.r1c1) - matrix.r2c2) * 2.0 ;
            W = (matrix.r1c2 - matrix.r2c1) / s;
            X = .25 * s;
            Y = (matrix.r1c0 + matrix.r0c1) / s;
            Z = (matrix.r2c0 + matrix.r0c2) / s;
        }
            //        else if(matrix.B2 > matrix.C3)
//        {
//            float s = (float) Math.Sqrt(((1.0f + matrix.B2) - matrix.A1) - matrix.C3) * 2.0f;
//        W = (matrix.A3 - matrix.C1) / s;
//        X = (matrix.A2 + matrix.B1) / s;
//        Y = .25f * s;
//        Z = (matrix.B3 + matrix.C2) / s;
//        }
        else if (matrix.r1c1 > matrix.r2c2) {
            var s = Math.sqrt(((1.0 + matrix.r1c1) - matrix.r0c0) - matrix.r2c2) * 2.0;
            W = (matrix.r2c0 - matrix.r0c2) / s;
            X = (matrix.r1c0 + matrix.r0c1) / s;
            Y = .25 * s;
            Z = (matrix.r2c1 + matrix.r1c2) / s;
        }

//        else
//        {
//            float s = (float) Math.Sqrt(((1.0f + matrix.C3) - matrix.A1) - matrix.B2) * 2.0f;
//        W = (matrix.B1 - matrix.A2) / s;
//        X = (matrix.A3 + matrix.C1) / s;
//        Y = (matrix.B3 + matrix.C2) / s;
//            Z = .25f * s;
//        }
        else {
            var s = Math.sqrt(((1.0 + matrix.r2c2) - matrix.r0c0) - matrix.r1c1) * 2.0 ;
            W = (matrix.r0c1 - matrix.r1c0) / s;
            X = (matrix.r2c0 + matrix.r0c2) / s;
            Y = (matrix.r2c1 + matrix.r1c2) / s;
            Z = .25 * s;
        }
        var tmp = new AiQuaternion();
        Quat.normalize(new Quat(X, Y, Z, W), tmp);
        return tmp;
    }

    public static function decompose(this1:Mat4, pScaling:AiVector3D, pRotation:AiQuaternion, pPosition:AiVector3D) {

        /* extract translation */
        pPosition.x = this1.r3c1;
        pPosition.y = this1.r3c2;
        pPosition.z = this1.r3c3;

        /* extract the columns of the matrix. */
        var vCols = [
            new AiVector3D(this1.r0c0, this1.r1c0, this1.r2c0),
            new AiVector3D(this1.r0c1, this1.r1c1, this1.r2c1),
            new AiVector3D(this1.r0c2, this1.r1c2, this1.r2c2)];

        /* extract the scaling factors */
        pScaling.x = vCols[0].length();
        pScaling.y = vCols[1].length();
        pScaling.z = vCols[2].length();

        /* and the sign of the scaling */
//todo if (det < 0) pScaling.negateAssign()

        /* and remove all scaling from the matrix */
        if (pScaling.x != 0) vCols[0] /= pScaling.x;
        if (pScaling.y != 0) vCols[1] /= pScaling.y;
        if (pScaling.z != 0) vCols[2] /= pScaling.z;

        // build a 3x3 rotation matrix
        var m = new AiMatrix3x3(
        vCols[0].x, vCols[1].x, vCols[2].x,
        vCols[0].y, vCols[1].y, vCols[2].y,
        vCols[0].z, vCols[1].z, vCols[2].z);

        // and generate the rotation quaternion from it
        var q:AiQuaternion = toQuaternion(m);
        pRotation.x = q.x;
        pRotation.y = q.y;
        pRotation.z = q.z;
        pRotation.w = q.w;
    }

    static public function getMatrix(q:AiQuaternion):AiMatrix3x3 {
        var X = q.x;
        var Y = q.y;
        var Z = q.z;
        var W = q.z;
        var xx = X * X;
        var yy = Y * Y;
        var zz = Z * Z;

        var xy = X * Y;
        var zw = Z * W;
        var zx = Z * X;
        var yw = Y * W;
        var yz = Y * Z;
        var xw = X * W;

        var mat = new AiMatrix3x3();
        mat.r0c0 = 1.0 - (2.0 * (yy + zz));
        mat.r0c1 = 2.0 * (xy + zw);
        mat.r0c2 = 2.0 * (zx - yw);

        mat.r1c0 = 2.0 * (xy - zw);
        mat.r1c1 = 1.0 - (2.0 * (zz + xx));
        mat.r1c2 = 2.0 * (yz + xw);

        mat.r2c0 = 2.0 * (zx + yw);
        mat.r2c1 = 2.0 * (yz - xw);
        mat.r2c2 = 1.0 - (2.0 * (yy + xx));

        return mat;
    }

    static public function slerp(start:AiQuaternion, end:AiQuaternion, factor:Float):AiQuaternion {
        //Calc cosine theta
        var cosom = (start.x * end.x) + (start.y * end.y) + (start.z * end.z) + (start.w * end.w);

        //Reverse signs if needed
        if (cosom < 0.0) {
            cosom = -cosom;
            end.x = -end.x;
            end.y = -end.y;
            end.z = -end.z;
            end.w = -end.w;
        }

        //calculate coefficients
        var sclp:Float = 0;
        var sclq:Float = 0;
        //0.0001 -> some episilon
        if ((1.0 - cosom) > 0.0001) {
            //Do a slerp
            var omega:Float = 0;
            var sinom:Float = 0;
            omega = Math.acos(cosom); //extract theta from the product's cos theta
            sinom = Math.sin(omega);
            sclp = Math.sin((1.0 - factor) * omega) / sinom;
            sclq = Math.sin(factor * omega) / sinom;
        }
        else {
            //Very close, do a lerp instead since its faster
            sclp = 1.0 - factor;
            sclq = factor;
        }

        var q:AiQuaternion = new AiQuaternion();
        q.x = (sclp * start.x) + (sclq * end.x);
        q.y = (sclp * start.y) + (sclq * end.y);
        q.z = (sclp * start.z) + (sclq * end.z);
        q.w = (sclp * start.w) + (sclq * end.w);
        return q;
    }


    public static var epsilon = 10e-3;

    public static function isBlack(this1:Vec3) return Math.abs(this1.x) < epsilon && Math.abs(this1.y) < epsilon && Math.abs(this1.z) < epsilon;

}
