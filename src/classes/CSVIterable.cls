/**
* File Name :   CSVIterable.cls
* Description : Class defining a new type of Iterable, similar to list but destructive after read
*			   Modified version of http://developer.financialforce.com/customizations/importing-large-csv-files-via-batch-apex/
*
* Modification Log
* ============================================================================
* Ver Date	   Author		 Modification
* --- ---------- -------------- --------------------------
* 0.1 02/04/2014 Klea Kolaric   Initial version
*
*
*/
public with sharing class CSVIterable implements Iterator<string>, Iterable<string>
{
	private String strCSVData;
	private String rowTerminator;
	
	public CSVIterable(String fileData)
	{
		this.strCSVData = fileData;
		fileData = null;
		
		// determine line terminator - though avoid single line CSV with no line terminator
		this.rowTerminator = this.strCSVData.contains(ConstantUtil.CRLF) ? ConstantUtil.CRLF :
								(this.strCSVData.contains(ConstantUtil.LF) ? ConstantUtil.LF :
									(this.strCSVData.contains(ConstantUtil.CR) ? ConstantUtil.CR :
										ConstantUtil.CRLF));
	}
	
	public String getRowTerminator()
	{
		return rowTerminator;
	}
	
	public Boolean hasNext()
	{
		return strCSVData.length() > 1 ? true : false;
	}
	
	public String next()
	{
		String row;
		if(strCSVData.contains(rowTerminator))
		{
			row = strCSVData.subString(0,strCSVData.indexOf(rowTerminator));
			// destroy read data
			strCSVData = strCSVData.subString(strCSVData.indexOf(rowTerminator) + rowTerminator.length(),strCSVData.length());
		}
		else	// last line - may not contain line terminator
		{
			row = strCSVData;
			strCSVData = '';
		}
		return row;
	}
	
	public Iterator<string> Iterator()
	{
		return this;  
	}
}