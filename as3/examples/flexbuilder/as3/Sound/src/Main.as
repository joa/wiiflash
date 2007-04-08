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
	import flash.display.Sprite;
	
	import org.wiiflash.Wiimote;
	import org.wiiflash.events.WiimoteEvent;

	[SWF(width='400',height='400',frameRate='255',backgroundColor='0x333333')]
	public class Main extends Sprite
	{
		[Embed(source='/assets/bdrum.mp3')] private static const BDRUM: Class;
		[Embed(source='/assets/snare.mp3')] private static const SNARE: Class;
		[Embed(source='/assets/clap.mp3' )] private static const CLAP:  Class;
		[Embed(source='/assets/crash.mp3')] private static const CRASH: Class;
		
		private var wiimote: Wiimote;
		
		private var pads: Array;
		private var hit: Boolean;
		
		public function Main()
		{
			//-- Create Screen
			initScreen();
			
			//-- Create Wiimote
			wiimote = new Wiimote;
			wiimote.addEventListener( WiimoteEvent.UPDATE, onWiimoteUpdate );
			
			wiimote.connect();
		}
		
		private function initScreen(): void
		{
			pads = new Array;
			
			var pad: Pad;
			
			addChild( pad = new Pad( new BDRUM ) );
			pads.push( pad );
			
			pad.x = 200 - 64 - 32;
			pad.y = 200;
			
			addChild( pad = new Pad( new SNARE ) );
			pads.push( pad );
			
			pad.x = 200 - 32;
			pad.y = 200;
			
			addChild( pad = new Pad( new CLAP ) );
			pads.push( pad );
			
			pad.x = 200 + 32;
			pad.y = 200;
			
			addChild( pad = new Pad( new CRASH ) );
			pads.push( pad );
			
			pad.x = 200 + 64 + 32;
			pad.y = 200;
		}
		
		private function onWiimoteUpdate( event: WiimoteEvent ): void
		{
			//-- If sensorY achieves a lot of acceleration, then...
			if ( wiimote.sensorY > .5 )
			{
				//-- No hit was made
				if ( !hit )
				{
					hit = true;
				
					//-- Get Pad from buttons
					var id: int = 0;
					
					if ( wiimote.a && wiimote.b )
					{
						id = 3;
					}
					else if ( wiimote.a )
					{
						id = 1;
					}
					else if ( wiimote.b )
					{
						id = 2;
					}
					
					//-- Play sound
					( pads[ id ] as Pad ).play();
				}
			}
			else if ( wiimote.sensorY < -.25 )
			{
				//-- Wiimote is up again -> reset hit flag
				hit = false;
			}
		}
	}
}

import flash.display.Sprite;
import flash.media.Sound;
import flash.events.MouseEvent;
import flash.media.SoundChannel;
import flash.display.Shape;
import flash.events.Event;

class Pad extends Sprite
{
	private var sample: Sound;
	private var channel: SoundChannel;
	
	private var reply: Shape;
	
	public function Pad( sample: Sound )
	{
		this.sample = sample;
		
		channel = sample.play();
		channel.stop();
		
		graphics.beginFill( 0x555555, 1 );
		graphics.drawCircle( 0, 0, 16 );
		graphics.endFill();
		
		graphics.lineStyle( 1, 0x666666 );
		graphics.moveTo( 0, -5 );
		graphics.lineTo( 0, 5 );
		graphics.moveTo( -5, 0 );
		graphics.lineTo( 5, 0 );
		
		mouseChildren = false;
		buttonMode = useHandCursor = true;
		
		reply = new Shape;
		reply.graphics.beginFill( 0xaa7777, 1 );
		reply.graphics.drawCircle( 0, 0, 16 );
		reply.graphics.endFill();
		reply.alpha = 0;
		
		addChild( reply );
		
		addEventListener( Event.ENTER_FRAME, onEnterFrame );
		addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
	}
	
	private function onEnterFrame( event: Event ): void
	{
		if ( reply.alpha > 0 )
			reply.alpha -= .025;
		else
			reply.alpha = 0;
	}
	
	public function play(): void
	{
		reply.alpha = 1;
		channel.stop();
		channel = sample.play();	
	}
	
	private function onMouseDown( event: MouseEvent ): void
	{
		play();
	}
}