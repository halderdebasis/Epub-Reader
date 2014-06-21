package com.debasishalder.book
{
	import com.debasishalder.epub.OPFManager;
	import com.debasishalder.epub.Unpacker;
	import com.debasishalder.utility.SQLiteDBSearch
	import flash.filesystem.File;
	import flash.system.System;

	public class AddBookManager
	{
		var unpacker:Unpacker;
		var OPF:OPFManager = new OPFManager();
		public  var SQLITE:SQLiteDBSearch 
		var Createtable:String = "CREATE TABLE IF NOT EXISTS library (category TEXT, title TEXT, creator TEXT, coverImage TEXT, flo TEXT, mcq TEXT, gfx TEXT, rawfile TEXT, bookstatus TEXT, bookid TEXT, filesize TEXT, fileextension TEXT)"
		public function AddBookManager(epb_path:String,caategory:String,sqlite:SQLiteDBSearch,nextfunc:Function = null,error:Function = null)
		{
			
			SQLITE = sqlite
			trace(epb_path)
			var tmp:File = new File(epb_path)
			var sql:String
			var bookid:String
			var ttl:String
			var date:Date
			var crtr:String 
			var filesizes:String 
			if(tmp.size > 0){
			filesizes = String(tmp.size)+' kb'
			}else{
				filesizes =''
			}
			if(tmp.extension == 'epub'){
				
			unpacker = new Unpacker(epb_path,'');
			var DBFIle:File = File.documentsDirectory
			DBFIle = DBFIle.resolvePath('preference/Library.db')
			if(!DBFIle.parent.exists){
				DBFIle.parent.createDirectory()
			}
			if(SQLITE == null){
				SQLITE = new SQLiteDBSearch(DBFIle.nativePath,trace)
				SQLITE.WriteStatement(Createtable,null,true,error)
			}
			//SQLITE.setDB(DBFIle.nativePath);
			DBFIle = null
			var MetaInfXml:XML = new XML(unpacker.extractString('META-INF/container.xml'));
			var opfFileName:String = MetaInfXml.children()[0].children()[0].attribute("full-path");
			System.disposeXML(MetaInfXml)
			MetaInfXml = null
			var OPFXML:XML = new XML(unpacker.extractString(opfFileName));
			OPF.setOPF(OPFXML);
			OPF.ReadMetadata()
			System.disposeXML(OPFXML)
			OPFXML = null
			var OO:Object = OPF.getMetadata()
			 date = new Date()
			 bookid = String(date.time)
			 ttl = OO.title.toString()
			 crtr = OO.creator.toString()
			crtr = crtr.split("'").join("`")
			ttl = ttl.split("'").join("`")
			OO = null
			 sql = "INSERT INTO library (category,title,creator,bookstatus,bookid,rawfile,filesize,fileextension)VALUES('"+caategory+"','"+ttl+"','"+crtr+"','added','"+bookid+"','"+epb_path+"','"+filesizes+"','"+tmp.extension+"')"
			SQLITE.WriteStatement(sql,nextfunc,true,error)
			OO = null
			sql = null
			date = null
			bookid = null
			opfFileName = null
			}/*else{
				date = new Date()
				bookid = String(date.time)
			 ttl = tmp.name
			 ttl = ttl.split(tmp.extension).join('')
			crtr = 'NULL' 
			//var filesizes:String
				 sql = "INSERT INTO library (category,title,creator,bookstatus,bookid,rawfile,filesize,fileextension)VALUES('"+caategory+"','"+ttl+"','"+crtr+"','added','"+bookid+"','"+epb_path+"','"+filesizes+"','"+tmp.extension+"')"
			trace(sql,nextfunc)
			SQLITE.WriteStatement(sql,nextfunc,true,error)
			OO = null
			sql = null
			date = null
			bookid = null
			opfFileName = null
			filesizes = null;
			}*/
			//trace(OO.title,OO.creator)
		}
		public function DeleteBook(CatagorySTRING:String,bookIndexid:String,success:Function = null,error:Function = null){
			var stat:String = "DELETE FROM library WHERE category='"+CatagorySTRING+"' AND bookid ='"+bookIndexid+"'"
			trace(stat)
			SQLITE.WriteStatement(stat,success,true,error)
			//SQLITE.SearchConditionalData('library',null,Condition)
		}
		public function setBookAsLoaded(dbpath:String,id:String,error = null){
			var stat:String = "UPDATE library SET rawfile='"+dbpath+"', bookstatus='loaded' WHERE bookid='"+id+"'";
			//trace(stat)
			SQLITE.WriteStatement(stat,null,true,error)
		}
public function dispose(){
	//DBFIle = null
			SQLITE = null
			OPF = null
			unpacker = null
	
}
	}

}