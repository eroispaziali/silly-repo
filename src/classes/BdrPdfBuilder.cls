/**
 *
 * Name:         Valerie Dunphy  valerie.dunphy@conseq.net
 * Date:           June 2014
 *
 *  Description : Generate HTML for a pdf of the BDR
 *
 *  =======================================================
 */
public class BdrPdfBuilder 
{
   transient private BDRWrapper wrapper;
   
   private String buffer;
   private Map<Id, String> mapLocality = new Map<Id, String>();
   
   public BdrPdfBuilder(BDRWrapper wrapper)
   {
      this.wrapper = wrapper;
      
      /* This Map is used to get round the governor limits on getting the Locality Name for the Service. 
      
         The better way to do this would be to retrieve the Service with the Locality__r.Name populated
         That needs to be explored in the queries that retrieve the Services. 
      */ 
      List<Account> lisLocality =
       [select id, Name 
        from Account where RecordType.DeveloperName = 'InternalOrganisation'  
        And Name like '%Locality'];
        
      for (Account acct : lisLocality) {
           mapLocality.put(acct.id,acct.Name);
      }
      
      

   }

   public String run()
   {
      this.buffer = '';
      
      String status = wrapper.bdr.Status__c;

      emitElement('h1', 'Business Development Record');
      emitElement('h2', 'first', wrapper.bdr.BDR_Name__c);
      emitElement('h3', 'first', wrapper.bdr.Name + '\tStatus: ' + status );
      

      
      if (status.equals('Declined')) {
        

            emitElement('h4', 'Reason(s) Declined');
            emitElement('p', wrapper.bdr.Reasons_Declined__c.replaceAll(';', ',  '));
            // Changed the data type of Bid_Feedback_Detail__c from Text Area to Text Area Long
            emitElement('p', wrapper.bdr.Bid_Feedback_Detail__c);
      }
      
      emitSummary();
      
      emitPartnership();
      emitServices();
      emitIncomeSummary();
      emitTenderDetails();
      emitContractDetails();
      emitFeedback();
    
      emitApprovalHistory();   
      emitAttachments();
      emitNotes();
      
      emitSignaturePanel(); // only relevant if to be signed by a Trustee
   
      return buffer;
      
   }
 
 
   private void emitSummary()
   {
      BDR__c bdr = wrapper.bdr;
      
      emitSummaryTable();
      
      emitTextBlock('Proposal Summary', bdr.Summary__c);
      emitTextBlock('Infrastructure/Capacity to deliver', bdr.Delivery_Risks__c);
      emitTextBlock('Sustainability', bdr.Sustainability__c);

      emitTextBlock('Staff/Volunteer recruitment required', bdr.Recruitment_Required__c);
      emitTextBlock('Redundancy Implications', bdr.Any_redundancies__c);
      emitTextBlock('Impact if proposal is declined', bdr.Exit_Strategy__c);
   }

