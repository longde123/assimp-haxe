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

    static function squareLength2(this1:AiVector3D) {
        return this1.x * this1.x + this1.y * this1.y + this1.z * this1.z;
    }


    public static function rotationX(a:Float):AiMatrix4x4 {
        var tmp:Mat4 = Mat4.identity(new AiMatrix4x4());

        /*
         |  1  0       0       0 |
     M = |  0  cos(A)  sin(A)  0 |
         |  0 -sin(A)  cos(A)  0 |
         |  0  0       0       1 |        */
        tmp.r1c1 = Math.cos(a);
        tmp.r2c2 = Math.cos(a);
        tmp.r1c2 = Math.sin(a);
        tmp.r2c1 = -Math.sin(a);
        return tmp;
    }

    public static function rotationY(a:Float) {
        var tmp:Mat4 = Mat4.identity(new AiMatrix4x4());

        /*
         |  cos(A)  0  -sin(A)  0 |
     M = |  0       1   0       0 |
         | sin(A)   0   cos(A)  0 |
         |  0       0   0       1 |        */
        tmp.r0c0 = Math.cos(a);
        tmp.r2c2 = Math.cos(a);
        tmp.r2c0 = Math.sin(a);
        tmp.r0c2 = -Math.sin(a);
        return tmp;
    }

    public static function rotationZ(a:Float) {
        var tmp:Mat4 = Mat4.identity(new AiMatrix4x4());

        /*
         |  cos(A)   sin(A)   0   0 |
     M = | -sin(A)   cos(A)   0   0 |
         |  0        0        1   0 |
         |  0        0        0   1 |       */
        tmp.r0c0 = Math.cos(a);
        tmp.r1c1 = Math.cos(a);
        tmp.r0c1 = Math.sin(a);
        tmp.r1c0 = -Math.sin(a);
        return tmp;
    }

    public static function translation(v:Vec3) {
        var tmp:Mat4 = Mat4.identity(new AiMatrix4x4());
        tmp.r0c3 = v.x;
        tmp.r1c3 = v.y;
        tmp.r2c3 = v.z;
        return tmp;
    }

    public static function scaling(v:Vec3) {
        var tmp:Mat4 = Mat4.identity(new AiMatrix4x4());
        tmp.r0c0 = v.x;
        tmp.r1c1 = v.y;
        tmp.r2c2 = v.z;
        return tmp;
    }
    /// <summary>
    /// Constructs a new Quaternion from a rotation matrix.
    /// </summary>
    /// <param name="matrix">Rotation matrix to create the Quaternion from.</param>
    public static function toQuaternion(matrix:AiMatrix3x3) {
        var trace = matrix.r0c0 + matrix.r1c1 + matrix.r2c2;
        var X = 0.0;
        var Y = 0.0;
        var Z = 0.0;
        var W = 0.0;

        if (trace > 0) {
            var s = Math.sqrt(trace + 1.0) * 2.0;
            W = .25 * s;

            X = (matrix.r2c1 - matrix.r1c2) / s;
            Y = (matrix.r0c2 - matrix.r2c0) / s;
            Z = (matrix.r1c0 - matrix.r0c1) / s;
        }
        else if ((matrix.r0c0 > matrix.r1c1) && (matrix.r0c0 > matrix.r2c2)) {
            var s = Math.sqrt(((1.0 + matrix.r0c0) - matrix.r1c1) - matrix.r2c2) * 2.0 ;
            W = (matrix.r1c1 - matrix.r2c2) / s;
            X = .25 * s;
            Y = (matrix.r0c1 + matrix.r1c0) / s;
            Z = (matrix.r0c2 + matrix.r2c0) / s;
        }
        else if (matrix.r1c1 > matrix.r2c2) {
            var s = Math.sqrt(((1.0 + matrix.r1c1) - matrix.r0c0) - matrix.r2c2) * 2.0;
            W = (matrix.r0c2 - matrix.r2c0) / s;
            X = (matrix.r0c1 + matrix.r1c0) / s;
            Y = .25 * s;
            Z = (matrix.r1c2 + matrix.r2c1) / s;
        }
        else {
            var s = Math.sqrt(((1.0 + matrix.r2c2) - matrix.r0c0) - matrix.r1c1) * 2.0 ;
            W = (matrix.r1c0 - matrix.r0c1) / s;
            X = (matrix.r0c2 + matrix.r2c0) / s;
            Y = (matrix.r1c2 + matrix.r2c1) / s;
            Z = .25 * s;
        }
        var tmp = new AiQuaternion();
        Quat.normalize(new Quat(X, Y, Z, W), tmp);
        return tmp;
    }

    public static function decompose(this1:Mat4, pScaling:AiVector3D, pRotation:AiQuaternion, pPosition:AiVector3D) {

        /* extract translation */
        pPosition.x = this1.r1c3;
        pPosition.y = this1.r1c3;
        pPosition.z = this1.r2c3;

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

/** Transformation of a vector by a 4x4 matrix */
    public static function times(this1:AiMatrix4x4, vector:AiVector3D) {
        return new AiVector3D(
        this1.r0c0 * vector.x + this1.r1c0 * vector.y + this1.r2c0 * vector.z + this1.r3c0,
        this1.r0c1 * vector.x + this1.r1c1 * vector.y + this1.r2c1 * vector.z + this1.r3c1,
        this1.r0c2 * vector.x + this1.r1c2 * vector.y + this1.r2c2 * vector.z + this1.r3c2);
    }

    public static var epsilon = 10e-3;

    public static function isBlack(this1:Vec3) return Math.abs(this1.x) < epsilon && Math.abs(this1.y) < epsilon && Math.abs(this1.z) < epsilon;

}
