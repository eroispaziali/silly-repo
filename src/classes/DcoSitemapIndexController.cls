public with sharing class DcoSitemapIndexController 
{
   public static Integer BLOCK_SIZE = 1000;
   public static String SITEMAP_URL = 'https://dementiafriends.secure.force.com/dco/dco_sitemap_xml';
   
   public List<Integer> getBlockList()
   {
   	List<Integer> blockList = new List<Integer>(); 
   	
      Integer total = [select count() from Services__c 
                       where Display_on_public_website__c = true
                       and Record_Type_Name__c = 'Internal' 
                       and Service_Status__c = 'Open']; 
      
      for (Integer p = 0; p*BLOCK_SIZE<total; p++) {
      	blockList.add(p); 
      }
   	
   	return blockList;
   }
   
   public String getSitemapUrl()
   {
   	return SITEMAP_URL;
   }

}