   private void emitSummaryTable()
   {
      BDR__c bdr = wrapper.bdr;
      beginElement('table', 'attribute-table');
      beginElement('tbody');
      
      // Locality and Area
      beginElement('tr');
      emitElement('td', 'label', 'Locality');
      emitElement('td', bdr.A2D_Locality__c, 'Name');
      
      emitElement('td', 'label', 'Area');
      emitElement('td', bdr.Area__c);
      closeElement('tr');
      
      // Region and Owner
      beginElement('tr');
      
      emitElement('td', 'label', 'Region');
      emitElement('td', bdr.Region__c);
      
      emitElement('td', 'label', 'Owner');
      emitElement('td', bdr.OwnerId, 'Name');
      closeElement('tr');
      
      
      // Estimated Income Required and Income Source
      beginElement('tr');
      
      emitElement('td', 'label', 'Income Source');
      emitElement('td', bdr.Income_Source__c, 'Name');
      
      emitElement('td', 'label', 'Est. Income Required');
      Decimal d = bdr.Total_Value__c==null ? 0 :bdr.Total_Value__c;
      emitElement('td', d.format());

      closeElement('tr');
      
      // Estimated Duration in months and Intended Start Date
      beginElement('tr');
   
      
      emitElement('td', 'label', 'Intended Start');
      emitElement('td', bdr.Intended_Start_Date__c);
      
      emitElement('td', 'label', 'Est Duration');
      emitElement('td', bdr.Estimated_Duration__c!=null ? bdr.Estimated_Duration__c.format() + ' months' : '');
      closeElement('tr');
      
      // BDM and Operations Manager
      beginElement('tr');
      emitElement('td', 'label', 'BDM');
      emitElement('td', bdr.BDM__c,'Name');
      emitElement('td', 'label', 'Operations Manager');
      emitElement('td', bdr.Operations_Manager__c, 'Name');
      closeElement('tr');
      
      // Regional Operations Manager and Operations Director
      beginElement('tr');
      emitElement('td', 'label', 'Regional Ops Manager');
      emitElement('td', bdr.Area_Manager__c,'Name');
      emitElement('td', 'label', 'Operations Director');
      emitElement('td', bdr.Operations_Director__c, 'Name');
      closeElement('tr');
      
      // Sign-off Level and Strategic Objectives Met
      beginElement('tr');
      emitElement('td', 'label', 'Sign-Off Level');
      
      String signOff = '';
      emitElement('td', bdr.Required_Approval_Level__c);
      emitElement('td', 'label', 'Strategic Ambition');
      emitElement('td', bdr.Strategic_objectives_met__c);
      closeElement('tr');
      
      // Tender and Development Type
      beginElement('tr');
      emitElement('td', 'label', 'Tender');
      emitElement('td', bdr.Tender__c);
      emitElement('td', 'label', 'Development Type');
      emitElement('td', bdr.Development_Type__c);
      closeElement('tr');
      
      beginElement('tr');
      emitElement('td', 'label', 'Service Specifications');
      emitTd(3, bdr.Service_Specifications__c);
      closeElement('tr');
      
      beginElement('tr');
      emitElement('td', 'label', 'HR Implications');
      String sHRI = bdr.HR_Implications__c;
      emitTd(3, sHRI==null?'':sHRI.replace(';',', '));
      closeElement('tr');
      
      if (bdr.IT_Implications__c==true) {      
          beginElement('tr');
          emitElement('td', 'label', 'IT Implications');

          emitTd(3, 'Yes');
          emitElement('td','');
          closeElement('tr');
      }
      
      closeElement('tbody');
      closeElement('table');
   }


  private void emitPartnership()
  {
     if (wrapper.bdr.Partnership_Status__c==null ) { return ; }  
    
     emitElement('h2', 'Partnership');
     emitPartnershipDetailsTable();
  }
  
  private void emitPartnershipDetailsTable()
   {
      BDR__c bdr = wrapper.bdr;

      beginElement('table', 'attribute-table');
      beginElement('tbody');
      
      beginElement('tr');
      
      emitElement('td', 'label', 'Partnership Status');
      emitElement('td', bdr.Partnership_Status__c);
      closeElement('tr');
      
      beginElement('tr');
      emitElement('td', 'label', 'Partner');
      emitElement('td', bdr.PartnerType__c);
      
      closeElement('tr');

      if (bdr.Partnership_Detail__c!=null) {
         beginElement('tr');
         emitElement('td', 'label', 'Partnership Detail');
    
        emitElement('td', bdr.Partnership_Detail__c);
        }
      closeElement('tr');
      
      closeElement('tbody');
      closeElement('table');
   }
     
