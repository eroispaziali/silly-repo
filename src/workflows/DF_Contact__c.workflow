<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Attended_False</fullName>
        <field>Attended__c</field>
        <literalValue>0</literalValue>
        <name>Attended False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contacted_False</fullName>
        <field>Contacted__c</field>
        <literalValue>0</literalValue>
        <name>Contacted False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DF_Contact_Status</fullName>
        <field>Status__c</field>
        <literalValue>Converted</literalValue>
        <name>DF Contact Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DF_Status_RT_Change</fullName>
        <field>Status__c</field>
        <literalValue>Prospective</literalValue>
        <name>DF Status RT Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Eligible_False</fullName>
        <field>Eligible__c</field>
        <literalValue>0</literalValue>
        <name>Eligible False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Session_Code_Verified_False</fullName>
        <field>Session_Code_Verified__c</field>
        <literalValue>0</literalValue>
        <name>Session Code Verified False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>DF Code Verfied</fullName>
        <actions>
            <name>DF_Contact_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>DF_Contact__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Dementia Friend</value>
        </criteriaItems>
        <criteriaItems>
            <field>DF_Contact__c.Session_Code_Verified__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>For DF if the code is verified then update the status field to be converted</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DF Contact Recordtype</fullName>
        <actions>
            <name>Attended_False</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Contacted_False</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>DF_Status_RT_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Eligible_False</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Session_Code_Verified_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the record type of the DF Contact is changed, set Attended,eligible, Sessioncode verfied and contacted to untick/false and Status to Prospective</description>
        <formula>ISCHANGED( RecordTypeId )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
