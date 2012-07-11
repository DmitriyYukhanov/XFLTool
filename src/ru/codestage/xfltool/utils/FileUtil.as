package ru.codestage.xfltool.utils 
{
	import flash.filesystem.File;
	
	/**
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class FileUtil 
	{
		
		public function FileUtil() 
		{
			
		}
		
		/**
		 * Searchs given directory for the files with specific extension (no masks!)
		 * @param	ext extension of files to llok for
		 * @param	currentPath path to start search from
		 * @param	recursive set to true to search in all nested folders
		 * @return	returns Vector of found files paths
		 */
		public static function searchForFilesByExt(ext:String, currentPath:File, recursive:Boolean = true):Vector.<File>
		{
			var foundFiles:Vector.<File> = new Vector.<File>();
			if (currentPath.isDirectory)
			{
				var dirElements:Array = currentPath.getDirectoryListing();
				
				var len:uint = dirElements.length;
				var i:uint = 0;
				
				for (i; i < len; i++ )
				{
					var foundElement:File = (dirElements[i] as File);
					if (foundElement.isDirectory)
					{
						if (recursive) foundFiles = foundFiles.concat(searchForFilesByExt(ext, foundElement, true));
					}
					else if (foundElement.extension == ext)
					{
						foundFiles.push(foundElement);
					}
				}
			}
			else if (currentPath.extension == ext)
			{
				foundFiles.push(currentPath);
			}
			
			return foundFiles;
		}
	}

}