   private void emitServices()
   {
      boolean first = true;
      String sCount = 'Services (' + wrapper.Services.svcWrappers.size() +')'; 
      emitElement('h2', sCount);
      List<BdrServiceWrapper> Services =  wrapper.Services.svcWrappers;
      
      for (BdrServiceWrapper sw : Services) {
         if (!first) emitElement('br');
         emitServiceTable(sw.svc, sw.evidence, sw.fundReqWrappers, sw.location);
         first = false;
      }
   }
   
   
   private void emitServiceTable(Services__c svc, Evidence_for_Need__c evidence, List<BdrFundReqWrapper> costs, Location__c location)
   {
      beginElement('table', 'attribute-table keep-together service-table');
      beginElement('tbody');
      
      beginElement('tr');
      beginTd(4, 'first');
      emitElement('label', svc.Name);
      closeTd();
      closeElement('tr');
      
      beginElement('tr');
      emitElement('td', 'label', 'Service Type');
      emitElement('td', svc.Service_type__c);
      emitElement('td', 'label', 'Locality');
     
      /* This line generates too many SOQL queries for large numbers of services */
      //emitElement('td', svc.Locality__c, 'Name');
        emitElement('td', mapLocality.get(svc.Locality__c));
    
      
     closeElement('tr');
     
     beginElement('tr');     
      emitElement('td', 'label', 'Service Location');
      emitTd(3, svc.Default_Location__r.Name);

      
      closeElement('tr');
      
      beginElement('tr');
      emitElement('td', 'label', 'Status');
      emitElement('td', svc.Service_Status__c);
      
      emitElement('td', 'label', 'Open Date');
      emitElement('td', svc.Service_Opendate__c);
      closeElement('tr');
      
      if (svc.Property_Notes__c!=null) {
          beginElement('tr');
          emitElement('td', 'label', 'Property Notes');
          emitTd(3, svc.Property_Notes__c);
          closeElement('tr');
      }
      
      if (evidence != null) {
        
         /* Show a message if all the fields are empty */
         String sNoEvidenceMessage = '';
         if (evidence.Evidence_Overview__c==null &&
             evidence.Consequences_of_Closure__c== null && 
             evidence.Usage_Profile__c==null &&
             evidence.Demography_Comments__c==null) {
             sNoEvidenceMessage = '';       
         }
        
         beginElement('tr');
                emitElement('td', 'label', 'Evidence of Need');
                emitTd(3, sNoEvidenceMessage);
         closeElement('tr');
         
         if (evidence.Evidence_Overview__c!=null) {
             beginElement('tr');
                 emitElement('td', 'label', 'Evidence Overview');
                 emitTd(3, evidence.Evidence_Overview__c);
             closeElement('tr');
         }
         
         if (evidence.Consequences_of_Closure__c!=null) {
         beginElement('tr');
             emitElement('td', 'label', 'Exit Strategy');
             emitTd(3, evidence.Consequences_of_Closure__c);
         closeElement('tr');
           }
         
        if (evidence.Usage_Profile__c!=null) {
            beginElement('tr');
                 emitElement('td', 'label', 'Service Data');
                 emitTd(3, evidence.Usage_Profile__c);
             closeElement('tr');
        }
         
         if (evidence.Demography_Comments__c!=null) {
         beginElement('tr');
             emitElement('td', 'label', 'Demography');
             emitTd(3, evidence.Demography_Comments__c);
         closeElement('tr');
           }
         
      }
      
      if (   svc.Estimated_Break_Even__c !=null &&
             (svc.Service_Status__c=='Draft' || svc.Service_Status__c=='Accepted')
          ) {
          beginElement('tr');
          emitElement('td', 'label', 'Estimated Break Even (Mnths)');
          emitTd(3, String.valueOf(svc.Estimated_Break_Even__c));
          closeElement('tr');
      }
      
      emitServiceCostTable(costs);
            
      closeElement('tbody');
      closeElement('table');
   }

   private void emitServiceCostTable(List<BdrFundReqWrapper> costs)
   {
      if (costs==null || costs.size()==0) return;
      
      beginElement('tr');
      emitElement('td', 'label', 'Costs and Income Allocation');
      beginTd(3, '');
      
      beginElement('table', 'cost-table');

      beginElement('thead');
      emitElement('th','Financial Year');
      emitElement('th','Cost');
      emitElement('th','Income from this BDR');
      emitElement('th','Other Secured Income');
      emitElement('th','Other Proposed Income');
      emitElement('th','Total not Covered');
      closeElement('thead');

      beginElement('tbody');
      for (BdrFundReqWrapper row : costs) {
         beginElement('tr');
         emitElement('td', row.freq.Fiscal_Year__c);
         emitElement('td', row.freq.Total_Amount__c);
         emitElement('td', row.Allocation.Allocation_Amount__c);
         emitElement('td', row.getOtherAllocationAmount());
         emitElement('td', row.getOtherAllocationAmountProposed());
         emitElement('td', row.freq.Total_Uncovered_Potential__c);
         closeElement('tr');
      }
      closeElement('tbody');

      closeElement('table');

      closeTd();
      closeElement('tr');
   }

