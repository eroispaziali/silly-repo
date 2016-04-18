public class ProposalClone {
    private Id ProposalIdOld;
    
    // Default constructor
    public ProposalClone (){
        // get the passed Id parameter
        ProposalIdOld = System.currentPageReference().getParameters().get('id') ;
    }
    
    // Visualforce extension constructor
    public ProposalClone(ApexPages.StandardController controller) {
        Proposal__c p = (Proposal__c)controller.getRecord();
        ProposalIdOld = p.Id;
    }
    
    public PageReference cloneProposal() {
        Proposal__c pOld = [
            select Another_agency_currently_delivering__c
            ,Any_other_reasons__c
            ,Area__c
            ,Area_Manager__c
            ,BDM__c
            ,Beneficiaries__c
            ,Capacity_infrastructure_to_deliver__c
            ,Country_Region__c
            ,Currently_delivering_the_service__c
            ,Demography__c
            ,Dependence_on_buying_external_services__c
            ,Description_of_proposed_service__c
            ,Does_TUPE_apply__c
            ,Evaluation_service_users_views__c
            ,Evidence_from_service_users__c
            ,Existing_good_practice__c
            ,Existing_service_data__c
            ,Fits_Corporate_Plan__c
            ,Fits_external_business_plans__c
            ,Funding_source_s__c
            ,Have_relationship_with_a_trust__c
            ,Health_social_care_professional_views__c
            ,How_it_meets_strategic_objective__c
            ,How_many_years_funding__c
            ,How_will_service_be_evaluated__c
            ,Identified_funding_in_fundraising_plan__c
            ,Identified_gap__c
            ,Job_title__c
            ,Joint_local_working_considered__c
            ,Local_delivery_skills__c
            ,Locality__c
            ,Name
            ,Other_beneficiary__c
            ,Partnership_working_been_considered__c
            ,Service_definition__c
            ,Service_recently_reviewed__c
            ,Service_specification__c
            ,Service_start_funding_date__c
            ,Skilled_staff_available_to_deliver__c
            ,Source_of_current_funding__c
            ,Specific_budget_quoted__c
            ,Specified_in_current_business_plans__c
            ,Status__c
            ,Strategic_objectives_met__c
            ,Suitable_premises_available__c
            ,Sustainability_of_service_exit_strategy__c
            ,Tender_submission_date__c
            ,Timescale_to_set_up_realistic__c
            ,TUPE_Contracts_Exist__c
            ,Type_of_current_funding__c
            ,VAT_applicable__c
            ,Which_funding_source_s__c
            ,Who_joint_working_considered__c
            ,Who_partnership_working_considered__c
            ,Who_reviewed_service__c
            ,Why_best_for_us_to_deliver__c
            ,Why_timescales_unrealistic__c
            from Proposal__c
            where id = :ProposalIdOld
        ];
        
        // Deep clone old proposal so all fields are copied
        Proposal__c pNew = pOld.clone(false, true);
        
        // Change name
        pNew.name = '[Clone] ' + pOld.name;
        
        // Set owner to current user
        pNew.OwnerId = UserInfo.getUserId();
        
        insert pNew;
        
        // Redirect to new Proposal's detail page
        PageReference propPage = new PageReference('/' + pNew.id);
        propPage.setRedirect(true);
        return propPage;
    }
    
    //
    //  TEST ProposalClone
    //
    
    private static testMethod void testProposalClone() {
        // find BDM user
        UserRole role = [select id from UserRole where Name = 'BDM - North' limit 1]; 
        User u = [select id from User where isActive = true and UserRoleId = :role.Id limit 1];
        
              
        UserRole role2 = [select id from UserRole where Name = 'Area Management - North East' limit 1]; 
        User u2 = [select id from User where isActive = true and UserRoleId = :role2.Id limit 1];
        
        
        Proposal__c prop = new Proposal__c(Name='Test proposal');
        prop.BDM__c = u.Id;
        prop.Area_Manager__c = u2.Id;
        
        prop.Strategic_objectives_met__c = 'blah';
        prop.How_it_meets_strategic_objective__c = 'blah';
        prop.Fits_Corporate_Plan__c = 'blah';
        prop.Fits_external_business_plans__c = 'blah';
        prop.Description_of_proposed_service__c = 'blah';
        prop.How_will_service_be_evaluated__c = 'blah';
        prop.Evaluation_service_users_views__c = 'blah';
        prop.Sustainability_of_service_exit_strategy__c = 'blah';
        prop.Dependence_on_buying_external_services__c = 'blah';
        prop.Why_best_for_us_to_deliver__c = 'blah';
        prop.Capacity_infrastructure_to_deliver__c = 'blah';
        prop.Beneficiaries__c = 'blah';
        prop.Service_definition__c = 'blah';
        
        insert prop;
        
        // Create a PageReference to the VF page being tested       
        PageReference pageRef = Page.ProposalClone;
        test.setCurrentPage(pageRef);
        
        // Now create the standard controller for the service
        ApexPages.StandardController stdCon = new ApexPages.StandardController(prop);
        pageRef.getParameters().put('id', prop.Id);
        
        // Test constructors
        ProposalClone cnt = new ProposalClone();
        cnt = new ProposalClone(stdCon);
        
        cnt.cloneProposal();
    }
}