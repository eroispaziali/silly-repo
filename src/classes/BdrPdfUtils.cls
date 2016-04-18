/**
 *
 *  Name:         Valerie Dunphy  valerie.dunphy@conseq.net
 *  Date:         May 2014
 *
 *  Description : Generate HTML for a pdf of the BDR
 *
 *
 */
public without sharing class BdrPdfUtils 
{
    public BdrPdfUtils() {}
    
    /**
     *  This method takes a bdr object, and a name
     *  deletes any existing attachments with the same name 
     *  Creates a pdf of the bdr and attaches it to the bdr
     *  Called from Bdr_SyncChildRecords.trigger with a name like 'BDR-10456 Accepted'
     *  
     *  @param name    name of the BDR
     *  @param bdr     The BDR to be made into a pdf
     *
     */
    public static boolean storeHtmlAttachment(String name, String description, BDR__c bdr)
    {
      return storeHtmlAttachment(name, description, new BDRWrapper(bdr)); 
    }
     
    /**
     *  This method takes a bdr object, and a name
     *  deletes any existing attachments with the same name 
     *  Creates a pdf of the bdr and attaches it to the bdr
     *  Called from Bdr_SyncChildRecords.trigger with a name like 'BDR-10456 Accepted'
     *  
     *  @param name    name of the BDR
     *  @param bdr     The BDR to be made into a pdf
     *
     */
    public static boolean storeHtmlAttachment(String name, String description, BDRWrapper wrapper)
    {
    try {
    
    delete new List<Attachment>([select Id from Attachment where parentId = :wrapper.bdrid and Name = :name]);

    // Get the BDR as a HTML String - not including images as these are not supported by Blob.toPDF
    String pdfContent = generatePdfHtml(wrapper);

    Attachment attachmentPDF = new Attachment();
    attachmentPDF.parentId = wrapper.bdrid;
    attachmentPDF.Name = name;
    attachmentPDF.description = description;

    //No longer convert to PDF here as styling is ignored(!)
    //attachmentPDF.body = Blob.toPDF(pdfContent);
    
    // Creates a binary object out of the given html string and stores it as the Attachment body.
    // The body is a blog. We have a string in pdfContent so we must convert it to a blob
    attachmentPDF.body = Blob.valueOf(pdfContent);
    attachmentPDF.isPrivate=false;
   
    insert attachmentPDF;
    }
     catch(Exception e) {
        wrapper.bdr.addError('updatePdfAttachment Error');
    }  

    return true; 
}
     
    /*
      This method is called by VF pages that generate a pdf from the BDR, like BDR_Notification_PDF_Print component
   */
    public static String generatePdfHtml(BDRWrapper wrapper)
    {
      BdrPdfBuilder builder = new BdrPdfBuilder(wrapper);
      return builder.run();           
    }
    
    public static String generatePdfHtml(BDR__c bdr)
    {
      return generatePdfHtml(new BDRWrapper(bdr));
    }

}