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

use ooc-geometry
use ooc-base
import RasterPacked
import RasterImage
import RasterBgr
import StbImage
import Image
import Color
import Canvas, RasterCanvas

RasterUvCanvas: class extends RasterPackedCanvas {
	target ::= this _target as RasterUv
	init: func (image: RasterUv) { super(image) }
	_drawPoint: override func (x, y: Int) {
		position := this _map(IntPoint2D new(x, y))
		if (this target isValidIn(position x, position y))
			this target[position x, position y] = this target[position x, position y] blend(this pen alphaAsFloat, this pen color toUv())
	}
	draw: override func ~ImageSourceDestination (image: Image, source, destination: IntBox2D) {
		uv: RasterUv = null
		if (image instanceOf?(RasterUv))
			uv = image as RasterUv
		else if (image instanceOf?(RasterImage))
			uv = RasterUv convertFrom(image as RasterImage)
		else
			Debug raise("Unsupported image type in RasterUvCanvas draw")
		this _resizePacked(uv buffer pointer as ColorUv*, uv, source, destination)
		if (uv != image)
			uv referenceCount decrease()
	}
}

RasterUv: class extends RasterPacked {
	bytesPerPixel ::= 2
	init: func ~allocate (size: IntVector2D) { super~allocate(size) }
	init: func ~allocateStride (size: IntVector2D, stride: UInt) { super(size, stride) }
	init: func ~fromByteBufferStride (buffer: ByteBuffer, size: IntVector2D, stride: UInt) { super(buffer, size, stride) }
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntVector2D) { this init(buffer, size, this bytesPerPixel * size x) }
	init: func ~fromRasterUv (original: This) { super(original) }
	init: func ~fromRasterImage (original: RasterImage) { super(original) }
	create: func (size: IntVector2D) -> Image { This new(size) }
	copy: func -> This { This new(this) }
	apply: func ~bgr (action: Func(ColorBgr)) {
		this apply(ColorConvert fromYuv(action))
	}
	apply: func ~yuv (action: Func(ColorYuv)) {
		uvRow := this buffer pointer
		uSource := uvRow
		vRow := uvRow + 1
		vSource := vRow
		width := this size x
		height := this size y

		for (y in 0 .. height) {
			for (x in 0 .. width) {
				action(ColorYuv new(128, uSource@, vSource@))
				uSource += 2
				vSource += 2
			}
			uvRow += this stride
			uSource = uvRow
			vSource = uvRow + 1
		}
	}
	apply: func ~monochrome (action: Func(ColorMonochrome)) {
		this apply(ColorConvert fromYuv(action))
	}

	distance: func (other: Image) -> Float {
		result := 0.0f
		if (!other || (this size != other size))
			result = Float maximumValue
		else if (!other instanceOf?(This)) {
			converted := This convertFrom(other as RasterImage)
			result = this distance(converted)
			converted referenceCount decrease()
		} else {
			for (y in 0 .. this size y)
				for (x in 0 .. this size x) {
					c := this[x, y]
					o := (other as This)[x, y]
					if (c distance(o) > 0) {
						maximum := o
						minimum := o
						for (otherY in Int maximum(0, y - this distanceRadius) .. Int minimum(y + 1 + this distanceRadius, this size y))
							for (otherX in Int maximum(0, x - this distanceRadius) .. Int minimum(x + 1 + this distanceRadius, this size x))
								if (otherX != x || otherY != y) {
									pixel := (other as This)[otherX, otherY]
									if (maximum u < pixel u)
										maximum u = pixel u
									else if (minimum u > pixel u)
										minimum u = pixel u
									if (maximum v < pixel v)
										maximum v = pixel v
									else if (minimum v > pixel v)
										minimum v = pixel v
								}
						distance := 0.0f
						if (c u < minimum u)
							distance += (minimum u - c u) as Float squared
						else if (c u > maximum u)
							distance += (c u - maximum u) as Float squared
						if (c v < minimum v)
							distance += (minimum v - c v) as Float squared
						else if (c v > maximum v)
							distance += (c v - maximum v) as Float squared
						result += (distance) sqrt() / 3
					}
				}
			result /= ((this size x squared + this size y squared) as Float sqrt())
		}
	}
	_createCanvas: override func -> Canvas { RasterUvCanvas new(this) }
	operator [] (x, y: Int) -> ColorUv { this isValidIn(x, y) ? ((this buffer pointer + y * this stride) as ColorUv* + x)@ : ColorUv new(0, 0) }
	operator []= (x, y: Int, value: ColorUv) { ((this buffer pointer + y * this stride) as ColorUv* + x)@ = value }
	save: override func (filename: String) -> Int {
		bgr := RasterBgr convertFrom(this)
		result := bgr save(filename)
		bgr referenceCount decrease()
		result
	}
	open: static func (filename: String) -> This {
		rasterBgr := RasterBgr open(filename)
		result := This convertFrom(rasterBgr)
		rasterBgr referenceCount decrease()
		result
	}
	convertFrom: static func (original: RasterImage) -> This {
		result: This
		if (original instanceOf?(This))
			result = (original as This) copy()
		else {
			result = This new(original)
			row := result buffer pointer
			rowLength := result size x
			rowEnd := row as ColorUv* + rowLength
			destination := row as ColorUv*
			f := func (color: ColorYuv) {
				(destination as ColorUv*)@ = ColorUv new(color u, color v)
				destination += 1
				if (destination >= rowEnd) {
					row += result stride
					destination = row as ColorUv*
					rowEnd = row as ColorUv* + rowLength
				}
			}
			original apply(f)
			(f as Closure) free()
		}
		result
	}
}
