/**
* File Name   :    FieldSetUtil.cls
* Description :    Moved FieldSet helper methods to this class
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 09/05/2014 Klea Kolaric	Intial
*
*/
public with sharing class FieldSetUtil {
	
    /**/
    
    // replace charaters that can't appear in the Developer Name of the fieldset
    public static String formFieldSetBaseName(String assetTypeName)
    {
    	String fieldSetName = assetTypeName;
    	fieldSetName = fieldSetName.replace('(','');
    	fieldSetName = fieldSetName.replace(')','');
    	fieldSetName = fieldSetName.replace('"','');
    	fieldSetName = fieldSetName.replace('\'','');
    	fieldSetName = fieldSetName.replace('&',' ');
    	fieldSetName = fieldSetName.replace(' / ',' ');
    	fieldSetName = fieldSetName.replace(' \\ ',' ');
    	fieldSetName = fieldSetName.replace(' ','_');
    	return fieldSetName;
    }
    
    /**/
    
    // query database based on passed in fieldset
    public static List<Sobject> queryViaFieldSet(List<Schema.FieldSetMember> fieldSet, String queryObject, String whereClause)
    {
    	String q = 'SELECT ';
    	for(Schema.FieldSetMember fld : fieldSet)
    	{
    		q += fld.getFieldPath() + ', ';
    	}
    	q = q.removeEnd(', ');
    	q += ' FROM ' + queryObject;
    	q += String.isBlank(whereClause) ? '' : (' WHERE ' + whereClause);
    	
    	return Database.query(q);
    }
    
    /**/
    
    // pass in Schema.sObjectType.Object__c.fields.getMap().values() for flds
    public static List<sObject> queryAllFields(List<Schema.SObjectField> flds, String queryObject, String whereClause)
    {
    	String queryString = 'SELECT ';
        for (Schema.SObjectField f : flds)
        {
            queryString += f.getDescribe().getName() + ', ';
        }
        queryString = queryString.removeEnd(', ');
        queryString += ' FROM ' + queryObject;
        queryString += String.isBlank(whereClause) ? '' : (' WHERE ' + whereClause);
        
        return Database.query(queryString);
    }
    
    /**/
    
    // check if object has populated fields which have been marked as requiered in either fild set or definition
    public static String checkRequiredFieldsFS(sObject obj, List<Schema.FieldSetMember> fieldSet)
    {
    	final String sep = ', ';
    	
    	String retStr = '';
    	for(Schema.FieldSetMember fsm : fieldSet)
    	{
    		if(fsm.getRequired() || fsm.getDBRequired())	// if field is required in field set or definition
    		{
    			Object ob = obj.get(fsm.getFieldPath());
    			if(ob == null || (ob instanceof String && String.isBlank((String)ob)))
    			{
    				retStr +=  fsm.getFieldPath() + sep;
    			}
    		}
    	}
    	return String.isBlank(retStr) ? retStr : ('Required fields missing: ' + retStr.removeEnd(sep) + '<br/>');
    }
    
    /**/
    
    // find field set based on a label/api name, return empty list if none found
    public static List<Schema.FieldSetMember> getFieldSet(Map<String,Schema.FieldSet> fieldSetMap, String fieldSetLabel)
    {
    	String fieldSetName = formFieldSetBaseName(fieldSetLabel);
    	Schema.FieldSet fs = fieldSetMap.get(fieldSetName);
    	return fs != null ? fs.getFields() : new List<Schema.FieldSetMember>();
    }
    
    //get fieldset type for textArea fields
    public String getTextAreaType()
	{
		return Schema.displayType.TEXTAREA.name().toLowerCase();
	}
	
	//get fieldset type for text fields
	public String getTextType()
	{
		return Schema.displayType.String.name().toLowerCase();
	}

}