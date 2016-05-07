/**
* File Name :   CSVReaderTest.cls
* Description : Made to only test the methods in CSVReader.cls
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 07/04/2014 Klea Kolaric   Initial version
*
*
*/
@isTest
private class CSVReaderTest {

    static testMethod void parseBasicCsvString()
    {
        Blob blobCSV = Blob.valueOf(basicCsvString);
        
        Integer numberOfRows = basicCsvString.split(CSVReader.lineTerminator).size();
        Integer numberOfCols = basicCsvString.split(CSVReader.lineTerminator).get(0).split(',').size();
        
        Test.startTest();
        List<List<String>> resultMatrix = CSVReader.readCSVFile(blobCSV);
        Test.stopTest();
        
        system.assertEquals(resultMatrix.size(),numberOfRows);
        for(List<String> rowList : resultMatrix)
        {
        	 system.assertEquals(rowList.size(),numberOfCols);
        	 for(String strVal : rowList)
        	 {
        	 	system.assert(String.isNotBlank(strVal));
        	 }
        }
    }
    
    static testMethod void parseQuotedCsvString()
    {
    	//add extra fields to the file that contains "" and replace them later ''
    	String quotedString1 = '"I\'m a little teapot"';
    	String quotedString2 = '"This is my handle"';
    	String quotedString3 = 'Un! Deux! Trois! Dis: Miroir Noir!';
    	
        String quotedCsvString = basicCsvString;
        quotedCsvString += quotedString1 + ',Row52' + CSVReader.lineTerminator;
        quotedCsvString += 'Row61,' + quotedString2 + CSVReader.lineTerminator;
        quotedCsvString += 'Row71,' + quotedString3 + CSVReader.lineTerminator;
        
        Integer numberOfRows = quotedCsvString.split(CSVReader.lineTerminator).size();
        Integer numberOfCols = quotedCsvString.split(CSVReader.lineTerminator).get(0).split(',').size();
        
        Test.startTest();
        List<List<String>> resultMatrix = CSVReader.readCSVFile(quotedCsvString);
        Test.stopTest();
        
        system.assertEquals(resultMatrix.size(),numberOfRows);
        for(List<String> rowList : resultMatrix)
        {
        	 system.assertEquals(rowList.size(),numberOfCols);
        	 for(String strVal : rowList)
        	 {
        	 	system.assert(String.isNotBlank(strVal));
        	 }
        }
        system.assertEquals(quotedString1.replace('"',''),resultMatrix.get(numberOfRows-3).get(0));
        system.assertEquals(quotedString2.replace('"',''),resultMatrix.get(numberOfRows-2).get(1));
        system.assertEquals(quotedString3.replace('"',''),resultMatrix.get(numberOfRows-1).get(1));
    }
    
    static testMethod void parseCsvStringWithEmptyLines()
    {
    	Boolean exceptionHappend = false;
    	List<List<String>> resultMatrix;
    	
        Integer numberOfRows = basicCsvString.split(CSVReader.lineTerminator).size();
        Integer numberOfCols = basicCsvString.split(CSVReader.lineTerminator).get(0).split(',').size();
        
        // construct string with empty lines
        String newCsvString = '';
        String emptyLineContainer = CSVReader.lineTerminator;
        for(String row : basicCsvString.split(CSVReader.lineTerminator))
        {
        	newCsvString += row + emptyLineContainer;
        	emptyLineContainer += CSVReader.lineTerminator;
        }
        // assert new string has more rows than old one
        system.assert(newCsvString.split(CSVReader.lineTerminator).size() > numberOfRows);
		
		//trow an error message when file contains black fields       
        Test.startTest();
        try
        {
        	resultMatrix = CSVReader.readCSVFile(newCsvString);
        }
        catch(CSVReader.CSVReadException e)
        {
        	exceptionHappend = true;
        }
        Test.stopTest();
       	
        system.assert(exceptionHappend);
        
    }
    
    static testMethod void parseFaultyRowCsvString()
    {
        String newCsvString = basicCsvString;
        
        newCsvString += 'Row51,Row52' + CSVReader.lineTerminator;	
        newCsvString += 'Row61,Row62,Row63'; // faulty row
        Boolean exceptionHappend = false;
        
        Test.startTest();
        try
        {
        	List<List<String>> resultMatrix = CSVReader.readCSVFile(newCsvString);
        }
        catch(CSVReader.CSVReadException e)
        {
        	exceptionHappend = true;
        }
        Test.stopTest();
        
        system.assert(exceptionHappend);
    }
    
    static testMethod void coverOtherMethods()
    {
    	String text = 'rendom text';
    	
    	CSVReader.CSVValue val1 = new CSVReader.CSVValue();
    	val1.value = text;
    	val1.enclosed = false;
    	val1.terminator = CSVReader.lineTerminator;
    	
    	CSVReader.CSVValue val2 = new CSVReader.CSVValue(text,false,CSVReader.lineTerminator);
    	
    	 system.assert(val1.equals(val2));
    	 val2.enclosed = true;
    	 system.assert(!val1.equals(val2));
    }
    
    /*** helper variables/methods ***/
    
    static final String basicCsvString = 'Field1,Field2' + CSVReader.lineTerminator
								    	+ 'Row11,Row12' + CSVReader.lineTerminator
								    	+ 'Row21,Row22' + CSVReader.lineTerminator
								    	+ 'Row31,Row32' + CSVReader.lineTerminator
								    	+ 'Row41,Row42' + CSVReader.lineTerminator;
}