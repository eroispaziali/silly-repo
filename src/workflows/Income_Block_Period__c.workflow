<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>BdrUniqueFiscalIncomeBlock</fullName>
        <field>uniqueFiscalPeriod__c</field>
        <formula>Text(Fiscal_Year__c ) + &quot;:&quot; + CASESAFEID(Income_Block__c)</formula>
        <name>BdrUniqueFiscalIncomeBlock</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>BdrUniqueFiscalIncomeBlock</fullName>
        <actions>
            <name>BdrUniqueFiscalIncomeBlock</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>BLANKVALUE( Income_Block__c ,&apos;Y&apos;)&lt;&gt;&apos;Y&apos; &amp;&amp;   !(ISPICKVAL(Fiscal_Year__c, &apos;&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
