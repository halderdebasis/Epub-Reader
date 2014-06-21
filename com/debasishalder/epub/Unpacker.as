

package com.debasishalder.epub
{
	import nochump.util.zip.*;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.filesystem.*;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	import com.debasishalder.event.EpubEvent;
	public class Unpacker extends EventDispatcher
	{
		public static const UNPACK_FILE:String = "unpack";
		private var StreamStat:String = 'NONE';
		public var ZIP_Object:Object = {};
		private var _zipFile:ZipFile;
		private var zipInput:File;
		public var _directory:String;
		private var _percentage:Number;
		private var stream:FileStream = new FileStream();
		private var _currentFile:String;
		public var ActualFile_Name:String;
		private var zipFile:ZipFile;
		private var inputURL:String = '';
		private var OutPutURl:String = '';
		private var zipOutput:File;
		public function get percentage():Number
		{
			return _percentage;
		}
		public function get directory():String
		{
			return _directory;
		}
		public function get currentFile():String
		{
			return _currentFile;
		}


		public function unpack(ZipPath:String):void
		{

			System.useCodePage = true;
			inputURL = ZipPath;
			zipInput = new File(inputURL);

			stream.open(zipInput,FileMode.READ);
			extract();
		}


		public function Unpacker(ZipPath:String,OutPutPath:String):void
		{
			_directory = OutPutPath;
			inputURL = ZipPath;
			_percentage = 0;
			zipInput = new File(inputURL);
			stream.open(zipInput,FileMode.READ);
			StreamStat = 'OPEN';
			_zipFile = new ZipFile(stream);
		}


		private function showProgress(event:ProgressEvent):void
		{
			_percentage = Number(event.bytesLoaded / event.bytesTotal);
			dispatchEvent(event);
		}
		private function dispatchComplete():void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}

		private function extract():void
		{
			_zipFile = new ZipFile(stream);
			_zipFile.addEventListener(EpubEvent.ON_EPUB_ERROR,dispatchError);
			extractFile(0);
		}
		private function dispatchError(e:EpubEvent)
		{
			dispatchEvent(new EpubEvent(EpubEvent.ON_EPUB_ERROR,e.ITEM));
		}
		private function extractFile(id:int):void
		{
			var applicationDirectory:File = File.applicationDirectory;
			var filePath:String;
			var zipEntry:ZipEntry;
			zipEntry = ZipEntry(_zipFile.entries[id]);
			filePath = _directory;
			filePath += (zipEntry.name);
			var nm:String = zipEntry.name;
			var nnm:Array = nm.split('/');
			var mmn:String = nnm[nnm.length - 1];
			var objname:String = mmn.split('.').join('_');
			_currentFile = zipEntry.name;

			var FileExtention:String = _currentFile.substr(_currentFile.lastIndexOf('.'),_currentFile.length);

			if (FileExtention == '.html' || FileExtention == '.HTML' || FileExtention == '.xml' || FileExtention == '.XML' || FileExtention == '.OPF' || FileExtention == '.opf'|| FileExtention == '.htm'|| FileExtention == '.HTM'|| FileExtention == '.css'|| FileExtention == '.CSS' ||FileExtention == '.ncx' || FileExtention == 'e')
			{

				var ba:ByteArray = _zipFile.getInput(zipEntry);
				var dd:String = ba.toString();
				ba.clear();
				ZIP_Object[objname] = dd;


			}
			else
			{
				if (mmn !='')
				{
					var storage1:File = new File(_directory+mmn);
					var entry1:FileStream = new FileStream();
					entry1.open(storage1, FileMode.WRITE);
					entry1.writeBytes(_zipFile.getInput(zipEntry));
					entry1.close();
					entry1 = null;
					_zipFile.getInput(zipEntry).clear();

				}

			}
			dispatchEvent(new ProgressEvent(UNPACK_FILE));

			if (id >= _zipFile.entries.length - 1)
			{

				_zipFile.getInput(zipEntry).clear();
				dispatchComplete();
			}
			else
			{

				setTimeout(extractFile, 50, (id + 1));
			}
			applicationDirectory = null;
			filePath = null;
			zipEntry = null;
			nm = null;
			nnm = null;
			mmn = null;
			objname = null;
			FileExtention = null;
			ba = null;
			dd = null;
		}
		public function CompleteZipWork():void
		{
			if (StreamStat == 'OPEN')
			{
				stream.close();
				StreamStat = 'CLOSE';
			}
		}



		public function extractString(fileName_PAth:String):String
		{
			var filePath:String;
			var entry:ZipEntry = _zipFile.getEntry(fileName_PAth);
			var ba:ByteArray = _zipFile.getInput(entry);
			var dd:String = ba.toString();
			ba.clear();
			filePath = null;
			entry = null;
			ba = null;
			return dd;

		}
		public function extractByte(fileName_PAth:String):ByteArray
		{
			var filePath:String;
			var entry:ZipEntry = _zipFile.getEntry(fileName_PAth);
			var ba:ByteArray = _zipFile.getInput(entry);
			return ba;
			filePath = null;
			entry = null;

		}
		public function extractFiles(fileName_PAth:String):void
		{
			var nnm:Array = fileName_PAth.split('/');
			ActualFile_Name = nnm[nnm.length - 1];
			var storage1:File = new File(_directory+ActualFile_Name);
			if (storage1.exists)
			{
				dispatchComplete();
			}
			else
			{
				var entry:ZipEntry = _zipFile.getEntry(fileName_PAth);
				var entry1:FileStream = new FileStream();
				entry1.open(storage1, FileMode.WRITE);
				entry1.writeBytes(_zipFile.getInput(entry));
				entry1.close();
				entry1 = null;
				_zipFile.getInput(entry).clear();
				System.gc();
				dispatchComplete();
			}
			nnm = null;
			storage1 = null;
			entry = null;
			entry1 = null;
		}

		public function dispose()
		{
			_zipFile.removeEventListener(EpubEvent.ON_EPUB_ERROR,dispatchError);
			StreamStat = null;
			ZIP_Object = null;
			_zipFile = null;
			zipInput = null;
			_directory = null;
			stream = null;
			_currentFile = null;
			ActualFile_Name = null;
			zipFile = null;
			inputURL = null;
			OutPutURl = null;
			zipOutput = null;
		}

	}
}