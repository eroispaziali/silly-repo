<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>BdrUniqueServiceLink</fullName>
        <field>uniqueServiceLink__c</field>
        <formula>CASESAFEID(BDR__r.Id)  +  &apos;.&apos; + CASESAFEID(Service__r.Id)</formula>
        <name>BdrUniqueServiceLink</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>BdrUniqueServiceLink</fullName>
        <actions>
            <name>BdrUniqueServiceLink</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>ensure the same service cannot be added to the same BDR twice</description>
        <formula>BLANKVALUE( Service__c ,&apos;Y&apos;)&lt;&gt;&apos;Y&apos; &amp;&amp; BLANKVALUE( BDR__c ,&apos;Y&apos;)&lt;&gt;&apos;Y&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
