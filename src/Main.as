package
{
	import com.onebyonedesign.particleeditor.ParticleEditor;
	import com.onebyonedesign.particleeditor.ParticleView;
	import com.onebyonedesign.particleeditor.SettingsModel;
	import com.terry.www.DragIn;
	import com.terry.www.DragOut;
	import com.terry.www.clearSprite;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.textures.Texture;
	
	[SWF(width='1424', height='800', backgroundColor='#232323', frameRate='60')]
	public class Main extends Sprite
	{
		[Embed(source="../assets/fire.pex", mimeType="application/octet-stream")]
		private const DEFAULT_CONFIG:Class;
		
		[Embed(source = "../assets/bg.png")] 
		private static const Sausage:Class;
		
		/** Starling instance */
		public static  var mStarling:Starling;
		public static  var stageWidth:  int ;
		public static  var stageHeigth: int ;
		
		/** Starling view port */
		private var mViewPort:Rectangle ;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			initStage();
			initParticleDisplay();
			
			intEvent();
		}
		
		private function intEvent():void
		{
			addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER,onDragIn);//通常做拖入文件的类型检查	
			addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,onDrop);//拖拽完成事件
		}
		
		private function initStage():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.showDefaultContextMenu = false;
			
			stageWidth = stage.stageWidth;
			stageHeigth = stage.stageHeight;
		}
		
		private function initParticleDisplay():void
		{
			mViewPort = new Rectangle(0, 0, stageWidth, stageHeigth);
			mStarling = new Starling(ParticleView, stage, mViewPort);
            mStarling.addEventListener("rootCreated", onStarlingRoot);
			mStarling.antiAliasing = 4;
			//mStarling.stage.alpha = 1 ;
			mStarling.stage.color = 0x000000;
			mStarling.enableErrorChecking = false;
			mStarling.start();
		}
		
		private function onStarlingRoot(event:*):void
		{
            mStarling.removeEventListener("rootCreated", onStarlingRoot);
            
            var settings:SettingsModel = new SettingsModel();
            settings.x = 400 ;
            addChild(settings);
			
            var initialConfig:XML = XML(new DEFAULT_CONFIG());
            
            var editor:ParticleEditor = new ParticleEditor(settings, initialConfig, (mStarling.root as ParticleView));
			
			
//			var bgBitmap:Bitmap = new Sausage();
//			var texture:Texture = Texture.fromBitmap(bgBitmap);
//			var bgImage : Image = new Image(texture); 
//			mStarling.stage.addChildAt(bgImage, 0);
			
			
		}
		
		
		
		/////////////////////////////////////////////// 拖动 改变地图  //////////////////////////////////////////////////////////////////////
		
		public var sp:Sprite;
		public var file:File;
		private var loader:Loader;
		private function onDragIn(event:NativeDragEvent):void{
			
			var transferable:Clipboard = event.clipboard;	
			if(transferable.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)){
				var files:Array = transferable.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				for each(var file:File in files){
					if(file.extension =="jpg" || file.extension =="png" ){
						NativeDragManager.acceptDragDrop(this); //指定的目标交互式对象可以接受与当前拖动事件对应的放置。
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
			var img:Bitmap = (e.currentTarget as LoaderInfo).content as Bitmap;
			
			img.width = get2Math(img.width);
			img.height = get2Math(img.height);
			
			var display : starling.display.DisplayObject = mStarling.stage.getChildAt(0);
			if( display is Image)
			{
				display.dispose();
				mStarling.stage.removeChild(display);
			}
			
			var texture:Texture = Texture.fromBitmap(img);
			img.bitmapData.dispose();
			var bgImage : Image = new Image(texture);
			mStarling.stage.addChildAt(bgImage, 0);
		}
		
		/**
		 * 如果图片不是宽高 2的N次方，转换一下  
		 * @param num
		 * @return 
		 * 
		 */
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