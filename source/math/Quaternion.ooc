//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
import FloatPoint3D
import FloatRotation3D
import FloatTransform2D
import FloatTransform3D
import math

Quaternion: cover {
	real: Float
	imaginary: FloatPoint3D
	precision := 0.000001f
	// q = w + xi + yj + zk
	w ::= this real
	x ::= this imaginary x
	y ::= this imaginary y
	z ::= this imaginary z

	// NOTE: The coordinates are represented differently in C# Kean:
	// x = this w
	// y = this x
	// z = this y
	// w = this z

	inverse ::= This new(this w, -this x, -this y, -this z)
	isValid ::= (this w == this w && this x == this x && this y == this y && this z == this z)
	isIdentity ::= (this w == 1.0f && this x == 0.0f && this y == 0.0f && this z == 0.0f)
	isNull ::= (this w == 0.0f && this x == 0.0f && this y == 0.0f && this z == 0.0f)
	norm ::= (this real squared() + (this imaginary norm) squared()) sqrt()
	normalized ::= this / this norm
	rotation ::= 2.0f * (this logarithm imaginary) norm
	conjugate ::= This new(this real, -(this imaginary))
	identity: static This { get { This new(1.0f, 0.0f, 0.0f, 0.0f) } }
	init: func@ (=real, =imaginary)
	init: func@ ~floats (w, x, y, z: Float) { this init(w, FloatPoint3D new(x, y, z)) }
	init: func@ ~default { this init(0, 0, 0, 0) }
	init: func@ ~floatArray (source: Float[]) { this init(source[0], source[1], source[2], source[3]) }
	apply: func (vector: FloatPoint3D) -> FloatPoint3D {
 		vectorQuaternion := This new(0.0f, vector)
		result := hamiltonProduct(hamiltonProduct(this, vectorQuaternion), this inverse)
		FloatPoint3D new(result x, result y, result z)
	}
	createRotation: static func (angle: Float, direction: FloatPoint3D) -> This {
		halfAngle := angle / 2.0f
		point3DNorm := direction norm
		if (point3DNorm != 0.0f)
			direction /= point3DNorm
		This new(0.0f, halfAngle * direction) exponential
	}
	createRotationX: static func (angle: Float) -> This {
		This createRotation(angle, FloatPoint3D new(1.0f, 0.0f, 0.0f))
	}
	createRotationY: static func (angle: Float) -> This {
		This createRotation(angle, FloatPoint3D new(0.0f, 1.0f, 0.0f))
	}
	createRotationZ: static func (angle: Float) -> This {
		This createRotation(angle, FloatPoint3D new(0.0f, 0.0f, 1.0f))
	}
	hamiltonProduct: static func (left, right: This) -> This {
		a1 := left w;
		b1 := left x;
		c1 := left y;
		d1 := left z;
		a2 := right w;
		b2 := right x;
		c2 := right y;
		d2 := right z;

		w := a1 * a2 - b1 * b2 - c1 * c2 - d1 * d2;
		x := a1 * b2 + b1 * a2 + c1 * d2 - d1 * c2;
		y := a1 * c2 - b1 * d2 + c1 * a2 + d1 * b2;
		z := a1 * d2 + b1 * c2 - c1 * b2 + d1 * a2;
		return This new(w, x, y, z);
	}
	getEulerAngles: func -> FloatRotation3D {
		// http://www.jldoty.com/code/DirectX/YPRfromUF/YPRfromUF.html
		// Should be used in order Yaw -> Pitch -> Roll or Pitch -> Yaw -> Roll,
		// According to jldoty it should be Roll -> Pitch -> Yaw, but this doesn't work
		//
		// Forward, up and right might need to be changed depending on phone coordinate system and camera direction
		// World coordinates: x axis -> west, y axis -> north, z axis -> up
		// Forward is direction of camera.
		forward := FloatPoint3D new(0.0f, 0.0f, -1.0f)
		up := FloatPoint3D new(1.0f, 0.0f, 0.0f)
		right := FloatPoint3D new(0.0f, -1.0f, 0.0f)

		forwardRotated := this apply(forward)
		upRotated := this apply(up)

		pitch := asin(-forwardRotated z) - Float pi / 2.0f
		yaw := atan2(forwardRotated y, forwardRotated x)

		yawTransform := FloatTransform2D new(cos(yaw), sin(yaw), 0.0f, -sin(yaw), cos(yaw), 0.0f, 0.0f, 0.0f, 1.0f)
		pitchTransform := FloatTransform2D new(cos(pitch), 0.0f, -sin(pitch), 0.0f, 1.0f, 0.0f, sin(pitch), 0.0f, cos(pitch))
		yawAndPitch := yawTransform * pitchTransform

		upYawPitch := yawAndPitch * up
		rightYawPitch := yawAndPitch * right

		roll: Float
		if (Float absolute(rightYawPitch x) > Float absolute(rightYawPitch y) && Float absolute(rightYawPitch x) > Float absolute(rightYawPitch z))
			roll = asin((upYawPitch scalarProduct(upRotated) * upYawPitch x - upRotated x) / rightYawPitch x)
		else if (Float absolute(rightYawPitch y) > Float absolute(rightYawPitch z))
			roll = asin((upYawPitch scalarProduct(upRotated) * upYawPitch y - upRotated y) / rightYawPitch y)
		else
			roll = asin((upYawPitch scalarProduct(upRotated) * upYawPitch z - upRotated z) / rightYawPitch z)

		FloatRotation3D new(pitch, -yaw, roll)
	}
	distance: func (other: This) -> Float {
		(this - other) norm
	}
	rotationX: Float {
		get {
			result: Float
			value := this w * this y - this z * this x
			if ((value abs() - 0.5f) abs() < this precision)
				result = 0.0f
			else
				result = (2.0f * (this w * this x + this y * this z)) atan2(1.0f - 2.0f * (this x squared() + this y squared()))
			result
		}
	}
	rotationY: Float {
		get {
			result: Float
			value := this w * this y - this z * this x
			if ((value abs() - 0.5f) abs() < this precision)
				result = Float sign(value) * (Float pi / 2.0f)
			else
				result = ((2.0f * value) clamp(-1, 1)) asin()
			result
		}
	}
	rotationZ: Float {
		get {
			result: Float
			value := this w * this y - this z * this x
			if ((value abs() - 0.5f) abs() < this precision)
				result = 2.0f * (this z atan2(this w))
			else
				result = (2.0f * (this w * this z + this x * this y)) atan2(1.0f - 2.0f * (this y squared() + this z squared()))
			result
		}
	}
	direction: FloatPoint3D {
		get {
			quaternionLogarithm := this logarithm
			quaternionLogarithm imaginary / quaternionLogarithm imaginary norm
		}
	}
	logarithm: This {
		get {
			result: This
			norm := this norm
			point3DNorm := this imaginary norm
			if (point3DNorm != 0)
				result = This new(norm log(), (this imaginary / point3DNorm) * ((this real / norm) acos()))
			else 
				result = This new(norm, FloatPoint3D new())
			result
		}
	}
	exponential: This {
		get {
			result: This
			point3DNorm := this imaginary norm
			exponentialReal := this real exp()
			if (point3DNorm != 0)
				result = This new(exponentialReal * point3DNorm cos(), exponentialReal * (this imaginary / point3DNorm) * point3DNorm sin())
			else
				result = This new(exponentialReal, FloatPoint3D new())
			result
		}
	}
	operator == (other: This) -> Bool {
		this w == other w && this x == other x && this y == other y && this z == other z
	}
	operator != (other: This) -> Bool {
		!(this == other)	
	}
	operator < (other: This) -> Bool {
		this w < other w && this x < other x && this y < other y && this z < other z
	}
	operator > (other: This) -> Bool {
		this w > other w && this x > other x && this y > other y && this z > other z
	}
	operator <= (other: This) -> Bool {
		this w <= other w && this x <= other x && this y <= other y && this z <= other z
	}
	operator >= (other: This) -> Bool {
		this w >= other w && this x >= other x && this y >= other y && this z >= other z
	}
	operator + (other: This) -> This {
		This new(this real + other real, this imaginary + other imaginary)
	}
	operator - (other: This) -> This {
		this + (-other)
	}
	operator - -> This {
		This new(-this real, -this imaginary)
	}
	operator / (value: Float) -> This {
		This new(this w / value, this x / value, this y / value, this z / value)
	}
	operator * (value: Float) -> This {
		This new(this w * value, this x * value, this y * value, this z * value)
	}
	operator * (other: This) -> This {
		realResult := this real * other real - this imaginary scalarProduct(other imaginary)
		imaginaryResult := this real * other imaginary + this imaginary * other real + this imaginary vectorProduct(other imaginary)
		This new(realResult, imaginaryResult)
	}
	operator * (value: FloatPoint3D) -> FloatPoint3D {
		(this * This new(0.0f, value) * this inverse) imaginary
	}
	operator [] (index: Int) -> Float {
		result: Float
		match (index) {
			case 0 => result = this w
			case 1 => result = this x
			case 2 => result = this y
			case 3 => result = this z
			case => raise("Quaternion: Invalid index: #{index}, valid indices are 0-3.")
		}
		result
	}
	operator as -> String { this toString() }
	toArray: func -> Float[] {
		result := [this w, this x, this y, this z]
		result
	}
	//
	// This function is not yet needed, and there are no tests for it yet.
	//
	/*toFloatTransform3D: func -> FloatTransform3D {
		normalized := this normalized
		nw := normalized w
		nx := normalized x
		ny := normalized y
		nz := normalized z
		
		nwSquared := nw squared()
		nxSquared := nx squared()
		nySquared := ny squared()
		nzSquared := nz squared() 
		
		a := nwSquared + nxSquared - nySquared - nzSquared
		b := 2.0f * (nx * nz + nw * nz)
		c := 2.0f * (nx * nz - nw * ny)
		d := 2.0f * (nx * ny - nw * nz)
		e := nwSquared - nxSquared + nySquared - nzSquared
		f := 2.0f * (nw * nx + ny * nz)
		g := 2.0f * (nw * ny + nx * nz)
		h := 2.0f * (ny * nz - nw * nx)
		i := nwSquared - nxSquared + nySquared + nzSquared
		
		FloatTransform3D new(a, b, c, d, e, f, g, h, i, 0, 0, 0)
	}*/
	toString: func -> String {
		"Real: " << "%8f" formatFloat(this real) >>
		" Imaginary: " & "%8f" formatFloat(this imaginary x) >> " " & "%8f" formatFloat(this imaginary y) >> " " & "%8f" formatFloat(this imaginary z)
	}
}
operator * (value: Float, other: Quaternion) -> Quaternion {
	other * value
}
