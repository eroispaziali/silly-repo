<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_urgent_action_to_facilities</fullName>
        <description>Email urgent action to facilities</description>
        <protected>false</protected>
        <recipients>
            <recipient>eauser@alzehimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/Site_Survey_Urgent_Action</template>
    </alerts>
    <rules>
        <fullName>Urgent Action Required</fullName>
        <actions>
            <name>Email_urgent_action_to_facilities</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Survey__c.Urgent_Action_Required_tick__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Email Facilities alerting them about this location</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
