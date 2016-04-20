<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Bid_Approved_Email_Owner_and_BDM</fullName>
        <description>Bid Approved - Email Owner and BDM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>BDM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>BDC_Email_Templates/Bid_Approved</template>
    </alerts>
    <alerts>
        <fullName>Bid_Rejected_Email_Owner_and_BDM</fullName>
        <description>Bid Rejected - Email Owner and BDM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>BDM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>BDC_Email_Templates/Bid_Rejected</template>
    </alerts>
</Workflow>
