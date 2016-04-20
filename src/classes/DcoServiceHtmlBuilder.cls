public with sharing class DcoServiceHtmlBuilder 
{
   private String buffer;
   private Services__c svc;

   public String buildHtml(Services__c service)
   {  
   	buffer = '';
      svc = service;
      
      beginElement('html');
      emitHead();
      emitBody();
      closeElement('html');
                  
      return buffer;
    }
    
   private void emitHead()
   {
      beginElement('head');

      emitElement('title', svc.Name);
      emitMetadata();

      closeElement('head');
   }
   
   private void emitMetadata()
   {
	   emitMetaTag('content-language','en');
	   emitMetaTag('robots','index');
	   emitMetaTag('Author','Alzheimer\'s Society');
	   emitMetaTag('Publisher','Alzheimer\'s Society');
	   emitMetaTag('Coverage','UK');
	   emitMetaTag('Description', svc.Service_Description__c);
	   
	   emitMetaTag('DC.creator','Alzheimer\'s Society');
	   emitMetaTag('DC.date.created',svc.CreatedDate.format('yyyy-MM-dd'));
	   emitMetaTag('DC.format','text/html');
	   emitMetaTag('DC.language','en');
	   emitMetaTag('DC.publisher','Alzheimer\'s Society');
	   emitMetaTag('DC.rights.copyright','Copyright Alzheimer\'s Society. Registered charity no 296645.');
	   emitMetaTag('DC.coverage','UK');
	   emitMetaTag('DC.identifier','http://www.alzheimers.org.uk/dco/services/'+svc.Id);
      emitMetaTag('DC.title', svc.Name);
	   emitMetaTag('DC.description', svc.Service_Description__c);
	   
	   if (svc.Location__Latitude__s != null) {
	      emitMetaTag('geo.position', svc.Location__Latitude__s+';'+svc.Location__Longitude__s);
	   }
   }
   
   private void emitBody()
   {
      beginElement('body');

      emitElement('h1', svc.Name);

      emitElement('h2', svc.service_street__c+' '+svc.service_city__c+' '+svc.service_postcode__c);

      emitElement('h3', 'Service Description');
      emitElement('p', svc.service_description__c);

      emitElement('h3', 'Service Details');
      emitElement('p', 'For', svc.service_targetclientgroup__c);
      emitElement('p', 'Parking', svc.Parking__c);
      emitElement('p', 'Toilets', svc.Toilet_Facilities__c);
      emitElement('p', 'Accessibility', svc.Accessibility__c);
      emitElement('p', 'Hours', svc.service_operationhourscomment__c);

      emitElement('h3', 'Contact Information');
      emitElement('p', 'Contact name', svc.Contact_first_name__c+' '+svc.Contact_last_name__c);
      emitElement('p', 'Telephone', svc.service_telephone__c);
      emitElement('p', 'Email', svc.service_email__c);
      emitElement('p', 'Website', svc.service_website__c);

      closeElement('body');
   }
    
   private void emitMetaTag(String name, String content)
   {
      buffer += '<meta name="'+name+'" content="'+escape(content)+'"/>';
   }

   private void beginElement(String name)
   {
      buffer += '<'+name+'>';
   }

   private void closeElement(String name)
   {
      buffer += '</'+name+'>';
   }

   private void emitElement(String name)
   {
      buffer += '<'+name+'/>';
   }

   private void emitElement(String name, String content)
   {
      if (content == null) return;
      buffer += '<'+name+'>'+escape(content)+'</'+name+'>';
   }

   private void emitElement(String name, String label, String content)
   {
      if (content == null) return;
      buffer += '<'+name+'>'+escape(label)+': '+escape(content)+'</'+name+'>';
   }

   private static String escape(String text)
   {
      text = text.replace('<', '&lt;');
      text = text.replace('>', '&gt;');
      text = text.replace('&', '&amp;');
      return text;      
   }

}