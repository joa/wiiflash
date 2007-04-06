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
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.wiiflash.Wiimote;

	[SWF(width='400',height='240',frameRate='255',backgroundColor='0x333333')]
	public class Main extends Sprite
	{
		//-- Screens
		private var screen0: BitmapData;
		private var screen1: BitmapData;
		
		//-- Output for Pitch/Roll
		private var plot0: AxisPlotter;
		private var plot1: AxisPlotter;
		private var plot2: AxisPlotter;
		private var plot3: AxisPlotter;
	
		//-- Graphs
		private var graph0: ValuePlotter;
		private var graph1: ValuePlotter;
		
		//-- Wimote
		private var wiimote: Wiimote;
		
		public function Main()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			//-- Setting up the debug environment
			plot0 = new AxisPlotter;
			plot1 = new AxisPlotter;
			plot2 = new AxisPlotter;
			plot3 = new AxisPlotter;
			
			addChild( plot0 );
			addChild( plot1 );
			addChild( plot2 );
			addChild( plot3 );
			
			plot3.x = plot2.x = plot1.x = plot0.x = plot0.y = AxisPlotter.radius + 0x10;
			plot1.y = 2 * ( AxisPlotter.radius + 0x10 );
			plot2.y = 3 * ( AxisPlotter.radius + 0x10 );
			plot3.y = 4 * ( AxisPlotter.radius + 0x10 );
			
			plot0.angle = Math.PI;
			plot1.angle = Math.PI;
			plot2.angle = Math.PI;
			plot3.angle = Math.PI;
			
			screen0 = new BitmapData( stage.stageWidth - 0x30 - AxisPlotter.radius * 2, 2 * AxisPlotter.radius + 0x10, false, 0 );
			screen1 = screen0.clone();
			
			graph0 = new ValuePlotter( screen0 );
			graph1 = new ValuePlotter( screen1 );
			
			var b0: Bitmap = new Bitmap( screen0 );
			var b1: Bitmap = new Bitmap( screen1 );
			
			b0.x = 0x20 + AxisPlotter.radius * 2;
			b0.y = 0x10;
			
			b1.x = b0.x;
			b1.y = b0.y + b0.height + 0x10;
			
			addChild( b0 );
			addChild( b1 );
			
			//-- Pause/Resume (useful! ;))
			stage.addEventListener( MouseEvent.MOUSE_DOWN, pause );
			stage.addEventListener( MouseEvent.MOUSE_UP, resume );
			
			//-- Creating the Wiimote
			wiimote = new Wiimote();
			wiimote.addEventListener( Event.CONNECT, resume );
			
			wiimote.connect();
		}
		
		private function pause( event: Event ): void { removeEventListener( Event.ENTER_FRAME, loop ); }
		private function resume(event: Event ): void { addEventListener( Event.ENTER_FRAME, loop ); }
		
		private function loop( event: Event ): void
		{
			//-- Get interpolated Y value using mean of last 0x10 values
			var yInterp0: Number = graph0.getMean( 0x10 );
			
			//-- Get interpolated Y value using mean of last 0x20 values
			var yInterp1: Number = graph0.getMean( 0x20 );			
			
			//-- Clamp
			if ( yInterp0 > 1 ) yInterp0 = 1;
			else if ( yInterp0 < -1 ) yInterp0 = -1;
			
			if ( yInterp1 > 1 ) yInterp1 = 1;
			else if ( yInterp1 < -1 ) yInterp1 = -1;
			
			//-- Roll (without interpolation)
			plot0.angle = -Math.PI - wiimote.roll;
			
			//-- Pitch (without interpolation)
			plot1.angle = -Math.PI - wiimote.pitch;
			
			//-- Pitch (interpolated over 0x10 values)
			plot2.angle = -Math.PI - Math.asin( yInterp0 );
			
			//-- Pitch (interpolated over 0x20 values)
			plot3.angle = -Math.PI - Math.asin( yInterp1 );
			
			//-- Graph of sensorY without interpolation
			graph0.push( wiimote.sensorY );
			
			//-- Graph of sensorY with interpolated value (0x10 steps)
			graph1.push( yInterp0 );
		}
	}
}

