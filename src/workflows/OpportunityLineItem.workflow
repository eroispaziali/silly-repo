<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_alert_to_Michael_Docker_to_allocate_training</fullName>
        <description>Email alert to Michael Docker to allocate training</description>
        <protected>false</protected>
        <recipients>
            <recipient>robert.stuckey@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Alzheimer_s_Trading_Ltd_Templates/Training_Allocation</template>
    </alerts>
    <alerts>
        <fullName>Email_to_Dee_Charlotte</fullName>
        <description>Email to Dee &amp; Charlotte</description>
        <protected>false</protected>
        <recipients>
            <recipient>charlotte.wilson@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dee.bond@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mike.tinson@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Alzheimer_s_Trading_Ltd_Templates/TiAD_DVD</template>
    </alerts>
    <rules>
        <fullName>Training DVD</fullName>
        <actions>
            <name>Email_to_Dee_Charlotte</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Product2.ProductCode</field>
            <operation>equals</operation>
            <value>TZAR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.IsWon</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Notification to Charlotte and Dee to send DVD</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Training to be allocated</fullName>
        <actions>
            <name>Email_alert_to_Michael_Docker_to_allocate_training</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.IsWon</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Product2.Name</field>
            <operation>contains</operation>
            <value>Train,Training</value>
        </criteriaItems>
        <description>Alzheimer&apos;s Trading Ltd</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