   private void emitIncomeSummary()
   {
      if (wrapper.hasIncomeBlock != 'Yes') return;
      emitElement('h2', 'Income Summary');
      emitIncomeSummaryTable();
      emitElement('br');
      emitIncomeDetailTable();
   }

private void emitIncomeSummaryTable()
   {
      
      beginElement('table', 'attribute-table keep-together');
      beginElement('tbody');
      
      beginElement('tr');
      emitElement('td', 'label', 'Estimated Income Required');
      emitElement('td','align-right', wrapper.bdr.Total_Value__c);      
      emitTd(2,'');
      closeElement('tr');
      
      beginElement('tr');
      emitElement('td', 'label', 'Total Actual Income');
      emitElement('td', 'align-right w6', wrapper.incBlock.Total_Amount__c);
      emitElement('td', 'label', 'Total Allocation');
      emitElement('td', 'align-right w6', wrapper.totalAllocation);
      closeElement('tr');
      
      /* Why was this here - this is form other BDRs, noit relevant to the income from this one ?
      beginElement('tr');
      emitElement('td', 'label', 'Total Actual Income');
      emitElement('td', wrapper.incBlock.Total_Amount__c);
      emitElement('td', 'label', 'Total Other Allocation');
      emitElement('td', 'w30pxc', wrapper.totalOtherSecureAllocation);
      closeElement('tr');
      
      beginElement('tr');
      emitElement('td', 'label', '');
      emitElement('td', '');
      emitElement('td', 'label', 'Total Other Proposed Allocation');
      emitElement('td', 'w30pc', wrapper.totalOtherProposedAllocation);
      closeElement('tr');      
      */
      
      closeElement('tbody');
      closeElement('table');

   }

   private void emitIncomeDetailTable()
   {
    
      beginElement('table', 'attribute-table keep-together');
      beginElement('tbody');
      beginElement('tr');
      emitElement('td', 'label', 'Income for Financial Years');
      beginTd(3, '');
    
          beginElement('table', 'cost-table');
    
          beginElement('thead');
          emitElement('th', 'Financial Year');
          emitElement('th','align-right','Total Amount');
          emitElement('th','align-right', 'Essential Support Amount');
          emitElement('th','align-right', 'Local Support Amount');
      
          emitElement('th','w30pc left','Comments');          
          closeElement('thead');
    
          beginElement('tbody');
    
          for (Income_Block_Period__c row : wrapper.incomeData) {
             beginElement('tr');
             emitElement('td',  row.Fiscal_Year__c);
             emitElement('td', 'align-right', row.Total_Amount__c);
             emitElement('td', 'align-right', row.Essential_Support_Amount__c);
             emitElement('td', 'align-right', row.Local_Support_Amount__c);
            
             emitElement('td', 'left w30pc', row.Risk_Description__c);
             closeElement('tr');
          }
          
          closeElement('tbody');
    
          closeElement('table');

      closeTd();
      closeElement('tr');
      closeElement('tbody');
      closeElement('table');    

   }

   private void emitTenderDetails()
   {
      BDR__c bdr = wrapper.bdr;
      if (bdr.Tender__c != 'Yes') return; 
      emitElement('h2', 'Tender Details');
      emitTenderDetailsTable();
      emitTextBlock('Comments about TUPE', bdr.Tupe_Detail__c);
   }

