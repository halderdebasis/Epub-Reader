////////////////////////////////////////////////////////////////////////////////
//
// ADOBE SYSTEMS INCORPORATED
// Copyright 2007-2010 Adobe Systems Incorporated
// All Rights Reserved.
//
// NOTICE:  Adobe permits you to use, modify, and distribute this file 
// in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.adobe
{
	import flash.text.StyleSheet;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.conversion.ImportExportConfiguration;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.IFormatResolver;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.property.Property;
	import flashx.textLayout.tlf_internal;
	use namespace tlf_internal;

	/** This version hands back a style on demand from the dictinoary.
	 * Another way to do it would be to "redo" the cascade top down.
	 */
	public class CSSFormatResolver implements IFormatResolver
	{
		/** cache of already calculated styles. */
		private var _textLayoutFormatCache:Dictionary;
		/** Hangs on to the parsed styleSheet */
		private var _styleSheet:StyleSheet;
				
		/** Create a flex style resolver.  */
		public function CSSFormatResolver(styleSheet:StyleSheet):void
		{
			_textLayoutFormatCache = new Dictionary(true);
			_styleSheet = styleSheet;
		}
		
		/** Use styleSelector to look up a style declaration from the parsed style.  Add each set attribute to a TextLayoutFormat creating one if necessary. */
		private function addStyleAttributes(attr:TextLayoutFormat, styleSelector:String):TextLayoutFormat
	 	{
	 		var foundStyle:Object = _styleSheet.getStyle(styleSelector);
	 		if (foundStyle)
	 		{ 				
				// description is a list of all the TLF defined attributes
				// Property is an internal, but very useful, class that defines a TLF attribute.  We're just looking at its name.
	 			for each (var prop:Property in TextLayoutFormat.description)
	 			{
	 				var propStyle:Object = foundStyle[prop.name];
	 				if (propStyle)
	 				{
	 					if (attr == null)
	 						attr = new TextLayoutFormat();
	 					attr[prop.name] = propStyle;
	 				}
	 			}
	 		}
	 		return attr;
	 	}
	 
	  	/** Calculate the TextLayoutFormat style for a particular element. Implements three style selectors for each element
		 * - type selector (this is new for 2.0 - each element has a typeName property that is normally the TLF typeName. 
		 * 	The HTML importer converts <foo> to a TLF element with typeName="foo"
		 * - class selector 
		 * - id selector
		 */
	 	public function resolveFormat(elem:Object):ITextLayoutFormat
	 	{
	 		var attr:TextLayoutFormat = _textLayoutFormatCache[elem];
	 		if (attr !== null)
	 			return attr;
	 			
	 		if (elem is FlowElement)
	 		{
				attr = addStyleAttributes(attr, elem.typeName);
				
				if (elem.styleName != null)
					attr = addStyleAttributes(attr, "." + elem.styleName);
					
				if (elem.id != null)
					attr = addStyleAttributes(attr, "#" + elem.id);
			
				_textLayoutFormatCache[elem] = attr;
			}
	 		return attr;
	 	}
 		
 		/** Calculate the user style for a particular element. The parsed styleSheet is held in _styleSheet.  Apply the CSS selectors here. 
		 * Generally this is only called when the already calculated result isn't in the cache.  */
 		public function resolveUserFormat(elem:Object,userStyle:String):*
 		{
 			var flowElem:FlowElement = elem as FlowElement;
 			var foundStyle:Object;
 			var propStyle:*;
 			
 			// support non-tlf styles
 			if (flowElem)
 			{
 				if (flowElem.id)
 				{
 					foundStyle = _styleSheet.getStyle("#"+flowElem.id);
 					if (foundStyle)
 					{
 						propStyle = foundStyle[userStyle];
 						if (propStyle !== undefined)
 							return propStyle;
 					}
 				}
 				if (flowElem.styleName)
 				{
					foundStyle = _styleSheet.getStyle("."+flowElem.styleName);
 					if (foundStyle)
 					{
						foundStyle = foundStyle[userStyle];
 						if (propStyle !== undefined)
 							return propStyle;
 					}
 				}
 				
				foundStyle = _styleSheet.getStyle(flowElem.typeName);
 				if (foundStyle)
 				{
					propStyle = foundStyle[userStyle];
 					if (propStyle !== undefined)
 						return propStyle;
 				}
 			}
 			return undefined;
 		}
 		
 		/** Completely clear the cache.  None of the results are valid. */
 		public function invalidateAll(tf:TextFlow):void
 		{
 			_textLayoutFormatCache = new Dictionary(true);	// clears the cache
 		}
 		
 		/** The style of one element is invalidated.  */
 		public function invalidate(target:Object):void
 		{
 			delete _textLayoutFormatCache[target];
			
			// recursively descend if this element is a FlowGroupElement.  Is this needed?
 			var blockElem:FlowGroupElement = target as FlowGroupElement;
 			if (blockElem)
 			{
	 			for (var idx:int = 0; idx < blockElem.numChildren; idx++)
	 				invalidate(blockElem.getChildAt(idx));
	 		}
 		}
 		 	
	 	/** Called when a TextFlow is copied.  In this case these are sharable between TextFlows.  If the flows have different styleSheets you may want to clone this. */
		public function getResolverForNewFlow(oldFlow:TextFlow,newFlow:TextFlow):IFormatResolver
	 	{ return this; }
	}
}
