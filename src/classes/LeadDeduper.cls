public with sharing class LeadDeduper{
 //Constructor
    public LeadDeduper(){}
    public List<Lead>  SearchLead(Lead pCurrentRecord, String pCompany, String pLastName, String pPostcode, 
                                  string pCity, id pRecordTypeId, Boolean pShowAllRecordTypes, Integer pSearchLimit){
     Boolean postCodeValid = false;
     String LeadLikeLastName;                                 
     List<String> LeadNameParts;
     String FirstName;
     String LastName;
     String Company;                                
     List<Lead> lstMatchingLeads = new List<Lead>();
     List<Lead> ListOfMatches = new List<Lead>();
     List<Lead> ListOfAdditionalMatches = new List<Lead>();
     integer currentLimit;
      // check that we have a valid post code
     postCodeValid=IsValidPostCode(pPostCode);
     //search
     //search # 1 match on name and postcode
     currentLimit = pSearchLimit;
     if (((Company!=null||Company!='')||(LastName!=null||LastName!=''))&& postCodeValid) {
         if (pShowAllRecordTypes){
             ListOfMatches = [Select id,Name,Street,City,PostalCode,State,Phone,Owner.Alias from Lead 
                              Where Company=:pCompany and LastName=:pLastName and 
                              PostalCode =:pPostCode order by FirstName LIMIT:currentLimit];
         }   
         else {
             ListOfMatches = [Select id,Name,Street,City,PostalCode,State,Phone,Owner.Alias from Lead
                              Where Company=:pCompany and LastName=:pLastName 
                              and PostalCode =:pPostCode and RecordTypeId=:pRecordTypeId order by FirstName LIMIT:currentLimit];
             }
         system.debug('############Search1'+ListOfMatches.size());
         currentLimit = currentLimit - ListOfAdditionalMatches.size();
         }
     //Search #2 Match on wildcard name and postcode
     if (((Company!=null||Company!='')||(LastName!=null||LastName!=''))&& postCodeValid) {
         if (pShowAllRecordTypes){
             ListOfAdditionalMatches = [Select id,Name,Street,City,PostalCode,State,Phone,Owner.Alias from Lead 
                              Where FirstName LIKE:pCompany and LastName LIKE:pLastName and 
                              PostalCode =:pPostCode order by FirstName LIMIT:currentLimit];
         }   
         else {
             ListOfAdditionalMatches = [Select id,Name,Street,City,PostalCode,State,Phone,Owner.Alias from Lead
                              Where Company LIKE:pCompany and LastName LIKE:pLastName 
                              and PostalCode =:pPostCode and RecordTypeId=:pRecordTypeId order by FirstName LIMIT:currentLimit];
             }
         system.debug('############Search2'+ListOfMatches.size());
         currentLimit = currentLimit - ListOfAdditionalMatches.size();
         
         for(Lead eachLead: ListofAdditionalMatches){
            ListOfMatches.Add(eachLead);
         }
      }
      //Search #3 Match on Wildcard Last Name
      if (((LastName!=null||LastName!=''))&& (currentLimit>0)){
      LeadlikeLastName = pLastName.trim()+'%';
      if (pShowAllRecordTypes){
             ListOfAdditionalMatches = [Select id,Name,Street,City,PostalCode,State,Phone,Owner.Alias from Lead 
                              Where LastName LIKE:LeadlikeLastName order by FirstName LIMIT:currentLimit];
         }   
         else {
             ListOfAdditionalMatches = [Select id,Name,Street,City,PostalCode,State,Phone,Owner.Alias from Lead
                              Where LastName LIKE:LeadlikeLastName and RecordTypeId=:pRecordTypeId order by FirstName LIMIT:currentLimit];
             }
          System.Debug ('##################Search3: ' + ListOfAdditionalMatches.size());
          currentLimit = currentLimit - ListOfAdditionalMatches.size();
           for(Lead eachLead : ListOfAdditionalMatches ) {   
            ListOfMatches.Add(eachLead); 
          }    
      }  
     //Search #4 Match on Postcode
     if((postCodeValid)&&(currentLimit>0)){
      if (pShowAllRecordTypes){
             ListOfAdditionalMatches = [Select id,Name,Street,City,PostalCode,State,Phone,Owner.Alias from Lead 
                              Where PostalCode =:pPostCode order by FirstName LIMIT:currentLimit];
         }   
         else {
             ListOfAdditionalMatches = [Select id,Name,Street,City,PostalCode,State,Phone,Owner.Alias from Lead
                              Where PostalCode =:pPostCode and RecordTypeId=:pRecordTypeId order by FirstName LIMIT:currentLimit];
             }
      system.debug('##############Search4:'+ListOfAdditionalMatches.size()); 
      currentLimit = currentLimit - ListOfAdditionalMatches.size();
       for(Lead eachLead : ListOfAdditionalMatches ) {   
         ListOfMatches.Add(eachLead); 
       }    
     } 
     
    //retrun lstMatchingLeads without duplicates and without current record
    set<Lead> leadset = new set<Lead>();
     for(Lead l:ListOfMatches){
         if(leadset.add(l)){
             if(l.id!=pCurrentRecord.id){
             lstMatchingLeads.add(l);
             }
        }                              
     }     
     return lstMatchingLeads;
   }
  private Boolean IsValidPostCode(string pPostcode) {
     boolean isValid = false;
     If (pPostcode==null||pPostcode=='') {
          isValid = false;
          return isValid;
      }
     // Regular Expression for Postcode
     String postcodeRegex= '^([A-PR-UWYZa-pr-uwyz]([0-9]{1,2}|([A-HK-Ya-hk-y][0-9]|[A-HK-Ya-hk-y][0-9]([0-9]|[ABEHMNPRV-Yabehmnprv-y]))|[0-9][A-HJKS-UWa-hjks-uw])\\ {0,1}[0-9][ABD-HJLNP-UW-Zabd-hjlnp-uw-z]{2}|([Gg][Ii][Rr]\\ 0[Aa][Aa])|([Ss][Aa][Nn]\\ {0,1}[Tt][Aa]1)|([Bb][Ff][Pp][Oo]\\ {0,1}([Cc]\\/[Oo]\\ )?[0-9]{1,4})|(([Aa][Ss][Cc][Nn]|[Bb][Bb][Nn][Dd]|[BFSbfs][Ii][Qq][Qq]|[Pp][Cc][Rr][Nn]|[Ss][Tt][Hh][Ll]|[Tt][Dd][Cc][Uu]|[Tt][Kk][Cc][Aa])\\ {0,1}1[Zz][Zz]))$';
     //'^([A-PR-UWYZa-pr-uwyz]([0-9]{1,2}|([A-HK-Ya-hk-y][0-9]|[A-HK-Ya-hk-y][0-9]([0-9]|[ABEHMNPRV-Yabehmnprv-y]))|[0-9][A-HJKS-UWa-hjks-uw])\ {0,1}[0-9][ABD-HJLNP-UW-Zabd-hjlnp-uw-z]{2}|([Gg][Ii][Rr]\ 0[Aa][Aa])|([Ss][Aa][Nn]\ {0,1}[Tt][Aa]1)|([Bb][Ff][Pp][Oo]\ {0,1}([Cc]\/[Oo]\ )?[0-9]{1,4})|(([Aa][Ss][Cc][Nn]|[Bb][Bb][Nn][Dd]|[BFSbfs][Ii][Qq][Qq]|[Pp][Cc][Rr][Nn]|[Ss][Tt][Hh][Ll]|[Tt][Dd][Cc][Uu]|[Tt][Kk][Cc][Aa])\ {0,1}1[Zz][Zz]))$');
     Pattern MyPattern = Pattern.compile(postcodeRegex);

     // then instantiate a new Matcher object ”MyMatcher”
     Matcher MyMatcher = MyPattern.matcher(pPostcode);

     if (!MyMatcher.matches()) {
          isValid = false;
     }else{
           isValid = true;
     }
     return isValid;
    }   
    
    private static testMethod void testLeadDeduper(){                                 
     Lead leadRec = new Lead(FirstName='Test',LastName='One1',PostalCode='SW1A 2AA',company = 'Test Company', Status = 'Open - Not Contacted',
                             RecordTypeId=[Select Id from RecordType Where SObjectType='Lead' and Name like 'Alzheimer_s_Trading_Lead_Record_Type%'].id);                                 
     insert leadRec;
     List<Lead> lstLds = new List<Lead>();
     Boolean bShowAll = true;
     Boolean bShowOne = false;
     Integer NoRecords = 100;   
     String lLeadFirstName = '';
     String lLeadLastName = '';
     String lPostCode= '';   
     String lCity='';
    
     Id RecordTypeId;                                 
     RecordTypeId = [Select Id from RecordType where SObjectType='Lead' and Name like'Alzheimer_s_Trading_Lead_Record_Type%'].id;                                 
     LeadDeduper dd = new LeadDeduper();
        
     lstLds = dd.SearchLead(leadRec,lLeadFirstName,lLeadLastName,lPostcode,lCity,RecordTypeId,bShowAll,NoRecords);   
     lLeadFirstName = 'Test';
     lstLds = dd.SearchLead(leadRec,lLeadFirstName,lLeadLastName,lPostcode,lCity,RecordTypeId,bShowAll,NoRecords);
     lstLds = dd.SearchLead(leadRec,lLeadFirstName,lLeadLastName,lPostcode,lCity,RecordTypeId,bShowOne,NoRecords);   
     lPostcode='ABC123';                                 
     lstLds = dd.SearchLead(leadRec,lLeadFirstName,lLeadLastName,lPostcode,lCity,RecordTypeId,bShowAll,NoRecords);
     lstLds = dd.SearchLead(leadRec,lLeadFirstName,lLeadLastName,lPostcode,lCity,RecordTypeId,bShowOne,NoRecords); 
     lLeadFirstName = 'Test';
     lLeadLastName = 'One1';    
     lPostCode = 'SW1A 2AA';   
     lstLds = dd.SearchLead(leadRec,lLeadFirstName,lLeadLastName,lPostcode,lCity,RecordTypeId,bShowAll,NoRecords);
     lstLds = dd.SearchLead(leadRec,lLeadFirstName,lLeadLastName,lPostcode,lCity,RecordTypeId,bShowOne,NoRecords);
                                   
                                 
    }                                   
                                      
                                      
                                      
}