package com.terry.www
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	
	import starling.display.Image;
	import starling.textures.Texture;
	
	
	public class DragIn extends Sprite
	{
		private static var instance:DragIn;
		public var sp:Sprite;
		public var file:File;
		private var loader:Loader;
		public function DragIn(parm:Parm)
		{
			sp = new Sprite();
			addChild(sp);
			drawbackgroud();
			init();
		}
		public static function getInstance():DragIn{
			if(instance==null){
				var parm:Parm = new Parm();
				instance = new DragIn(parm);
			}
			return instance;
		}
		public function init():void {
			sp.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER,onDragIn);//通常做拖入文件的类型检查	
			sp.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,onDrop);//拖拽完成事件
		}
		private function removeListener():void{
			sp.removeEventListener(NativeDragEvent.NATIVE_DRAG_ENTER,onDragIn);//通常做拖入文件的类型检查	
			sp.removeEventListener(NativeDragEvent.NATIVE_DRAG_DROP,onDrop);//拖拽完成事件
		}
		private function drawbackgroud():void{
			sp.graphics.beginFill(0x00ffff,1);
			sp.graphics.drawRect(0,0,Main.stageWidth,Main.stageHeigth);
			sp.graphics.endFill();
		}
		private function onDragIn(event:NativeDragEvent):void{
			
			var transferable:Clipboard = event.clipboard;	
			if(transferable.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)){
				var files:Array = transferable.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				for each(var file:File in files){
					if(file.extension =="jpg" || file.extension =="png" ){
						NativeDragManager.acceptDragDrop(sp); //指定的目标交互式对象可以接受与当前拖动事件对应的放置。
//						NativeDragManager.doDrag(sp,transferable);
						break;
					}
					else {
						trace("格式不对，仅接受jpg和png");
					}
				}
			} else {	
				trace("格式不对，仅接受jpg和png");
			}
		}
		
		private function onDrop(event:NativeDragEvent):void
		{
			var dropfiles:Array= event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;	
			file = dropfiles[0];	
			trace(file.url);
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,picComHandler);
			loader.load(new URLRequest(file.url));
		}
		private function picComHandler(e:Event):void
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,picComHandler);
			clearSprite(sp);
			var img:Bitmap = (e.currentTarget as LoaderInfo).content as Bitmap;
			
			img.width = get2Math(img.width);
			img.height = get2Math(img.height);
				
//			sp.addChild(img);
			var texture:Texture = Texture.fromBitmap(img);
			var bgImage : Image = new Image(texture);
			Main.mStarling.stage.addChildAt(bgImage, 0);
			DragOut.getInstance().addListener();
		}
		
		private function get2Math(num : int):int
		{
			var   rval : int=1;
			rval*=2;
			while(rval<num)
				rval<<=1;
			return rval;
		}
	
	
	}
}
class Parm{}