   private void emitTenderDetailsTable()
   {
      BDR__c bdr = wrapper.bdr;

      beginElement('table', 'attribute-table');
      beginElement('tbody');
      
      beginElement('tr');
      emitElement('td', 'label', 'Status');
      emitElement('td', bdr.Bid_Status__c);
      emitElement('td', 'label', 'TUPE Status');
      emitElement('td', bdr.Tupe__c);
      closeElement('tr');
      
      beginElement('tr');
      emitElement('td', 'label', 'Clarification Questions By');
      emitElement('td', bdr.Clarification_Questions_Deadline__c);
      emitElement('td', 'label', 'Bid Sign-Off By');
      emitElement('td', bdr.Bid_Sign_Off_Deadline__c);
      closeElement('tr');
      
      beginElement('tr');
      emitElement('td', 'label', 'Bid Submission By');
      emitElement('td', bdr.Bid_Submission_Deadline__c);
      emitElement('td', 'label', 'Fixed Tender Amount');
      emitElement('td', String.valueOf(bdr.Fixed_Tender_Amount__c));
      closeElement('tr');
      
      closeElement('tbody');
      closeElement('table');
   }

   private void emitContractDetails()
   {
      BD_Contract__c contract = wrapper.contract;
      if (wrapper.hasContract != 'Yes'|| contract == null) return; 
      emitElement('h2', 'Contract Details');
      emitContractDetailsTable();
      emitTextBlock('Contract Comments and Risks', contract.Comments__c);
   }

   private void emitContractDetailsTable()
   {
    BD_Contract__c contract = wrapper.contract;
    if (contract==null) return;
        
      beginElement('table', 'attribute-table');
      beginElement('tbody');
      
      beginElement('tr');
      emitElement('td', 'label', 'Contract Type');
      emitElement('td', contract.Contract_Type__c);
      emitElement('td', 'label', 'Cost Centre');
      emitElement('td', contract.Cost_Centre__c);
      closeElement('tr');
      
      beginElement('tr');
      emitElement('td', 'label', 'Funding Conditions');
      emitElement('td', contract.Funding_Conditions__c);
      emitElement('td', 'label', 'Details of Funding Conditions');
      emitElement('td', contract.Details_of_Funding_Conditions__c);
      closeElement('tr');
      
      beginElement('tr');
      emitElement('td', 'label', 'Funder Code');
      emitElement('td', contract.Funder_Code__c);
      emitElement('td', 'label', 'Contract Paperwork attached');
      emitElement('td', (contract.Contract_Paperwork_Attached__c ? 'Yes' : 'No'));
      closeElement('tr');
      
      beginElement('tr');
      emitElement('td', 'label', 'Contract Administrator');
      emitElement('td', contract.Contract_administrator_internal__c,'Name');
      emitElement('td', 'label', 'Required Signatures');
      emitElement('td', contract.Required_Signatures__c);
      closeElement('tr');
      
      beginElement('tr');
      emitElement('td', 'label', 'Start Date');
      emitElement('td', contract.Start_date__c);
      emitElement('td', 'label', 'Term');
      emitElement('td', contract.Term__c);
      closeElement('tr');
      
      beginElement('tr');
      emitElement('td', 'label', 'End Date');
      emitElement('td', contract.End_date__c);
      emitElement('td', 'label', 'Review date');
      emitElement('td', contract.Review_date__c);
      closeElement('tr');
      
      beginElement('tr');
      emitElement('td', 'label', 'Option to Extend to');
      emitElement('td', contract.Option_to_extend_to__c);
      emitElement('td', 'label', 'Extension Terms');
      emitElement('td', contract.Extension_Terms__c);
      closeElement('tr');
      
      beginElement('tr');
      emitElement('td', 'label', 'Renewal Risk');
      emitElement('td', contract.Renewal_Risk__c);
      emitElement('td', '', '');
      emitElement('td', '');
      closeElement('tr');
      
      beginElement('tr');
      emitElement('td', 'label', 'Location of signed contract');
      emitElement('td', contract.Location_of_Original_Signed_Contract__c);
      emitElement('td', 'label', 'Paperwork checked by');
      emitElement('td', contract.Contract_paperwork_checked_by__c, 'Name');
      closeElement('tr');
      
      beginElement('tr');
      emitElement('td', 'label', 'Most Senior Signature Job Title');
      emitElement('td', contract.Most_Senior_Signature_Job_Title__c);
      emitElement('td', 'label', 'Most Senior Signature Name');
      emitElement('td', contract.Most_Senior_Signature_Name__c);
      closeElement('tr');
      
      beginElement('tr');
      emitElement('td', 'label', 'Significant Contract Risks');
      emitElement('td',  contract.Risk_Index_Applies__c);
      emitElement('td', 'label', 'Specific Terms for Reporting');

      String sHCI = contract.Highlighted_Contract_Items__c; 
      emitElement('td', sHCI==null? '' :sHCI.replace(';',', '));
      closeElement('tr');
      
      closeElement('tbody');
      closeElement('table');

      List<Attachment> lisAttachment= [select name from Attachment where parentId=:contract.id and isDeleted=false and isPrivate=false];
      if (lisAttachment!=null && !lisAttachment.isEmpty()) { 

          emitElement('h4', 'Contract Attachments');         
      
          beginElement('table', 'attribute-table');
          beginElement('tbody');
             for (Attachment a : lisAttachment) {
               beginElement('tr');
               emitElement('td',a.Name);
               closeElement('tr');   
             }   
          closeElement('tbody');
          closeElement('table');
     }
      
     List<Note> lisNotes= [select Owner.Name, CreatedDate, Title, Body from Note where parentId=:contract.id and isDeleted=False and isPrivate=false];      
     if (lisNotes!=null && !lisNotes.isEmpty()) {  
     
         emitElement('h4', 'Contract Notes');         
      
         beginElement('table', 'attribute-table');
         beginElement('tbody');
             for (Note note : lisNotes) {
                beginElement('tr');
                emitElement('td','w10',note.Owner.Name);
                emitElement('td','w10',note.CreatedDate);
                emitElement('td',note.Title);
                closeElement('tr');
                beginElement('tr');
                emitTd(4,note.Body);
                closeElement('tr');            
             } 
         closeElement('tbody');
         closeElement('table');
     }
      
   }

