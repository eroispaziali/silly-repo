public virtual class BaseControllerExtension {

    /**
    @author 		gary.grant@conseq.co.uk 
    @date 			May 2014
    @description Base Controller Extension. Controller Extension classes can extend this 
                 		class to includes the methods on the BaseControllerExtension.
    
    */
    protected ApexPages.StandardController ctl;
    protected DateTime oSystemModStamp;

    /**
    @description Constructor. Ensures SystemModStamp is retrieved with the sObject and stored in 
    a var in the page ViewState for use in later contention tests
    */
    public BaseControllerExtension(ApexPages.StandardController controller)
    {
      ctl=controller;

      /* Unit tests cannot run addFields because the data is passed in to the controller
         not retrieved by it in test code. Ensure the object passed in to the controller in the 
         class already has all the data required.   
      */  
      if (!Test.isRunningTest()){
          ctl.addFields(new List<String>{'SystemModStamp'});
    
          sObject o=ctl.getRecord();
          
          //Put the value at load time into a ViewState variable
          oSystemModStamp=(DateTime)o.get('SystemModStamp');
          system.debug('Base Controller : SystemModStamp ' + oSystemModStamp);
      }
        
    }         

  /**
    @description This method can be called prior to an update to test whether the record being saved 
    has been modified by another user since it was retrieved from the database. If that is the case
    an error is thrown and the save is aborted.

    The process relies on the value of SystemModStamp being stored in a var in the Visual Force at display time. 
    This value is compared with the SystemModStamp from the instance of the record that is in the database 
    at the point of saving. A difference indicates the record was updated by another user since the record was 
    retrieved from the database by the current user's transaction, in which case an error is generated. 

    The process initiates additional SOQL queries, which may impact governor limits
       
    This method is ignored for Unit Tests and always returns false (save OK). 
    SystemModStamp will not be available in sObjects used for testing, 
    because they are created in memory and used immediately, not retrieved from the database. 

    The process uses SystemModStamp because automated processes that are not specifically part of a 
    user initiated save action will update SystemModStamp and leave DateLastModified unchanged.

    */
  
  public boolean contentionCheck() 
  {    
         
     sObject o = ctl.getRecord(); 
     String id = (String)o.get('id'); 
     String sQuery = 'select SystemModStamp, LastModifiedDate, LastModifiedById from ' + o.getSObjectType().getDescribe().getName() + ' where id =:id for Update';
     List<sObject> lis = database.query(sQuery);

     // If this list is empty, the sObject has not previously been saved
     if (lis.isEmpty()) { 
         return false;
     }    

     // This check is ignored for Unit Test because SystemModStamp will generally not be available
     // in sObjects used in Unit Tests. 
     if (Test.isRunningTest()){ 
         this.oSystemModStamp=(DateTime)lis[0].get('SystemModStamp'); 
     } 

     system.debug('Base Controller : SystemModStamp ' + oSystemModStamp);
     system.debug('Base Controller : SystemModStamp Obj.Id ' + o.id);

     system.debug('Base Controller : Object SystemModStamp ' + lis[0].get('SystemModStamp'));
     system.debug('Base Controller : Object id ' + lis[0].id); 

     /* If the database instance of the record does not share a common SystemModStamp with the 
        value retrieved when the transaction was initiated, that indicates an update by another user 
        in the intervening period.  */
     if(lis[0].get('SystemModStamp')== this.oSystemModStamp) {
        return false;  
     } 
       
     /* At this point we know there is a Contention Error 
      * If LastModifiedDate and SystemModStamp are not the same, that indicates the
      * update was triggered by an automated process, not a user initiated save action.
      * Adjust the error message accordingly */     
       putContentionErrorMessage(lis,o); 

     return true; 
  }

  /* This method can be called by Unit Tests directly for coverage and detail testing */  
  public void putContentionErrorMessage(List<sObject> lis, sObject o)
  {      
       if(lis[0].get('LastModifiedDate')==lis[0].get('SystemModStamp')) {    
     
         String uid = (String)lis[0].get('LastModifiedById');
         String sQuery = 'select Name from User where id =:uid';
         lis = database.query(sQuery);
         
         o.addError('The record (' + o.get('name') +'/' + o.getSObjectType().getDescribe().getName() +') you were editing was modified by ' + (String)lis[0].get('Name') + ' during your edit session. Please reload the page before editing again.');
     
     } else {
     
         o.addError('The record you were editing was modified by a background automated process during your edit session. Please reload the page before editing again.');
     
     }
      
  }    
    
}