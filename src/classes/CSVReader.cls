/**
* File Name :   CSVReader.cls
* Description : Class to facilitate reading the CSV, if needed in chunks
*               Modified version of 
*               https://docs.google.com/leaf?id=0B2snsA4L4ojWNWE0ZGRiMzgtNjA4ZC00OWQwLWFjM2MtMTYzZjI5NmE2YjU5&hl=en&authkey=CLG85PoD
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 01/04/2014 Klea Kolaric   Initial version
*
*
*/
public with sharing class CSVReader {
    
    public static String lineTerminator = ConstantUtil.CRLF;
    public static String valueSeparator = ConstantUtil.COMMA;
    
    public class CSVReadException extends Exception {}
    
    // return parsed file as "matrix" - rows represent complete records, and columns are fields
    
    public static List<List<String>> readCSVFile(Blob fileContent)
    {
        String fileString = fileContent.toString();
        fileContent = null;
        return readCSVFile(fileString);
    }
    
    public static List<List<String>> readCSVFile(String fileString)
    {
        //fileString = fileString.replaceAll('\\s*\\z', '');    // remove any trailing empty lines
        if (!fileString.endsWith(lineTerminator))   // parser expects all rows to have a endline as a terminator
        {
            fileString = fileString + lineTerminator;
        }
        
        List<List<String>> objectValues = new List<List<String>>();
        List<String> fieldValues = new List<String>();
        
        Boolean eod = false;  // eod = End Of Document
        while(!eod)
        {
            CSVValue csvVal = readCSVValue(fileString);
            fieldValues.add(csvVal.value);
            //check if the field value is null or blank
            if (csvVal.value=='' || csvVal.value==null)
            {
            	//trow an error if there are any groups or members left blank(groups and members are required for upload)
            	throw new CSVReadException(ConstantUtil.CSV_CONTAINS_NULL_FIELDS);
            }
            if(csvVal.terminator == lineTerminator)
            {
                // if row was not blank - contains one or more non-blank value
                if(String.isNotBlank(fieldValues.get(0)) || fieldValues.size() > 1)
                {
                    objectValues.add(fieldValues);
                
                    // check that each row has the same number of columns
                    if(objectValues.get(0).size() != fieldValues.size())
                    {
                        throw new CSVReadException(
                            'Mismatch in number of columns.\n'
                            + 'Expected: ' + objectValues.get(0).size() + '(1. row)\n'
                            + 'Actual: ' + fieldValues.size() + '(' + objectValues.size() + '. row)\n');
                    }
                }
                
                fieldValues = new List<String>();
            }
            
            if(csvVal.biteSize() == fileString.length() || fileString.length() == 0)
            {
                eod = true;
            }
            else
            {
                fileString = fileString.substring(csvVal.biteSize());
            }
        }
        
        return objectValues;
    }
    
    /**/
    
    // read single (field) value from the file
    public static CSVValue readCSVValue(String strData)
    {
        CSVValue csvVal = new CSVValue();
        
        if (strData.startsWith(ConstantUtil.DQUOTE))
        {
            csvVal.enclosed = true;
          
            Integer searchIndex = 1;    // starting index to search
            Integer dquoteIndex = -1;   // index of DQUOTE
            Integer dquotesIndex = -1;  // index of DQUOTEDQUOTE
                            
            Boolean closerFound = false;    // have you found closing DQUOTE
            
            while(!closerFound) // look for double dquotes, ignore single dquoted
            {
                dquoteIndex = strData.indexOf(ConstantUtil.DQUOTE, searchIndex);
                dquotesIndex = strData.indexOf(ConstantUtil.DQUOTEDQUOTE, searchIndex);
                
                if(dquoteIndex == dquotesIndex) // found begining of double dquote
                {
                    searchIndex = dquotesIndex + ConstantUtil.DQUOTEDQUOTE.length();
                }
                else    // found ending of double dquote
                {
                    closerFound = true;
                }
            }
            
            csvVal.value = strData.substring(ConstantUtil.DQUOTE.length(),dquoteIndex)
                                .replaceAll(ConstantUtil.DQUOTEDQUOTE, ConstantUtil.DQUOTE);
            
            Integer commaIndex = strData.indexOf(valueSeparator, dquoteIndex);
            Integer crlfIndex = strData.indexOf(lineTerminator, dquoteIndex);
            
            if(commaIndex != -1 && commaIndex < crlfIndex)
            {
                csvVal.terminator = valueSeparator;
            }
            else
            {
                csvVal.terminator = lineTerminator;
            }
        }
        else
        {
            csvVal.enclosed = false;
          
            Integer commaIndex = strData.indexOf(valueSeparator);
            Integer termIndex = strData.indexOf(lineTerminator);
         
            if(commaIndex != -1 && commaIndex < termIndex)
            {
                csvVal.value = strData.substring(0,commaIndex);
                csvVal.terminator = valueSeparator;
            }
            else
            {
                csvVal.value = strData.substring(0,termIndex);
                csvVal.terminator = lineTerminator;
            }
        }
        
        return csvVal;
    }
    
    /**/
    
    public static void setLineTerminator(String lnTerm)
    {
    	lineTerminator = lnTerm;
    }
    
    /**/
    
    public static void setValueSeparator(String valSep)
    {
    	valueSeparator = valSep;
    }
    
    /**
    * CSVValue is a class structure containing information about a CSV
    * value that was read from a CSV file, including such information as
    * whether the value was encapsulated in double-quotes.
    */
    
    public class CSVValue
    {
        public String value;        // the value contained in a row
        public Boolean enclosed;    // whether the value was surrounded by double-quotes
        public String terminator;   // the character that identified the end of the CSV value (COMMA or CRLF)
        
        public CSVValue()
        {
            this.value = null;
            this.enclosed = false;
            this.terminator = null;
        }
        
        public CSVValue(String value, Boolean enclosed, String terminator)
        {
            this.value = value;
            this.enclosed = enclosed;
            this.terminator = terminator;
        }
        
         // returns the number of characters to remove from the data String in order to reach the next value in the data String.
        public Integer biteSize()
        {
            Integer biteSize = value.replaceAll(ConstantUtil.DQUOTE, ConstantUtil.DQUOTEDQUOTE).length() + terminator.length();
            if(enclosed)
            {
                biteSize += ConstantUtil.DQUOTE.length() * 2;
            }
            return biteSize;
        }
        
        public Boolean equals(CSVValue compCSVValue)
        {
            return this.value.equals(compCSVValue.value) 
                && this.enclosed == compCSVValue.enclosed && this.terminator == compCSVValue.terminator;
        }
        
    }
    
    

}