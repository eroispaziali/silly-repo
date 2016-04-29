/**
* File Name :   CSVBatchReader.cls
* Description : Class reding from CSV file in batches
*               Modified version of http://developer.financialforce.com/customizations/importing-large-csv-files-via-batch-apex/
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 02/04/2014 Klea Kolaric   Initial version
* 0.2 08/08/2014 Cristina P		Upload Audience Group and Members in the same time
*
*
*/
public with sharing class CSVBatchReader implements Database.batchable<String>, Database.Stateful {
	
	private String csvFile;
	private Id campaignId;
	private Id scheduleId;
	private Boolean firstBatch;
	private String lineTerminator; 
	private String valueSeparator;
	
	public CSVBatchReader(String csvFile, Id campaignId, Id selectedSchId)
	{
		this.csvFile = csvFile;
		this.campaignId = campaignId;
		this.scheduleId = selectedSchId;
		this.lineTerminator = ConstantUtil.CRLF;
		this.valueSeparator = ConstantUtil.COMMA;
		this.firstBatch = true; 
	}
	
	public Iterable<String> start(Database.batchableContext batchableContext)
	{
		CSVIterable fileIterable = new CSVIterable(csvFile);
		csvFile = null;
		lineTerminator = fileIterable.getRowTerminator();
		return fileIterable;
	}
	
	public void execute(Database.BatchableContext batchableContext, List<string> scope) 
	{
		String csvContent = '';
		// skip header on reading first batch
		if(firstBatch)
		{
			// set value separator (handle different type of sepparators 
			//so the csv upload functionality will work for people that are using 
			//colon and semicolon as separator in the csv file)
			if(scope.get(0).contains(':'))
          		valueSeparator =  ConstantUtil.COLON;
      		else if (scope.get(0).contains(';'))
          		valueSeparator=  ConstantUtil.SEMICOLON ;
      		else
          		valueSeparator=  ConstantUtil.COMMA;
			// remove header
			scope.remove(0);
			firstBatch = false;
		}
		
		for(String row : scope)
		{
			csvContent += row + lineTerminator;
		}
		CSVReader.setLineTerminator(lineTerminator);
		CSVReader.setValueSeparator(valueSeparator);
		List<List<string>> csvLines = CSVReader.readCSVFile(csvContent);
		csvContent = null;
		
		CW_AudienceCSVUploadController.processGroups(csvLines,campaignId,scheduleId);
		CW_AudienceCSVUploadController.processGroupMembers(csvLines,campaignId,scheduleId);
	}
	
	public void finish(Database.BatchableContext batchableContext)
	{
		// currently not used
	}
}