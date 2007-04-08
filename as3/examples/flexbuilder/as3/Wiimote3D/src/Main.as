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
	import flash.filters.BlurFilter;
	import flash.geom.*;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.materials.MaterialsList;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.objects.Collada;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.scenes.Scene3D;
	
	import org.wiiflash.Wiimote;

	[SWF(width='1000',height='600',backgroundColor='0x000000',frameRate='255')]
	public class Main extends Sprite
	{
		//-- Papervision3D
		private var container: Sprite;
		private var scene: Scene3D;
		private var camera: Camera3D;
		private var rootNode: DisplayObject3D;
		
		//-- Last frame Wiimote values
		private var roll: Number;
		private var pitch: Number;
		
		//-- Wiimote
		private var wiimote: Wiimote;

		//-- Graphics		
		private var screen: Bitmap;
		private var colorDamp: ColorTransform;
		private var colorFx: Matrix;
		
		public function Main()
		{
			//-- Reset old values
			pitch = roll = 0;
			
			//-- Create Wiimote
			wiimote = new Wiimote();
			wiimote.addEventListener( Event.CONNECT, onWiimoteConnect );
			
			//-- Initialize stage and set up Papervision3D
			stage.quality = StageQuality.LOW;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			container = new Sprite;
			
			container.x = 250;
			container.y = 250;
			
			scene = new Scene3D( container );
			
			camera = new Camera3D();
			camera.x = 0;
			camera.y = 0;
			camera.z = 1000;
			camera.zoom = 5;
			camera.focus = 100;

			rootNode = scene.addChild( new DisplayObject3D( 'rootNode' ) );
						
			var list: Object = new Object;
			var m: WireframeMaterial = new WireframeMaterial( 0xffffff );
			
			list['_1_-_Default'] = m;
			
			var collada: Collada = new Collada( 'assets/wiimote.dae', new MaterialsList( list ), 0.03125 * .5 * .5 )
			collada.addEventListener(FileLoadEvent.LOAD_COMPLETE, onColladaComplete );
			
			//-- Set up the graphics
			var scl: Number = .25;
			colorFx = new Matrix;
			colorFx.a = ( 500 + scl ) / 500;
			colorFx.d = ( 500 + scl ) / 500;
			colorFx.tx = -scl;
			
			colorDamp = new ColorTransform( .82, .84, .88 );
			
			screen = new Bitmap( new BitmapData( 500, 500, false, 0 ) );
			addChild( screen );
			
			screen.x = 250;
			screen.y = 50;
			
			//-- Connect Wiimote
			wiimote.connect();
		}
		
		private function onColladaComplete( event: FileLoadEvent ): void
		{
			var collada: Collada = event.target as Collada;
			
			collada.removeEventListener( FileLoadEvent.LOAD_COMPLETE, onColladaComplete );
			
			rootNode.addChildren( collada );
		}
		
		private function onWiimoteConnect( event: Event ): void
		{
			stage.addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}
		
		private function onEnterFrame( event: Event ): void
		{
			try
			{
				var wii3D: DisplayObject3D = rootNode.getChildByName( 'Box01' );
				
				//-- Reset wiimote view
				wii3D.rotationZ = 0;
				wii3D.rotationY = 180;
				wii3D.rotationX = 45;
				
				//-- Apply inertia to wiimote.roll
				roll -= ( roll + 90 * wiimote.roll ) * .5;
				
				//-- Roll wiimote view
				wii3D.roll( roll );
			}
			catch ( error: Error ) {}
			
			//-- Reset main view
			rootNode.rotationX = rootNode.rotationY = rootNode.rotationZ = 0;
			
			//-- Apply inertia to wiimote.pitch
			pitch -= ( pitch + 90 * wiimote.pitch ) * .5;

			//-- Pitch main view
			rootNode.pitch( pitch );
			
			//-- Render (with some motion blur)
			scene.renderCamera( camera );
			screen.bitmapData.draw( screen.bitmapData, colorFx, colorDamp, null, null, true );
			screen.bitmapData.applyFilter( screen.bitmapData, screen.bitmapData.rect, new Point, new BlurFilter( 8, 8, 1 ) );
			screen.bitmapData.draw( container, container.transform.matrix );
		}
	}
}
