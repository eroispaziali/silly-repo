@isTest
public class TestBdrUtils
{
    /***********************************************************************************************
     * @author          gary.grant@conseq.co.uk   
     * @date            June 2013 
     * @description     A set of utility methods that creates a full set of Test Data for testing 
                        BDR application components. The method returns a Map of Maps
                        with a full set of records for each component of the application
    ***********************************************************************************************/


   /** 
    *   @description    Utility method for creating a full set of test data for BDR application test methods
    *
    **/

    static testMethod void TestDataCreation()
    {

        Map<String, Object> mapTestData= TestBdrUtils.getTestData();
        Map<String, BDR__c> mapBdr = (Map<String,BDR__c>)mapTestData.get('bdr');
        BDR__c bdr = (BDR__c)mapBdr.get('bdr1');  
    
        System.debug('Start Date In Test : ' + bdr.Intended_Start_Date__c);
        System.debug('Duration In Test : ' + bdr.Estimated_Duration__c);
        System.debug('Fiscal Years In Test : ' + bdr.Fiscal_Years__c);
        System.assert(bdr.Fiscal_Years__c=='2012/13;2013/14');
    
    
        //A map with two types of ServiceWrapperList (bdr, list)
        Map<String, BdrServiceWrapperList> mapSwl = (Map<String, BdrServiceWrapperList>)mapTestData.get('swl');
    
        //A ServiceWrapperList with two BDR's referenced
        BdrServiceWrapperList lisW = mapSwl.get('swl1');
    
        //An individual service wrapper
        BdrServiceWrapper svcW = lisW.SvcWrappers[0];
    
        //A service
        Services__c svc = svcW.svc;
    
        //A fund requirement wrapper
        BdrFundReqWrapper freq = svcW.fundReqWrappers[0];
    
        //the figures from the funder requirement wrapper that reference a second bdr
        Decimal d = freq.getOtherAllocationAmountPotential();
        d=freq.getOtherAllocationAmountProposed();
        d=freq.getOtherAllocationAmount();    
        
    }

    public static Map<String,Object> getTestData()
    {

    
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'BDC'];
        for(Profile p : ps){ profiles.put(p.name, p.id); }

        Map<String,Id> roles = new Map<String,Id>();
        List<UserRole> rl = [select id, name from UserRole where name = 'Area Management - London' limit 1];
        for(UserRole r : rl){ roles.put(r.name, r.id); }

        List<UserRole> r2 = [select id, name from UserRole where name = 'Locality Management - North East London' limit 1];
        for(UserRole r : r2){ roles.put(r.name, r.id); }     

        User userBDM = [select id from user where Title like '%Business Development Manager' and isActive=true limit 1];
        User userAM = [select id from user where UserRoleId =:roles.get('Area Management - London') and isActive=true limit 1];
        User userAuthor = [select id from user where UserRoleId =:roles.get('Locality Management - North East London') and isActive=true limit 1];
        User userOD = [select id from user where UserRoleId =:roles.get('Area Management - London') and isActive=true limit 1];
        User userRA = [select id from user where Title like 'Regional Accountant%' and isActive=true limit 1];
        User userHR = [select id from user where UserRoleId =:roles.get('Area Management - London') and isActive=true limit 1];
        User userLM = [select id from user where Title like 'Operations Manager%' and isActive=true limit 1];
        User userSIM = [select id from user where Title like 'Service Improvement Manager%' and isActive=true limit 1]; 


        //This recordTypes for a custom object to work around A2D. These orgs have record types for each level in the hierarchy    
        Map<String, String> mapOrgRecIds = new Map<String, String>();
        for(RecordType r : [select DeveloperName, id from RecordType where sObjectType ='BDR_Organisation__c']) {
            mapOrgRecIds.put(r.DeveloperName, r.id);
        }    

        //An A2DOrganisation Region
        Bdr_Organisation__c a2dRegion = new BDR_Organisation__c();
        a2dRegion.Name='A2d Region';
        a2dRegion.SIM__c = userSIM.id;
        a2dRegion.Hr_Manager__c = userHR.id;
        a2dRegion.Regional_Accountant__c = userRA.id;
        a2dRegion.Operations_Director__c = userOD.id;
        
        String recTypeId = mapOrgRecIds.get('Region');
        a2dRegion.recordTypeId = recTypeId;
        insert a2dRegion;

        //An A2DOrganisation Area
        Bdr_Organisation__c a2dArea = new BDR_Organisation__c();
        a2dArea.Name='A2d Area';
        a2dArea.Region__c=a2dRegion.id;
        a2dArea.Rom__c = userAM.id;
        
        recTypeId = mapOrgRecIds.get('Area');
        a2dArea.recordTypeId = recTypeId;
        insert a2dArea;    

