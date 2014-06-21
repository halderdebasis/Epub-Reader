package com.debasishalder.utility
{
	import flash.events.EventDispatcher;
	import flash.events.SQLEvent;
	import flash.data.SQLTableSchema;
	import flash.errors.SQLError;
	import flash.events.SQLErrorEvent;
	import flash.data.SQLResult;
	import flash.filesystem.File;
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.data.SQLSchemaResult;
	import flash.data.SQLMode;
	import flash.net.Responder;

	public class SQLiteDBSearch extends EventDispatcher
	{
		private var AfterCommitFunction:Function;
		public var ERRORMASSAGE:String;
		public var ERRORID:int;
		public var ERRORNAME:String;
		public var dbFile:File;
		public var ALERT:Function;
		private var TestPa:File = File.documentsDirectory;
		public var DBPath:String;
		private var SQLWriteStatement:SQLStatement;
		private var SQLRESULT:SQLResult;
		private var SQLSCHEMA:SQLSchemaResult;
		private var SQLResultArray:Array;
		private var SelectedColumn:String;
		private var SelectedColumnNumber:int;
		private var AFTERCOMMITFUNCTION:Function;
		private var ColumnResult:Array;
		private var sqlConnection:SQLConnection = new SQLConnection();
		private var SqlString:SQLStatement;
		private var SQLtableName:String = '';
		public var TableColumnArray:Array;
		public function SQLiteDBSearch(path:String=null,alert:Function = null)
		{
			dbFile = new File(path);
			if (! dbFile.parent.exists)
			{
				dbFile.parent.createDirectory();
			}
			DBPath = TestPa.nativePath;
			ALERT = alert;
		}
		public function setDB(path:String ,alert:Function = null)
		{

			dbFile = new File(path);
			DBPath = TestPa.nativePath;
			if (alert != null)
			{
				ALERT = alert;
			}

		}
		public function SearchConditionalData(table:String,col:String = null, condition:String = null,MR:Boolean = false)
		{
			var S:String;
			SQLtableName = table;
			SelectedColumn = col;
			if (condition != null && col == null)
			{
				S = "SELECT * FROM " + table + " WHERE (" + condition + " )";
			}
			else if (condition == null && col == null)
			{
				S = "SELECT * FROM " + table;
			}
			else if (condition == null && col != null)
			{
				S = "SELECT " + col + " FROM " + table;
			}
			else if (condition != null && col != null)
			{
				S = "SELECT " + col + " FROM " + table + " WHERE (" + condition + " )";
			}
			ExecuteStatement(S,dbScheme,true);
		}
		public function UPdateTable(table:String,col:String = null, condition:String = '',NextFunc:Function = null)
		{
			var S:String = "UPDATE " + table + " SET  " + col + "  WHERE " + condition;

			ExecuteStatement(S,NextFunc);
		}
		private function AfterUpdate()
		{
		}

		public function JoinCondition(Condition:Array,JoiningString:String):String
		{
			var S:String;
			var D:Array = new Array();
			for (var i:int = 0; i < Condition.length; i++)
			{
				if (Condition[i] != '' && Condition[i] != null)
				{
					D.push(Condition[i]);
				}
			}
			S = D.join(' '+JoiningString+' ');
			D = null;
			return S;
		}
		public function MakeCondition(str:String,col:String,middle:String = null,end:String = null,makeReg:Boolean = true ):String
		{

			var string:String = str;
			if (string == null || string == '' || string.toLocaleLowerCase() == 'all')
			{
				return '';
			}
			var strSS:String = '';
			if (string.indexOf(',') != (-1))
			{
				var ib:Array = string.split(',');
				for (var p1:int = 0; p1 < ib.length; p1++)
				{
					if (makeReg)
					{
						strSS +=  col + " " + middle + " '%" + ib[p1] + "%' " + end + " ";
					}
					else
					{
						strSS +=  col + " " + middle + " '" + ib[p1] + "' " + end + " ";
					}
				}
				strSS = strSS.substring(0,strSS.lastIndexOf(end));

			}
			else
			{
				if (makeReg)
				{
					strSS +=  col + " " + middle + " '%" + string + "%'  ";
				}
				else
				{
					strSS +=  col + " " + middle + " '" + string + "'  ";
				}
			}
			return strSS;
		}
		public function SelectMax(table:String,col:String,condition:String = null)
		{
			var C:String = '';
			var S:String;
			SelectedColumn = col;
			if (condition != null)
			{
				C = ' WHERE ' + condition;
			}
			S = 'SELECT ' + col + ' FROM  ' + table + ' WHERE ' + col + ' = (SELECT MAX(' + col + ') FROM ' + table + ')';
			ExecuteStatement(S,dbScheme,true);
		}
		public function SearchDistinctData(table:String,col:String,condition:String = null)
		{
			var S:String;
			SQLtableName = table;
			SelectedColumn = col;
			if (condition != null)
			{
				S = "SELECT DISTINCT " + col + " FROM " + table + " WHERE (" + condition + " )";
			}
			else
			{
				S = "SELECT DISTINCT " + col + " FROM " + table;
			}

			ExecuteStatement(S,dbScheme,true);
		}
		public function ExecuteStatement(stateMent:String,NextFuntion:Function = null,ResultR:Boolean = false):void
		{
			ERRORMASSAGE = null;
			ERRORID = -1;
			AfterCommitFunction = NextFuntion;
			stateMent = stateMent.split("'BLANK'").join(' NULL ');
			stateMent = stateMent.split('&amp;').join('&');
			stateMent = stateMent.split('&nbsp;').join(' ');
			if (! sqlConnection.connected)
			{
				try
				{
					sqlConnection.open(dbFile,SQLMode.CREATE );
				}
				catch (e:Error)
				{
					ERRORMASSAGE = e.message;
					ERRORID = e.errorID;
					ERRORNAME = e.name;
					trace(ERRORMASSAGE);
				}
			}
			sqlConnection.begin();
			SqlString = new SQLStatement();
			SqlString.sqlConnection = sqlConnection;
			SqlString.text = stateMent;
			SqlString.execute();
			if (ResultR)
			{
				sqlConnection.loadSchema(null, null);
				SQLSCHEMA = sqlConnection.getSchemaResult();
				SQLRESULT = SqlString.getResult();
			}
			sqlConnection.close();
			if (AfterCommitFunction != null)
			{
				AfterCommitFunction();
			}

		}
		public function reopenconnection()
		{
			sqlConnection.close();
			sqlConnection.open(dbFile,SQLMode.CREATE );

		}
		public function WriteStatement(stateMent:String = null,NextFuntion:Function = null,commits:Boolean = false,errors:Function = null,checkNull:Boolean = true):void
		{
			ERRORMASSAGE = null;
			ERRORID = -1;
			AFTERCOMMITFUNCTION = NextFuntion;
			if (stateMent == null)
			{
				onCommitComplete();
				return;
			}
			stateMent = stateMent.split("'BLANK'").join(' NULL ');
			if (checkNull)
			{
				stateMent = stateMent.split("''").join(' NULL ');
			}
			stateMent = stateMent.split('&amp;').join('&');
			stateMent = stateMent.split('&nbsp;').join(' ')
			;
			sqlConnection.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			if (! sqlConnection.connected)
			{
				try
				{
					sqlConnection.open(dbFile,SQLMode.CREATE );
					sqlConnection.begin();
				}
				catch (e:Error)
				{
					ERRORMASSAGE = e.message;
					ERRORID = e.errorID;
					ERRORNAME = e.name;
					trace('ERRORMASSAGE  = '+ERRORMASSAGE);
					if (errors != null)
					{
						errors(e);
					}
				}

			}
			else
			{
				sqlConnection.begin();
			}

			try
			{
				SQLWriteStatement = new SQLStatement();
				SQLWriteStatement.sqlConnection = sqlConnection;
				SQLWriteStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler);
				SQLWriteStatement.text = stateMent;
				SQLWriteStatement.execute();
				SQLRESULT = SQLWriteStatement.getResult();
				sqlConnection.commit(new Responder(onCommitComplete ,onError));

			}
			catch (error:SQLError)
			{
				ERRORMASSAGE = error.details;
				ERRORID = error.errorID;
				errors(error);
				sqlConnection.rollback();
				onCommitComplete();
			}

		}
		public function getTableSchema(n:int = -1,Name:String=''):SQLTableSchema
		{
			var table:SQLTableSchema;
			if (SQLSCHEMA == null)
			{
				DatabaseSchemaChecker();
			}
			if (n != -1)
			{
				table = SQLSCHEMA.tables[n];
			}
			if (n == -1 && Name !='')
			{
				for (var j:int = 0; j < SQLSCHEMA.tables.length; j++)
				{
					if (SQLSCHEMA.tables[j].name == Name)
					{
						table = SQLSCHEMA.tables[j];
						break;
					}
				}
			}
			return table;
		}
		private function onError(error:SQLError):void
		{
			if (ALERT != null)
			{
				ALERT('Error',error.message);
			}
		}



		private function onCommitComplete(e:SQLEvent = null):void
		{
			sqlConnection.close();
			if (errorHandler != null)
			{
				SQLWriteStatement.removeEventListener(SQLErrorEvent.ERROR, errorHandler);
				sqlConnection.removeEventListener(SQLErrorEvent.ERROR, errorHandler);
			}
			if (AFTERCOMMITFUNCTION != null)
			{
				AFTERCOMMITFUNCTION();
			}
		}
		private function errorHandler(event:SQLErrorEvent):void
		{
			if (ALERT != null)
			{
				ALERT('Error',String(event.errorID));
			}
		}
		public function DatabaseSchemaChecker(error:Function = null)
		{

			if (! sqlConnection.connected)
			{
				sqlConnection.open(dbFile,SQLMode.CREATE );
			}
			try
			{
				sqlConnection.loadSchema(null, null);
				SQLSCHEMA = sqlConnection.getSchemaResult();
				dbScheme(true);
			}
			catch (e:SQLError)
			{
				if (error != null)
				{
					error('Database Error','Error in Database Structure');
				}
				TableColumnArray = null;
			}

		}

		private function dbScheme(ColnameOnly:Boolean = false)
		{
			TableColumnArray = new Array();
			var table:SQLTableSchema;

			for (var s:int = 0; s < SQLSCHEMA.tables.length; s++)
			{
				table = SQLSCHEMA.tables[s];
				if (table.name == SQLtableName)
				{

					break;
				}
			}

			for (var i=0; i<table.columns.length; i++)
			{
				if (table.columns[i].name == SelectedColumn)
				{
					SelectedColumnNumber = i;
				}
				TableColumnArray.push(table.columns[i].name);
			}
			if (! ColnameOnly)
			{
				dtataToArray();
			}
		}
		public function getColumnName():Array
		{
			return TableColumnArray;
		}
		public function dtataToArray()
		{
			SQLResultArray = new Array();
			var FetchedString:String;
			if (SQLRESULT && SQLRESULT.data)
			{
				for (var i:int = 0; i < SQLRESULT.data.length; i++)
				{
					SQLResultArray[i] = new Array();
					for (var j:int = 0; j < TableColumnArray.length; j++)
					{
						FetchedString = SQLRESULT.data[i][TableColumnArray[j]];
						SQLResultArray[i].push(FetchedString);
					}
				}
			}

			if (SelectedColumn != null)
			{
				ColumnResult = new Array();
				for (var s:int =0; s < SQLResultArray.length; s++)
				{
					var AD:String = SQLResultArray[s][SelectedColumnNumber];
					ColumnResult.push(AD);
				}
			}
		}

		public function getAllTableName():Array
		{
			DatabaseSchemaChecker();
			var Ar:Array = new Array();
			for (var n:int = 0; n < SQLSCHEMA.tables.length; n++)
			{
				Ar.push(SQLSCHEMA.tables[n].name);
			}
			return Ar;
		}
		public function getResultObject():SQLResult
		{
			return SQLRESULT;
		}
		public function getResult():Array
		{
			var Ret:Array;
			if (SelectedColumn != null)
			{
				Ret = ColumnResult;
			}
			else
			{
				Ret = SQLResultArray;
			}
			return Ret;
		}

	}

}