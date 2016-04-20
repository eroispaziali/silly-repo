<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Lead_First_Name_Title_Case</fullName>
        <description>Update the first name so that the first letter is capitalized</description>
        <field>FirstName</field>
        <formula>UPPER(LEFT(FirstName,1))&amp;LOWER(Mid(FirstName, 2, Len(FirstName)-1))</formula>
        <name>Lead First Name Title Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead_Last_Name_Title_Case</fullName>
        <field>LastName</field>
        <formula>UPPER(LEFT(LastName,1))&amp;LOWER(Mid(LastName, 2, Len(LastName)-1))</formula>
        <name>Lead Last Name Title Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Lead First Name</fullName>
        <actions>
            <name>Lead_First_Name_Title_Case</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.FirstName</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Lead Last Name</fullName>
        <actions>
            <name>Lead_Last_Name_Title_Case</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.LastName</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
