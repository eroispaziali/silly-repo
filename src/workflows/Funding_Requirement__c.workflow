<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>BdrUniqueFiscalService</fullName>
        <description>Set the value of concatinated Fiscal Year and Service__c into the record. This field is unique, so an error will be thrown if two records with the same value are created</description>
        <field>uniqueFiscalService__c</field>
        <formula>Text(Fiscal_Year__c ) + &quot;:&quot; + CASESAFEID(Service__c)</formula>
        <name>BdrUniqueFiscalService</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>BdrUniqueFiscalFundingReq</fullName>
        <actions>
            <name>BdrUniqueFiscalService</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Compute the value of uniqueFiscalYear into the record. This field is unique, ensuring no duplicate values are entered.</description>
        <formula>BLANKVALUE(Service__c,&apos;Y&apos;)&lt;&gt;&apos;Y&apos; &amp;&amp;   !(ISPICKVAL(Fiscal_Year__c, &apos;&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