        //An A2DOrganisation Locality
        Bdr_Organisation__c a2dLocality = new BDR_Organisation__c();
        a2dLocality.Name='A2d Locality';
        a2dLocality.Operations_manager__c = userLM.id;
        a2dLocality.Area__c = a2dArea.id;
        a2dLocality.Region__c = a2dRegion.id;
        a2dLocality.BDM__c = userBDM.id;
        
        recTypeId = mapOrgRecIds.get('Locality');
        a2dLocality.recordTypeId = recTypeId;
        insert a2dLocality;


        //An organisation
        recTypeId = [Select Id from RecordType where sObjectType = 'Account' and DeveloperName = 'InternalOrganisation' limit 1].Id;

        Account regLoc = new Account();
        regLoc.recordTypeId=recTypeId;
        if(userRA!=null) { regLoc.regional_accountant__c = userRA.id; }
        if(userOD!=null) { regLoc.Operations_Director__c = userOD.id; }
        if(userSIM!=null) { regLoc.SIM__c = userSIM.id; }
        regLoc.name='xxx Region';    
        insert regLoc;

        Account areaLoc = new Account();
        areaLoc.recordTypeId=recTypeId;
        areaLoc.name='xxx Area';
        areaLoc.parentId=regLoc.id;
        if(userHR!=null) { areaLoc.HR_Advisor__c = userHR.id; }
        insert areaLoc;

        Account loc = new Account();
        loc.recordTypeId=recTypeId;
        loc.name='xxx Locality';
        if(userLM!=null) { loc.Locality_Manager__c = userLM.id; }
        insert loc;


        //BDR
        BDR__c bdr1 = new BDR__c();  
        bdr1.bdr_name__c='bdr1';
        bdr1.Intended_Start_Date__c = Date.newInstance(2012,4,1);
        bdr1.Estimated_Duration__c = 24;
        //bdr1.fiscal_years__c='2012/13;2013/14';
        bdr1.status__c='Draft';
        bdr1.Required_Approval_Level__c='Regional Operations Manager';
        bdr1.Area_manager__c=userAM.id;
        bdr1.BDM__c=userBDM.id;
        bdr1.ownerId=userAuthor.id;
        bdr1.locality__c=loc.id;
        bdr1.A2D_Locality__c=a2dLocality.id;
        bdr1.Total_Value__c = 20000;

        insert bdr1;          
        System.debug('BDR1 in Test Method Fiscal Yrs:' + bdr1.Fiscal_Years__c);    


        //A second BDR to show 'Other funding'
        BDR__c bdr2 = new BDR__c();  
        bdr2.bdr_name__c='bdr2';        
        //bdr2.fiscal_years__c='2012/13;2013/14';
        bdr2.Intended_Start_Date__c = Date.newInstance(2012,4,1);
        bdr2.Estimated_Duration__c = 24;
        bdr2.status__c='Draft';
        bdr2.Required_Approval_Level__c='Regional Operations Manager';
        bdr2.Area_manager__c=userAM.id;
        bdr2.BDM__c=userBDM.id;
        bdr2.ownerId=userAuthor.id;
        bdr2.locality__c=loc.id;
        bdr2.A2D_Locality__c=a2dLocality.id;
        bdr2.Total_Value__c=20000;

        insert bdr2;

        BDR__c bdr3 = new BDR__c();  
        bdr3.bdr_name__c='bdr3';
        bdr3.Intended_Start_Date__c = Date.newInstance(2012,4,1);
        bdr3.Estimated_Duration__c = 24;
        //bdr3.fiscal_years__c='2012/13;2013/14';
        bdr3.status__c='Draft';
        bdr3.Required_Approval_Level__c='Regional Operations Manager';
        bdr3.Area_manager__c=userAM.id;
        bdr3.BDM__c=userBDM.id;
        bdr3.ownerId=userAuthor.id;
        bdr3.locality__c=loc.id;
        bdr3.A2D_Locality__c=a2dLocality.id;
        bdr3.Income_Source__c=loc.id;
        bdr3.Total_Value__c=20000;

        insert bdr3;
          

        recTypeId = [Select Id from RecordType where sObjectType = 'Services__c' and DeveloperName = 'Internal' limit 1].Id;
        Services__c svc1 = new Services__c();
        svc1.recordTypeId=recTypeId;
        svc1.name='TestService1';
        svc1.service_status__c='Draft';
        svc1.Locality__c=loc.id;
        svc1.operated_by__c=loc.id;    
        svc1.service_type__c='Advocacy';
        svc1.service_financeactivitycode__c='STV1';
        insert svc1;

        //A dementia connect service
        Services__c svc2 = new Services__c();
        svc2.recordTypeId=recTypeId;
        svc2.name='TestService2';
        svc2.service_status__c='Draft';
        svc2.Locality__c=loc.id;
        svc2.operated_by__c=loc.id;
        insert svc2;

