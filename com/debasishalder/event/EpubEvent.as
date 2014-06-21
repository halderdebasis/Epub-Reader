package com.debasishalder.event
{
	import flash.events.Event;
	public class EpubEvent extends Event
	{
		public var ITEM:Object;
		public static const ON_BOOK_CLICK:String = "ON_BOOK_CLICK";
		public static const ON_EPUB_ITEM_CLICK:String = "ON_EPUB_ITEM_CLICK";
		public static const ON_CANCEL_CLICK:String = "ON_CANCEL_CLICK";
		public static const ON_BOOKMARK_CLICK:String = "ON_BOOKMARK_CLICK";
		public static const ON_EPUB_LOAD_COMPLETE:String = "ON_EPUB_LOAD_COMPLETE";
		public static const ON_EPUB_ERROR:String = "ON_EPUB_ERROR";
		public function EpubEvent(type:String,Item:Object = null):void
		{
			super(type);
			ITEM = Item;
		}

		public override function clone():Event
		{
			return new EpubEvent(type, ITEM);
		}
	}
}