<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Alert_to_Matthew_Watson_in_Finance</fullName>
        <description>Email Alert to Matthew Wood in Finance</description>
        <protected>false</protected>
        <recipients>
            <recipient>matthew.wood@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Alzheimer_s_Trading_Ltd_Templates/Invoice_Request</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_to_Michael_Docker_to_Allocate_Trainer_for_this_Closed_Deal</fullName>
        <description>Email alert to  Michael Docker to Allocate Trainer for this Closed Deal</description>
        <protected>false</protected>
        <recipients>
            <recipient>robert.stuckey@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Alzheimer_s_Trading_Ltd_Templates/Training_Allocation</template>
    </alerts>
    <alerts>
        <fullName>Notification_for_invoicing</fullName>
        <description>Notification for invoicing</description>
        <protected>false</protected>
        <recipients>
            <recipient>matthew.wood@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Alzheimer_s_Trading_Ltd_Templates/Invoice_Request</template>
    </alerts>
    <fieldUpdates>
        <fullName>Opp_name_when_created</fullName>
        <description>Keep a track of Opportunity name when created</description>
        <field>Opp_name_when_created__c</field>
        <formula>Name</formula>
        <name>Opp name when created</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Name_Update_on_Creation</fullName>
        <description>Opportunity name to include the created date when the opportunity is first created</description>
        <field>Name</field>
        <formula>Name  &amp; &apos; &apos;&amp;  TEXT(  DAY(TODAY()))&amp;&apos;/&apos;&amp;TEXT(  MONTH(TODAY()))&amp;&apos;/&apos;&amp;TEXT( YEAR(TODAY()))</formula>
        <name>Opportunity Name Update on Creation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Name_update_Won</fullName>
        <description>Opportunity Name to be updated with delivery date, if the opportunity is Closed Won</description>
        <field>Name</field>
        <formula>Opp_name_when_created__c &amp;&apos; &apos;&amp;&apos; &apos;&amp;&apos;Delivered&apos;&amp;&apos; &apos;&amp;TEXT( DAY(Delivery_Date__c))&amp;&apos;/&apos;&amp;TEXT( MONTH(Delivery_Date__c))&amp;&apos;/&apos;&amp;TEXT( YEAR(Delivery_Date__c))</formula>
        <name>Opportunity Name update Won</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Alzheimer%27s Trading Ltd - Closed Won - Training %26 Invoice</fullName>
        <actions>
            <name>Email_alert_to_Michael_Docker_to_Allocate_Trainer_for_this_Closed_Deal</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Alzheimer&apos;s Trading Ltd Opportunity</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <description>Alzheimer&apos;s Trading Ltd Workflow for when an Opportunity is Closed one. Email to Michael Docker for training allocation on the deal
Email to finance to create invoice</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Matt notification</fullName>
        <actions>
            <name>Notification_for_invoicing</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Training_Allocated__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>training allocation</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Name update</fullName>
        <actions>
            <name>Opp_name_when_created</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Opportunity_Name_Update_on_Creation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Alzheimer&apos;s Trading Ltd Opportunity</value>
        </criteriaItems>
        <description>Update the Opportunity Name when created to include the created date and save the original name in a buffer field</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Name update When Won</fullName>
        <actions>
            <name>Opportunity_Name_update_Won</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Alzheimer&apos;s Trading Ltd Opportunity</value>
        </criteriaItems>
        <description>Update the Opportunity Name to contain the delivery date if the Opp is closed won</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Acknowledgement Letter</fullName>
        <actions>
            <name>SendAcknowledgement</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won,Posted</value>
        </criteriaItems>
        <description>used to remind donation owner to send acknowledgement for any donations that are Posted / Closed Won.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>SendAcknowledgement</fullName>
        <assignedToType>owner</assignedToType>
        <description>Please send an acknowledgement for this donation</description>
        <dueDateOffset>7</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Send Acknowledgement</subject>
    </tasks>
</Workflow>
