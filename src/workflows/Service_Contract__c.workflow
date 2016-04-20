<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Contract_soon_to_expire</fullName>
        <description>Contract soon to expire</description>
        <protected>false</protected>
        <recipients>
            <field>Contract_administrator_internal__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>BDC_Email_Templates/Contract_expiry</template>
    </alerts>
    <rules>
        <fullName>Service Contract Expiry</fullName>
        <actions>
            <name>Review_Service_Contract</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Service_Contract__c.Review_date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Email contract administrator when Review Date is hit</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Contract_soon_to_expire</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Service_Contract__c.Review_date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <tasks>
        <fullName>Review_Service_Contract</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>Service_Contract__c.Review_date__c</offsetFromField>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Review Service Contract</subject>
    </tasks>
</Workflow>
