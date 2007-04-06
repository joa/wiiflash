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
	import flash.utils.ByteArray;
	
	import org.wiiflash.events.*;
	
	/**
	 * The Nunchuk class represents a Nunchuk.
	 * A Nunchuk object can not be created manually. The only access to a Nunchuk is
	 * by using the <code>nunchuk</code> property of a Wiimote object.
	 * 
	 * @see http://www.wiili.org/index.php/Nunchuk Nunchuk description on wiili.org
	 * @see org.wiiflash.Wiimote org.wiiflash.Wiimote
	 * 
	 * @author Joa Ebert
	 * @authoer Thibault Imbert
	 */	
	public final class Nunchuk
	{
		/**
		 * @private
		 * 
		 * Flag that enables Nunchuk initialitzation. Set this to true before
		 * calling the Nunchuk constructor.
		 */
		internal static var initializing: Boolean = false;
		
		private var _x: Number;
		private var _y: Number;
		private var _z: Number;
		
		private var _stickX: Number;
		private var _stickY: Number;
		
		private var _cButton: Button
		private var _zButton: Button;

		private var _parent: Wiimote;
		
		/**
		 * @private
		 * 
		 * Creates a new Nunchuk object.
		 * 
		 * A Nunchuk object may only be created by the Wiimote class.
		 * 
		 * @throws Error Thrown when constructor is called manually.
		 */		
		public function Nunchuk()
		{
			if ( !Nunchuk.initializing )
				throw new Error( 'Can not create Nunchuk instance manually.\nAccess is only available using a Wiimote object.' );
			Nunchuk.initializing = false;
			
			_cButton = new Button( ButtonType.C );
			_zButton = new Button( ButtonType.Z );
		}
		
		/**
		 * @private
		 * 
		 * The parent of the Nunchuk.
		 */		
		internal function set parent( newValue: Wiimote ): void
		{
			_parent = newValue;
		}
		
		//-----------------------------------------------------------------------------------
		// Buttons
		//-----------------------------------------------------------------------------------
		
		/**
		 * Indicates if button <em>C</em> is pressed.
		 */
		public function get c(): Boolean
		{
			return _cButton.state;
		}
		
		/**
		 * Indicates if button <em>Z</em> is pressed.
		 */
		public function get z(): Boolean
		{
			return _zButton.state;
		}
		
		//-----------------------------------------------------------------------------------
		// Sensors
		//-----------------------------------------------------------------------------------
		
		/**
		 * Value of the <em>x</em> acceleration sensor.
		 * This value is scaled by the calibration data that has been read from the Nunchuk.
		 */
		public function get sensorX(): Number
		{
			return _x;
		}
		
		/**
		 * Value of the <em>y</em> acceleration sensor.
		 * This value is scaled by the calibration data that has been read from the Nunchuk.
		 */
		public function get sensorY(): Number
		{
			return _y;
		}
		
		/**
		 * Value of the <em>z</em> acceleration sensor.
		 * This value is scaled by the calibration data that has been read from the Nunchuk.
		 */
		public function get sensorZ(): Number
		{
			return _z;
		}
		
		/**
		 * Value of the <em>x</em> stick-axis.
		 * This value is scaled by the calibration data that has been read from the Nunchuk.
		 */
		public function get stickX(): Number
		{
			return _stickX;
		}
		
		/**
		 * Value of the <em>y</em> stick-axis.
		 * This value is scaled by the calibration data that has been read from the Nunchuk.
		 */
		public function get stickY(): Number
		{
			return _stickY;
		}		
		
		/**
		 * Pitch angle of the Wiimote in radians.
		 * This value is scaled by the calibration data that has been read from the Nunchuk.
		 */		
		public function get pitch(): Number
		{
			return Wiimote.calcAngle( sensorY );
		}
		
		/**
		 * Roll angle of the Wiimote in radians.
		 * This value is scaled by the calibration data that has been read from the Nunchuk.
		 */		
		public function get roll(): Number
		{
			return Wiimote.calcAngle( sensorX );
		}
		
		/**
		 * Yaw angle of the Nunchuk in radians.
		 * This value is scaled by the calibration data that has been read from the Nunchuk.
		 */		
		public function get yaw(): Number
		{
			return Wiimote.calcAngle( sensorZ );
		}
		
		//-----------------------------------------------------------------------------------
		// Parsing
		//-----------------------------------------------------------------------------------
		
		/**
		 * @private
		 * 
		 * Updates Nunchuk data.
		 */		
		internal function update( pack: ByteArray ): void
		{
			var buttonState: int = pack.readUnsignedByte();
			
			_cButton.update( buttonState );
			_zButton.update( buttonState );
			
			_stickX = pack.readFloat();
			_stickY = pack.readFloat();
			
			_x = pack.readFloat();
			_y = pack.readFloat();
			_z = pack.readFloat();
			
			if ( _cButton.state && !_cButton.lastState )
			{
				_parent.dispatchEvent( new ButtonEvent( ButtonType.getEventFromType( _cButton.type, true ), true ) );
			}
			else if ( !_cButton.state && _cButton.lastState )
			{
				_parent.dispatchEvent( new ButtonEvent( ButtonType.getEventFromType( _cButton.type, false ), false ) );
			}
			
			if ( _zButton.state && !_zButton.lastState )
			{
				_parent.dispatchEvent( new ButtonEvent( ButtonType.getEventFromType( _zButton.type, true ), true ) );
			}
			else if ( !_zButton.state && _zButton.lastState )
			{
				_parent.dispatchEvent( new ButtonEvent( ButtonType.getEventFromType( _zButton.type, false ), false ) );
			}
		}
		
		/**
		 * Returns the string representation of the specified object.
		 * 
		 * @return A string representation of the object.  
		 */	
		public function toString(): String
		{
			return '[Nunchuk parent: ' + _parent + ']';
		}
	}
}