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
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import org.wiiflash.Wiimote;

	[SWF(width='600',height='400',frameRate='255',backgroundColor='0x333333')]
	public class Main extends Sprite
	{
		private var wiimote: Wiimote;
		
		private var x0: Number;
		private var y0: Number;
		
		private var p1: Shape;
		private var p2: Shape;
		
		public function Main()
		{
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			
			addChild( p1 = new Shape );
			
			p1.graphics.lineStyle( 1, 0xff00, .5 );
			p1.graphics.drawCircle( 0, 0, 8 );
			
			p1.graphics.moveTo( 0, -10 );
			p1.graphics.lineTo( 0, 10 );
			
			p1.graphics.moveTo( -10, 0 );
			p1.graphics.lineTo( 10, 0 );
			
			addChild( p2 = new Shape );
			
			p2.graphics.lineStyle( 1, 0xff, .5 );
			p2.graphics.drawCircle( 0, 0, 8 );
			
			p2.graphics.moveTo( 0, -10 );
			p2.graphics.lineTo( 0, 10 );
			
			p2.graphics.moveTo( -10, 0 );
			p2.graphics.lineTo( 10, 0 );
			
			wiimote = new Wiimote;
			
			wiimote.addEventListener( Event.CONNECT, onWiimoteConnect );
			wiimote.connect();
		}
		
		private function onWiimoteConnect( event: Event ): void
		{
			stage.addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}
		
		private function onEnterFrame( event: Event ): void
		{
			if ( wiimote.ir.p1 )
			{
				p1.visible = true;
				
				p1.x = ( 1 - wiimote.ir.x1 ) * stage.stageWidth;
				p1.y = wiimote.ir.y1 * stage.stageHeight;
			}
			else
				p1.visible = false;
				
			if ( wiimote.ir.p2 )
			{
				p2.visible = true;
				
				p2.x = ( 1 - wiimote.ir.x2 ) * stage.stageWidth;
				p2.y = wiimote.ir.y2 * stage.stageHeight;
			}
			else
				p2.visible = false;
		}
	}
}
