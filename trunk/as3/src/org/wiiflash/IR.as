/*
Copyright (c) 2007 Joa Ebert and Thibault Imbert

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
package org.wiiflash
{
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import org.wiiflash.events.WiimoteEvent;
	
	/**
	 * The IR class represents the data structure of the IR sensor from a Wiimote.
	 * An IR object can not be created manually. The only access to an IR object is
	 * by using the <code>ir</code> property of a Wiimote object.
	 * 
	 * @see http://www.wiili.org/index.php/Wiimote#IR_Sensor IR sensor description on wiili.org
	 * @see org.wiiflash.Wiimote org.wiiflash.Wiimote
	 * 
	 * @author Joa Ebert
	 * @author Thibault Imbert
	 */	
	public final class IR
	{
		/**
		 * @private
		 * 
		 * Flag that enables IR initialitzation. Set this to true before
		 * calling the IR constructor.
		 */
		internal static var initializing: Boolean = false;
		
		private var _p1: Boolean;
		private var _p1Last: Boolean;
		
		private var _p2: Boolean;
		private var _p2Last: Boolean;
				
		private var _x1: Number;
		private var _x2: Number;
		private var _y1: Number;
		private var _y2: Number;
		
		private var _parent: Wiimote;
		
		/**
		 * @private
		 * 
		 * Creates a new IR object.
		 * 
		 * An IR object may only be created by the Wiimote class.
		 * 
		 * @throws Error Thrown when constructor is called manually.
		 */	
		public function IR()
		{
			if ( !IR.initializing )
				throw new Error( 'Can not create IR instance manually.\nAccess is only available using a Wiimote object.' );
				
			IR.initializing = false;
		}
		
		/**
		 * The <em>x</em> value of point <em>1</em>.
		 */
		public function get x1(): Number
		{
			return _x1;
		}
		
		/**
		 * The <em>y</em> value of point <em>1</em>.
		 */
		public function get y1(): Number
		{
			return _y1;
		}
		
		/**
		 * The <em>x</em> value of point <em>2</em>.
		 */
		public function get x2(): Number
		{
			return _x1;
		}
		
		/**
		 * The <em>y</em> value of point <em>2</em>.
		 */
		public function get y2(): Number
		{
			return _y1;
		}
		
		/**
		 * Flag that indicates if point <em>1</em> has been found.
		 */		
		public function get p1(): Boolean
		{
			return _p1;
		}

		/**
		 * Flag that indicates if point <em>2</em> has been found.
		 */		
		public function get p2(): Boolean
		{
			return _p2;
		}
		
		/**
		 * Point <em>1</em> as a Point object.
		 */		
		public function get point1(): Point
		{
			return new Point( _x1, _y1 );
		}
		
		/**
		 * Point <em>2</em> as a Point object.
		 */		
		public function get point2(): Point
		{
			return new Point( _x2, _y2 );
		}
		
		/**
		 * Returns the string representation of the specified object.
		 * 
		 * @return A string representation of the object.  
		 */	
		public function toString(): String
		{
			return '[IR x1: ' + x1 + ', x2: ' + x2 + ', y1: ' + y1 + ', y2: ' + y2 + ']';
		}
		
		/**
		 * @private
		 * 
		 * The parent of the IR.
		 */		
		internal function set parent( newValue: Wiimote ): void
		{
			_parent = newValue;
		}
		
		/**
		 * @private
		 */		
		internal function update( pack: ByteArray ): void
		{
			if ( ( _p1 = pack.readByte() == 1 ) == true )
			{
				_x1 = pack.readFloat();
				_y1 = pack.readFloat();
			}
			else
			{
				_x1 = NaN;
				_y1 = NaN;

				pack.position += 8;
			}
			
			if ( ( _p2 = pack.readByte() == 1 ) == true )
			{
				_x2 = pack.readFloat();
				_y2 = pack.readFloat();
			}
			else
			{
				_x2 = NaN;
				_y2 = NaN;
				
				pack.position += 8;
			}
			
			if ( _p1 && !_p1Last )
			{
				_parent.dispatchEvent( new WiimoteEvent( WiimoteEvent.IR1_FOUND ) );
			}
			else if ( !_p1 && _p1Last )
			{
				_parent.dispatchEvent( new WiimoteEvent( WiimoteEvent.IR1_LOST ) );
			}
			
			if ( _p2 && !_p2Last )
			{
				_parent.dispatchEvent( new WiimoteEvent( WiimoteEvent.IR2_FOUND ) );
			}
			else if ( !_p2 && _p2Last )
			{
				_parent.dispatchEvent( new WiimoteEvent( WiimoteEvent.IR2_LOST ) );
			}
			
			_p1Last = _p1;
			_p2Last = _p2;
		}
	}
}