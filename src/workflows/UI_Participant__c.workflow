<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>UI_Active_Request_Approved</fullName>
        <description>UI_Active_Request_Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>gary.grant@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Society_Contact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>User_Involvement_Email_Templates/UI_Approved_Active</template>
    </alerts>
    <alerts>
        <fullName>UI_Active_Request_Rejected</fullName>
        <description>UI Active Request Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>User_Involvement_Email_Templates/UI_Active_Rejected</template>
    </alerts>
    <alerts>
        <fullName>UI_Request_Active_Status</fullName>
        <description>UI Request Active Status</description>
        <protected>false</protected>
        <recipients>
            <recipient>gary.grant@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>SU_SSM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>User_Involvement_Email_Templates/UI_Request_Active</template>
    </alerts>
    <fieldUpdates>
        <fullName>UI_Reset_Requires_Approval</fullName>
        <field>Requires_Approval__c</field>
        <literalValue>0</literalValue>
        <name>UI_Reset_Requires_Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UI_Set_Pending_Approval</fullName>
        <field>Status__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>UI_Set_Pending_Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UI_Set_Status_Active</fullName>
        <field>Status__c</field>
        <literalValue>Active</literalValue>
        <name>UI Set Status Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UI_Set_Status_Pending_Approval</fullName>
        <field>Status__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>UI Set Status Pending Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UI_Set_Status_Unconfirmed</fullName>
        <description>Set the status back to unconfirmed</description>
        <field>Status__c</field>
        <literalValue>Unconfirmed</literalValue>
        <name>UI Set Status Unconfirmed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
