trigger Service_MeasuresInsert on Service_Measures_Data__c (before insert, before update)  {
    Id Measures_Care_services;
    Id Measures_Event_Services;
    Id Measures_Information_and_helpline_services;
    Id Newsletter_Services_Measures;
    Id Measures_One_to_One_Services;
    Id Measures_Other_services;
    Id Measures_Clients_including_professionals;
    
    Map<Id, Service_Measures_Data__c > measureMap = new Map<Id, Service_Measures_Data__c >();

    //get record types for insert only
    if (System.Trigger.isInsert){ 
        Measures_Care_services = [select Id from RecordType where DeveloperName = 'Measures_Care_services'].Id;
        Measures_Event_Services= [select Id from RecordType where DeveloperName = 'Measures_Event_Services'].Id;
        Measures_One_to_One_Services= [select Id from RecordType where DeveloperName = 'Measures_One_to_One_Services'].Id;
        Measures_Other_services= [select Id from RecordType where DeveloperName = 'Measures_Other_services'].Id;
        Measures_Clients_including_professionals = [select Id from RecordType where DeveloperName = 'Measures_Clients_including_professionals'].Id;
        Measures_Information_and_helpline_services= [select Id from RecordType where DeveloperName = 'Measures_Information_and_helpline_services'].Id;
        Newsletter_Services_Measures= [select Id from RecordType where DeveloperName = 'Newsletter_Services_Measures'].Id;
    }        
    // Put new row(s) in a map 
    for (Service_Measures_Data__c m: System.Trigger.new) {
        if (m.Service__c != null) {
        measureMap.put(m.Id, m);
        }
    }
    // Using a single database query, find all the measure data records in  
    // the database that have the same reporting period as any  
    // of the meassures being inserted.  
    
    for (Service_Measures_Data__c measure: System.Trigger.new) {
        // System.debug('>>>>>>>>>>>>>>>>>>>>>> service' + measure.Service__c);
        // System.debug('>>>>>>>>>>>>>>>>>>>>>> service' + measure.Reporting_Period__c);
        if (System.Trigger.isInsert ||
                           ( (measure.Service__c == System.Trigger.oldMap.get(measure.Id).Service__c)
                            && measure.Reporting_Period__c == System.Trigger.oldMap.get(measure.Id).Reporting_Period__c) ==false)  
         
        for (Service_Measures_Data__c measure2 : [SELECT Id,Service__c, Reporting_Period__c FROM Service_Measures_Data__c
                                                  WHERE  Service__c = :measure.Service__c and Reporting_Period__c = :measure.Reporting_Period__c]){

            System.debug('################### period' + measure2.Reporting_Period__c);
            for(Service_Measures_Data__c target : measureMap .values()) {
                
                System.debug('*************** Current Target: ' + target.Name);
                if (target.Service__c == measure2.Service__c && (target.Reporting_Period__c == measure2.Reporting_Period__c)) {
                    System.debug('*************** Current Target: ' + target.Reporting_Period__c);
                    Service_Measures_Data__c  n = measureMap.get(target.Id);
                    n.Month__c.addError('A measures record already exists for this period');
                }    
            }
        
        }                                          
    }
   if (System.Trigger.isInsert){  
       for (Service_Measures_Data__c nc:Trigger.new) {
            if (nc.RecordTypeId == NULL && (nc.Group_Name__c !=NULL)) {
                try {
                     if (nc.Group_Name__c=='Care services') {
                         nc.RecordTypeId = Measures_Care_services;
                     }
                     else if (nc.Group_Name__c=='Events') {
                         nc.RecordTypeId = Measures_Event_Services;
                     }
                     else if (nc.Group_Name__c=='One to one support') {
                         nc.RecordTypeId = Measures_One_to_One_Services;
                     }
                     else if (nc.Group_Name__c=='Other services') {
                         nc.RecordTypeId = Measures_Other_services;
                     }
                     else if (nc.Group_Name__c=='Training') {
                         nc.RecordTypeId = Measures_Clients_including_professionals;
                     }
                     else if (nc.Group_Name__c=='Information and helplines') {
                         nc.RecordTypeId = Measures_Information_and_helpline_services;
                     }
                     else if (nc.Group_Name__c=='Newsletters') {
                         nc.RecordTypeId = Newsletter_Services_Measures;
                     }
                    
                } catch(Exception e) {
                    // do nothing
                }
            }
        }
    }

}