  private void emitFeedback()
  {
     if (wrapper.bdr.Bid_Feedback__c==null ) { return ; }  
    
     emitElement('h2', 'Feedback - Reasons for Success/Loss/Declined');
     emitFeedbackDetailsTable();
  }
  
     private void emitFeedbackDetailsTable()
   {
      BDR__c bdr = wrapper.bdr;

      beginElement('table', 'attribute-table');
      beginElement('tbody');
      
      beginElement('tr');
      
      emitElement('td', 'label', 'Feedback');
      emitElement('td', bdr.Bid_Feedback__c);
      closeElement('tr');
 
 /* Temporarily commenting out this so that I can change the data type of Bid_Feedback_Detail__c' from Text Area to Text Area Long
      if (bdr.Bid_Feedback_Detail__c!=null) 
      beginElement('tr');
      emitElement('td', 'label', 'Feedback Detail');
      emitElement('td', bdr.Bid_Feedback_Detail__c);
      
      closeElement('tr'); */     
      
      closeElement('tbody');
      closeElement('table');
   }    

   /* This feature cannot be used prior to the update for Summer 14
      because it includes the ProcessDefinition relationship
   */
  
   private void emitApprovalHistory()
   {

      BDR__c bdr = wrapper.bdr;
      List<ProcessInstance> lisPi = CustomUtils.getApprovalHistories(bdr.id);
      if(lisPi==null || lisPi.isEmpty()) { return; }

      emitElement('h2', 'Approval History');
      
      for(ProcessInstance pi : lisPi) {        

         String sDefinitionName = pi.ProcessDefinition.Name;   

         // Put in the Approval Cycle. This depends on the names of the Approvals
         // These need to be kept in line 

         String sProcessName = '';
         if (sDefinitionName.indexOf('Acceptance')>-1) {
            sProcessName = 'Initial Acceptance';
         }
         if (sDefinitionName.indexOf('Proposed')>-1) {
            sProcessName = 'Proposal Approval';
         }
         if (sDefinitionName.indexOf('Finalise')>-1) {
            sProcessName = 'Final Approval';
         }
         
         beginElement('table', 'attribute-table keep-together');
       
         beginElement('tbody');
         beginElement('tr');
         emitElement('th', 'label left w8', sProcessName);
         emitElement('th', 'label left w10', 'Approver');
         emitElement('th', 'label left w6', 'Status');
         emitElement('th', 'label left w10', 'Date');
         emitElement('th', 'label left w30pc', 'Comments');
         closeElement('tr');

         for(ProcessInstanceHistory pih : pi.StepsAndWorkitems) {
         
            beginElement('tr');
            emitElement('td', 'label', '');
            emitElement('td', pih.Actor.Name);
            emitElement('td', pih.StepStatus);
            emitElement('td', pih.CreatedDate.format('dd/MM/yy hh:mm'));
            emitElement('td', 'w30pc', pih.Comments);
            closeElement('tr');
         }

         closeElement('tbody');
         closeElement('table');

      }  

   }
  

