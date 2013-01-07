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
package com.hexagonstar.tween.plugins
{
	import com.hexagonstar.tween.Tween;
	import com.hexagonstar.util.number.isNumber;
	
	
	/**
	 * ScalePlugin combines scaleX and scaleY into one "scale" property. <br />
	 * <br />
	 * 
	 * <b>USAGE:</b><br />
	 * <br />
	 * <code>
	 * 		import com.greensock.TweenLite; <br />
	 * 		import com.greensock.plugins.TweenPlugin; <br />
	 * 		import com.greensock.plugins.ScalePlugin; <br />
	 * 		TweenPlugin.activate([ScalePlugin]); // activation is permanent in the SWF, so this line only needs to be run once.<br /><br />
	 * 
	 * 		TweenLite.to(mc, 1, {scale:2});  // tweens horizontal and vertical scale simultaneously <br /><br />
	 * </code>
	 */
	public class ScalePlugin extends TweenPlugin
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private **/
		protected var _target:Object;
		/** @private **/
		protected var _startX:Number;
		/** @private **/
		protected var _changeX:Number;
		/** @private **/
		protected var _startY:Number;
		/** @private **/
		protected var _changeY:Number;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		public function ScalePlugin()
		{
			propertyName= "scale";
			overwriteProperties = ["scaleX", "scaleY", "width", "height"];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function onInitTween(target:Object, value:*, tween:Tween):Boolean
		{
			if (!target.hasOwnProperty("scaleX")) return false;
			
			_target = target;
			_startX = _target['scaleX'];
			_startY = _target['scaleY'];
			
			if (isNumber(value))
			{
				_changeX = value - _startX;
				_changeY = value - _startY;
			}
			else
			{
				_changeX = _changeY = Number(value);
			}
			
			return true;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function killProperties(lookup:Object):void
		{
			var i:int = overwriteProperties.length;
			while (i--)
			{
				if (overwriteProperties[i] in lookup)
				{
					/* If any of the properties are found in the lookup, this whole
					 *  plugin instance should be essentially deactivated. To do that,
					 *  we must empty the overwriteProps Array. */
					overwriteProperties = [];
					return;
				}
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function set changeFactor(v:Number):void
		{
			_target['scaleX'] = _startX + (v * _changeX);
			_target['scaleY'] = _startY + (v * _changeY);
		}
	}
}
