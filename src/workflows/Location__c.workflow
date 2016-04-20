<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EmailFacilitiesreleaseexpiry</fullName>
        <description>Email Facilities re lease expiry</description>
        <protected>false</protected>
        <recipients>
            <recipient>frank.branscombe@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>helen.bougadellis@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>phil.shoesmith@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/FACILITIESLeaseExpirywarning</template>
    </alerts>
    <fieldUpdates>
        <fullName>UpdatePropertyName</fullName>
        <field>Name</field>
        <formula>UPPER( Name )</formula>
        <name>UpdatePropertyName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>UpdatePropertyName</fullName>
        <actions>
            <name>UpdatePropertyName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Property Name to Uppercase.</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
