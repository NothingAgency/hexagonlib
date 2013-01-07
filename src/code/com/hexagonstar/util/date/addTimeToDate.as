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
package com.hexagonstar.util.date
{
	/**
	 * Creates a new date object from the specified date object which has the time added
	 * specified by days, hours, minutes, seconds and ms.
	 * 
	 * @param date
	 * @param days
	 * @param hours
	 * @param minutes
	 * @param seconds
	 * @param ms
	 * @return A new Date object.
	 */
	public function addTimeToDate(date:Date, days:Number = 0, hours:Number = 0, minutes:Number = 0,
		seconds:Number = 0, ms:Number = 0):Date
	{
		if (!date) return null;
		var clone:Date = cloneDate(date);
		clone.time = clone.time + ((days * 86400000) + (hours * 3600000) + (minutes * 60000)
			+ (seconds * 1000) + ms);
		return clone;
	}
}
