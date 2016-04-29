/**
* File Name   :    WrapperUtil.cls
* Description :    Class to hold wrapper objects and associated methods
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 20/03/2014 Klea Kolaric	Initial version
* 0.1 08/05/2014 Klea Kolaric	fieldSetMemberWrapper
*
*
*/
public with sharing class WrapperUtil {
	
	public static Set<Id> createdSelectedObjectSet(List<SelectWrapper> selWrps)
	{
		Set<Id> retSet = new Set<Id>();
		for(SelectWrapper sw : selWrps)
		{
			if(sw.selected)
			{
				retSet.add((Id) sw.optionValue);
			}
		}
		
		return retSet;
	}
	
	/**/
	
	public static Map<Id,Set<Id>> createdSelectedParentSubObjectMappedSet(List<SelectListWrapper> labelWs)
	{
		Map<Id,Set<Id>> retMap = new Map<Id,Set<Id>>();
		
		for(SelectListWrapper lw : labelWs)
		{
			Id parentId = (id) lw.superObject.get('id');
			retMap.put(parentId,new Set<Id>());
			for(SelectWrapper sw : lw.subObjects)
			{
				if(sw.selected)
				{
					retMap.get(parentId).add((Id) sw.optionValue);
				}
			}
		}
		
		return retMap;
	}
	
	/**/
	
	// generic method to create a list of options from List<sObject>, will avoid duplicates
	public static List<SelectWrapper> createWrapperList(List<sObject> objectList, String relation, 
		String nameField, String valueField, String idField)
	{
		List<SelectWrapper> wrapperList = new List<SelectWrapper>();
		Set<Id> ids = new Set<Id>();	// a set for removing duplicates
		
		for(sObject so : objectList)
		{
			sObject soTemp = relation == null ? so : so.getSObject(relation);
			
			Id objectId = (Id) soTemp.get(idField);
			if(objectId != null && !ids.contains(objectId))
			{
				wrapperList.add(new SelectWrapper((String) soTemp.get(nameField), (String) soTemp.get(valueField)));
				ids.add(objectId);
			}
		}
		wrapperList.sort();
		
		return wrapperList;
	}
	
	/**/
	// create a list of sobjects and select option - super and sub objects need to be relate to each other or by junction object
	public static List<WrapperUtil.SelectListWrapper> createObjectWrapperList(List<sObject> sobjs, List<WrapperUtil.SelectWrapper> columnList, 
																				String superRelation, String subRelation,
																				String nameField, String valueField, String idField)
	{
		Map<Id,WrapperUtil.SelectListWrapper> lws = new Map<Id,WrapperUtil.SelectListWrapper>();
		List<Id> sortByIds = new List<Id>(); // preserve sort order
		List<WrapperUtil.SelectListWrapper> retList = new List<WrapperUtil.SelectListWrapper>();
		
		if(sobjs.isEmpty())
		{
			return lws.values();
		}
		
		// create mappig of subObjects to "columns"
		Map<Id,Integer> positions = new Map<Id,Integer>();
		Integer columnSize = 0;	// will correspond to list size in the end
		for(WrapperUtil.SelectWrapper prod : columnList)
		{
			positions.put((Id) prod.optionValue, columnSize);
			columnSize++;
		}
		
		// create matrix
		for(sObject sobj : sobjs)
		{
			sObject soTempSuper = superRelation == null ? (Sobject) sobj : sobj.getSObject(superRelation);
			Id superObjectId = (Id) soTempSuper.get('id');
			
			if(!lws.containsKey(superObjectId))
			{
				lws.put(superObjectId,new WrapperUtil.SelectListWrapper(soTempSuper,columnSize));
				// if new value add to sort list - this works if site catalogues are sorted by label
				if(sortByIds.isEmpty() || sortByIds.get(sortByIds.size()-1) != superObjectId)
				{
					sortByIds.add(superObjectId);
				}
			}
			
			sObject soTempSub = subRelation == null ? (Sobject) sobj : sobj.getSObject(subRelation);
			
			// add product/site in correct column
			lws.get(superObjectId).subObjects.set(positions.get((Id) soTempSub.get(idField)), 
				new WrapperUtil.SelectWrapper((String) soTempSub.get(nameField), (String) soTempSub.get(valueField)));
		}
		
		// do sorted adding to list
		if(sortByIds.size() == lws.size())
		{
			for(Id labelId : sortByIds)
			{
				retList.add(lws.get(labelId));
			}
		}
		
		return retList;
	}
	
	
	/*** wrapper classes ***/
	
	public class SelectListWrapper
	{
		public SObject superObject {get; set;}
		public List<SelectWrapper> subObjects {get; set;}
		public Boolean selected {get; set;}
		public Boolean showRow {get; set;}
		
		// this specific object makes it easer to reach the superobject from VF pages etc
		// the references point to the same place in the memory so changes on one reflect to the other
		public CW_Label__c label {get; set;}
		public CW_Site_Catalogue__c siteCat {get; set;}
		public CW_Campaign_Asset_Type__c campAssetType {get; set;}
		
		public SelectListWrapper(SObject superObject, Integer listSize)
		{
			this.superObject = superObject;
			showRow = true;
			selected = false;
			subObjects = new List<SelectWrapper>();
			
			if(listSize != null && listSize > 0)
			{
				for(Integer i=0; i<listSize; i++)
				{
					subObjects.add(new SelectWrapper(null, null));
				}
			}
			
			assignObjectByType();
		}
		
		private void assignObjectByType()
		{
			label = superObject instanceof CW_Label__c ? (CW_Label__c) superObject : null;
			siteCat = superObject instanceof CW_Site_Catalogue__c ? (CW_Site_Catalogue__c) superObject : null;
			campAssetType = superObject instanceof CW_Campaign_Asset_Type__c ? (CW_Campaign_Asset_Type__c) superObject : null;
		}
		
		public Integer getNotNullSubObjectSize()
		{
			Integer i = 0;
			for(SelectWrapper so : subObjects)
			{
				if(so.optionValue != null)
				{
					i++;
				}
			}
			return i;
		}
		
		public void selectAll()
		{
			for(SelectWrapper so : subObjects)
			{
				if(so.optionValue != null)
				{
					so.selected = true;
				}
			}
		}
		
		public void deselectAll()
		{
			for(SelectWrapper so : subObjects)
			{
				if(so.optionValue != null)
				{
					so.selected = false;
				}
			}
		}
		
	}
	
	/**/

	public class SelectWrapper implements Comparable
	{
		public Boolean selected {get; set;}
		public String optionName {get; set;}
		public String optionValue {get; set;}
		
		public SelectWrapper(String optionName, String optionValue)
		{
			this.basicConstructor(optionName,optionValue);
		}
		
		/*public SelectWrapper(Boolean selected, String optionName, String optionValue)
		{
			this.basicConstructor(optionName,optionValue);
			this.selected = selected;
		}*/
		
		private void basicConstructor(String optionName, String optionValue)
		{
			this.optionName = optionName;
			this.optionValue = optionValue;
			this.selected = false;
		}
		
		public Integer compareTo(Object compareTo)
		{
			Integer returnVal = 0;
			
			if(this.optionName > ((SelectWrapper) compareTo).optionName)
			{
				returnVal = 1;
			}
			else
			{
				if(this.optionName < ((SelectWrapper) compareTo).optionName)
				{
					returnVal = -1;
				}
			}
			
			return returnVal;
		}
	}
	
	/**/
	
	public class fieldSetMemberWrapper
    {
    	public Schema.FieldSetMember fsm {get; set;}
    	public Boolean editable {get; set;}
    	
    	public fieldSetMemberWrapper(Schema.FieldSetMember fsm,Boolean editable)
    	{
    		this.fsm = fsm;
    		this.editable = editable;
    	}
    }

}