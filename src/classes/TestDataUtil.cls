/**
* File Name   :    TestDataUtil.cls
* Description :    PEN-131
*                  must have be able to select Brand, Label, Language, Product, Country for Site Catalogue
*
* Modification Log
* ============================================================================
* Ver Date       Author         Modification
* --- ---------- -------------- --------------------------
* 0.1 05/03/2014 Klea Kolaric   Initial version
* 0.2 12/03/2014 Chris Yorkston Added new functions getRandomNumber() and getRandomString()
* 0.3 25/03/2014 Chris Yorkston Added new functions getUser() and createUser()
*
*
*/

@isTest
public with sharing class TestDataUtil {

    public static final String RANDOM_CHARS             = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    public static final String ALPHA_CHARS              = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    public static final String RANDOM_ALL               = '35';
    public static final String RANDOM_ALPHA             = '25';

    public static Id personAccountRTId = [select id from RecordType where SobjectType = 'Account' AND IsPersonType = true limit 1].id;

    /*** individual data creation methods ***/

    public static Account createPersonAccount()
    {
        Account acc = new Account();
        acc.FirstName = 'testName';
        acc.LastName = 'testSurname';
        acc.RecordtypeId = TestDataUtil.personAccountRTId;
        return acc;
    }

    public static CW_Campaign__c createCampaign()
    {
        CW_Campaign__c camp = new CW_Campaign__c();
        camp.Name = 'TestCampaign';
        camp.Campaign_Start_Date__c = Date.today().addDays(1);
        camp.Campaign_End_Date__c = camp.Campaign_Start_Date__c.addMonths(3);
        camp.Estimated_Cost__c = 2000;
        return camp;
    }

    public static CW_Campaign__c getCampaign()
    {
        CW_Campaign__c camp = new CW_Campaign__c();
        camp.Name = getRandomAlphaString(10);
        Date d = Date.today();
        camp.Campaign_Start_Date__c = d.addDays(1);
        camp.Campaign_End_Date__c = d.addMonths(3);
        camp.Estimated_Cost__c = getRandomNumber();
        return camp;
    }

    public static List<CW_Campaign__c> getCampaigns(Integer numberOfCampaigns)
    {
        List<CW_Campaign__c> camps = new List<CW_Campaign__c>();
        for (Integer i=0;i<numberOfCampaigns;i++) {
            CW_Campaign__c c = getCampaign();
            camps.add(c);
        }
        return camps;
    }

    public static CW_Brand__c createBrand()
    {
        CW_Brand__c brand = new CW_Brand__c();
        brand.Name = 'BWin';
        brand.Is_Active__c = true;
        return brand;
    }

    public static List<CW_Brand__c> getBrands(Integer numberOfBrands)
    {
        List<CW_Brand__c> brands = new List<CW_Brand__c>();
        for (Integer i=0;i<numberOfBrands;i++) {
            CW_Brand__c brand = new CW_Brand__c();
            brand.Name = getRandomAlphaString(10);
            brand.Is_Active__c = true;
            brands.add(brand);
        }
        return brands;
    }

    public static CW_Label__c createLabel(Id brandId)
    {
        CW_Label__c lab = new CW_Label__c();
        lab.Name = 'bwin.com';
        lab.Code__c = 'bwcom';
        lab.Brand__c = brandId;
        lab.Is_Active__c = true;
        return lab;
    }

    public static List<CW_Label__c> getLabels(List<CW_Brand__c> brands)
    {
        List<CW_Label__c> labels = new List<CW_Label__c>();
        for (CW_Brand__c b :brands) {
            CW_Label__c label = new CW_Label__c();
            label.Name = getRandomAlphaString(5);
            label.Code__c = getRandomAlphaString(5);
            label.Brand__c = b.Id;
            label.Is_Active__c = true;
            labels.add(label);
        }
        return labels;
    }

    public static CW_Country__c createCountry()
    {
        CW_Country__c cntry = new CW_Country__c();
        cntry.Name = 'United Kingdom';
        cntry.Is_Active__c = true;
        return cntry;
    }

    public static List<CW_Country__c> getCountries(Integer numberOfCountries)
    {
        List<CW_Country__c> countries = new List<CW_Country__c>();
        for (Integer i=0;i<numberOfCountries;i++) {
            CW_Country__c country = new CW_Country__c();
            country.Name = getRandomAlphaString(10);
            country.Is_Active__c = true;
            countries.add(country);
        }
        return countries;
    }

    public static CW_Language__c createLanguage()
    {
        CW_Language__c lang = new CW_Language__c();
        lang.Name = 'EN';
        lang.Code__c = lang.Name;
        lang.Is_Active__c = true;
        return lang;
    }

    public static CW_Language__c getLanguage(String langName)
    {
        CW_Language__c lang = new CW_Language__c();
        lang.Name = langName;
        lang.Code__c = lang.Name;
        lang.Is_Active__c = true;
        return lang;
    }

    public static List<CW_Language__c> getLanguages(Integer numberOfLanguages)
    {
        List<CW_Language__c> languages = new List<CW_Language__c>();
        for (Integer i=0;i<numberOfLanguages;i++) {
            CW_Language__c language = new CW_Language__c();
            language.Name = getRandomAlphaString(10);
            language.Code__c = getRandomAlphaString(5);
            language.Is_Active__c = true;
            languages.add(language);
        }
        return languages;
    }

    public static CW_Product__c createProduct()
    {
        CW_Product__c prod = new CW_Product__c();
        prod.Name = 'Sports';
        prod.Code__c = 'SPO';
        prod.Is_Active__c = true;
        return prod;
    }

    public static List<CW_Product__c> getProducts(Integer numberOfProducts)
    {
        List<CW_Product__c> products = new List<CW_Product__c>();
        for (Integer i=0;i<numberOfProducts;i++) {
            CW_Product__c product = new CW_Product__c();
            product.Name = getRandomAlphaString(10);
            product.Code__c = getRandomAlphaString(5);
            product.Is_Active__c = true;
            products.add(product);
        }
        return products;
    }

    public static CW_Site_Catalogue__c createSiteCatalogue(Id labelId, Id countryId, Id productId)
    {
        CW_Site_Catalogue__c sc = new CW_Site_Catalogue__c();
        sc.Country__c = countryId;
        sc.Label__c = labelId;
        sc.Product__c = productId;
        sc.Is_Active__c = true;
        return sc;
    }

    public static List<CW_Site_Catalogue__c> getSiteCatalogues(
        List<CW_Label__c> labels,
        List<CW_Country__c> countries,
        List<CW_Product__c> products
    ) {
        List<CW_Site_Catalogue__c> siteCats = new List<CW_Site_Catalogue__c>();
        for (Integer i=0;i<labels.size();i++) {
            CW_Site_Catalogue__c sc = new CW_Site_Catalogue__c();
            sc.Country__c = countries[i].Id;
            sc.Label__c = labels[i].Id;
            sc.Product__c = products[i].Id;
            sc.Is_Active__c = true;
            siteCats.add(sc);
        }
        return siteCats;
    }

    public static CW_Site_Language__c createSiteLanguage(Id siteCatalogueId, Id languageId)
    {
        CW_Site_Language__c sl = new CW_Site_Language__c();
        sl.Site_Catalogue__c = siteCatalogueId;
        sl.Language__c = languageId;
        return sl;
    }

    public static CW_Campaign_Sites__c createCampaignSites(Id campaignId, Id siteCatalogueId, Id languageId)
    {
        CW_Campaign_Sites__c cs = new CW_Campaign_Sites__c();
        cs.Campaign__c = campaignId;
        cs.Site_Catalogue__c = siteCatalogueId;
        cs.Language__c = languageId;
        return cs;
    }

    public static List<CW_Campaign_Sites__c> getCampaignSites(
        Id campaignId,
        List<CW_Site_Catalogue__c> siteCats,
        List<CW_Language__c> languages
    ) {
        List<CW_Campaign_Sites__c> campSiteList = new List<CW_Campaign_Sites__c>();
        for (Integer i=0;i<siteCats.size();i++) {
            CW_Campaign_Sites__c cs = new CW_Campaign_Sites__c();
            cs.Campaign__c = campaignId;
            cs.Site_Catalogue__c = siteCats[i].Id;
            cs.Language__c = languages[i].Id;
            campSiteList.add(cs);
        }
        return campSiteList;
    }

    public static CW_Asset_Type__c createAssetType()
    {
        CW_Asset_Type__c assetType = new CW_Asset_Type__c();
        assetType.Name = 'Mailer';
        return assetType;
    }

    public static CW_Asset__c createAsset(Id assetTypeId)
    {
        CW_Asset__c asst = new CW_Asset__c();
        asst.Name = 'Mailer Basic';
        asst.Asset_Type__c = assetTypeId;
        return asst;
    }

    public static CW_Campaign_Asset_Type__c createCampaignAssetType(Id assetTypeId, Id campaignId)
    {
        CW_Campaign_Asset_Type__c campAT = new CW_Campaign_Asset_Type__c();
        campAT.Campaign__c = campaignId;
        campAT.Asset_Type__c = assetTypeId;
        return campAT;
    }

    public static CW_Asset_Catalogue__c createAssetCatalogue(Id siteCatId, Id assetId)
    {
        CW_Asset_Catalogue__c assetCat = new CW_Asset_Catalogue__c();
        assetCat.Site_Catalogue__c = siteCatId;
        assetCat.Asset__c = assetId;
        return assetCat;
    }

    public static CW_Audience_Group__c createAudienceGroup(Id campaignId)
    {
        CW_Audience_Group__c audienceGroup = new CW_Audience_Group__c();
        audienceGroup.Name = 'Audience Group';
        audienceGroup.Campaign__c = campaignId;
        return audienceGroup;
    }

    public static CW_Audience_Group__c getAudienceGroup(Id campaignId)
    {
        CW_Audience_Group__c audienceGroup = new CW_Audience_Group__c();
        audienceGroup.Name = getRandomAlphaString(10);
        audienceGroup.Campaign__c = campaignId;
        return audienceGroup;
    }

    public static  List<CW_Audience_Group__c> createAudienceGroups(Id campId,Integer noOfGroups,Boolean IsCtrlGrp,String  GrpName){
        List<CW_Audience_Group__c> listGroups = new List<CW_Audience_Group__c>();
        for (Integer i=1;i<=noOfGroups;i++)
        {
            CW_Audience_Group__c aGroup = new CW_Audience_Group__c();
            aGroup.Name = GrpName+i;
            aGroup.Campaign__c = campId;
            aGroup.Description__c = 'Test '+i;
            aGroup.Is_Control_Group__c = IsCtrlGrp;
            listGroups.add(aGroup);
        }
        return listGroups;
    }

    public static List<CW_Audience_Group__c> createAudienceGroups(Id campId,Integer noOfGroups)
    {
        return createAudienceGroups(campId,noOfGroups,true,'Audience Group no ');
    }

    public static List<CW_Audience_Group__c> getAudienceGroups(List<CW_Campaign__c> campaigns)
    {
        List<CW_Audience_Group__c> audienceGroups = new List<CW_Audience_Group__c>();
        for (CW_Campaign__c c :campaigns) {
            audienceGroups.add( getAudienceGroup(c.Id) );
        }
        return audienceGroups;
    }

    public static CW_Schedule__c createSchedule(CW_Campaign__c camp)
    {
        CW_Schedule__c sche = new CW_Schedule__c();
        sche.Marketing_Campaign__c = camp.Id;
        sche.Start_Date__c = camp.Campaign_Start_Date__c;
        sche.End_Date__c = camp.Campaign_End_Date__c;
        sche.Evaluation_Start_Date__c = sche.Start_Date__c;
        sche.Evaluation_End_Date__c = sche.End_Date__c+60;
        return sche;
    }

    public static CW_Schedule__c getSchedule(Id campaignId, Date d) {
        CW_Schedule__c s = new CW_Schedule__c();
        s.Marketing_Campaign__c = campaignId;
        s.Start_Date__c = d;
        s.Evaluation_Start_Date__c = s.Start_Date__c;
        s.End_Date__c = d.addDays(2);
        s.Evaluation_End_Date__c = s.End_Date__c;
        return s;
    }

    public static List<CW_Schedule__c> getSchedules(Id campaignId, Integer numberOfSchedules) {
        List<CW_Schedule__c> schedules = new List<CW_Schedule__c>();
        for (Integer i=0; i<numberOfSchedules; i++) {
            CW_Schedule__c s = getSchedule(campaignId, Date.today().addDays(1));
            schedules.add(s);
        }
        return schedules;
    }

    public static CW_Audience_Group_Schedule__c createAudienceGroupSchedule(Id groupId, Id scheduleId)
    {
        CW_Audience_Group_Schedule__c ags = new CW_Audience_Group_Schedule__c();
        ags.Audience_Group__c = groupId;
        ags.Schedule__c = scheduleId;
        return ags;
    }

    public static CW_Roadmap__c createRoadmap()
    {
        CW_Roadmap__c roadmap = new CW_Roadmap__c();
        roadmap.Name = 'New Roadmap';
        roadmap.Start_Date__c = Date.today().addDays(1);
        roadmap.End_Date__c = Date.today().addDays(15);
        return roadmap;
    }

    public static CW_Roadmap__c getRoadmap()
    {
        CW_Roadmap__c roadmap = new CW_Roadmap__c();
        roadmap.Name = getRandomAlphaString(10);
        roadmap.Start_Date__c = Date.today().addDays(1);
        roadmap.End_Date__c = Date.today().addDays(15);
        return roadmap;
    }

    public static Group createGroup(String groupName)
    {
        Group newGroup = new Group();
        newGroup.Name = groupName;
        return newGroup;
    }

    public static GroupMember createGroupMember(Id groupId, Id userId)
    {
        GroupMember newGroupMember = new GroupMember();
        newGroupMember.GroupId = groupId;
        newGroupMember.UserOrGroupId = userId;
        return newGroupMember;
    }

    public static CW_Campaign_Sites__c createCampaignSite(Id campId, Id siteCatalogueId, Id languageId)
    {
        CW_Campaign_Sites__c campSite = new CW_Campaign_Sites__c();
        campSite.Campaign__c = campId;
        campSite.Language__c = languageId;
        campSite.Site_Catalogue__c = siteCatalogueId;
        return campSite;
    }

    public static CW_Campaign_Navigation_Settings__c createCampaignNavigationSettings(Pagereference pg, Integer ind, Boolean cimAccess)
    {
        CW_Campaign_Navigation_Settings__c cnv = new CW_Campaign_Navigation_Settings__c();
        cnv.Page_Name__c = StringUtil.standardisePageName(pg.getUrl().split('apex/').get(1));
        cnv.Order__c = ind;

        // create name following naming convention
        List<String> strList =
            cnv.Page_Name__c.replace(ConstantUtil.CW_PREFIX + ConstantUtil.CW_PAGE_DELIMITER,'').split(ConstantUtil.CW_PAGE_DELIMITER);
        cnv.Name = String.join(strList,' ');
        cnv.Field_Set__c = String.join(strList,ConstantUtil.CW_PAGE_DELIMITER);
        cnv.accessibleByCIMorBI__c = cimAccess;

        return cnv;
    }

    public static List<CW_Campaign_Navigation_Settings__c> getCampaignNavigationSettings(List<Pagereference> pageReferences) {
        List<CW_Campaign_Navigation_Settings__c> campaignNavigationSettings = new List<CW_Campaign_Navigation_Settings__c>();
        for (Integer i=0;i<pageReferences.size();i++) {
            CW_Campaign_Navigation_Settings__c navigationItem = new CW_Campaign_Navigation_Settings__c();
            navigationItem.Page_Name__c = StringUtil.standardisePageName(pageReferences[i].getUrl().split('apex/').get(1));
            navigationItem.Order__c = i+1;

            // create name following naming convention
            List<String> strList =
                navigationItem.Page_Name__c.replace(ConstantUtil.CW_PREFIX + ConstantUtil.CW_PAGE_DELIMITER,'').split(ConstantUtil.CW_PAGE_DELIMITER);
            navigationItem.Name = String.join(strList,' ');
            navigationItem.Field_Set__c = String.join(strList,ConstantUtil.CW_PAGE_DELIMITER);
            if (math.mod(i, 2) == 0)
                navigationItem.accessibleByCIMorBI__c = true;
            else
                navigationItem.accessibleByCIMorBI__c = false;
            campaignNavigationSettings.add(navigationItem);
        }
        return campaignNavigationSettings;
    }

    public static CW_Offer_Type__c createOfferType(String offerTypeName)
    {
        CW_Offer_Type__c newOfferType = new CW_Offer_Type__c();
        newOfferType.Name = offerTypeName;
        return newOfferType;
    }

    public static CW_Reward_Type__c createRewardType(String rewardTypeName)
    {
        CW_Reward_Type__c newRewardType = new CW_Reward_Type__c();
        newRewardType.Name = rewardTypeName;
        return newRewardType;
    }

    public static CW_Reward_Catalogue__c createRewardCatalogue(Id offerTypeId, Id rewardTypeId)
    {
        CW_Reward_Catalogue__c rewardCat = new CW_Reward_Catalogue__c();
        rewardCat.Name = 'test';
        rewardCat.Offer_Type__c = offerTypeId;
        rewardCat.Reward_Type__c = rewardTypeId;
        return rewardCat;
    }

    public static CW_Reward_Library__c createRewardLibrary(Id rewardTypeId){
        CW_Reward_Library__c library = new CW_Reward_Library__c();
        library.Currency__c='EURO';
        library.Reward_Type__c = rewardTypeId;
        return library;
    }

   public static CW_Campaign_Reward__c createCampaignReward(Id campOfferId,Id CatalogId, Id LibraryId,Id rewardTypeId){
        CW_Campaign_Reward__c reward= new CW_Campaign_Reward__c();
        reward.Bonus_ID__c='123456';
        reward.Reward_Catalogue__c = CatalogId;
        reward.Campaign_Offer__c = campOfferId;
        reward.Reward_Library__c = LibraryId;
        reward.Reward_Type__c = rewardTypeId;
        return reward;
    }
    
    public static CW_Campaign_Offer__c createCampaignOffer(Id campId,Id offerTypeId)
    {
    	CW_Campaign_Offer__c campOffer = new CW_Campaign_Offer__c();
    	campOffer.Campaign__c = campId;
    	campOffer.Offer_Type__c = offerTypeId;
    	return campOffer;
    }
    
     public static CW_Task__c createTask(Id campaignId, Id queueId, Id requestorId)
     {
     	CW_Task__c task = new CW_Task__c();
     	task.Name = 'Test' + (Integer)TestDataUtil.getRandomNumber();
     	task.Details__c = TestDataUtil.getRandomAlphaString(10);
     	task.Status__c = 'Not Started';
     	task.Category__c = 'BI';
     	task.Due_Date__c = Date.today() + (Integer)TestDataUtil.getRandomNumber(); 
     	task.OwnerId = queueId;
     	task.Requestor__c = requestorId;
     	task.Marketing_Campaign__c = campaignId;
     	return task;
     }


    // it might be better for CW_WizardBrandLabelUtilTest.dataSetup() to be moved to this class (possible TO DO)
    // create whole set of data needed for site catalogue functionality
    public static void completeSiteCatalogueDataCreation()
    {
        CW_WizardBrandLabelUtilTest.dataSetup();
    }

    // it might be better for CW_WizardAssetUtilTest.dataSetup() to be moved to this class (possible TO DO)
    // create whole set of data needed for asset catalogue functionality
    public static void completeAssetCatalogueDataCreation()
    {
        CW_WizardBrandLabelUtilTest.dataSetup();
        CW_WizardAssetUtilTest.dataSetup();
    }


    public static Double getRandomNumber() {
        return Math.round(Math.random() * 101) - 1;
    }

    public static String getRandomAlphaString(Integer len) { return getRandomString(len, RANDOM_ALPHA); }
    public static String getRandomString(Integer len) { return getRandomString(len, RANDOM_ALL); }
    public static String getRandomString(Integer len, String mode)
    {
        String retVal = '';
        if (len != null && len >= 1)
        {
            Integer chars = 0;
            Integer random;
            do
            {
                random = Math.round(Math.random() * Integer.valueOf(mode));
                retVal += RANDOM_CHARS.substring(random, random + 1);
                chars++;
            } while (chars < len);
        }
        return retVal;
    }

    public static User getUser() {
        User u = new User();
        u.Alias = getRandomAlphaString(6);
        u.Email = u.Alias + '@' + 'testorg.com';
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LastName = u.Alias;
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'Europe/London';
        u.UserName = u.Email;

        return u;
    }

    public static UserRole getRole(String roleName)
    {
        UserRole ur = new UserRole();
        ur.Name = roleName;

        return ur;
    }

    public static UserRole createRole(String roleName)
    {
        UserRole ur = getRole(roleName);
        insert ur;

        return ur;
    }

    public static User getStandardUser() {
        User u = getUser();
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name='Standard User' limit 1];
        if (profiles!=null && !profiles.isEmpty()) {
            u.ProfileId = profiles[0].Id;
        } else {
            // unable to get user with standard user profile
            return null;
        }

    return u;
    }

    public static User getUserWithProfileName(String profileName) {
        User u = getUser();
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name=: profileName limit 1];
        if (profiles!=null && !profiles.isEmpty()) {
            u.ProfileId = profiles[0].Id;
        } else {
            // unable to get user with supplied profile name
            return null;
        }

        return u;
    }

    public static User createtUserWithProfileName(String profileName) {
        User u1 = getUserWithProfileName(profileName);

        insert u1;
        return u1;
    }

    public static User createStandardUser() {
        User u = getStandardUser();
        insert u;
        return u;
    }

    public static Boolean checkList(List<WrapperUtil.SelectWrapper> swList, String strName)
    {
        for(WrapperUtil.SelectWrapper sw : swList)
        {
            if(sw.optionName == strName)
            {
                sw.selected = !sw.selected;
                return sw.selected;
            }
        }
        return null;
    }

    public static Boolean checkMatrix(List<WrapperUtil.SelectListWrapper> lwMatrix, String rowName, String columnName)
    {
        for(WrapperUtil.SelectListWrapper lw : lwMatrix)
        {
            if(lw.showRow)
            {
                if(((String) lw.superObject.get('Name')) == rowName)
                {
                    for(WrapperUtil.SelectWrapper sw : lw.subObjects)
                    {
                        if(sw.optionName == columnName)
                        {
                            sw.selected = !sw.selected;
                            return sw.selected;
                        }
                    }
                }
            }
        }
        return null;
    }

    /*** static variables for testing ***/

    // countries
    public static final String UNITEDKINGDOM = 'United Kingdom';
    public static final String GERMANY = 'Germany';
    public static final String FRANCE = 'France';
    public static final String IRELAND = 'Ireland';
    public static final String NORWAY = 'Norway';
    public static final String SWEDEN = 'Sweden';

    public static List<String> getCountryList()
    {
        return new List<String>{UNITEDKINGDOM,GERMANY,FRANCE,IRELAND,NORWAY,SWEDEN};
    }

    // languages
    public static final String EN = 'EN';
    public static final String FR = 'FR';
    public static final String GA = 'GA';
    public static final String SV = 'SV';
    public static final String DE = 'DE';
    public static final String NW = 'NW';

    public static List<String> getLanguageList()
    {
        return new List<String>{EN,FR,GA,SV,DE,NW};
    }

    // products
    public static final String SPORTS = 'Sports';
    public static final String POKER = 'Poker';
    public static final String CASINO = 'Casino';

    public static List<String> getProductList()
    {
        return new List<String>{SPORTS,POKER,CASINO};
    }

    // brands
    public static final String BWINTEST = 'BWinTest';
    public static final String GOODSPORTSTEST = 'GoodsportTest';

    public static List<String> getBrandList()
    {
        return new List<String>{BWINTEST,GOODSPORTSTEST};
    }

    // label domains
    public static final String DOTCOM = '.com';
    public static final String DOTDE = '.de';
    public static final String DOTFR = '.fr';

    public static List<String> getLabelDomainsList()
    {
        return new List<String>{DOTCOM,DOTDE,DOTFR};
    }

    // asset types
    public static final String MAILER = 'Mailer';
    public static final String TEASER = 'Teaser';
    public static final String BANNER = 'Banner';

    public static List<String> getAssetTypeList()
    {
        return new List<String>{MAILER,TEASER,BANNER};
    }

    // assets - combine with asset types to create 6 permutations
    public static final String BASIC = 'Basic';
    public static final String ADVANCED = 'Advanced';

    public static List<String> getAssetExtensionList()
    {
        return new List<String>{BASIC,ADVANCED};
    }

    public static Group getGroup() {
        Group g = new Group();
        g.Name = getRandomAlphaString(6);
        g.Email = g.Name + '@test.com';
        return g;
    }

    public static Group createGroup() {
        Group g = getGroup();
        insert g;
        return g;
    }

    public static Group getQueue() {
        Group g = getGroup();
        g.Type = 'Queue';
        return g;
    }

    public static Group createQueue() {
        Group g = getQueue();
        insert g;
        return g;
    }

    public static GroupMember getGroupMember() {
        GroupMember gm = new GroupMember();
        return gm;
    }

    public static Contact getContact() {
        Contact c = new Contact();
        c.LastName = getRandomAlphaString(10);
        c.Lifetime_NGR__c = getRandomNumber();
        c.Lifetime_Wager__c = getRandomNumber();
        return c;
    }

    public static List<Contact> getContacts(Integer numberOfContacts) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i=0; i<numberOfContacts; i++) {
            Contact c = getContact();
            contacts.add(c);
        }
        return contacts;
    }

    public static CW_Audience_Group_Member__c getAudienceGroupMember() {
        CW_Audience_Group_Member__c agm = new CW_Audience_Group_Member__c();
        agm.Lifetime_NGR__c = 0;
        agm.Lifetime_Wager__c = 0;
        return agm;
    }

    public static List<CW_Audience_Group_Member__c> getAudienceGroupMembersWithGroupAndContacts(
        Id audienceGroupId,
        List<Contact> contacts
    ) {

        List<CW_Audience_Group_Member__c> members = new List<CW_Audience_Group_Member__c>();

        for (Contact c :contacts) {
            CW_Audience_Group_Member__c agm = new CW_Audience_Group_Member__c();
            agm.Contact__c = c.Id;
            agm.Audience_Group_LU__c = audienceGroupId;
            members.add(agm);
        }

        return members;
    }

}