        /*Service Links BDr1*/    
        BDR_service_link__c sl1 = new BDR_Service_Link__c();
        sl1.service__c = svc1.id;
        sl1.bdr__c = bdr1.id;
        insert sl1;    

        BDR_service_link__c sl2 = new BDR_Service_Link__c();
        sl2.service__c = svc2.id;
        sl2.bdr__c = bdr1.id;
        insert sl2;    
        /*END Service Links BDr1*/    

        /*Service Links BDr2*/    
        BDR_service_link__c sl21 = new BDR_Service_Link__c();
        sl21.service__c = svc1.id;
        sl21.bdr__c = bdr2.id;
        insert sl21;    

        BDR_service_link__c sl22 = new BDR_Service_Link__c();
        sl22.service__c = svc2.id;
        sl22.bdr__c = bdr2.id;
        insert sl22;    
        /*Service Links BDr2*/    

        
        Funding_Requirement__c fr1 = new Funding_Requirement__c();
        fr1.service__c = svc1.id;
        fr1.Total_Amount__c = 1000;
        fr1.Actual_FCR__c=100;
        fr1.fiscal_year__c='2012/13';
        insert fr1;

        Funding_Requirement__c fr2 = new Funding_Requirement__c();
        fr2.service__c = svc1.id;
        fr2.Total_Amount__c = 1000;
        fr2.Actual_FCR__c=100;
        fr2.fiscal_year__c='2013/14';
        insert fr2;

        Funding_Requirement__c fr21 = new Funding_Requirement__c();
        fr21.service__c = svc2.id;
        fr21.Total_Amount__c = 1000;
        fr21.Actual_FCR__c=100;
        fr21.fiscal_year__c='2012/13';
        insert fr21;

        Funding_Requirement__c fr22 = new Funding_Requirement__c();
        fr22.service__c = svc2.id;
        fr22.Total_Amount__c = 1000;
        fr22.Actual_FCR__c=100;
        fr22.fiscal_year__c='2013/14';
        insert fr22;

        Evidence_For_Need__c efn1 = new Evidence_For_Need__c();
        efn1.service__c = svc1.id;
        efn1.isCurrent__c=true;
        insert efn1;
        
        Evidence_For_Need__c efn2 = new Evidence_For_Need__c();
        efn2.service__c = svc2.id;
        efn1.isCurrent__c=true;
        insert efn2;

        /*income block 1*/
        Income_Block__c ib1 = new Income_Block__c();
        ib1.bdr__c=bdr1.id;
        insert ib1;
        
        Income_Block_Period__c ibp1 = new Income_Block_Period__c();
        ibp1.Income_Block__c = ib1.id;
        ibp1.fiscal_year__c = '2012/13';
        ibp1.total_amount__c = 2000;
        insert ibp1; 

        Income_Block_Period__c ibp2 = new Income_Block_Period__c();
        ibp2.Income_Block__c = ib1.id;
        ibp2.fiscal_year__c = '2013/14';
        ibp2.total_amount__c = 2000;
        insert ibp2; 

        Fund_Allocation__c fa1= new Fund_Allocation__c();
        fa1.funding_requirement__c = fr1.id;
        fa1.income_block_period__c = ibp1.id;
        fa1.Allocation_amount__c = 500;
        fa1.status__c='Draft';
        insert fa1;
        
        Fund_Allocation__c fa2= new Fund_Allocation__c();
        fa2.funding_requirement__c = fr2.id;
        fa2.income_block_period__c = ibp2.id;
        fa2.Allocation_amount__c = 500;
        fa2.status__c='Draft';
        insert fa2;

        Fund_Allocation__c fa3= new Fund_Allocation__c();
        fa3.funding_requirement__c = fr21.id;
        fa3.income_block_period__c = ibp2.id;
        fa3.Allocation_amount__c = 500;
        fa3.status__c='Draft';
        insert fa3;
        
        Fund_Allocation__c fa4= new Fund_Allocation__c();
        fa4.funding_requirement__c = fr22.id;
        fa4.income_block_period__c = ibp2.id;
        fa4.Allocation_amount__c = 500;
        fa4.status__c='Draft';
        insert fa4;


        /*END income block 1*/

        /*income block 2*/
        Income_Block__c ib2 = new Income_Block__c();
        ib2.bdr__c=bdr2.id;
        insert ib2;
        
        Income_Block_Period__c ibp21 = new Income_Block_Period__c();
        ibp21.Income_Block__c = ib2.id;
        ibp21.fiscal_year__c = '2012/13';
        ibp21.total_amount__c = 1500;
        insert ibp21; 

        Income_Block_Period__c ibp22 = new Income_Block_Period__c();
        ibp22.Income_Block__c = ib2.id;
        ibp22.fiscal_year__c = '2013/14';
        ibp22.total_amount__c = 1500;
        insert ibp22; 

