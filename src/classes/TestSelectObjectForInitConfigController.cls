/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : APEX Test Class for SelectObjectForInitConfigController.
 *  Author  : Lakshmi Rajendram
 *  Date    : 25-11-2014
 *  Version : 0.1 Unit Test
 *
 *               
 *  Modification History
 *  Date            Who         Description 
 *  dd-mm-yyyy      ??          ????                           
*******************************************************************************************/
@isTest
                    
public class TestSelectObjectForInitConfigController {



 public  testMethod static void TestInitConfigController() {
        ConfigText__c  ct=new ConfigText__c();
        insert ct;
         ApexPages.Standardcontroller con = new ApexPages.StandardController(ct);
         SelectObjectForInitConfigController conCls= new SelectObjectForInitConfigController(new ApexPages.StandardController(ct));
         List<SelectOption> availObject = conCls.getObjectNameOptions(); 
        
         conCls.getIsSysAdmin(); 
         String selectedlisObject='Services__c';
         conCls.doAction();
                }
        
        
        }