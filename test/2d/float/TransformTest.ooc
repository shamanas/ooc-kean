use ooc-unit
use ooc-math
import math
import lang/IO
//import ../../../source/FloatExtension

TransformTest: class extends Fixture {
	precision := 1.0f / 1_0000.0f
	transform0 := Transform new(3.0f, 1.0f, 2.0f, 1.0f, 5.0f, 7.0f)
	transform1 := Transform new(7.0f, 4.0f, 2.0f, 5.0f, 7.0f, 6.0f)
	transform2 := Transform new(29.0f, 11.0f, 16.0f, 7.0f, 38.0f, 20.0f)
	transform3 := Transform new(1.0f, -1.0f, -2.0f, 3.0f, 9.0f, -16.0f)
	transform4 := Transform new(10.0f, 20.0f, 30.0f, 40.0f, 50.0f, 60.0f)
	point0 := Point new(-7.0f, 3.0f)
	point1 := Point new(-10.0f, 3.0f)
	size := Size new(10.0f, 10.0f)
	init: func () {
		super("Transform")
		this add("equality", func() {
			transform := Transform new()
//			expect(this transform0, is equal to(this transform0))
//			expect(this transform0 equals(this transform0 as Object), is true)
			expect(this transform0 == this transform0, is true)
			expect(this transform0 == this transform1, is false)
			expect(this transform0 == transform, is false)
			expect(transform == transform, is true)
			expect(transform == this transform0, is false)
		})
		this add("inverse transform", func() {
//			expect(this transform0 Inverse, is equal to(this transform3))
		})
		this add("multiplication, transform - transform", func() {
//			expect(this transform0 * this transform1, is equal to(this transform2))
		})
		this add("multiplication, transform - point", func() {
//			expect(this transform0 * this point0, is equal to(this point1))
		})
		this add("create zero transform", func() {
			transform := Transform new()
			expect(transform a, is equal to(0.0f) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))
			expect(transform e, is equal to(0.0f) within(this precision))
			expect(transform f, is equal to(0.0f) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))
			expect(transform i, is equal to(0.0f) within(this precision))
		})
		this add("create identity transform", func() {
			transform := Transform Identity
			expect(transform a, is equal to(1.0f) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))
			expect(transform e, is equal to(1.0f) within(this precision))
			expect(transform f, is equal to(0.0f) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))
			expect(transform i, is equal to(1.0f) within(this precision))
		})
		this add("rotate", func() {
			identity := Transform Identity
			angle := PI as Float / 9.0f 
			transform := Transform createZRotation(angle)
			transform = transform rotate(-angle)
			expect(transform a, is equal to(1.0f) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))
			expect(transform e, is equal to(1.0f) within(this precision))
			expect(transform f, is equal to(0.0f) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))
			expect(transform i, is equal to(1.0f) within(this precision))
		})
		this add("scale", func() {
			scale := 20.0f 
			identity := Transform new(scale, 0.0f, 0.0f, scale, 0.0f, 0.0f);
			transform := Transform createScaling(scale, scale);
			transform = transform scale(5.0f)
			expect(transform a, is equal to(100.0f) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))
			expect(transform e, is equal to(100.0f) within(this precision))
			expect(transform f, is equal to(0.0f) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))
			expect(transform i, is equal to(1.0f) within(this precision))
		})
		this add("translate", func() {
			xDelta := 40.0f
			yDelta := -40.0f 
			transform := Transform createTranslation(xDelta, yDelta)
			transform = transform translate(-xDelta, -yDelta)
			expect(transform a, is equal to(1.0f) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))
			expect(transform e, is equal to(1.0f) within(this precision))
			expect(transform f, is equal to(0.0f) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))
			expect(transform i, is equal to(1.0f) within(this precision))
		})
		this add("create rotation", func() {
			angle := PI as Float / 9.0f
			transform := Transform createZRotation(angle)
			expect(transform a, is equal to(angle cos()) within(this precision))
			expect(transform b, is equal to(angle sin()) within(this precision))
			expect(transform d, is equal to(-angle sin()) within(this precision))
			expect(transform e, is equal to(angle cos()) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))
		})
		this add("create scale", func() {
			scale := 20.0f
			transform := Transform createScaling(scale, scale);
			expect(transform a, is equal to(scale) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))
			expect(transform e, is equal to(scale) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))
		})
		this add("create translation", func() {
			xDelta := 40.0f
			yDelta := -40.0f
			transform := Transform createTranslation(xDelta, yDelta)
			expect(transform a, is equal to(1.0f) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))
			expect(transform e, is equal to(1.0f) within(this precision))
			expect(transform g, is equal to(xDelta) within(this precision))
			expect(transform h, is equal to(yDelta) within(this precision))
		})
		this add("get values", func() {
			transform := this transform0
			expect(transform a, is equal to(3.0f) within(this precision))
			expect(transform b, is equal to(1.0f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(2.0f) within(this precision))
			expect(transform e, is equal to(1.0f) within(this precision))
			expect(transform f, is equal to(0.0f) within(this precision))
			expect(transform g, is equal to(5.0f) within(this precision))
			expect(transform h, is equal to(7.0f) within(this precision))
			expect(transform i, is equal to(1.0f) within(this precision))
		})
		this add("get ScalingX", func() {
			scale := this transform0 ScalingX
			expect(scale, is equal to(3.162277f) within(this precision))
		})
		this add("get ScalingY", func() {
			scale := this transform0 ScalingY
			expect(scale, is equal to(2.23606801f) within(this precision))
		})
		this add("get Scaling", func() {
			scale := this transform0 Scaling
			expect(scale, is equal to(2.69917297f) within(this precision))
		})
		this add("get ScalingX", func() {
			translation := this transform0 Translation
			expect(translation width, is equal to(5.0f) within(this precision))
			expect(translation height, is equal to(7.0f) within(this precision))
		})
	}
}
TransformTest new() run()
