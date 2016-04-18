<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>DF_Event_Status</fullName>
        <field>Event_Status__c</field>
        <literalValue>Closed</literalValue>
        <name>DF Event Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>DF Event Status</fullName>
        <actions>
            <name>DF_Event_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Status is set to Closed, if Event is in past</description>
        <formula>DATEVALUE( Event_Date_Time__c ) &lt;  TODAY()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