  private void emitAttachments()
   {

      BDR__c bdr = wrapper.bdr;
   
      Integer c = 0;   
    
      List<Attachment> lisAttachment= [select name from Attachment where parentId=:bdr.id and isDeleted=false and isPrivate=false];      
      if (lisAttachment==null || lisAttachment.isEmpty()) { return ; }
        
     emitElement('h2', 'Attachments');      
     emitElement('h4', 'BDR Attachments');         
  
     beginElement('table', 'attribute-table');
     beginElement('tbody');
         for (Attachment a : lisAttachment) {
            beginElement('tr');
            emitElement('td',a.Name);
            closeElement('tr');            
         } 
     closeElement('tbody');
     closeElement('table');

   }

   private void emitNotes()
   {

      BDR__c bdr = wrapper.bdr;
   
      Integer c = 0;   
    
      List<Note> lisNotes= [select Owner.Name, CreatedDate, Title, Body from Note where parentId=:bdr.id and isDeleted=false and isPrivate=false];      
      if (lisNotes==null || lisNotes.isEmpty()) { return ; }
        
     emitElement('h2', 'Notes');      
     emitElement('h4', 'BDR Notes');         
  
     for (Note note : lisNotes) {
        beginElement('table', 'attribute-table');
        beginElement('tbody');
 
        beginElement('tr');
        emitElement('td','w10', note.Owner.Name);
        emitElement('td','w10',note.CreatedDate);
        emitElement('td',note.Title);
        closeElement('tr');
        beginElement('tr');
        emitTd(4,note.Body);
        closeElement('tr');            
          
        closeElement('tbody');
        closeElement('table');
        emitElement('BR','');
     }

   }    

  
  private void emitSignaturePanel()
  {
     if (wrapper.bdr.Required_Approval_Level__c!='2 from Chairman, Treasurer, Vice Chair, CEO' ) { return ; }  
    
     emitElement('h2','Signature Approval');
     beginElement('table', 'keep-together');
     beginElement('tbody');
     
     beginElement('tr');
     	emitElement('td','w10','');
     	emitElement('td','');
     closeElement('tr');
     
     beginElement('tr');
     	emitElement('td','w10','');
     	emitElement('td','');
     closeElement('tr');
     
     beginElement('tr');
     	emitElement('td','w10','Signed');
     	emitElement('td','..........................................................................................');
     closeElement('tr');
     
     beginElement('tr');
     	emitElement('td','w10','');
     	emitElement('td','');
     closeElement('tr');
     
     beginElement('tr');
     	emitElement('td','w10','');
     	emitElement('td','');
     closeElement('tr');   
     
     beginElement('tr');
	     emitElement('td','w10','Name');
	     emitElement('td','..........................................................................................');
     closeElement('tr');
     
     beginElement('tr');
     	emitElement('td','w10','');
     	emitElement('td','');
     closeElement('tr');   
     
     beginElement('tr');
     	emitElement('td','w10','');
     	emitElement('td','');
     closeElement('tr');
     
     beginElement('tr');
    	 emitElement('td','w10','Title');     
    	 emitElement('td','..........................................................................................');
     closeElement('tr');
     
     beginElement('tr');
     	emitElement('td','w10','');
     	emitElement('td','');
     closeElement('tr');   
     
     beginElement('tr');
     	emitElement('td','w10','');
     	emitElement('td','');
     closeElement('tr');
     
     beginElement('tr');
     	emitElement('td','w10','Date');
     	emitElement('td','..........................................................................................');
     closeElement('tr');
     
     closeElement('tbody');
     closeElement('table');
     
  }

