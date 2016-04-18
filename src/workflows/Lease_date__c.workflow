<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Internal_Break_Notification_Date_Leases</fullName>
        <ccEmails>moves@alzheimers.org.uk</ccEmails>
        <description>Internal Break Notification Date</description>
        <protected>false</protected>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/Internal_Break_Notification_Date</template>
    </alerts>
    <alerts>
        <fullName>Rent_Review_Notification_Date</fullName>
        <ccEmails>moves@alzheimers.org.uk</ccEmails>
        <description>Rent Review Notification Date</description>
        <protected>false</protected>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/Rent_Review_Notification</template>
    </alerts>
    <alerts>
        <fullName>Termination_Notification_Date</fullName>
        <ccEmails>moves@alzheimers.org.uk</ccEmails>
        <description>Termination Notification Date</description>
        <protected>false</protected>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/Termination_Notification_Date</template>
    </alerts>
    <rules>
        <fullName>Internal Break Notification</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lease_date__c.Break_Notification__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Sends an email when the Internal Break Notification date is hit</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Internal_Break_Notification_Date_Leases</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Lease_date__c.Break_Notification__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Rent Review Notification</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lease_date__c.Review_Notification__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Sends an email when the Rent Review Notification date is hit</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Rent_Review_Notification_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Lease_date__c.Review_Notification__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Termination Notification</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lease_date__c.Termination_Notification__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Sends an email when the Termination Notification date is hit</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Termination_Notification_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Lease_date__c.Termination_Notification__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