//-----------------------------------------------------------------------------------
// ONLY LOOK AT THIS CODE AT YOUR OWN RISK :o)
// Not beautiful. Not optimized.
//-----------------------------------------------------------------------------------
import flash.display.*

class ValuePlotter
{
	private var values: Array;
	private var screen: BitmapData;
	private var grid: BitmapData;
	
	public function ValuePlotter( screen: BitmapData )
	{
		screen.fillRect( screen.rect, 0x303030 );
		
		for ( var x: int = 0; x < screen.width; x++ )
		{
			screen.setPixel( x, 0, 0x555555 );
			
			if ( ( x % 4 ) == 0 )
				screen.setPixel( x, screen.height >> 1, 0x444444 );
				
			screen.setPixel( x, screen.height - 1, 0x555555 );
		}
		
		for ( var y: int = 0; y < screen.height; y++ )
		{
			screen.setPixel( 0, y, 0x555555 );
			
			if ( ( y % 4 ) == 0 )
				screen.setPixel( screen.width >> 1, y, 0x444444 );
			
			screen.setPixel( screen.width - 1, y, 0x555555 );
		}
		
		this.screen = screen;
		
		grid = screen.clone();
		
		values = new Array( screen.width - 2 );
		for ( x = 0; x < ( screen.width - 2 ); x++ )
			values[ x ] = 0;
	}
	
	public function getMean( n: int ): Number
	{
		var m: Number = 0;
		
		for ( var x: int = 0; x < n; x++ )
			m += values[ int( values.length - 1 - x ) ];
		m /= n;
		
		return m;
	}
	
	public function push( value: Number ): void
	{
		var halfHeight: int = ( screen.height >> 1 );
		values.shift();
		values.push( value );
		
		screen.draw( grid );
		
		var lastY: int;
		var m: int = values.length;
		
		for ( var x: int = 0; x < m; x++ )
		{
			var y: int = halfHeight + halfHeight * -1 * values[ x ];
			
			if ( y < 1 ) y = 1;
			if ( y > screen.height - 2 ) y = screen.height - 2;
			
			screen.setPixel( 1 + x, y, 0xff00ff );
			
			if ( x != 0 )
			{
				var y0: int = y;
				
				if ( y0 > lastY )
				{
					while ( --y0 > lastY )
					{
						screen.setPixel( 1 + x, y0, 0xff00ff );
					}
				}
				else if ( y0 < lastY )
				{
					while ( ++y0 < lastY )
					{
						screen.setPixel( 1 + x, y0, 0xff00ff );
					}
				}
			}
			
			lastY = y;
		}
	}
}

class AxisPlotter extends Sprite
{
	public static const radius: Number = 0x28;
	private static const segments: int = 0x70;
	
	private var circle: Shape;
	private var value: Shape;
	
	public function AxisPlotter()
	{
		circle = new Shape;
		
		var g: Graphics = circle.graphics;
		
		g.lineStyle( 1, 0x555555 );
		
		g.moveTo( radius * Math.sin( .5 * -Math.PI ), radius * Math.cos( .5 * -Math.PI ) );
		for ( var i: Number = 1; i <= segments; i++ )
			g.lineTo( radius * Math.sin( -.5 * Math.PI - Math.PI * (i/segments) ), radius * Math.cos( -.5 * Math.PI - Math.PI * (i/segments) ) );
		
		value = new Shape;
		
		g = value.graphics;
		g.beginFill( 0xff00ff, 1 );
		g.drawCircle( 0, 0, 3 );
		g.endFill();
		
		circle.cacheAsBitmap = true;
		value.cacheAsBitmap = true;
		
		addChild( circle );
		addChild( value );
	}
	
	public function set angle( newValue: Number ): void
	{
		value.x = radius * Math.sin( newValue );
		value.y = radius * Math.cos( newValue );
	}
}