 /*********************************************************************	
  
  UTILITY METHODS	
  
  *********************************************************************/

   private void beginElement(String name)
   {
      buffer += '<'+name+'>';
   }

   private void beginElement(String name, String cssClass)
   {
      buffer += '<'+name+' class="'+ cssClass +'">';
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
      if (content == null) content = '';
      buffer += '<'+name+'>'+escape(content)+'</'+name+'>';
   }

   private void emitElement(String name, Decimal content)
   {
      buffer += '<'+name+'>'+(content == null ? '0' : content.format())+'</'+name+'>';
   }

   private void emitElement(String name, Date content)
   {
      buffer += '<'+name+'>'+(content == null ? '' : content.format())+'</'+name+'>';
   }

   private void emitElement(String name, Datetime content)
   {
      buffer += '<'+name+'>'+(content == null ? '' : content.format())+'</'+name+'>';
   }

   private void emitElement(String name, String sClass, Datetime content)
   {
      buffer += '<'+name+' class="'+sClass+'">'+(content == null ? '' : content.format())+'</'+name+'>';
   }

   private void emitElement(String name, String cssClass, String content)
   {
      if (content == null) content = '';
      buffer += '<'+name+' class="'+ cssClass +'">'+escape(content)+'</'+name+'>';
   }

   private void emitElement(String name, String cssClass, Decimal content)
   {
      buffer += '<'+name+' class="'+ cssClass +'">'+(content == null ? '0' : content.format())+'</'+name+'>';
   }
    
   private void emitElement(String name, String cssClass, Id oid, String fieldName)
   {
      String content = oid == null ? '' : String.valueOf(dblookup(oid, fieldName));
      emitElement(name, cssClass, content); 
   }

   private void emitElement(String name, Id oid, String fieldName)
   {
      String content = oid == null ? '' : String.valueOf(dblookup(oid, fieldName));
      emitElement(name, content); 
   }

   private void emitTd(Integer colspan, String content)
   {
      if (content == null) content = '';
      buffer += '<td colspan="'+ colspan +'">'+escape(content)+'</td>';
   }

   private void beginTd(Integer colspan, String cssClass)
   {
      buffer += '<td class="'+ cssClass +'" colspan="'+ colspan +'">';
   }

   private void closeTd()
   {
      closeElement('td');
   }

   private void emitTextBlock(String title, String text)
   {
      if (text==null || text.length()==0) return;
      beginElement('div', 'keep-together');
      emitElement('h4', title);
      emitElement('div', 'text-content',text);
      closeElement('div');
   }
   
   private static String escape(String text)
   {
      text = text.replace('<', '&lt;');
      text = text.replace('>', '&gt;');
      text = text.replace('&', '&amp;');
      return text;      
   }
   
   /* This method needs some investigation - potential for too many SOQL queries 
      Explore options for replacing with __r references in the queries that source the objects     
   */
   private static Object dblookup(Id unid, String field)
   {
      Schema.SObjectType tp = unid.getSObjectType();
      Schema.DescribeSObjectResult dr = tp.getDescribe();
      String query = 'SELECT '+ field + ' FROM ' + dr.getName() + 
                           ' WHERE Id=\'' + unid + '\'';
      sObject[] result = Database.query(query);
      return result.size() == 0 ? '????' : result[0].get(field);
   }
   
}