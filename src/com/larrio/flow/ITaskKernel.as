package com.larrio.flow
{
	import flash.events.ErrorEvent;
	import flash.events.IEventDispatcher;
	
	/**
	 * 任务执行失败时派发 
	 */	
	[Event(name="error",type="flash.events.ErrorEvent")]
	
	/**
	 * 任务执行完毕时派发 
	 */	
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * 任务执行核心
	 * @author larryhou
	 * @createTime Dec 6, 2012 8:43:49 PM
	 */
	public interface ITaskKernel extends IEventDispatcher
	{
		 /**
		  * 执行任务
		  */		
		 function execute(data:Object):void;
		 
		 /**
		  * 运行时传参数据引用
		  */		 
		 function get data():Object;
		 
		 /**
		  * 任务执行完成后产生的结果 
		  */		 
		 function get result():Object;
	}
}