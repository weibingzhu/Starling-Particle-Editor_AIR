package com.terry.www
{
	import flash.display.Sprite;
	
	/**
	 *清理一个sprite 
	 */
	public function clearSprite(spr : Sprite):void
	{
		////////////////////////////////没有测试这两种哪种较快////////////////////////////////////
		//1在执行的过程中，其他程序把一个child删了，会不会报错
//		var l : int  = spr.numChildren ;
//		for (var i:int = 0; i <l ; i++) 
//			spr.removeChildAt(0);
		while (spr.numChildren > 0) spr.removeChildAt(0);
	}
	
}