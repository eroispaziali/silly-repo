<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_an_email_alert_to_submit_the_service_charge_reconciliation</fullName>
        <description>Send an email alert to submit the service charge reconciliation</description>
        <protected>false</protected>
        <recipients>
            <field>Email_for_alert__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>SystemAdministrators</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Service_Charge_Reconciliation_email</template>
    </alerts>
    <alerts>
        <fullName>Workflow_is_working</fullName>
        <description>Workflow is working</description>
        <protected>false</protected>
        <recipients>
            <recipient>lakshmi.rajendram@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/FACILITIESLeaseExpirywarning</template>
    </alerts>
    <alerts>
        <fullName>email_alert_to_submit_the_service_charge_budget</fullName>
        <description>email alert to submit the service charge budget</description>
        <protected>false</protected>
        <recipients>
            <field>Email_for_alert__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>SystemAdministrators</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Service_Charge_Budget_Email</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_email</fullName>
        <field>Email_for_alert__c</field>
        <formula>Email_formula__c</formula>
        <name>Update email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Alert to submit the service charge budget</fullName>
        <active>true</active>
        <formula>Property_Contract__r.Latest_service_charge_record__c &lt;= CreatedDate &amp;&amp; NOT(ISBLANK(End_Date__c)) &amp;&amp;  Budget_received__c =False &amp;&amp;  RecordType.DeveloperName  =&quot;Service_Charge&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>email_alert_to_submit_the_service_charge_budget</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Property_Insurance__c.End_Date__c</offsetFromField>
            <timeLength>-30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Alert to to submit the service charge reconciliation for the previous year</fullName>
        <active>true</active>
        <formula>Property_Contract__r.Latest_service_charge_record__c &lt;= CreatedDate &amp;&amp; NOT(ISBLANK(End_Date__c))&amp;&amp;   Reconciliation_Received__c = False &amp;&amp;
RecordType.DeveloperName =&quot;Service_Charge&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_an_email_alert_to_submit_the_service_charge_reconciliation</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Property_Insurance__c.End_Date__c</offsetFromField>
            <timeLength>-90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update email field for alert</fullName>
        <actions>
            <name>Update_email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Property_Insurance__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
