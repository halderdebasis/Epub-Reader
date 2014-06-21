package com.debasishalder.epub
{
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.system.System;

	public class OPFManager extends EventDispatcher
	{
		public var _metadata:Object;
		var _opfDoc:XML;
		public var opf:Namespace;
		//var idrefDict:Dictionary
		var i:int = 0
		var dc:Namespace
		var _processingItems:Vector.<String>
		var CSSItems:Vector.<String>
		public function OPFManager()
		{
			// constructor code
		}
		public function setOPF(xml:XML)
		{
			_opfDoc = xml;
			opf = _opfDoc.namespace();
		}
		public function ReadMetadata()
		{
			
			if ((_opfDoc == null))
			{
				return null
			}
			_metadata = new Object  ;
			dc = new Namespace("http://purl.org/dc/elements/1.1/");
			_metadata.title = _opfDoc.opf::metadata.dc::title.toString();
			var CreatorLength:int = _opfDoc.opf::metadata.dc::creator.length()
			if( _opfDoc.opf::metadata.dc::creator.length() > 1){
				var Author:Array = new Array()
				for(i = 0; i < CreatorLength; i++){
					Author.push( _opfDoc.opf::metadata.dc::creator[i].toString()) 
				}
				_metadata.creator = Author.join(', ')
				Author = null
			}else{
			_metadata.creator = _opfDoc.opf::metadata.dc::creator.toString();
			}
			if(_metadata.creator == '' || _metadata.creator == null || _metadata.creator == undefined){
				_metadata.creator = 'Unknown Author'
			}
			if(_metadata.title == '' || _metadata.title == null || _metadata.title == undefined){
				_metadata.title = 'Untitled Book'
			}
			//makePagesFromOpf()
			//return _metadata;
		}
		protected function makePagesFromOpf():void {
			
			
			 _processingItems = new Vector.<String>();
			 CSSItems = new Vector.<String>();
			var extractedItems:Array = new Array();
			var itemNodes:XMLList = _opfDoc.opf::manifest.opf::item;			
			var i:int;
			var id:String;
			var mimeType:String
			for (i=0; i<itemNodes.length(); i++) {
				mimeType= itemNodes[i].attribute("media-type").toString();
				id = itemNodes[i].@id.toString();
				if ( mimeType == 'application/xhtml+xml') {
					extractedItems[id] = new Object();
					extractedItems[id].path = itemNodes[i].@href.toString();
				} else if(mimeType == "text/css"){
					CSSItems.push(itemNodes[i].@href.toString())
				}
			}
			itemNodes = null
			var spineNodes:XMLList = _opfDoc.opf::spine.opf::itemref;
			for (i=0; i<spineNodes.length() ; i++) {
				id = spineNodes[i].@idref.toString();
				try{
					var sss:String = String(extractedItems[id.toString()].path)
					trace('spineNodes:XMLList = _opfDoc.opf::spine.opf::itemref;  '+sss)
				_processingItems.push(extractedItems[id.toString()].path);
				extractedItems[id].path = null
				extractedItems[i] = null
				}catch(e:Error){
					trace(e.message)
				}
			}
			extractedItems = null
			spineNodes = null
			id = null
			mimeType = null
			dispatchEvent(new Event(Event.COMPLETE))
		}
		
		public function getOPF(){
			if ((_opfDoc == null))
			{
				return 
			}
			ReadMetadata()
			makePagesFromOpf()
		}
		public function getAllPages():Vector.<String>{
			return _processingItems
		}
		public function getAllCSS():Vector.<String>{
			return CSSItems
		}
		public function getMetadata():Object{
			return _metadata
		}
		public function dispose(){
		if(_opfDoc){
			System.disposeXML(_opfDoc)
			_opfDoc = null
		}
		_metadata = null
		opf = null		
		dc = null
		_processingItems = null
		CSSItems = null
		}
	}

}