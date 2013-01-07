/*
 * hexagonlib - Multi-Purpose ActionScript 3 Library.
 *       __    __
 *    __/  \__/  \__    __
 *   /  \__/HEXAGON \__/  \
 *   \__/  \__/  LIBRARY _/
 *            \__/  \__/
 *
 * Licensed under the MIT License
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package com.hexagonstar.util.geom
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	
	/**
	 * Uses a matrix to transform 2D coordinates into a different space. If you pass a 
	 * 'targetPoint', the result will be stored in this point instead of creating a new object.
	 * 
	 * @param m
	 * @param x
	 * @param y
	 * @param targetPoint
	 * @return Point
	 */
	public function transform2DCoords(m:Matrix, x:Number, y:Number, targetPoint:Point = null):Point
	{
		if (!targetPoint) targetPoint = new Point();
		targetPoint.x = m.a * x + m.c * y + m.tx;
		targetPoint.y = m.d * y + m.b * x + m.ty;
		return targetPoint;
	}
}
