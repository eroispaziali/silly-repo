public class BDR_Attachment_Print_Controller
{

    protected ApexPages.StandardController ctl;
    
    /*
     *  Default constructor.
     */
	public  BDR_Attachment_Print_Controller()
    {
        
    }
    

    public BDR_Attachment_Print_Controller(ApexPages.StandardController controller)
    {
	    ctl=controller;
        /*
         * Ensure that the standard controller retrieves the Body field for the Attachment so 
         * that we can refer to it below. If this will not run well with tests then may need to 
         * add a hidden field to the BDR_Attachment_Print page.
         */
        ctl.addFields(new List<String>{'Body'});
    }         
    
	public String getAttachmentHtml()
    {
        Attachment att = (Attachment)ctl.getRecord();
        return att.Body.toString();
    } 

	public String getPrototypeHtml()
    {
        StaticResource res = [select Body from StaticResource where Name = 'bdr_pdf_test_html'];
        return res.Body.toString();
    } 

    
}