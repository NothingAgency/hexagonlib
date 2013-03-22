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
package com.hexagonstar.util.image
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;


	public final class JPGEncoder implements IImageEncoder
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		private const ZIGZAG:Vector.<int> = Vector.<int>([0, 1, 5, 6, 14, 15, 27, 28, 2, 4, 7, 13, 16, 26, 29, 42, 3, 8, 12, 17, 25, 30, 41, 43, 9, 11, 18, 24, 31, 40, 44, 53, 10, 19, 23, 32, 39, 45, 52, 54, 20, 22, 33, 38, 46, 51, 55, 60, 21, 34, 37, 47, 50, 56, 59, 61, 35, 36, 48, 49, 57, 58, 62, 63]);
		private const AASF:Vector.<Number> = Vector.<Number>([1.0, 1.387039845, 1.306562965, 1.175875602, 1.0, 0.785694958, 0.541196100, 0.275899379]);
		private const UVQT:Vector.<int> = Vector.<int>([17, 18, 24, 47, 99, 99, 99, 99, 18, 21, 26, 66, 99, 99, 99, 99, 24, 26, 56, 99, 99, 99, 99, 99, 47, 66, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99]);
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _sf:int;
		private var _yTable:Vector.<int> = new Vector.<int>(64, true);
		private var _uvTable:Vector.<int> = new Vector.<int>(64, true);
		private var _outputfDCTQuant:Vector.<int> = new Vector.<int>(64, true);
		private var _fdtblY:Vector.<Number> = new Vector.<Number>(64, true);
		private var _fdtblUV:Vector.<Number> = new Vector.<Number>(64, true);
		private var _yqt:Vector.<int> = Vector.<int>([16, 11, 10, 16, 24, 40, 51, 61, 12, 12, 14, 19, 26, 58, 60, 55, 14, 13, 16, 24, 40, 57, 69, 56, 14, 17, 22, 29, 51, 87, 80, 62, 18, 22, 37, 56, 68, 109, 103, 77, 24, 35, 55, 64, 81, 104, 113, 92, 49, 64, 78, 87, 103, 121, 120, 101, 72, 92, 95, 98, 112, 100, 103, 99]);
		
		private var _ydcHT:Vector.<BitString>;
		private var _uvdcHT:Vector.<BitString>;
		private var _yacHT:Vector.<BitString>;
		private var _uvacHT:Vector.<BitString>;
		
		private var _stdDCLuminanceCodes:Vector.<int> = Vector.<int>([0, 0, 1, 5, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0]);
		private var _stdDCLuminanceValues:Vector.<int> = Vector.<int>([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]);
		private var _stdACLuminanceCodes:Vector.<int> = Vector.<int>([0, 0, 2, 1, 3, 3, 2, 4, 3, 5, 5, 4, 4, 0, 0, 1, 0x7d]);
		private var _stdACLuminanceValues:Vector.<int> = Vector.<int>([0x01, 0x02, 0x03, 0x00, 0x04, 0x11, 0x05, 0x12, 0x21, 0x31, 0x41, 0x06, 0x13, 0x51, 0x61, 0x07, 0x22, 0x71, 0x14, 0x32, 0x81, 0x91, 0xa1, 0x08, 0x23, 0x42, 0xb1, 0xc1, 0x15, 0x52, 0xd1, 0xf0, 0x24, 0x33, 0x62, 0x72, 0x82, 0x09, 0x0a, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8a, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9a, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xba, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xca, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xda, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0xea, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa]);
		private var _stdDCChrominanceCodes:Vector.<int> = Vector.<int>([0, 0, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0]);
		private var _stdDCChrominanceValues:Vector.<int> = Vector.<int>([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]);
		private var _stdACChrominanceCodes:Vector.<int> = Vector.<int>([0, 0, 2, 1, 2, 4, 4, 3, 4, 7, 5, 4, 4, 0, 1, 2, 0x77]);
		private var _stdACChrominanceValues:Vector.<int> = Vector.<int>([0x00, 0x01, 0x02, 0x03, 0x11, 0x04, 0x05, 0x21, 0x31, 0x06, 0x12, 0x41, 0x51, 0x07, 0x61, 0x71, 0x13, 0x22, 0x32, 0x81, 0x08, 0x14, 0x42, 0x91, 0xa1, 0xb1, 0xc1, 0x09, 0x23, 0x33, 0x52, 0xf0, 0x15, 0x62, 0x72, 0xd1, 0x0a, 0x16, 0x24, 0x34, 0xe1, 0x25, 0xf1, 0x17, 0x18, 0x19, 0x1a, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8a, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9a, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xba, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xca, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xda, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0xea, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa]);
		
		private var _bitcode:Vector.<BitString> = new Vector.<BitString>(65535, true);
		private var _category:Vector.<int> = new Vector.<int>(65535, true);
		
		private var _byteOut:ByteArray;
		private var _byteNew:int = 0;
		private var _bytePos:int = 7;
		
		private var _du:Vector.<int> = new Vector.<int>(64, true);
		
		private var _ydu:Vector.<Number> = new Vector.<Number>(64, true);
		private var _udu:Vector.<Number> = new Vector.<Number>(64, true);
		private var _vdu:Vector.<Number> = new Vector.<Number>(64, true);
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		public function JPGEncoder(quality:int = 60)
		{
			if (quality < 1) quality = 1;
			else if (quality > 100) quality = 100;
			
			_sf = quality < 50 ? int(5000 / quality) : int(200 - (quality << 1));
			
			init();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function encode(image:BitmapData):ByteArray
		{
			// Initialize bit writer
			_byteOut = new ByteArray();

			_byteNew = 0;
			_bytePos = 7;

			// Add JPEG headers
			_byteOut.writeShort(0xFFD8);
			// SOI
			writeAPP0();
			writeDQT();
			writeSOF0(image.width, image.height);
			writeDHT();
			writeSOS();

			// Encode 8x8 macroblocks
			var DCY:Number = 0;
			var DCU:Number = 0;
			var DCV:Number = 0;
			_byteNew = 0;
			_bytePos = 7;

			var width:int = image.width;
			var height:int = image.height;

			for (var ypos:int = 0; ypos < height; ypos += 8)
			{
				for (var xpos:int = 0; xpos < width; xpos += 8)
				{
					RGB2YUV(image, xpos, ypos);
					DCY = processDU(_ydu, _fdtblY, DCY, _ydcHT, _yacHT);
					DCU = processDU(_udu, _fdtblUV, DCU, _uvdcHT, _uvacHT);
					DCV = processDU(_vdu, _fdtblUV, DCV, _uvdcHT, _uvacHT);
				}
			}

			// Do the bit alignment of the EOI marker
			if ( _bytePos >= 0 )
			{
				var fillbits:BitString = new BitString();
				fillbits.len = _bytePos + 1;
				fillbits.val = (1 << (_bytePos + 1)) - 1;
				writeBits(fillbits);
			}
			_byteOut.writeShort(0xFFD9);
			// EOI
			return _byteOut;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function init():void
		{
			ZIGZAG.fixed = true;
			AASF.fixed = true;
			_yqt.fixed = true;
			UVQT.fixed = true;
			_stdACChrominanceCodes.fixed = true;
			_stdACChrominanceValues.fixed = true;
			_stdACLuminanceCodes.fixed = true;
			_stdACLuminanceValues.fixed = true;
			_stdDCChrominanceCodes.fixed = true;
			_stdDCChrominanceValues.fixed = true;
			_stdDCLuminanceCodes.fixed = true;
			_stdDCLuminanceValues.fixed = true;
			
			// Create tables
			initHuffmanTbl();
			initCategoryNumber();
			initQuantTables(_sf);
		}
		
		
		private function initQuantTables(sf:int):void
		{
			var i:int;
			const I64:int = 64;
			const I8:int = 8;
			for (i = 0; i < I64; ++i)
			{
				var t:int = int((_yqt[i] * sf + 50) * 0.01);
				if (t < 1)
				{
					t = 1;
				}
				else if (t > 255)
				{
					t = 255;
				}
				_yTable[ZIGZAG[i]] = t;
			}

			for (i = 0; i < I64; i++)
			{
				var u:int = int((UVQT[i] * sf + 50) * 0.01);
				if (u < 1)
				{
					u = 1;
				}
				else if (u > 255)
				{
					u = 255;
				}
				_uvTable[ZIGZAG[i]] = u;
			}
			i = 0;
			for (var row:int = 0; row < I8; ++row)
			{
				for (var col:int = 0; col < I8; ++col)
				{
					_fdtblY[i] = (1 / (_yTable [ZIGZAG[i]] * AASF[row] * AASF[col] * I8));
					_fdtblUV[i] = (1 / (_uvTable[ZIGZAG[i]] * AASF[row] * AASF[col] * I8));
					i++;
				}
			}
		}
		
		
		private function computeHuffmanTbl(nrcodes:Vector.<int>, std_table:Vector.<int>):Vector.<BitString>
		{
			var codevalue:int = 0;
			var pos_in_table:int = 0;
			var HT:Vector.<BitString> = new Vector.<BitString>(251, true);
			var bitString:BitString;
			for (var k:int = 1; k <= 16; ++k)
			{
				for (var j:int = 1; j <= nrcodes[k]; ++j)
				{
					HT[std_table[pos_in_table]] = bitString = new BitString();
					bitString.val = codevalue;
					bitString.len = k;
					pos_in_table++;
					codevalue++;
				}
				codevalue <<= 1;
			}
			return HT;
		}
		
		
		private function initHuffmanTbl():void
		{
			_ydcHT = computeHuffmanTbl(_stdDCLuminanceCodes, _stdDCLuminanceValues);
			_uvdcHT = computeHuffmanTbl(_stdDCChrominanceCodes, _stdDCChrominanceValues);
			_yacHT = computeHuffmanTbl(_stdACLuminanceCodes, _stdACLuminanceValues);
			_uvacHT = computeHuffmanTbl(_stdACChrominanceCodes, _stdACChrominanceValues);
		}
		
		
		private function initCategoryNumber():void
		{
			var nrlower:int = 1;
			var nrupper:int = 2;
			var bitString:BitString;
			const I15:int = 15;
			var pos:int;
			for (var cat:int = 1; cat <= I15; ++cat)
			{
				// Positive numbers
				for (var nr:int = nrlower; nr < nrupper; ++nr)
				{
					pos = int(32767 + nr);
					_category[pos] = cat;
					_bitcode[pos] = bitString = new BitString();
					bitString.len = cat;
					bitString.val = nr;
				}
				// Negative numbers
				for (var nrneg:int = -(nrupper - 1); nrneg <= -nrlower; ++nrneg)
				{
					pos = int(32767 + nrneg);
					_category[pos] = cat;
					_bitcode[pos] = bitString = new BitString();
					bitString.len = cat;
					bitString.val = nrupper - 1 + nrneg;
				}
				nrlower <<= 1;
				nrupper <<= 1;
			}
		}
		
		
		private function writeBits(bs:BitString):void
		{
			var value:int = bs.val;
			var posval:int = bs.len - 1;
			while ( posval >= 0 )
			{
				if (value & uint(1 << posval) )
					_byteNew |= uint(1 << _bytePos);
				posval--;
				_bytePos--;
				if (_bytePos < 0)
				{
					if (_byteNew == 0xFF)
					{
						_byteOut.writeByte(0xFF);
						_byteOut.writeByte(0);
					}
					else _byteOut.writeByte(_byteNew);
					_bytePos = 7;
					_byteNew = 0;
				}
			}
		}


		
		/**
		 * DCT & quantization core
		 */
		private function fDCTQuant(data:Vector.<Number>, fdtbl:Vector.<Number>):Vector.<int>
		{
			/* Pass 1: process rows. */
			var dataOff:int = 0;
			var d0:Number, d1:Number, d2:Number, d3:Number, d4:Number, d5:Number, d6:Number, d7:Number;
			var i:int;
			const I8:int = 8;
			const I64:int = 64;
			
			for (i = 0; i < I8; ++i)
			{
				d0 = data[int(dataOff)];
				d1 = data[int(dataOff + 1)];
				d2 = data[int(dataOff + 2)];
				d3 = data[int(dataOff + 3)];
				d4 = data[int(dataOff + 4)];
				d5 = data[int(dataOff + 5)];
				d6 = data[int(dataOff + 6)];
				d7 = data[int(dataOff + 7)];

				var tmp0:Number = d0 + d7;
				var tmp7:Number = d0 - d7;
				var tmp1:Number = d1 + d6;
				var tmp6:Number = d1 - d6;
				var tmp2:Number = d2 + d5;
				var tmp5:Number = d2 - d5;
				var tmp3:Number = d3 + d4;
				var tmp4:Number = d3 - d4;

				/* Even part */
				var tmp10:Number = tmp0 + tmp3;
				/* phase 2 */
				var tmp13:Number = tmp0 - tmp3;
				var tmp11:Number = tmp1 + tmp2;
				var tmp12:Number = tmp1 - tmp2;

				data[int(dataOff)] = tmp10 + tmp11;
				/* phase 3 */
				data[int(dataOff + 4)] = tmp10 - tmp11;

				var z1:Number = (tmp12 + tmp13) * 0.707106781;
				/* c4 */
				data[int(dataOff + 2)] = tmp13 + z1;
				/* phase 5 */
				data[int(dataOff + 6)] = tmp13 - z1;

				/* Odd part */
				tmp10 = tmp4 + tmp5;
				/* phase 2 */
				tmp11 = tmp5 + tmp6;
				tmp12 = tmp6 + tmp7;

				/* The rotator is modified from fig 4-8 to avoid extra negations. */
				var z5:Number = (tmp10 - tmp12) * 0.382683433;
				/* c6 */
				var z2:Number = 0.541196100 * tmp10 + z5;
				/* c2-c6 */
				var z4:Number = 1.306562965 * tmp12 + z5;
				/* c2+c6 */
				var z3:Number = tmp11 * 0.707106781;
				/* c4 */

				var z11:Number = tmp7 + z3;
				/* phase 5 */
				var z13:Number = tmp7 - z3;

				data[int(dataOff + 5)] = z13 + z2;
				/* phase 6 */
				data[int(dataOff + 3)] = z13 - z2;
				data[int(dataOff + 1)] = z11 + z4;
				data[int(dataOff + 7)] = z11 - z4;

				dataOff += 8;
				/* advance pointer to next row */
			}

			/* Pass 2: process columns. */
			dataOff = 0;
			for (i = 0; i < I8; ++i)
			{
				d0 = data[int(dataOff)];
				d1 = data[int(dataOff + 8)];
				d2 = data[int(dataOff + 16)];
				d3 = data[int(dataOff + 24)];
				d4 = data[int(dataOff + 32)];
				d5 = data[int(dataOff + 40)];
				d6 = data[int(dataOff + 48)];
				d7 = data[int(dataOff + 56)];

				var tmp0p2:Number = d0 + d7;
				var tmp7p2:Number = d0 - d7;
				var tmp1p2:Number = d1 + d6;
				var tmp6p2:Number = d1 - d6;
				var tmp2p2:Number = d2 + d5;
				var tmp5p2:Number = d2 - d5;
				var tmp3p2:Number = d3 + d4;
				var tmp4p2:Number = d3 - d4;

				/* Even part */
				var tmp10p2:Number = tmp0p2 + tmp3p2;
				/* phase 2 */
				var tmp13p2:Number = tmp0p2 - tmp3p2;
				var tmp11p2:Number = tmp1p2 + tmp2p2;
				var tmp12p2:Number = tmp1p2 - tmp2p2;

				data[int(dataOff)] = tmp10p2 + tmp11p2;
				/* phase 3 */
				data[int(dataOff + 32)] = tmp10p2 - tmp11p2;

				var z1p2:Number = (tmp12p2 + tmp13p2) * 0.707106781;
				/* c4 */
				data[int(dataOff + 16)] = tmp13p2 + z1p2;
				/* phase 5 */
				data[int(dataOff + 48)] = tmp13p2 - z1p2;

				/* Odd part */
				tmp10p2 = tmp4p2 + tmp5p2;
				/* phase 2 */
				tmp11p2 = tmp5p2 + tmp6p2;
				tmp12p2 = tmp6p2 + tmp7p2;

				/* The rotator is modified from fig 4-8 to avoid extra negations. */
				var z5p2:Number = (tmp10p2 - tmp12p2) * 0.382683433;
				/* c6 */
				var z2p2:Number = 0.541196100 * tmp10p2 + z5p2;
				/* c2-c6 */
				var z4p2:Number = 1.306562965 * tmp12p2 + z5p2;
				/* c2+c6 */
				var z3p2:Number = tmp11p2 * 0.707106781;
				/* c4 */

				var z11p2:Number = tmp7p2 + z3p2;
				/* phase 5 */
				var z13p2:Number = tmp7p2 - z3p2;

				data[int(dataOff + 40)] = z13p2 + z2p2;
				/* phase 6 */
				data[int(dataOff + 24)] = z13p2 - z2p2;
				data[int(dataOff + 8)] = z11p2 + z4p2;
				data[int(dataOff + 56)] = z11p2 - z4p2;

				dataOff++;
				/* advance pointer to next column */
			}

			// Quantize/descale the coefficients
			var fDCTQuant:Number;
			for (i = 0; i < I64; ++i)
			{
				// Apply the quantization and scaling factor & Round to nearest integer
				fDCTQuant = data[int(i)] * fdtbl[int(i)];
				_outputfDCTQuant[int(i)] = (fDCTQuant > 0.0) ? int(fDCTQuant + 0.5) : int(fDCTQuant - 0.5);
			}
			return _outputfDCTQuant;
		}


		// Chunk writing
		private function writeAPP0():void
		{
			_byteOut.writeShort(0xFFE0);
			// marker
			_byteOut.writeShort(16);
			// length
			_byteOut.writeByte(0x4A);
			// J
			_byteOut.writeByte(0x46);
			// F
			_byteOut.writeByte(0x49);
			// I
			_byteOut.writeByte(0x46);
			// F
			_byteOut.writeByte(0);
			// = "JFIF",'\0'
			_byteOut.writeByte(1);
			// versionhi
			_byteOut.writeByte(1);
			// versionlo
			_byteOut.writeByte(0);
			// xyunits
			_byteOut.writeShort(1);
			// xdensity
			_byteOut.writeShort(1);
			// ydensity
			_byteOut.writeByte(0);
			// thumbnwidth
			_byteOut.writeByte(0);
			// thumbnheight
		}


		private function writeSOF0(width:int, height:int):void
		{
			_byteOut.writeShort(0xFFC0);
			// marker
			_byteOut.writeShort(17);
			// length, truecolor YUV JPG
			_byteOut.writeByte(8);
			// precision
			_byteOut.writeShort(height);
			_byteOut.writeShort(width);
			_byteOut.writeByte(3);
			// nrofcomponents
			_byteOut.writeByte(1);
			// IdY
			_byteOut.writeByte(0x11);
			// HVY
			_byteOut.writeByte(0);
			// QTY
			_byteOut.writeByte(2);
			// IdU
			_byteOut.writeByte(0x11);
			// HVU
			_byteOut.writeByte(1);
			// QTU
			_byteOut.writeByte(3);
			// IdV
			_byteOut.writeByte(0x11);
			// HVV
			_byteOut.writeByte(1);
			// QTV
		}


		private function writeDQT():void
		{
			_byteOut.writeShort(0xFFDB);
			// marker
			_byteOut.writeShort(132);
			// length
			_byteOut.writeByte(0);

			var i:int;
			const I64:int = 64;
			for (i = 0; i < I64; ++i)
				_byteOut.writeByte(_yTable[i]);

			_byteOut.writeByte(1);

			for (i = 0; i < I64; ++i)
				_byteOut.writeByte(_uvTable[i]);
		}


		private function writeDHT():void
		{
			_byteOut.writeShort(0xFFC4);
			// marker
			_byteOut.writeShort(0x01A2);
			// length

			_byteOut.writeByte(0);
			// HTYDCinfo
			var i:int;
			const I11:int = 11;
			const I16:int = 16;
			const I161:int = 161;
			for (i = 0; i < I16; ++i)
				_byteOut.writeByte(_stdDCLuminanceCodes[int(i + 1)]);

			for (i = 0; i <= I11; ++i)
				_byteOut.writeByte(_stdDCLuminanceValues[int(i)]);

			_byteOut.writeByte(0x10);
			// HTYACinfo

			for (i = 0; i < I16; ++i)
				_byteOut.writeByte(_stdACLuminanceCodes[int(i + 1)]);

			for (i = 0; i <= I161; ++i)
				_byteOut.writeByte(_stdACLuminanceValues[int(i)]);

			_byteOut.writeByte(1);
			// HTUDCinfo

			for (i = 0; i < I16; ++i)
				_byteOut.writeByte(_stdDCChrominanceCodes[int(i + 1)]);

			for (i = 0; i <= I11; ++i)
				_byteOut.writeByte(_stdDCChrominanceValues[int(i)]);

			_byteOut.writeByte(0x11);
			// HTUACinfo

			for (i = 0; i < I16; ++i)
				_byteOut.writeByte(_stdACChrominanceCodes[int(i + 1)]);

			for (i = 0; i <= I161; ++i)
				_byteOut.writeByte(_stdACChrominanceValues[int(i)]);
		}


		private function writeSOS():void
		{
			_byteOut.writeShort(0xFFDA);
			// marker
			_byteOut.writeShort(12);
			// length
			_byteOut.writeByte(3);
			// nrofcomponents
			_byteOut.writeByte(1);
			// IdY
			_byteOut.writeByte(0);
			// HTY
			_byteOut.writeByte(2);
			// IdU
			_byteOut.writeByte(0x11);
			// HTU
			_byteOut.writeByte(3);
			// IdV
			_byteOut.writeByte(0x11);
			// HTV
			_byteOut.writeByte(0);
			// Ss
			_byteOut.writeByte(0x3f);
			// Se
			_byteOut.writeByte(0);
			// Bf
		}


		// Core processing
		private function processDU(CDU:Vector.<Number>, fdtbl:Vector.<Number>, DC:Number, HTDC:Vector.<BitString>, HTAC:Vector.<BitString>):Number
		{
			var EOB:BitString = HTAC[0x00];
			var M16zeroes:BitString = HTAC[0xF0];
			var pos:int;
			const I16:int = 16;
			const I63:int = 63;
			const I64:int = 64;
			var DU_DCT:Vector.<int> = fDCTQuant(CDU, fdtbl);
			// ZigZag reorder
			for (var j:int = 0;j < I64;++j)
			{
				_du[ZIGZAG[j]] = DU_DCT[j];
			}
			var Diff:int = _du[0] - DC;
			DC = _du[0];
			// Encode DC
			if (Diff == 0)
			{
				writeBits(HTDC[0]);
				// Diff might be 0
			}
			else
			{
				pos = int(32767 + Diff);
				writeBits(HTDC[_category[pos]]);
				writeBits(_bitcode[pos]);
			}
			// Encode ACs
			var endPos:int = 63;
			for (; (endPos > 0) && (_du[endPos] == 0); endPos--)
			{
			};
			// end0pos = first element in reverse order !=0
			if ( endPos == 0)
			{
				writeBits(EOB);
				return DC;
			}
			var i:int = 1;
			var lng:int;
			while ( i <= endPos )
			{
				var startpos:int = i;
				for (; (_du[i] == 0) && (i <= endPos); ++i)
				{
				}
				var nrzeroes:int = i - startpos;
				if ( nrzeroes >= I16 )
				{
					lng = nrzeroes >> 4;
					for (var nrmarker:int = 1; nrmarker <= lng; ++nrmarker)
						writeBits(M16zeroes);
					nrzeroes = int(nrzeroes & 0xF);
				}
				pos = int(32767 + _du[i]);
				writeBits(HTAC[int((nrzeroes << 4) + _category[pos])]);
				writeBits(_bitcode[pos]);
				i++;
			}
			if ( endPos != I63 )
			{
				writeBits(EOB);
			}
			return DC;
		}
		
		
		private function RGB2YUV(img:BitmapData, xpos:int, ypos:int):void
		{
			var pos:int = 0;
			const I8:int = 8;
			for (var y:int = 0; y < I8; ++y)
			{
				for (var x:int = 0; x < I8; ++x)
				{
					var P:uint = img.getPixel32(xpos + x, ypos + y);
					var R:int = (P >> 16) & 0xFF;
					var G:int = (P >> 8) & 0xFF;
					var B:int = (P    ) & 0xFF;
					_ydu[int(pos)] = ((( 0.29900) * R + ( 0.58700) * G + ( 0.11400) * B)) - 0x80;
					_udu[int(pos)] = (((-0.16874) * R + (-0.33126) * G + ( 0.50000) * B));
					_vdu[int(pos)] = ((( 0.50000) * R + (-0.41869) * G + (-0.08131) * B));
					++pos;
				}
			}
		}
	}
}


final class BitString
{
	public var len:int = 0;
	public var val:int = 0;
}
