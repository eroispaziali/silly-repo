public with sharing class servicesEXT {
    public Services__c service;
    public Document document;   // for the photo

    public boolean deletePhoto = false;
    
    private static final string IMG_PLACEHOLDER = '01570000001O9n2';
    
    // Default constructor
    public servicesEXT() {
        service = [select id, Image_Doc_ID__c, service_operationhours__c, service_operationhourscomment__c, service_street__c, service_city__c, service_postcode__c, RecordType.Name
                           from Services__c where id = :ApexPages.currentPage().getParameters().get('id')];
                           
        //service.RecordTypeId = [select Id from RecordType
        //                      where Id = :ApexPages.currentPage().getParameters().get('RecordType')].Id;
        
        commonConstructor();
    }
    
    // Visualforce extension constructor
    public servicesEXT(ApexPages.StandardController controller) {
        service = (Services__c)controller.getRecord();
        
        string RecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
        if (RecordTypeId <> '' && RecordTypeId <> null)
            service.RecordTypeId = RecordTypeId;
        
        commonConstructor();
    }
    
    // Initialise local Session variables and fill with service's opening times
    // -- used in both constructors --
    private void commonConstructor() {
        document = new Document();
        
        deletePhoto = false;
    }
    
    // getter/setter for flag that says whether or not to remove reference to the photo
    public boolean getDeletePhoto()         { return deletePhoto; }
    public void setDeletePhoto(boolean x)   { deletePhoto = x; }
    
    public string getAddress() {
        Services__c s = [select service_street__c, service_city__c, service_postcode__c
                                         from Services__c where id = :service.Id];
        return s.service_postcode__c;
    }
    
    // Getter for Service object
    public Services__c getService() {
        if (service==null) service = new Services__c();
        return service;
    }
    
    // Getter for document object
    public Document getDocument() {
        if (document==null) document = new Document();
        return document;
    }
    
    // Return salesforce URL for displaying photo in <img> tags
    public string getImageURL() {
        Services__c s = [select Image_Doc_ID__c from Services__c where id = :service.Id];
        return '/servlet/servlet.FileDownload?file=' + s.Image_Doc_ID__c;
    }
    
    private void saveDocument() {
        // Get id of public guidebook photos folder
        Folder f = [select id from Folder where DeveloperName = 'Guidebook_photos' limit 1];
        document.folderId = f.Id;
        try {
            //if ( (document.Body != null) && (document.Body.toString() != '') ) {
                upsert document;
                
                // Set service's image to be this document Id
                service.Image_Doc_ID__c = document.Id;
            //} else {
                // No image to upload so set to placeholder as long as it's blank
                //if ( (service.Image_Doc_ID__c == '') || (service.Image_Doc_ID__c == null) )
                    //service.Image_Doc_ID__c = IMG_PLACEHOLDER;
            //}
            
        } catch (Exception e) {
            // Do nothing
        }
        
    }
    
    private void deleteDocument() {
        try {
            // Find existing document (if any) and delete it - unless it's the placeholder image
            if (service.Image_Doc_ID__c != IMG_PLACEHOLDER) {
                Document d = [select id from Document where id = :service.Image_Doc_Id__c];
                delete d;
            }
            
        } catch (Exception e) { /* do nothing */ }
        
        // Revert to placeholder image
        service.Image_Doc_Id__c = IMG_PLACEHOLDER;
    }
    
    public PageReference save() {
        // If user ticked 'delete photo' then remove document and references to it
        // otherwise save new document and link to service record

        // If user picked an image, save document and link it to this service
        if ( (document.Body != null) && (document.Body.toString() != '') )
            saveDocument();
        // If user hasn't chosen a file but service image doesn't exist, set to placeholder
        else if ( (service.Image_Doc_ID__c == '') || (service.Image_Doc_ID__c == null) )
            service.Image_Doc_ID__c = IMG_PLACEHOLDER;
        else if (deletePhoto)
            deleteDocument();
        
        upsert service;
        
        // Send user to the Service's detail page
        PageReference servicePage = new PageReference('/' + service.id);
        servicePage.setRedirect(true);
        return servicePage;
    }
    
        // Redirect to the Service edit page
    public PageReference edit() {
        PageReference servicePage = new PageReference('/apex/ServiceEdit?id=' + service.id);
        servicePage.setRedirect(true);
        return servicePage;
    }
    
    // Redirect to the Add Photo page
    public PageReference addPhoto() {
        PageReference servicePage = new PageReference('/apex/ServicePhotoAdd?id=' + service.id);
        servicePage.setRedirect(true);
        return servicePage;
    }
    
    // Remove the photo document and redirect to Service's detail page
    public PageReference deletePhoto() {
        deleteDocument();
        
        update service;
        
        // Send user to the Service's detail page
        PageReference servicePage = new PageReference('/' + service.id);
        servicePage.setRedirect(true);
        return servicePage;
    }
    
    // Redirect user to the Service's detail page
    public PageReference cancel() {
        PageReference servicePage = new PageReference('/' + service.id);
        servicePage.setRedirect(true);
        return servicePage;
    }
    
    // Return the user to the Services tab
    public PageReference cancelNew() {
        PageReference contPage = new PageReference('/a0z/o');
        contPage.setRedirect(true);
        return contPage;
    }
    
    //
    //  TEST ServicesEXT
    //
    private static testMethod void testServicesEXT() {
        Services__c service = new Services__c(Name='Test service');
        insert service;
                
        service.Image_Doc_ID__c = '';
        
        // Create a PageReference to the VF page being tested       
        PageReference pageRef = Page.Service;
        test.setCurrentPage(pageRef);
        
        // Now create the standard controller for the service
        ApexPages.StandardController stdCon = new ApexPages.StandardController(service);
        pageRef.getParameters().put('id', service.Id);
        
        // Test constructors
        servicesEXT cnt = new servicesEXT();
        cnt = new servicesEXT(stdCon);
        
        // Test record type parameter
        pageRef.getParameters().put('RecordType', service.RecordTypeId);
        cnt = new servicesEXT(stdCon);
        
        // Test properties
        Document document = cnt.getDocument();
        Services__c s = cnt.getService();
        cnt.getDeletePhoto();
        cnt.getAddress();
        cnt.getImageURL();
        
        // Test both branches of the save method
        cnt.setDeletePhoto(true);
        cnt.save();
        cnt.setDeletePhoto(false);
        cnt.save();
        cnt.saveDocument();
        
        cnt.addPhoto();
        cnt.deletePhoto();
        
        // Test PageReference methods
        cnt.edit();
        cnt.addPhoto();
        cnt.cancel();
        cnt.cancelNew();
    }
}