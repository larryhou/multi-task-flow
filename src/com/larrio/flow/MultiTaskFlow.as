package com.larrio.flow
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * 任务执行失败时派发 
	 */	
	[Event(name="error",type="flash.events.ErrorEvent")]
	
	/**
	 * 所有任务执行完毕时派发 
	 */	
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * 单个任务执行完毕时派发 
	 */	
	[Event(name="change", type="flash.events.Event")]

	/**
	 * 多任务控制器
	 * @author larryhou
	 * @createTime Dec 6, 2012 8:41:06 PM
	 */
	public class MultiTaskFlow extends EventDispatcher implements ITaskKernel
	{
		private var _queue:Array;
		private var _result:Array;
		
		private var _currentKernel:ITaskKernel;
		private var _kernels:Vector.<ITaskKernel>;
		
		private var _numFail:uint;
		private var _numSuccess:uint;
		
		private var _percent:Number;
		
		private var _index:uint;
		private var _count:uint;
		private var _length:uint;
		private var _running:Boolean;
		
		/**
		 * 构造函数
		 * create a [MutilTaskFlow] object
		 * @param numThreads	任务执行的线程数，当线程数为1时可以理解为串行执行
		 * @param kernalClass	任务执行类
		 */		
		public function MultiTaskFlow(numThreads:uint, kernalClass:Class)
		{
			numThreads = Math.max(1, numThreads);
			
			_kernels = new Vector.<ITaskKernel>;
			for (var i:int = 0; i < numThreads; i++)
			{
				_kernels.push(new kernalClass());
			}
		}
		
		/**
		 * 重置数据
		 */		
		public function reset():void
		{
			_queue = [];
			_result = [];
			
			_length = 0;
			_percent = 0;
			_count = _index = 0;
			
			_running = false;
			_numFail = _numSuccess = 0;
			for (var i:int = 0; i < _kernels.length; i++) unlisten(_kernels[i]);
		}
		
		/**
		 * 执行任务项 
		 * @param data	子任务数据列表：数组对象
		 */		
		public function execute(data:Object):void
		{
			reset();
			
			_queue = data as Array;
			if (!_queue)
			{
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
				return;
			}			
			
			_length = _queue.length;
			for (var i:int = 0; i < _kernels.length; i++) if(!runNextTask(_kernels[i])) break;
		}
		
		/**
		 * 运行下一个任务
		 * @param kernal	任务执行对象
		 * @return 	是否成功分配新任务
		 */		
		private function runNextTask(kernal:ITaskKernel):Boolean
		{
			if (_index < _queue.length)
			{	
				_running = true;
				
				listen(kernal);
				kernal.execute(_queue[_index++]);
				return true;
			}
			else
			if(_count >= _length)
			{
				_running = false;
				dispatchEvent(new Event(Event.COMPLETE));				
			}
			
			return false;
		}
		
		/**
		 * 注册侦听子任务事件
		 * @param kernal	子任务执行对象
		 */		
		private function listen(kernal:ITaskKernel):void
		{
			kernal.addEventListener(Event.COMPLETE, completeHandler);
			kernal.addEventListener(ErrorEvent.ERROR, completeHandler);
		}
		
		/**
		 * 取消侦听子任务事件
		 * @param kernal	子任务执行对象
		 */		
		private function unlisten(kernal:ITaskKernel):void
		{
			kernal.removeEventListener(Event.COMPLETE, completeHandler);
			kernal.removeEventListener(ErrorEvent.ERROR, completeHandler);
		}

		/**
		 * 单个任务执行完毕处理
		 */		
		private function completeHandler(e:Event):void
		{
			if (e.type == ErrorEvent.ERROR)
			{
				_numFail++;
			}
			else
			{
				_numSuccess++;
			}
			
			_count++;
			_currentKernel = e.currentTarget as ITaskKernel;
			
			unlisten(_currentKernel);
			
			_result ||= [];
			_currentKernel.result && _result.push(_currentKernel.result);
			
			_percent = (_count / _length) * 100;
			
			dispatchEvent(new Event(Event.CHANGE));
			runNextTask(_currentKernel);
		}		

		/**
		 * 存储每个子任务的运行结果：数组对象
		 */		
		public function get result():Object { return _result; }

		/**
		 * 子任务执行失败的个数
		 */		
		public function get numFail():uint { return _numFail; }

		/**
		 * 子任务执行成功的个数 
		 */		
		public function get numSuccess():uint { return _numSuccess; }
		
		/**
		 * 运行时传参对象：数组对象
		 */		
		public function get data():Object { return _queue; }

		/**
		 * 当前刚刚完成的任务执行对象
		 */		
		public function get currentKernel():ITaskKernel { return _currentKernel; }

		/**
		 * 任务完成百分比
		 */		
		public function get percent():Number { return _percent; }

		/**
		 * 总的任务数量
		 */		
		public function get length():uint { return _length; }

		/**
		 * 当前任务是否正在执行
		 */		
		public function get running():Boolean { return _running; }
		
	}
}