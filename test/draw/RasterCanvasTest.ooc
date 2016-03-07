/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use geometry
use draw
use draw-gpu
use opengl

RasterCanvasTest: class extends Fixture {
	inputFlower := "test/draw/input/Flower.png"
	init: func {
		super("RasterCanvas")
		this add("rgb", func {
			output := "test/draw/output/RasterCanvas_Rgb.png"
			image := RasterRgb open(this inputFlower)
			image canvas pen = Pen new(ColorRgb new(0, 255, 0))
			halfWidth := image size x / 2
			halfHeight := image size y / 2
			start := FloatPoint2D new(-halfWidth, -halfHeight)
			end := FloatPoint2D new(halfWidth, halfHeight)
			image canvas drawLine(start, end)
			start = FloatPoint2D new(halfWidth, -halfHeight)
			end = FloatPoint2D new(-halfWidth, halfHeight)
			image canvas drawLine(start, end)
			image save(output)
			original := RasterRgb open(this inputFlower)
			//TODO: This doesn't test if correctly drawn, only if the image has been modified
			expect(original distance(image) > 0.0f)
			original referenceCount decrease()
			image referenceCount decrease()
			output free()
		})
		this add("rgba", func {
			output := "test/draw/output/RasterCanvas_Rgba.png"
			image := RasterRgba open(this inputFlower)
			image canvas pen = Pen new(ColorRgb new(128, 0, 128))
			for (row in 0 .. image size y / 3)
				for (column in 0 .. image size x / 3)
					image canvas drawPoint(FloatPoint2D new(column * 3 - image size x / 2, row * 3 - image size y / 2))
			image save(output)
			original := RasterRgba open(this inputFlower)
			//TODO: This doesn't test if correctly drawn, only if the image has been modified
			expect(original distance(image) > 0.0f)
			original referenceCount decrease()
			image referenceCount decrease()
			output free()
		})
		this add("yuv420", func {
			output := "test/draw/output/RasterCanvas_Yuv420.png"
			image := RasterYuv420Semiplanar open(this inputFlower)
			for (i in 0 .. 30) {
				image canvas pen = Pen new(ColorRgb new((i % 3) * 80, (i % 5) * 50, (i % 10) * 25))
				box := IntBox2D createAround(IntPoint2D new(0, 0), IntVector2D new(10 * i, 10 * i))
				image canvas drawBox(FloatBox2D new(box))
			}
			image save(output)
			original := RasterYuv420Semiplanar open(this inputFlower)
			//TODO: This doesn't test if correctly drawn, only if the image has been modified
			expect(original distance(image) > 0.0f)
			original referenceCount decrease()
			image referenceCount decrease()
			output free()
		})
		this add("monochrome", func {
			output := "test/draw/output/RasterCanvas_Monochrome.png"
			image := RasterMonochrome open(this inputFlower)
			image canvas pen = Pen new(ColorRgb new(255, 255, 255))
			shiftX := image size x / 2
			shiftY := image size y / 2
			for (i in 0 .. image size x / 10)
				image canvas drawLine(FloatPoint2D new(i * 10 - shiftX, -shiftY), FloatPoint2D new(i * 10 - shiftX, shiftY))
			for (i in 0 .. image size y / 10)
				image canvas drawLine(FloatPoint2D new(-shiftX, i * 10 - shiftY), FloatPoint2D new(shiftX, i * 10 - shiftY))
			image save(output)
			original := RasterMonochrome open(this inputFlower)
			//TODO: This doesn't test if correctly drawn, only if the image has been modified
			expect(original distance(image) > 0.0f)
			original referenceCount decrease()
			image referenceCount decrease()
			output free()
		})
		this add("monochrome with alpha", func {
			output := "test/draw/output/RasterCanvas_MonochromeWithAlpha.png"
			image := RasterMonochrome open(this inputFlower)
			image canvas pen = Pen new(ColorRgba new(255, 255, 255, 100))
			shiftX := image size x / 2
			shiftY := image size y / 2
			factor := 2
			for (i in 0 .. image size x / factor)
				image canvas drawLine(FloatPoint2D new(i * factor - shiftX, -shiftY), FloatPoint2D new(i * factor - shiftX, shiftY))
			for (i in 0 .. image size y / factor)
				image canvas drawLine(FloatPoint2D new(-shiftX, i * factor - shiftY), FloatPoint2D new(shiftX, i * factor - shiftY))
			image save(output)
			original := RasterMonochrome open(this inputFlower)
			//TODO: This doesn't test if correctly drawn, only if the image has been modified
			expect(original distance(image) > 0.0f)
			original referenceCount decrease()
			image referenceCount decrease()
			output free()
		})
		this add("draw rgb image", func {
			inputSpace := "test/draw/input/Space.png"
			output := "test/draw/output/RasterCanvas_drawYUVonRGB.png"
			imageFlower := RasterYuv420Semiplanar open(this inputFlower)
			outputImage := RasterRgb open(inputSpace)
			outputImage canvas interpolationMode = InterpolationMode Smooth
			outputImage canvas draw(imageFlower, IntBox2D new(imageFlower size), IntBox2D new(20, 30, 100, 250))
			imageFlower _coordinateSystem = CoordinateSystem YUpward
			outputImage canvas draw(imageFlower, IntBox2D new(imageFlower size), IntBox2D new(130, 30, 100, 250))
			outputImage canvas interpolationMode = InterpolationMode Fast
			imageFlower _coordinateSystem = CoordinateSystem XLeftward
			outputImage canvas draw(imageFlower, IntBox2D new(imageFlower size), IntBox2D new(240, 30, 100, 250))
			imageFlower _coordinateSystem = CoordinateSystem XLeftward | CoordinateSystem YUpward
			outputImage canvas draw(imageFlower, IntBox2D new(imageFlower size), IntBox2D new(350, 30, 100, 250))
			outputImage save(output)
			imageFlower referenceCount decrease()
			outputImage referenceCount decrease()
			inputSpace free()
			output free()
		})
		this add("draw uv image", func {
			output := "test/draw/output/RasterCanvas_drawRGBonUV.png"
			inputSpace := "test/draw/input/Space.png"
			inputImage := RasterRgb open(this inputFlower)
			imageToDrawOn := RasterUv open(inputSpace)
			imageToDrawOn canvas draw(inputImage, IntBox2D new(inputImage size), IntBox2D new(130, 30, 100, 250))
			imageToDrawOn save(output)
			output free()
			inputImage free()
			imageToDrawOn free()
			inputSpace free()
		})
	}
	free: override func {
		this inputFlower free()
		super()
	}
}

RasterCanvasTest new() run() . free()
