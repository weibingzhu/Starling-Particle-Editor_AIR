package com.terry.www
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import com.terry.www.JPGEncoder;
	import com.terry.www.clearSprite;
	
//	import dream798.factory.images.JPGEncoder;
//	import dream798.factory.images.PNGEncoder
	
	public class DragOut extends Sprite
	{
		public var sp:Sprite;
		
		private static var instance:DragOut;
		private var ba:ByteArray;
		public function DragOut(parm:Parm)
		{
			sp = DragIn.getInstance().sp;
		}
		public static function getInstance():DragOut{
			if(instance==null){
				
				var parm:Parm = new Parm();
				instance=new DragOut(parm);
			}
			return instance;
		}
		/**
		 *注册侦听 
		 * 
		 */		
		public function addListener():void{
			sp.addEventListener(MouseEvent.MOUSE_DOWN,downHandler);
		}
		private function downHandler(e:MouseEvent):void
		{
			if (sp.numChildren == 0 ) return 
			var bmp:Bitmap = sp.getChildAt(0) as Bitmap;
			var jpg:JPGEncoder = new JPGEncoder();	
			ba = jpg.encode(bmp.bitmapData);	
			file = DragIn.getInstance().file;
			var transferObject:Clipboard = createClipboard(bmp); 
			NativeDragManager.doDrag(sp, transferObject, bmp.bitmapData, new Point(-mouseX,-mouseY)); 
			sp.addEventListener(NativeDragEvent.NATIVE_DRAG_START,startHandler);
//			sp.addEventListener(NativeDragEvent.NATIVE_DRAG_COMPLETE,comHandler);写在这里一拖拽就撤销了，改成拖拽离开舞台时再监听
			this.stage.addEventListener(Event.MOUSE_LEAVE,onMouseLeave);
		}
		
		/**
		 *当拖拽离开舞台时 
		 * @param event
		 */
		private function onMouseLeave(event:Event):void
		{
			sp.addEventListener(NativeDragEvent.NATIVE_DRAG_COMPLETE,comHandler);
		}
		private function startHandler(e:NativeDragEvent):void{
			trace("开始拖拽");		
		}
		
		private var file:File;
		
		/**
		 *拖拽完成 
		 * @param e
		 */		
		private function comHandler(e:NativeDragEvent):void{
			var fileStream:FileStream = new FileStream();	
			fileStream.open(file, FileMode.WRITE);	
			fileStream.writeBytes(ba,0,ba.length);	
			fileStream.close();
//			sp.removeChildAt(0);
			clearSprite(sp);
			sp.removeEventListener(MouseEvent.MOUSE_DOWN,downHandler);
			DragIn.getInstance().init();
		}
		public function createClipboard(image:Bitmap):Clipboard { 
			var transfer:Clipboard = new Clipboard();
			transfer.setData("bitmap", image, true);	
			transfer.setData(ClipboardFormats.BITMAP_FORMAT, image.bitmapData, false);
			transfer.setData(ClipboardFormats.FILE_LIST_FORMAT,new Array(file),false);
			return transfer;
		}
	}
}
class Parm{}