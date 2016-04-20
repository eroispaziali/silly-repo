public class serviceClone {
    // Class properties
    private Id ServiceIdOld;
    
    // Default constructor
    public serviceClone (){
        // get the passed Id parameter
        ServiceIdOld = System.currentPageReference().getParameters().get('id') ;
    }
    
    // Visualforce extension constructor
    public serviceClone(ApexPages.StandardController controller) {
        Services__c s = (Services__c)controller.getRecord();
        ServiceIdOld = s.Id;
    }
    
    public PageReference cloneService() {
        Services__c sOld = [
        select Accessibility__c,
            Activity_Code_Part_1__c,
            Activity_Code_Part_2__c,
            Contact_first_name__c,
            Contact_last_name__c,
            Contact_salutation__c,
            Core_Record_Set__c,
            Days_per_week__c,
            Default_Location__c,
            //Description__c,
            Display_on_public_website__c,
            Formal_Alzheimer_s_Caf__c,
            From_Services_db__c,
            Getting_There__c,
            Id,
            //Image_Doc_ID__c,
            Local_Authority__c,
            Locality__c,
            Map__c,
            Name,
            National_Service__c,
            //Photo__c,
            Number_of_Any_People_with_Dementia__c,
            Number_of_Older_People_with_Dementia__c,
            Number_of_Volunteers__c,
            Number_of_Younger_People_with_Dementia__c,
            Number_Posts_Staff__c,
            Opening_Times_Guidebook__c,
            Operated_By__c,
            Parking__c,
            Permission_Attached__c,
            //Photo__c,
            Photo_Caption__c,
            Postcode_Constituency__c,
            Postcode_Local_Authority__c,
            Postcode_Primary_Care_Trust__c,
            Postcode_Ward__c,
            Price__c,
            Primary_contact__c,
            Record_Type_Name__c,
            RecordTypeId,
            Refreshments__c,
            Registered_With_Regulator__c,
            Regulatory_Body__c,
            service_city__c,
            service_closedate__c,
            //service_code__c, ** Don't clone service_code__c because it's external ID field and causes errors **
            service_contact_hours__c,
            service_country__c,
            service_county__c,
            Service_Criteria__c,
            service_description__c,
            service_email__c,
            service_opendate__c,
            service_operationhours__c,
            service_operationhourscomment__c,
            service_postcode__c,
            service_status__c,
            service_street__c,
            service_targetclientgroup__c,
            service_telephone__c,
            service_type__c,
            service_website__c,
            Sub_Type__c,
            Toilet_Facilities__c 
            from Services__c
            where id = :ServiceIdOld
        ];
            
        // Deep clone old service so all fields are copied
        Services__c sNew = sOld.clone(false, true);
        
        // Change name
        // If name more than 72 chars, adding '[Clone] ' will make it over 80 chars and inserting will throw an error, so crop it.
        string newName = sOld.Name; 
        sNew.name = '[Clone] ' + (newName.length() < 72 ? newName : newName.substring(0, 69) + '...');
        
        // Change to Local service
        //sNew.RecordTypeId = [select id from recordtype where sobjecttype];
        
        // Don't want it to be 'from services db'
        sNew.From_Services_db__c = false;
        
        // Set image to placeholder if record has no image
        //if (sNew.Image_Doc_ID__c == null)
        //    sNew.Image_Doc_ID__c = '01570000000kBBT';
            
        // Set 'site' and 'DA site' to the current user's one (as long as they're not a guidebook volunteer, who has no role)
        try {
          UserRole role = [select Id, Name from UserRole where Id = :UserInfo.getUserRoleId()];
          if (role.Name <> 'Guidebook Volunteer') {
          //    sNew.Site__c = role.Name;
              //sNew.DA_Site__c = role.Name;
          }
        } catch (QueryException e) {
          // Ignore
        }
        
        insert sNew;
        
        // Redirect to new Service's detail page
        PageReference servicePage = new PageReference('/' + sNew.id);
        servicePage.setRedirect(true);
        return servicePage;
    }
    
    //
    //  TEST ServicesEXT
    //
    private static testMethod void testServicesEXT() {
    //  User u1 = [select id from User where alias='mgt'];
        
    //Run As U1
    //    System.RunAs(u1) 
        {
          Services__c service = new Services__c(Name='Test service', National_Service__c = true);
          insert service;
          
          // Create a PageReference to the VF page being tested       
          PageReference pageRef = Page.ServiceClone;
          test.setCurrentPage(pageRef);
          
          // Now create the standard controller for the service
          ApexPages.StandardController stdCon = new ApexPages.StandardController(service);
          pageRef.getParameters().put('id', service.Id);
          
          // Test constructors
          serviceClone cnt = new serviceClone();
          cnt = new serviceClone(stdCon);
          
          cnt.cloneService();
        }
    }
}