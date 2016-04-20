<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BDR_Contract_Information_Ready</fullName>
        <description>BDR_Contract_Information_Ready</description>
        <protected>false</protected>
        <recipients>
            <field>Contract_administrator_internal__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BDR_Email_Templates/BDR_Contract_Information_Ready_EmailTemplate</template>
    </alerts>
    <fieldUpdates>
        <fullName>BDC_Regional_Accountant_Email</fullName>
        <field>Regional_Accountant_Email__c</field>
        <formula>BDR__r.Regional_Accountant__r.Email</formula>
        <name>BDC_Regional_Accountant_Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>BDR Update Regional Account email</fullName>
        <actions>
            <name>BDR_Contract_Information_Ready</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>BDC_Regional_Accountant_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BD_Contract__c.Invoicing_information_complete__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Need regional account email address on contract to enable emails regarding contract.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
