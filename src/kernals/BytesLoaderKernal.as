package kernals
{
	import com.larrio.flow.ITaskKernel;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	/**
	 * 任务执行失败时派发 
	 */	
	[Event(name="error",type="flash.events.ErrorEvent")]
	
	/**
	 * 任务执行完毕时派发 
	 */	
	[Event(name="complete", type="flash.events.Event")]

	/**
	 * 
	 * @author larryhou
	 * @createTime Dec 6, 2012 9:37:12 PM
	 */
	public class BytesLoaderKernal extends EventDispatcher implements ITaskKernel
	{
		private var _result:ByteArray;
		private var _data:Object;
		
		/**
		 * 构造函数
		 * create a [ImageLoaderKernal] object
		 */
		public function BytesLoaderKernal()
		{
			
		}
		
		/**
		 * 执行加载图片逻辑
		 * @param data	包含URL的数据
		 * 
		 */		
		public function execute(data:Object):void
		{
			_data = data;
			_result = null;
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, completeHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, completeHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, completeHandler);
			loader.load(new URLRequest(_data.avatar));
		}
		
		/**
		 * 图片正常被加载完毕
		 */		
		private function completeHandler(e:Event):void
		{
			var loader:URLLoader = e.currentTarget as URLLoader;
			loader.removeEventListener(Event.COMPLETE, completeHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, completeHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, completeHandler);
			
			if (e.type == Event.COMPLETE)
			{
				_result = e.currentTarget.data;
				dispatchEvent(new Event(Event.COMPLETE));
			}
			else	
			{
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, ErrorEvent(e).text));
			}
		}
		
		/**
		 * 已加载图片字节数组
		 */		
		public function get result():Object { return _result; }

		/**
		 * 运行时传参对象
		 */		
		public function get data():Object { return _data; }


	}
}