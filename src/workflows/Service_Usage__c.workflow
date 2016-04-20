<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SU_Name_Update</fullName>
        <field>Name</field>
        <formula>Left(Primary_Service_User__r.LastName &amp; &apos;, &apos; &amp;  Primary_Service_User__r.FirstName &amp; &apos; (&apos; &amp;  Service_Field__r.Name,79) &amp; &apos;)&apos;</formula>
        <name>SU Name - Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SU_RecordType_Activity_Group</fullName>
        <description>Updates the Record Type based on selected Service Type.</description>
        <field>RecordTypeId</field>
        <lookupValue>Activity_Group</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SU RecordType - Activity Group</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SU_RecordType_Advocacy</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Advocacy</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SU RecordType - Advocacy</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SU_RecordType_Day_Support</fullName>
        <description>Updates the Record Type based on selected Service Type.</description>
        <field>RecordTypeId</field>
        <lookupValue>Day_Support_Establishment_Based</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SU RecordType - Day Support</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SU_RecordType_Dementia_Adviser</fullName>
        <description>Updates the record type based on the Service Type selected.</description>
        <field>RecordTypeId</field>
        <lookupValue>Dementia_Adviser_Service_Usage</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SU RecordType - Dementia Adviser</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SU_RecordType_Dementia_Cafe</fullName>
        <description>Updates the Record Type based on selected Service Type.</description>
        <field>RecordTypeId</field>
        <lookupValue>Dementia_Cafe</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SU RecordType - Dementia Cafe</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SU_RecordType_Home_Support</fullName>
        <description>Updates the Record Type based on selected Service Type.</description>
        <field>RecordTypeId</field>
        <lookupValue>Home_Support_Registered</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SU RecordType - Home Support</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SU_RecordType_Information_Programme</fullName>
        <description>Updates the Record Type based on selected Service Type.</description>
        <field>RecordTypeId</field>
        <lookupValue>Information_Programme</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SU RecordType - Information Programme</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SU_RecordType_Newsletter</fullName>
        <description>Updates the Record Type based on selected Service Type.</description>
        <field>RecordTypeId</field>
        <lookupValue>Newsletter</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SU RecordType - Newsletter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SU_RecordType_Other</fullName>
        <description>Updates the Record Type based on selected Service Type.</description>
        <field>RecordTypeId</field>
        <lookupValue>Other</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SU RecordType - Other</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SU_RecordType_Peer_Support</fullName>
        <description>Updates the Record Type based on selected Service Type.</description>
        <field>RecordTypeId</field>
        <lookupValue>Peer_Support</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SU RecordType - Peer Support</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SU_RecordType_Singing_for_the_Brain</fullName>
        <description>Updates the Record Type based on selected Service Type.</description>
        <field>RecordTypeId</field>
        <lookupValue>Singing_for_the_Brain</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SU RecordType - Singing for the Brain</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SU_RecordType_Social_Inclusion</fullName>
        <description>Updates the Record Type based on selected Service Type.</description>
        <field>RecordTypeId</field>
        <lookupValue>Social_Inclusion</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SU RecordType - Social Inclusion</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SU_RecordType_Volunteer_Befriending</fullName>
        <description>Updates the Record Type based on selected Service Type.</description>
        <field>RecordTypeId</field>
        <lookupValue>Volunteer_Befriending</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SU RecordType - Volunteer Befriending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SU_Record_Type_Dementia_Support</fullName>
        <description>Sets Record Type to Dementia Support</description>
        <field>RecordTypeId</field>
        <lookupValue>Dementia_Support_Service_Usage</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SU Record Type (Dementia Support)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>SU Name - Update</fullName>
        <actions>
            <name>SU_Name_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Service_Usage__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Name field will update with Primary Service User Last, First Name along with Service Name.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SU RecordType - Activity Group</fullName>
        <actions>
            <name>SU_RecordType_Activity_Group</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Service_Usage__c.Service_Type__c</field>
            <operation>equals</operation>
            <value>Activity group</value>
        </criteriaItems>
        <criteriaItems>
            <field>Service_Usage__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Outgoing Referral</value>
        </criteriaItems>
        <description>RecordType Id is updated, based on the selected Service Type.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SU RecordType - Advocacy</fullName>
        <actions>
            <name>SU_RecordType_Advocacy</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Service_Usage__c.Service_Type__c</field>
            <operation>equals</operation>
            <value>Advocacy</value>
        </criteriaItems>
        <criteriaItems>
            <field>Service_Usage__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Outgoing Referral</value>
        </criteriaItems>
        <description>RecordType Id is update, based on the selected Service Type.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SU RecordType - Day Support</fullName>
        <actions>
            <name>SU_RecordType_Day_Support</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Service_Usage__c.Service_Type__c</field>
            <operation>equals</operation>
            <value>Day care and support (establishment based)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Service_Usage__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Outgoing Referral</value>
        </criteriaItems>
        <description>RecordType Id is updated, based on the selected Service Type.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SU RecordType - Dementia Adviser</fullName>
        <actions>
            <name>SU_RecordType_Dementia_Adviser</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Service_Usage__c.Service_Type__c</field>
            <operation>equals</operation>
            <value>Dementia adviser</value>
        </criteriaItems>
        <criteriaItems>
            <field>Service_Usage__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Outgoing Referral</value>
        </criteriaItems>
        <description>RecordType Id is updated, based on the selected Service Type.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SU RecordType - Dementia Cafe</fullName>
        <actions>
            <name>SU_RecordType_Dementia_Cafe</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Service_Usage__c.Service_Type__c</field>
            <operation>equals</operation>
            <value>Dementia cafe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Service_Usage__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Outgoing Referral</value>
        </criteriaItems>
        <description>RecordType Id is updated, based on the selected Service Type.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SU RecordType - Dementia Support</fullName>
        <actions>
            <name>SU_Record_Type_Dementia_Support</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Service_Usage__c.Service_Type__c</field>
            <operation>equals</operation>
            <value>Dementia support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Service_Usage__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Outgoing Referral</value>
        </criteriaItems>
        <description>RecordType Id is updated, based on the selected Service Type.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SU RecordType - Home Support</fullName>
        <actions>
            <name>SU_RecordType_Home_Support</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Service_Usage__c.Service_Type__c</field>
            <operation>equals</operation>
            <value>Registered home care and support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Service_Usage__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Outgoing Referral</value>
        </criteriaItems>
        <description>RecordType Id is updated, based on the selected Service Type.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SU RecordType - Information Programme</fullName>
        <actions>
            <name>SU_RecordType_Information_Programme</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Service_Usage__c.Service_Type__c</field>
            <operation>equals</operation>
            <value>Information programme</value>
        </criteriaItems>
        <criteriaItems>
            <field>Service_Usage__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Outgoing Referral</value>
        </criteriaItems>
        <description>RecordType Id is updated, based on the selected Service Type.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SU RecordType - Newsletter</fullName>
        <actions>
            <name>SU_RecordType_Newsletter</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Service_Usage__c.Service_Type__c</field>
            <operation>equals</operation>
            <value>Newsletter</value>
        </criteriaItems>
        <criteriaItems>
            <field>Service_Usage__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Outgoing Referral</value>
        </criteriaItems>
        <description>RecordType Id is updated, based on the selected Service Type.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SU RecordType - Other</fullName>
        <actions>
            <name>SU_RecordType_Other</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Service_Usage__c.Service_Type__c</field>
            <operation>equals</operation>
            <value>Other (one to one)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Service_Usage__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Outgoing Referral</value>
        </criteriaItems>
        <description>RecordType Id is updated, based on the selected Service Type.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SU RecordType - Peer Support</fullName>
        <actions>
            <name>SU_RecordType_Peer_Support</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Service_Usage__c.Service_Type__c</field>
            <operation>equals</operation>
            <value>Peer support group</value>
        </criteriaItems>
        <criteriaItems>
            <field>Service_Usage__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Outgoing Referral</value>
        </criteriaItems>
        <description>RecordType Id is updated, based on the selected Service Type.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SU RecordType - Singing for the Brain</fullName>
        <actions>
            <name>SU_RecordType_Singing_for_the_Brain</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Service_Usage__c.Service_Type__c</field>
            <operation>equals</operation>
            <value>Singing for the Brain</value>
        </criteriaItems>
        <criteriaItems>
            <field>Service_Usage__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Outgoing Referral</value>
        </criteriaItems>
        <description>RecordType Id is updated, based on the selected Service Type.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SU RecordType - Social Inclusion</fullName>
        <actions>
            <name>SU_RecordType_Social_Inclusion</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Service_Usage__c.Service_Type__c</field>
            <operation>equals</operation>
            <value>Community support service</value>
        </criteriaItems>
        <criteriaItems>
            <field>Service_Usage__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Outgoing Referral</value>
        </criteriaItems>
        <description>RecordType Id is updated, based on the selected Service Type.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SU RecordType - Volunteer Befriending</fullName>
        <actions>
            <name>SU_RecordType_Volunteer_Befriending</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Service_Usage__c.Service_Type__c</field>
            <operation>equals</operation>
            <value>Befriending</value>
        </criteriaItems>
        <criteriaItems>
            <field>Service_Usage__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Outgoing Referral</value>
        </criteriaItems>
        <description>RecordType Id is updated, based on the selected Service Type.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
