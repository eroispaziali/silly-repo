public without sharing class BdrServiceAddUpdateExtension extends BaseControllerExtension
{

/************************************************************************************************************ 
 @author           gary.grant@conseq.co.uk
 @date             July 2014 

 @description     
                           The process saves a new Dementia Connect - Service record and creates
                           a BDR_Service_Link__c junction object that links the new service to the parent Business Development Record
 
 
                            Caution : This class is set to WITHOUT SHARING
                           If the users is able to use this class, they should be able to edit any records related to the service
                           The application interface controls edit to specific data 
        
                        
                           One parameter is passed in - the id of the parent BDR
**************************************************************************************************************/      

    public String bdrid {get;set;}
    
    public String selectedLocality { get; set; }
    
    // There is one Evidence For Need object per Service
    public Evidence_For_Need__c evidence {get;set;}
    
    // The 'Funding Requirement' is the Service cost. There is one per Financial Year
    public List<Funding_Requirement__c> fundingData {get;set;}

    public string bdrName {get;set;}
    public string bdrReference  {get;set;}
    public boolean isNew {get;set;}
    
    private List<String> lisFiscalYears;
    private BDR_Service_Link__c jnc;


    /** @description       The selection of Internal Evaluation Methods  */
     public String[] Internal_Evaluation_Methods_selection {get;set;} 
      
    /**  @description    Get the pick list value for Internal Evaluation Methods for use in checkbox selection */    
     public List<SelectOption> Internal_Evaluation_Methods_options {    
        get {           
              List<SelectOption> options = new List<SelectOption>();                
              Schema.DescribeFieldResult describeResult = Services__c.Internal_Evaluation_Methods__c.getDescribe();
              
              // Get the picklist values
              List<schema.picklistentry> values = describeResult.getPickListValues();
              for (Schema.PicklistEntry entry : values) {
                   options.add(new SelectOption(entry.getLabel(), entry.getValue()));
              }
              return options;                       
        }        
     }  
        
    /*
     *  The Service can only be edited when the Service status is 'Draft' or 'Accepted'
     */
    public boolean allowServiceEdit {
           get {
            
                Services__c svc=(Services__c)ctl.getRecord();
                
                return (svc.Service_Status__c=='Draft' || svc.Service_Status__c=='Accepted');
                
               }
           set;
    }      
    
    private List<Enhanced_Lookup__c> lstServicesFramework{get;set;}  

    public List<Enhanced_Lookup__c> ServicesFrameworkList {
     get { return lstServicesFramework;}
     set;
    }

     //Constructor
    public BdrServiceAddUpdateExtension(ApexPages.StandardController controller) {

        // Call the constructor of BaseControllerExtension
        super(controller);

        
        // Get the bdrid from the url
        bdrid=ApexPages.currentPage().getParameters().get('bdrid');
        if (bdrid==null) {
           ctl.getRecord().addError('This form is for use with a BDR. No BDR id specified');
           return;
        }
        
        BDR__c bdr = (BDR__c)[select id, Name, BDR_Name__c, Fiscal_Years__c from BDR__c where id = :bdrid];
        
        if (bdr.Fiscal_Years__c==null || bdr.Fiscal_Years__c=='') {
           ctl.getRecord().addError('Please specify the start date and term on the BDR before adding services');
           return;         
        }

        bdrName = bdr.BDR_Name__c;
        bdrReference = bdr.Name;
                
        lisFiscalYears=bdr.Fiscal_Years__c.split(';');
        
        // Help text
        fetchServicesFramework();

        isNew=false;

        if (ctl.getRecord().id==null) {

            System.debug('Service Id is Null');

            ctl.getRecord().put('Service_Status__c','Draft');            
            isNew=true; // initNewRecord will be called from the VF page

            Internal_Evaluation_Methods_selection = new List<String>();
            selectedLocality = '';
            
            evidence=new Evidence_For_Need__c();
            evidence.isCurrent__c=true;
            evidence.Release_Date__c=Date.today();
            evidence.Version__c=1;            

            // Initialise the Funding Requirement (Service Cost) object array.  One Funding Requirement per Financial Year
            fundingData = new List<Funding_Requirement__c>();        
            
            for (String sFiscal : lisFiscalYears) {                
                Funding_Requirement__c freq=new Funding_Requirement__c();
                freq.Fiscal_year__c=sFiscal;        
                fundingData.add(freq);            
            }                                  

            RecordType rType = 
            [Select Id from RecordType where sObjectType = 'Services__c' and DeveloperName = 'Internal' limit 1];            
            ctl.getRecord().put('RecordTypeId',rType.id);            
  
       } else {
       
          isNew = false;
          System.debug('Service id is Not NULL : ' + ctl.getRecord().id);
         
          Services__c svc = (Services__c)ctl.getRecord();
          Internal_Evaluation_Methods_selection = svc.Internal_Evaluation_Methods__c==null ? new List<String>() : svc.Internal_Evaluation_Methods__c.split(';');
          selectedLocality = svc.Locality__c==null ? '' : svc.Locality__c; 
           
          fundingData = 
          [select Fiscal_Year__c, Service__c, Total_Amount__c, Actual_fcr__c, Funding_In_Budget__c, Comments__c 
           from Funding_Requirement__c
           where Service__c=:ctl.getRecord().id and Fiscal_Year__c in :lisFiscalYears 
           order by Fiscal_Year__c asc];

          //Check there is a funding requirement for all relevant fiscal years  
          //TODO.. how to sort these funding requirements
          Map<String, Funding_Requirement__c> mapFr = new Map<String, Funding_Requirement__c>();
          
          for (Funding_Requirement__c fr : fundingData) {
             mapFr.put(fr.Fiscal_Year__c, fr);           
          }           

          for (String fy : lisFiscalYears) {
             if (mapFr.get(fy)==null) {             
               Funding_Requirement__c fr= new Funding_Requirement__c();
               fr.Fiscal_Year__c = fy;
               fundingData.add(fr);
             }
              
          }  
          
          // 
          List<Evidence_For_Need__c> lisEfn =
           [select name, Service__c, Evidence_Overview__c, Consequences_of_Closure__c, Demography_Comments__c, Usage_Profile__c 
            from Evidence_for_Need__c 
            where isCurrent__c = true and Service__c = :ctl.getRecord().id];
          
          if (lisEfn.isEmpty() && evidence==null) {
              evidence = new Evidence_For_Need__c();
              //evidence.service__c=svc.id;
              evidence.isCurrent__c=true;
              evidence.Release_Date__c = Date.Today();
              evidence.version__c=1;
          } else {                    
              evidence = lisEfn[0];                      
          }
       }
               
    }

    public pagereference cancel() {
        return new PageReference('/apex/BDR_Edit_Tabbed?id='+ bdrid + '&tab=tabServices');
    }    
    
    
    // Get the list of Internal Organisations to populate select
      public List<SelectOption>  getServiceLocalities() { 
      
          List<SelectOption> optionList = new List<SelectOption>();             
          String word = 'Locality';
    
          optionList.add(new SelectOption('', '--None--')); 
        
          for (Account Acct : [Select Id, Name From Account where RecordType.DeveloperName = 'InternalOrganisation' And Name like :'%'+word order by Name asc limit 200]) {
               String showName = Acct.Name.replaceAll(word,'');
               optionList.add(new SelectOption(Acct.Id, showName));  
          }
          return optionList;  
      }
      
      
      /*
       *  This should return the locality itself and it's child accounts that are Internal Organisations
       *  
       *  This method mimics the filters for the 'OperatedBy' field on the Dementia Connect Service Record
       *          
       *  Internal Services can only be operated by a Locality or a Local Service Office 
       *    (this lookup is filtered based on the Locality you selected in the previous field).
       *  
       */
     
      public List<SelectOption>  getOperatedByOptions() {
        
          List<SelectOption> optionList = new List<SelectOption>();   

          if (selectedLocality==null || selectedLocality=='') return optionList;
          List <Account> lisAccts =     [Select Id, Name From Account where RecordType.DeveloperName = 'InternalOrganisation' AND (id =:selectedLocality or Parent.Id =:selectedLocality)];                   
          for (Account Acct : lisAccts) {
     
               optionList.add(new SelectOption(Acct.Id, acct.Name));  
          }       
          return optionList;  
        
      }
      
     public List<SelectOption>  getRegulatoryBodyOptions() {
        
          List<SelectOption> optionList = new List<SelectOption>();   

          if (selectedLocality==null || selectedLocality=='') return optionList;
          List <Account> lisAccts =     [Select Id, Name From Account where RecordType.DeveloperName = 'InternalOrganisation' AND (id =:selectedLocality or Parent.Id =:selectedLocality)];                   
          for (Account Acct : lisAccts) {
     
               optionList.add(new SelectOption(Acct.Id, acct.Name));  
          }       
          return optionList;  
            }
    
      public pagereference saveAndClose() {

          //Set a database save point so everything can be rolled back if an error is thrown
          SavePoint sp=Database.setSavePoint();  

          if  ( contentionCheck() ) { 
             system.debug('***** CONTENTION');
             return null; 
          }

          ctl.getRecord().put('Internal_Evaluation_Methods__c',String.join(Internal_Evaluation_Methods_selection,';'));
              ctl.getRecord().put('Locality__c',selectedLocality);

          if (isNew) {        
              
              ctl.getRecord().put('Service_Status__c', 'Draft');    
              if (ctl.save()==null) { return null;}               

             /* Do this Without Sharing because the current user
                may not be the owner of the service, in which case they would not have edit access
             */         
              if (!BdrWrapper.addService(bdrid, ctl.getRecord().id)) {
                  Database.rollback(sp);
                  ctl.getRecord().addError('Save Failure on adding service');               
                  return null;
              }

                        
          } else {      
             
              try {
                  
                  //Without Sharing does not work on Controller.save();
                  Services__c svc = (Services__c)ctl.getRecord();  
                  update svc;     

              }
              catch (DmlException e) {
        
                  Database.rollback(sp);
                  String msg=e.getMessage();
                  System.debug('Service save Failure:' + ctl.getRecord().id); 
                  ctl.getRecord().addError(e.getDmlMessage(0));               
                  return null;
              }          
           }
               
         //save the evidence record
         if (saveEvidence()==false) {
           Database.rollback(sp);
           return null;     
         }  
          
         //Create Funding Requirements
         if (saveFundingRequirements()==false) {
           Database.rollback(sp);
           return null;
         }
    
        return new PageReference('/apex/BDR_Edit_Tabbed?id='+ bdrid + '&tab=tabServices');    

    }
    
    public pageReference save() {


          system.debug('Svc Add-Update : Updating Service ');

          //Set a database save point so everything can be rolled back if an error is thrown
          SavePoint sp=Database.setSavePoint();  

          if  ( contentionCheck() ) { 
             system.debug('***** CONTENTION');
             return null; 
          }
    
          ctl.getRecord().put('Internal_Evaluation_Methods__c',String.join(Internal_Evaluation_Methods_selection,';'));
          ctl.getRecord().put('Locality__c',selectedLocality);
          
          if (isNew) {        
                    
              ctl.getRecord().put('Service_Status__c', 'Draft');
                    
              if (ctl.save()==null) { 
                    System.debug('Saving the Service Added to a BDR Failed');               
                    return null ; 
              } 
              
              System.debug('Addin Service Save Success:' + ctl.getRecord().id);
              
             /* Do this thru the Without Sharing util class because the current user
                may not be the owner of the service, in which case they would not have edit access
             */         
              if (!BdrWrapper.addService(bdrid, ctl.getRecord().id)) {
                  Database.rollback(sp);
                  ctl.getRecord().addError('Save Failure on adding service');               
                  return null;
              }

              isNew = false;           

              if ( !Test.isRunningTest()) {
                /* Update the time stamp to avoid erroneous contention errors */
                oSystemModStamp = (DateTime)ctl.getRecord().get('SystemModStamp');
              }

          
            } else {      
    
              try {  
                
                  if   (ctl.save()==null) { 
                        ctl.getRecord().addError('Save Failure on service');               
                        return null; 
                  }  

                  Services__c svc = (Services__c)ctl.getRecord();  
                
                  //Without Sharing does not work on Controller.save();  ???? why not - replaced... ??
                  // CAUTION This needs to be a call to ctl.save because update svc does not update the 
                  // SystemModStamp 

                  //update svc;

                  // SystemModStamp is not available to test classes
                  // because it's loaded using ctl.addFields  

                  if (!Test.isRunningTest()) {  
                    system.debug('Svc Add-Update - Before Time ' + oSystemModStamp);

                    /* Update the time stamp to avoid erroneous contention errors */                  
                    oSystemModStamp = (DateTime)ctl.getRecord().get('SystemModStamp');
                    system.debug('Svc Add-Update - After Time ' + oSystemModStamp);
                  }
                  
              }
              
              catch (DmlException e) {
        
                  Database.rollback(sp);
                  String msg=e.getMessage();
                  System.debug('Service save Failure:' + ctl.getRecord().id); 
                  ctl.getRecord().addError(e.getDmlMessage(0));               
                  return null;
              }          
           }
           
         // Save the evidence record
         if (saveEvidence()==false) {
           //Database.rollback(sp);
           return null;     
         }  
       
          /*
           These save methods run without sharing thru the Utils Class
           That is necessary because in the case of updating records linked to an existing 
           services record, the current user may not have sufficient edit rights to create
           a new link between the service and it's child records
          */
          
         // Create Funding Requirements
         if (saveFundingRequirements()==false) {
           //Database.rollback(sp);
           return null;
         }
       
        ApexPages.Message message = new ApexPages.message(ApexPages.severity.Info,'Record has been saved at ' + system.now().format() + ' Please remember to save changes often.');
        ApexPages.addMessage(message);
        
        return null;
    }    
 
     public void populateSVCDesc (){
     
      String svcType = (String)ctl.getRecord().get('Service_Type__c');
      String subType = (String)ctl.getRecord().get('Sub_Type_Internal__c');
      
      Sobject[] servdesc = [select Service_Description__c from Service_Types__c where Service_Type__c =:svcType and Service_sub_type__c =:subType  limit 1];
      if( servdesc.size()>0){                                                  
          ctl.getRecord().put('Service_Description__c', ((Service_Types__c)servdesc[0]).Service_Description__c);
      } else {
          ctl.getRecord().put('Service_Description__c','');
      }
   
    
    }
 
    private boolean saveEvidence()
    {
       return BdrServiceWrapperUtils.updateEvidence(evidence, (Services__c)ctl.getRecord()); 
    }

    private boolean saveFundingRequirements() 
    {
       return BdrServiceWrapperUtils.updateFundingRequirements(fundingData, (Services__c)ctl.getRecord());      
    }

    private void fetchServicesFramework()
    {
         lstServicesFramework= new List<Enhanced_Lookup__c>(); 
         lstServicesFramework= [SELECT  Name, Lookup_Description__c, Lookup_field__c, Lookup_Value__c 
                             FROM Enhanced_Lookup__c 
                             WHERE lookup_field__c = 'Services_Framework_Principle__c' 
                             AND Active__c=true order by Order__c];
    }

}