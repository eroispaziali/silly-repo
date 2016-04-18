public with sharing class DcoSitemapController 
{
   //This needs to be CONFIRMED prior to use.
   public static String URL_ROOT = 'http://www.alzheimers.org.uk/local-information/dementia-connect';

   public List<Services__c> getServices()
   {
      Integer block = DcoSitemapIndexController.BLOCK_SIZE;
      Integer offset = DcoSitemapIndexController.BLOCK_SIZE * getPageNumber();
      return [select Id from Services__c 
                       where Display_on_public_website__c = true
                       and Record_Type_Name__c = 'Internal' 
                       and Service_Status__c = 'Open'
                       LIMIT :block OFFSET :offset ];
   }

   public Integer getPageNumber()
   {
      String url = ApexPages.currentPage().getParameters().get('p');
   	return url==null ? 0 : Integer.valueOf(url);  
   }

   public String getUrlRoot()
   {
   	return URL_ROOT;
   }

}