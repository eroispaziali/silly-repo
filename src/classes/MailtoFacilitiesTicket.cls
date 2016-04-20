Global class MailtoFacilitiesTicket implements Messaging.inboundEmailHandler {

Global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,  Messaging.InboundEnvelope env ) {
 
Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
 
// Create the new Idea from the incoming email
        createFacilitiesTicket(email.subject, email.plainTextBody, env.fromAddress);
    
 // Set the result to true, no need to send an email back to the user
 // with an error message
 result.success = true;
 // Return the result for the Apex Email Service
 return result;
}

//public static void sendEmail(String s, List<Facilities_Ticket__c> myIdea) {

 // Send an email back to the from email address of who created the idea
// String[] toAddresses = new String[] {s};

 // new instance of a single email message
// Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

//   mail.setToAddresses(toAddresses);
//   mail.setReplyTo('Facilities@alzheimers.org.uk');
//   mail.setSenderDisplayName('Facilities');
//   mail.setSubject('Facilities Request created : '+ myIdea[0].Description__c);
//   mail.setBccSender(false);
//   mail.setUseSignature(false);
//   mail.setPlainTextBody('Your email has been logged: ' + myIdea[0].description__c + ' : on the Faciliities helpdesk database.');
 // Send the email
// Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

//    }  

public static Facilities_Ticket__c[] createFacilitiesTicket(String IdeaTitle, String ideaBody, String fromEmail) {

  // instance of a new Idea
  Facilities_Ticket__c[] newIdea = new Facilities_Ticket__c[0];

  // create a new Idea
  newIdea.add(new Facilities_Ticket__c(comments__c = ideaBody,Reported_By__c = fromEmail,
                    description__c = IdeaTitle));

   insert newIdea;
         
   //sendEmail(fromEmail,newIdea); 

   return newIdea;    
 }    

static testMethod void myTestMethod() {

   // Create a new email, envelope object and Attachment
   Messaging.InboundEmail email = new Messaging.InboundEmail();
   Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

   email.subject = 'Improve performance on the new Formular 1 racecar';
   env.fromAddress = 'user@acme.com';

   // call the class and test it with the data in the testMethod
   MailtoFacilitiesTicket ideaTestObj = new MailtoFacilitiesTicket();
   ideaTestObj.handleInboundEmail(email, env );                      
  }   
}