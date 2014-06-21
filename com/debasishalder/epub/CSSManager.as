package com.debasishalder.epub
{
	import flash.system.System;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.utils.setTimeout
	public class CSSManager extends EventDispatcher
	{
		var css_String:String;
		var H1Stat:Boolean = false
		var H2Stat:Boolean = false
		var H3Stat:Boolean = false
		var H4Stat:Boolean = false
		var H5Stat:Boolean = false
		var H6Stat:Boolean = false
		public function CSSManager()
		{
		}
		public function dispose(){
		
		css_String = null
		System.gc()
		System.gc()
		System.gc()
		System.gc()
		}			
		public function ManageCSS(S:String)
		{
			S = S.replace(/\s*([@{}:;,]|\)\s|\s\()\s*|\/\*([^*\\\\]|\*(?!\/))+\*\/|[\n\r\t]/g,'$1');
			managePercent(S);
		}
		public function getCSS():String
		{
			return css_String;
		}
		function managePercent(ss:String):void
		{
			css_String = ss;
			var Arrays:Array = new Array();
			var prcnt:String = css_String.split("% ").join("~");
			prcnt = prcnt.split("%;").join("~;");
			var percntArr:Array = prcnt.split("~");
			var lastStr:String = percntArr[percntArr.length - 1];
			for (var r:int = 0; r < percntArr.length - 1; r++)
			{
				var prcntNumber:String = percntArr[r];
				for (var s:int = 1; s <= prcntNumber.length; s++)
				{
					var Endprcnt:String = prcntNumber.substr(prcntNumber.length - s,1);
					if ((Endprcnt == ":"))
					{
						var prcntnumb:String = prcntNumber.substr(prcntNumber.length - (s - 1),(s - 1));
						var prcntpix:Number = Math.round((Number(prcntnumb) * Number((16 / 100))));
						var prcntprevious_Str:String = prcntNumber.substr(0,prcntNumber.length - (s - 1));
						var prcntactArr:String = prcntprevious_Str + prcntpix;
						Arrays.push(prcntactArr);
						prcntnumb = null;
						prcntprevious_Str = null;
						prcntactArr = null;
						break;
					}
				}
			}
			css_String = addArray(Arrays) + lastStr;
			setTimeout(ManagePx,20,css_String);
			css_String = null;
			Arrays = null;
			prcnt = null;
			percntArr = null;
			lastStr = null;
			prcntNumber = null;
			Endprcnt = null;
			System.gc();
			System.gc();
			System.gc();

		}
		function addArray(Arr:Array):String
		{
			var allStr:String = '';
			for (var c:int = 0; c < Arr.length - 1; c++)
			{
				allStr +=  Arr[c];
			}
			Arr.splice(0,Arr.length);
			Arr = null;
			System.gc();
			System.gc();
			System.gc();
			return allStr;
		}

		function ManagePx(cssDt:String):void
		{
			var Arrays:Array = new Array();
			var em:String = cssDt.substr(0,cssDt.lastIndexOf('}') + 1);
			cssDt = null;
			em = em.split("em ").join("~");
			em = em.split("em;").join("~;");
			em = em.split("small;").join("12;");
			em = em.split("smaller;").join("12;");
			em = em.split("larger;").join("22;");
			em = em.split("small;").join("12;");
			em = em.split("large;").join("22;");
			em = em.split("medium;").join("17;");
			
			var emarr:Array = em.split("~");
			var lastStr:String = emarr[emarr.length - 1];
			for (var p:int = 0; p < emarr.length - 1; p++)
			{
				var emNumber:String = emarr[p];
				for (var q:int = 1; q <= emNumber.length; q++)
				{
					var Endemn:String = emNumber.substr(emNumber.length - q,1);
					if ((Endemn == ":"))
					{
						var numb:String = emNumber.substr(emNumber.length - (q - 1),(q - 1));
						var pix:Number = Math.round((Number(numb) / Number(0.0626)));
						var previous_Str:String = emNumber.substr(0,emNumber.length - (q - 1));
						var actArr:String = previous_Str + pix;
						Arrays.push(actArr);
						numb = null;
						previous_Str = null;
						actArr = null;
						break;
					}
				}
			}
			css_String = addArray(Arrays) + lastStr;
			setTimeout(managepoint,20,css_String);
			css_String = null;
			Arrays = null;
			em = null;
			emarr = null;
			lastStr = null;
			emNumber = null;
			Endemn = null;
			System.gc();
			System.gc();
			System.gc();
		}

		function managepoint(das:String):void
		{
			var Arrays:Array = new Array();
			var cssString:String = das;
			das = null;
			var pnt:String = cssString.split("pt ").join("~");
			pnt = pnt.split("pt;").join("~;");
			var pntArr:Array = pnt.split("~");
			var lastStr:String = pntArr[pntArr.length - 1];
			for (var r:int = 0; r < pntArr.length - 1; r++)
			{
				var pntNumber:String = pntArr[r];
				for (var s:int = 1; s <= pntArr.length; s++)
				{
					var Endpnt:String = pntNumber.substr(pntNumber.length - s,1);
					if ((Endpnt == ":"))
					{
						var pntnumb:String = pntNumber.substr(pntNumber.length - (s - 1),(s - 1));
						var pntpix:Number = Math.round((Number(pntnumb) / Number(1.33)));
						var pntprevious_Str:String = pntNumber.substr(0,pntNumber.length - (s - 1));
						var pntactArr:String = pntprevious_Str + pntpix;
						Arrays.push(pntactArr);
						pntnumb = null;
						pntprevious_Str = null;
						pntactArr = null;
						break;
					}
				}
			}
			css_String = addArray(Arrays) + lastStr;
			setTimeout(prefixPrepear,20,css_String);
			css_String = null;
			Arrays = null;
			cssString = null;
			pnt = null;
			pntArr = null;
			lastStr = null;
			pntNumber = null;
			Endpnt = null;
			System.gc();
			System.gc();
			System.gc();

		}

		function prefixPrepear(Sd:String):void
		{
			var cssddt:String = Sd;
			Sd = null;
			var Main_preFix:Array = new Array();
			var preFix:Array = new Array();
			var Sufix:Array = new Array();
			var cssLine:Array = cssddt.split("}");
			for (var i:int = 0; i < cssLine.length - 1; i++)
			{
				var p:Array = cssLine[i].split("{");
				var pfx:String = p[0];
				var sfx:String = p[1];
				preFix.push(pfx);
				Sufix.push(sfx);
				p = null;
				pfx = null;
				sfx = null;		
			}
		for (var k:int=0; k < preFix.length; k++)
		{
			var totalPfxStr:String = preFix[k];
			totalPfxStr = totalPfxStr.split('\n').join('');
			var Arr:Array
			var FontsizeCheck:String  = Sufix[k]
			var Fontsize:String
			var totalPfxStrSmall:String = totalPfxStr.toLocaleLowerCase()
			if(totalPfxStrSmall.indexOf('h1') != -1){
				if(FontsizeCheck.indexOf('font-size') == -1){
					Fontsize = Sufix[k]
					Fontsize += 'font-size:24;'
					Sufix[k] = Fontsize
					Fontsize = null;
				}
				H1Stat = true;
			}
			if(totalPfxStrSmall.indexOf('h2') != -1){
				if(FontsizeCheck.indexOf('font-size') == -1){
					Fontsize = Sufix[k]
					Fontsize += 'font-size:22;'
					Sufix[k] = Fontsize;
					Fontsize = null;					
				}
				H2Stat = true;
			}
			if(totalPfxStrSmall.indexOf('h3') != -1){
				if(FontsizeCheck.indexOf('font-size') == -1){
					Fontsize = Sufix[k]
					Fontsize += 'font-size:18;'
					Sufix[k] = Fontsize;
					Fontsize = null;					
				}
				H3Stat = true;
			}
			if(totalPfxStrSmall.indexOf('h4') != -1){
				if(FontsizeCheck.indexOf('font-size') == -1){
					Fontsize = Sufix[k]
					Fontsize += 'font-size:16;'
					Sufix[k] = Fontsize;
					Fontsize = null;					
				}
				H4Stat = true;
			}
			if(totalPfxStrSmall.indexOf('h5') != -1){
				if(FontsizeCheck.indexOf('font-size') == -1){
					Fontsize = Sufix[k]
					Fontsize += 'font-size:12;'
					Sufix[k] = Fontsize;
					Fontsize = null;					
				}
				H5Stat = true;
			}
			if(totalPfxStrSmall.indexOf('h6') != -1){
				if(FontsizeCheck.indexOf('font-size') == -1){
					Fontsize = Sufix[k]
					Fontsize += 'font-size:10;'
					Sufix[k] = Fontsize;
					Fontsize = null;					
				}
				H6Stat = true;
			}
			totalPfxStrSmall = null
			Fontsize = null
			FontsizeCheck = null
			if (totalPfxStr.indexOf('#') >= 0)
			{
				 Arr = totalPfxStr.split('#');
				totalPfxStr = Arr[Arr.length - 1];
				Arr = null;
			}
			if (totalPfxStr.indexOf('.') != -1 )
			{
				 Arr = totalPfxStr.split('.');
				totalPfxStr = Arr[Arr.length - 1];
				totalPfxStr = '#'+totalPfxStr
				//trace('totalPfxStr +'+totalPfxStr)
				Arr = null;
			}
			
			if (totalPfxStr.indexOf(' ') >= 0)
			{
				 Arr = totalPfxStr.split(' ');
				totalPfxStr = Arr[0];
				Arr = null;
			}
			var FS:String = totalPfxStr.charAt(0);
			/*if(FS == ' '){
				totalPfxStr = totalPfxStr.substring(1,totalPfxStr.length)
			}
			FS = totalPfxStr.charAt(0);*/
			if (FS != '.' && FS != '#')
			{
				Main_preFix.push('#'+totalPfxStr);
			}
			else if (FS == '.')
			{
				totalPfxStr = totalPfxStr.split('.').join('#');
				Main_preFix.push(totalPfxStr);
			}
			else if (FS != '#')
			{
				totalPfxStr = totalPfxStr.split('.').join('#');
				Main_preFix.push('#'+totalPfxStr);
			}
			else
			{
				Main_preFix.push('#'+totalPfxStr);
			}
			totalPfxStr = null;
		}
		cssddt = null;
		setTimeout(joinallArray,20,Main_preFix,Sufix);
		Main_preFix = null;
		preFix = null;
		Sufix = null;
		cssLine = null;
		System.gc();
		System.gc();
		System.gc();
	}
	function joinallArray(Main_preFix:Array,Sufix:Array):void
	{
		var main_Css:String = '';
		for (var n:int=0; n<Main_preFix.length; n++)
		{
			var ssssfx:String = '';
			var prefxx:String = '';
			var prefxstr:String = '';
			if (Main_preFix[n] == '')
			{
				prefxx = 'Blank';
			}
			else
			{
				prefxstr  = Main_preFix[n]
				;
				prefxx = prefxstr;
			}
			if (Sufix[n] == undefined || Sufix[n] == 'none' || prefxx == 'Blank')
			{
				ssssfx = '';
				prefxx = '';
			}
			else
			{

				ssssfx = ' {' + Sufix[n] + '} \n';
			}
			if (prefxstr.indexOf(',') != -1)
			{

				var PrfxArr:Array = prefxstr.split(',');
				for (var c:int =0; c <PrfxArr.length; c++)
				{

					var dn:String = '#'+PrfxArr[c] + ssssfx;
					main_Css +=  dn;
					dn = null;
				}
				PrfxArr = null;
			}else{

			var ln:String = prefxx + ssssfx;
			main_Css +=  ln;
			ln = null;
			}
			ssssfx = null;
			prefxx = null;
			prefxstr = null;
			
		}
		css_String = main_Css;
		setTimeout(finalizeCSS,20,css_String);
		main_Css = null;
		main_Css = null;
		ssssfx = null;
		prefxx = null;
		PrfxArr = null;
		dn = null;
		ln = null;
		Main_preFix = null;
		Sufix = null;
		System.gc();
		System.gc();
		System.gc();
		System.gc();
	}
	function finalizeCSS(S:String)
	{
		var pat:RegExp = /line-height\s*?\:\s*?\d*\.?\d*?\;?/ig;
		S = S.replace(pat,'');
		S = S.split('#body').join('body')
		S = S.split('#div').join('div')
		S = S.split('#span').join('span')
		S = S.split('#a').join('a')
		S = S.split('#p').join('p')
		/*S = S.split('#h1').join('h1')
		S = S.split('#h2').join('h2')
		S = S.split('#h3').join('h3')
		S = S.split('#h4').join('h4')
		S = S.split('#h5').join('h5')
		S = S.split('#h6').join('h6')*/
		S = S.split('##').join('#')
		S = S.split('#div').join('div')
		S = S.split('#TextFlow').join('TextFlow')
		//S.indexOf('h1 #TextFlow
		S +="#bookmark {backgroundColor:#000000;background-color:#000000;} "
		S +=".bookmark {backgroundColor:#000000;background-color:#000000;} "
		if(!H1Stat){
			S +='#h1 {font-size:24;}\n'
		}
		if(!H2Stat){
			S +='#h2 {font-size:22;}\n'
		}
		if(!H3Stat){
			S +='#h3 {font-size:18;}\n'
		}
		if(!H4Stat){
			S +='#h4 {font-size:16;}\n'
		}
		if(!H5Stat){
			S +='#h5 {font-size:12;}\n'
		}
		if(!H6Stat){
			S +='#h6 {font-size:10;}\n'
		}
		css_String = S;
		S = null;
		System.gc();
		System.gc();
		System.gc();
		dispatchEvent(new Event(Event.COMPLETE));
	}
}

}