        Fund_Allocation__c fa21= new Fund_Allocation__c();
        fa21.funding_requirement__c = fr1.id;
        fa21.income_block_period__c = ibp21.id;
        fa21.Allocation_amount__c = 500;
        fa21.status__c='Draft';
        insert fa21;
        
        Fund_Allocation__c fa22= new Fund_Allocation__c();
        fa22.funding_requirement__c = fr2.id;
        fa22.income_block_period__c = ibp22.id;
        fa22.Allocation_amount__c = 500;
        fa22.status__c='Draft';
        insert fa22;

        Fund_Allocation__c fa23= new Fund_Allocation__c();
        fa23.funding_requirement__c = fr21.id;
        fa23.income_block_period__c = ibp22.id;
        fa23.Allocation_amount__c = 500;
        fa23.status__c='Draft';
        insert fa23;


        Fund_Allocation__c fa24= new Fund_Allocation__c();
        fa24.funding_requirement__c = fr22.id;
        fa24.income_block_period__c = ibp22.id;
        fa24.Allocation_amount__c = 500;
        fa24.status__c='Draft';
        insert fa24;

        /*END income block 1*/

        /*Contract */
                
        ConfigText__c cfgR = new ConfigText__c();
        cfgR.isCurrent__c=true;
        cfgR.Release_Date__c=Date.today();
        cfgR.version__c=1;
        cfgR.Type__c='BDR: Contract Risk Index';
        insert cfgR;

        Map<String,ConfigText__c> mapCfg = new Map<String,ConfigText__c>();
        mapCfg.put('cfgR',cfgR);
        

        BD_Contract__c contract = new BD_Contract__c();
        contract.bdr__c = bdr1.id;
        contract.Risk_Index_Version__c = cfgR.id;
        contract.status__c='Draft';
        contract.start_date__c=Date.Today();
        contract.end_date__c=Date.Today().addMonths(12);
        insert contract;

        BdrServiceWrapperList swl = new BdrServiceWrapperList(bdr1.id);    

        List<Services__c> lis = new List<Services__c>();
        lis.add(svc1);
        lis.add(svc2);
        
        List<String> lisFiscal = new List<String>();
        lisFiscal.add('2012/13');
        lisFiscal.add('2013/14');        
        BdrServiceWrapperList swl2 = new BdrServiceWrapperList(lis,lisFiscal);    
     
     
        /*Put everything in a map, so this data set can be called from other test methods 
          the map is a map of String,Object, so extraction requires a cast to the correct class 
          before the object can be used. It's mostly nested maps of other objects */    
     
        Map<String,BdrServiceWrapperList> mapSwl = new Map<String,BdrServiceWrapperList>();
        mapSwl.put('swl1',swl);
        mapSwl.put('swl2',swl2); 
        
        /* Get the BDR from the database so that the instance represents the BDR post Trigger run */
        bdr1 = (BDR__c)CustomUtils.objectWithAllFields('id', bdr1.id, Schema.sObjectType.BDR__c);
        bdr2 = (BDR__c)CustomUtils.objectWithAllFields('id', bdr2.id, Schema.sObjectType.BDR__c);
        bdr3 = (BDR__c)CustomUtils.objectWithAllFields('id', bdr3.id, Schema.sObjectType.BDR__c);
        System.debug('Test bdr1 Fiscal Years: '+ bdr1.Fiscal_Years__c);
        
        Map<String,BDR__c> mapBdr = new Map<String, BDR__c>();
        mapBdr.put('bdr1',bdr1);
        mapBdr.put('bdr2',bdr1);
        mapBdr.put('bdr3',bdr1);
            
        /* Don't compute the bdrWrappers because the SOQL query limit will be exceeded
           Init them in the methods if required 
        */   

        //BdrWrapper bdrW1 = new BdrWrapper(bdr1);
        //BdrWrapper bdrW2 = new BdrWrapper(bdr2);    
        //BdrWrapper bdrW3 = new BdrWrapper(bdr3);    
        
        //Map<String,BdrWrapper> mapBdrW = new Map<String, BdrWrapper>();
        //mapBdrW.put('bdrW1',bdrW1);
        //mapBdr.put('bdrW2',bdrW2);    
        //mapBdr.put('bdrW3',bdrW3);    
        
        Map<String,User> mapUser = new Map<String, User>();    
        mapUser.put('userBDM', userBDM);
        mapUser.put('userAM', userAM);    

        Map<String, Object> mapMisc = new Map<String,Object>();    
        mapMisc.put('swl',mapSwl);
        //mapMisc.put('bdrW',mapBdrW); 
        mapMisc.put('bdr',mapBdr);
        mapMisc.put('cfg', mapCfg);
        mapMisc.put('users',mapUser);
        
        return mapMisc;
        
        }
    
}