public class DocumentViewer {
	public string documentId;

	public string getDocumentId() { return documentId; }
	public void setDocumentId(string docId) { documentId = docId; }
	
	// Return salesforce URL for displaying photo in <img> tags
    public string getImageURL() {
        //Document d = [select Id from Document where id = :documentId];
        return '/servlet/servlet.FileDownload?file=' + documentId;
    }
    
    //
    // TEST Document Viewer
    //
    private static testMethod void testDocViewer() {
		DocumentViewer dv = new DocumentViewer();
		dv.setDocumentId('');
		string docId = dv.getDocumentId();
		string url = dv.getImageURL();
		
		system.assertEquals(docId, '');
		system.assertEquals(url, '/servlet/servlet.FileDownload?file=');
	}
}