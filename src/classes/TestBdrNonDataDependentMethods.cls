/**
 * @author      gary.grant@conseq.co.uk
   @date        June 2014
   @description Test methods for BDR that not dependent on generating data          
 */
@isTest
private class TestBdrNonDataDependentMethods {

static testMethod void FiscalYearComputation()
{
    DateTime sdt = DateTime.newInstance(2013,3,31);
    DateTime edt = DateTime.newInstance(2016,7,30);

    List<String> lisFiscalYears = BdrUtils.computeFiscalYears(sdt,edt);
    system.debug('Size = ' + lisFiscalYears.size());

    for(String s : lisFiscalYears) {
        system.debug(s);
    }
    
    System.Assert(lisFiscalYears.size()==5);
    System.Assert(lisFiscalYears[0]=='2012/13');
    System.Assert(lisFiscalYears[3]=='2015/16');
    System.Assert(lisFiscalYears[4]=='2016/17');
    
}

static testMethod void FiscalSplitComputation()
{
    Date sdt = Date.newInstance(2013,3,1);
    Date edt = Date.newInstance(2017,2,28);

    Map<String, Integer> mapFiscalSplit = BdrUtils.computeFiscalSplit(sdt, edt, 48000);
    system.debug('Size = ' + mapFiscalSplit.keySet().size());

    List<String> lisKeys = new List<String>();
    for(String s : mapFiscalSplit.keySet()) {
        system.debug('key=' + s);
        system.debug('value=' + mapFiscalSplit.get(s));
        lisKeys.add(s);        
    }
    
    
    lisKeys.sort();
    System.Assert(lisKeys.size()==5);
    System.Assert(lisKeys[0]=='2012/13');
    System.Assert(lisKeys[3]=='2015/16');
    System.Assert(lisKeys[4]=='2016/17');
    
    System.Assert(mapFiscalSplit.get('2012/13')==1000);
    System.Assert(mapFiscalSplit.get('2015/16')==12000);
    System.Assert(mapFiscalSplit.get('2016/17')==11000);
    
    system.debug('Start Date Test 2');
    
    
    //Test 2
    
    sdt = Date.newInstance(2013,7,1);
    edt = Date.newInstance(2017,6,30);

    mapFiscalSplit = BdrUtils.computeFiscalSplit(sdt, edt, 48000);
    system.debug('Size = ' + mapFiscalSplit.keySet().size());

    lisKeys = new List<String>();
    for(String s : mapFiscalSplit.keySet()) {
        system.debug('key=' + s);
        system.debug('value=' + mapFiscalSplit.get(s));
        lisKeys.add(s);        
    }
    
    
    lisKeys.sort();
    System.Assert(lisKeys.size()==5);
    System.Assert(lisKeys[0]=='2013/14');
    System.Assert(lisKeys[2]=='2015/16');
    System.Assert(lisKeys[4]=='2017/18');
    
    System.Assert(mapFiscalSplit.get('2013/14')==9000);
    System.Assert(mapFiscalSplit.get('2015/16')==12000);
    System.Assert(mapFiscalSplit.get('2017/18')==3000);
    
    
    system.debug('Start Date Test 3');
    
    //Test 3
    
    sdt = Date.newInstance(2013,4,1);
    edt = Date.newInstance(2017,3,31);

    mapFiscalSplit = BdrUtils.computeFiscalSplit(sdt, edt, 48000);
    system.debug('Size = ' + mapFiscalSplit.keySet().size());

    lisKeys = new List<String>();
    for(String s : mapFiscalSplit.keySet()) {
        system.debug('key=' + s);
        system.debug('value=' + mapFiscalSplit.get(s));
        lisKeys.add(s);        
    }
    
    
    lisKeys.sort();
    System.Assert(lisKeys.size()==4);
    System.Assert(lisKeys[0]=='2013/14');
    System.Assert(lisKeys[2]=='2015/16');
    System.Assert(lisKeys[3]=='2016/17');
    
    System.Assert(mapFiscalSplit.get('2013/14')==12000);
    System.Assert(mapFiscalSplit.get('2015/16')==12000);
    System.Assert(mapFiscalSplit.get('2016/17')==12000);

system.debug('Start Date Test 4');

    //Test 4
    
    sdt = Date.newInstance(2013,3,15);
    edt = Date.newInstance(2017,3,14);

    mapFiscalSplit = BdrUtils.computeFiscalSplit(sdt, edt, 48000);
    system.debug('Size = ' + mapFiscalSplit.keySet().size());

    lisKeys = new List<String>();
    for(String s : mapFiscalSplit.keySet()) {
        system.debug('key=' + s);
        system.debug('value=' + mapFiscalSplit.get(s));
        lisKeys.add(s);        
    }
    
    
    lisKeys.sort();
    System.Assert(lisKeys.size()==5);
    System.Assert(lisKeys[0]=='2012/13');
    System.Assert(lisKeys[2]=='2014/15');
    System.Assert(lisKeys[4]=='2016/17');
    
    System.Assert(mapFiscalSplit.get('2012/13')==1000);
    System.Assert(mapFiscalSplit.get('2015/16')==12000);
    System.Assert(mapFiscalSplit.get('2016/17')==11000);

    
    system.debug('Start Date Test 5');
    
    //Test 5
    
    sdt = Date.newInstance(2015,6,12);
    edt = Date.newInstance(2016,6,11);

    mapFiscalSplit = BdrUtils.computeFiscalSplit(sdt, edt, 12000);
    system.debug('Size = ' + mapFiscalSplit.keySet().size());

    lisKeys = new List<String>();
    for(String s : mapFiscalSplit.keySet()) {
        system.debug('key=' + s);
        system.debug('value=' + mapFiscalSplit.get(s));
        lisKeys.add(s);        
    }
    
    
    lisKeys.sort();
    System.Assert(lisKeys.size()==2);
    System.Assert(lisKeys[0]=='2015/16');
    System.Assert(lisKeys[1]=='2016/17');
    
    System.Assert(mapFiscalSplit.get('2015/16')==10000);
    System.Assert(mapFiscalSplit.get('2016/17')==2000);
    
}


}