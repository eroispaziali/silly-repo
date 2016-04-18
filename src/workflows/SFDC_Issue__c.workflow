<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Memory_Walk_Project_Issue_Notification</fullName>
        <description>Memory Walk Project Issue Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Memory_Walk_Development_Team</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Projects_Issue_Management/New_Issue_Notification</template>
    </alerts>
    <alerts>
        <fullName>PI_Updated_Issue</fullName>
        <description>PI Updated Issue</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Test_Assigned_To__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Projects_Issue_Management/Updated_Issue_Notification</template>
    </alerts>
    <alerts>
        <fullName>Project_Issue_Notification</fullName>
        <description>Project Issue Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>gary.grant@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lakshmi.rajendram@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Projects_Issue_Management/New_Issue_Notification</template>
    </alerts>
    <rules>
        <fullName>PI Issue Notification</fullName>
        <actions>
            <name>Project_Issue_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Projects/Issues - notify new issue</description>
        <formula>True</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>PI Memory Walk Issue Notification</fullName>
        <actions>
            <name>Memory_Walk_Project_Issue_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SFDC_Project__c.Name</field>
            <operation>equals</operation>
            <value>Memory Walk</value>
        </criteriaItems>
        <description>Projects/Issues - notify new issue for Memory Walk</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>PI Memory Walk Updated Issue Notification</fullName>
        <actions>
            <name>PI_Updated_Issue</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Projects/Issues - notify updated issue for Memory Walk</description>
        <formula>SFDC_Project__r.Name = &apos;Memory Walk&apos; &amp;&amp; NOT( ISNEW() )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
