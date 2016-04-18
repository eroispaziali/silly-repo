<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>DAA_Stakeholder_reminder</fullName>
        <description>DAA Stakeholder reminder</description>
        <protected>false</protected>
        <recipients>
            <recipient>sarah.tilsed@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/Dementia_Action_Alliance_Stakeholder_reminder_notes_alert</template>
    </alerts>
    <alerts>
        <fullName>Email_Client_Record_Owner</fullName>
        <description>Email Client Record Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>DA_Email_Templates/DA_Obtain_Consent</template>
    </alerts>
    <fieldUpdates>
        <fullName>Person_First_Name_Title_case</fullName>
        <description>Update first name so that the first letter is captialized</description>
        <field>FirstName</field>
        <formula>UPPER(LEFT(FirstName,1))&amp;LOWER(Mid(FirstName, 2, Len(FirstName)-1))</formula>
        <name>Person_First_Name Title case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Person_Last_Name_Title_Case</fullName>
        <description>Makes sure that first characther is a captial.</description>
        <field>LastName</field>
        <formula>UPPER(LEFT(LastName,1))&amp;LOWER(Mid(LastName, 2, Len(LastName)-1))</formula>
        <name>Person Last Name Title Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Setinactivedate</fullName>
        <description>Set the inactive date to today</description>
        <field>Inactive_Date__c</field>
        <formula>Today()</formula>
        <name>Set inactive date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Client set inactive</fullName>
        <actions>
            <name>Setinactivedate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Active__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Store the date a client is flagged inactive</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DAA Stakeholder reminder</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Reminder__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Sends an email with Dementia Action Alliance stakeholder reminder notes when the reminder date is hit.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>DAA_Stakeholder_reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Contact.Reminder__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Person_First_Name</fullName>
        <actions>
            <name>Person_First_Name_Title_case</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.FirstName</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>New Person created with a First Name.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Person_Last_Name</fullName>
        <actions>
            <name>Person_Last_Name_Title_Case</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.LastName</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.RecordTypeId</field>
            <operation>equals</operation>
            <value>Carer of Person with Dementia,Friend or Family of Person with Dementia,Professional / Stakeholder,Person with Dementia</value>
        </criteriaItems>
        <description>New Person Record</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <tasks>
        <fullName>SendBirthdayCard</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>-5</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Send Birthday Card</subject>
    </tasks>
    <tasks>
        <fullName>Task_Obtain_written_consent_for_client</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>21</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>Contact.CreatedDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Obtain written consent for client</subject>
    </tasks>
</Workflow>
