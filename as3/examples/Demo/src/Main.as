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
package
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	
	import org.wiiflash.Wiimote;
	import org.wiiflash.events.ButtonEvent;
	import org.wiiflash.events.WiimoteEvent;

	[SWF(width='400',height='500',backgroundColor='0x333333',frameRate='255')]
	public class Main extends Sprite
	{
		private var output: TextField;
		private var wiimote: Wiimote;
		private var flash: int;
		
		public function Main()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			flash = 0;
			
			//-- Header
			var logo: TextField = new TextField();

			setFormat( logo );
			addChild( logo );
			
			logo.text = 'org.wiiflash.Wiimote';

			//-- Output
			output = new TextField();
			
			setFormat( output );
			addChild( output );
						
			output.y = 0x10;
			output.text = 'Connecting to server...';
			
			//-- Wiimote
			wiimote = new Wiimote();

			wiimote.addEventListener( Event.CONNECT, onWiimoteConnect );
			wiimote.addEventListener( WiimoteEvent.UPDATE, onWiimoteUpdate );
			
			//-- Listen and debug output (not necessary)
			wiimote.addEventListener( ButtonEvent.A_PRESS, onAPress );
			wiimote.addEventListener( ButtonEvent.A_RELEASE, onARelease );
			
			wiimote.addEventListener( WiimoteEvent.NUNCHUK_CONNECT, onNunchukConnect );
			wiimote.addEventListener( WiimoteEvent.NUNCHUK_DISCONNECT, onNunchukDisconnect );
			
			wiimote.addEventListener( WiimoteEvent.IR1_FOUND, onIR1Found );
			wiimote.addEventListener( WiimoteEvent.IR1_LOST, onIR1Lost );
			
			wiimote.connect();
		}
		
		
		//-----------------------------------------------------------------------------------
		// Some event listeners to trace output
		//-----------------------------------------------------------------------------------
	
		private function onNunchukConnect( event: WiimoteEvent ): void { trace( '[+] Nunchuk Connected' ); }
		private function onNunchukDisconnect( event: WiimoteEvent ): void { trace( '[-] Nunchuk Disconnected' ); }
		private function onIR1Found( event: WiimoteEvent ): void { trace( '[+] IR1 Found' ); }
		private function onIR1Lost( event: WiimoteEvent ): void { trace( '[-] IR1 Lost' ); }
		private function onAPress( event: ButtonEvent ): void { trace( '[+] A Press' ); }
		private function onARelease( event: ButtonEvent ): void { trace( '[-] A Release' ); }
		
		
		//-----------------------------------------------------------------------------------
		// LEDs effect on ENTER_FRAME event
		//-----------------------------------------------------------------------------------
		
		private function onEnterFrame( event: Event ): void
		{
			flash++;
			
			if ( ( flash % 0x20 ) == 0 )
			{
				wiimote.leds = Wiimote.LED1;
			}
			if ( ( flash % 0x40 ) == 0 )
			{
				wiimote.leds = Wiimote.LED2;
			}
			if ( ( flash % 0x60 ) == 0 )
			{
				wiimote.leds = Wiimote.LED3;
			}
			if ( ( flash % 0x80 ) == 0 )
			{
				wiimote.leds = Wiimote.LED4;
			}
		}
		
		
		//-----------------------------------------------------------------------------------
		// Wiimote CONNECT listener
		//-----------------------------------------------------------------------------------
		
		private function onWiimoteConnect( event: Event ): void
		{
			stage.addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}
		
		
		//-----------------------------------------------------------------------------------
		// Wiimote UPDATE listener
		//-----------------------------------------------------------------------------------
		
		private function onWiimoteUpdate( event: Event ): void
		{
			//-- Rumble if A and B are pressed
			wiimote.rumble = wiimote.a && wiimote.b;
		
			//-- Show data we got (this is not a full list of all properties!)
			output.text	= 'a: ' + wiimote.a + '\n'
						+ 'b: ' + wiimote.b + '\n\n'
						+ 'up: ' + wiimote.up + '\n'
						+ 'down: ' + wiimote.down + '\n'
						+ 'left: ' + wiimote.left + '\n'
						+ 'right: ' + wiimote.right + '\n\n'
						+ 'minus: ' + wiimote.minus + '\n'
						+ 'home: ' + wiimote.home + '\n'
						+ 'plus: ' + wiimote.plus + '\n\n'
						+ '1: ' + wiimote.one + '\n'
						+ '2: ' + wiimote.two + '\n\n'
						+ 'x: ' + wiimote.sensorX + '\n'
						+ 'y: ' + wiimote.sensorY + '\n'
						+ 'z: ' + wiimote.sensorZ + '\n\n'
						+ 'pitch: ' + Math.round( wiimote.pitch * 180 / Math.PI ) + '\n'
						+ 'roll: ' + Math.round( wiimote.roll * 180 / Math.PI ) + '\n\n'
						+ 'nunchuk: ' + wiimote.hasNunchuk + '\n\n'
						+ 'ir1: ' + wiimote.ir.p1 + '\n'
						+ 'ir2: ' + wiimote.ir.p2;
		
			if ( wiimote.hasNunchuk )
			{
				output.appendText( '\n\n' );
				output.appendText( 'x: ' + wiimote.nunchuk.sensorX + '\n'
							+ 'y: ' + wiimote.nunchuk.sensorY + '\n'
							+ 'z: ' + wiimote.nunchuk.sensorZ + '\n\n'
							+ 'stickX: ' + wiimote.nunchuk.stickX + '\n'
							+ 'stickY: ' + wiimote.nunchuk.stickY + '\n\n'
							+ 'c: ' + wiimote.nunchuk.c + '\n'
							+ 'z: ' + wiimote.nunchuk.z );
			}
			
			if ( wiimote.ir.p1 )
			{
				output.appendText( '\n\np1: ' + wiimote.ir.point1.toString() );
			}
			
			if ( wiimote.ir.p2 )
			{
				output.appendText( '\n\np2: ' + wiimote.ir.point2.toString() );
			}
		}
		
		
		//-----------------------------------------------------------------------------------
		// Utils
		//-----------------------------------------------------------------------------------
		
		private function setFormat( textField: TextField ): void
		{
			var format: TextFormat = new TextFormat;
			
			format.color = 0xffffff;
			format.font = 'verdana';
			format.size = 9;
			format.bold = true;
			
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.multiline = true;
			textField.defaultTextFormat = format;
		}
	}
}