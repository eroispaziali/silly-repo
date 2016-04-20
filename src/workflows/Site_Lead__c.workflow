<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Site_Lead_Confirmation_Email</fullName>
        <description>Site Lead Confirmation Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/Site_Lead_Confirmation_1</template>
    </alerts>
    <rules>
        <fullName>Site Lead Confirmation Email</fullName>
        <actions>
            <name>Site_Lead_Confirmation_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Lead__c.Consent_To_Contact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Site Lead Confirmation Email</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
