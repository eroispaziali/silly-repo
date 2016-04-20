<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BDR_Service_Now_Open_Alert</fullName>
        <description>BDR_Service_Now_Open_Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BDR_Email_Templates/BDR_Service_Now_Open</template>
    </alerts>
    <alerts>
        <fullName>Review_Service_email</fullName>
        <description>Review Service email</description>
        <protected>false</protected>
        <recipients>
            <field>Operations_Manager__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SSM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>DA_Email_Templates/Service_Review</template>
    </alerts>
    <alerts>
        <fullName>Servcies_Database_Reminder</fullName>
        <description>Servcies Database Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRS_Email_Templates/ServicesDatabaseReminder</template>
    </alerts>
    <alerts>
        <fullName>Service_Activity_Approval_Rejected_Email</fullName>
        <description>Service/Activity Approval Rejected Email</description>
        <protected>false</protected>
        <recipients>
            <field>Service_Data_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRS_Email_Templates/Service_Activity_Approval_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Service_Activity_External_Service_changes_need_to_reviewed</fullName>
        <description>Service/Activity External Service changes need reviewed</description>
        <protected>false</protected>
        <recipients>
            <recipient>Guidebook</recipient>
            <type>role</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>DA_Email_Templates/External_Service_Changed</template>
    </alerts>
    <alerts>
        <fullName>Service_Activity_changes_need_reviewed</fullName>
        <description>Service/Activity changes need reviewed</description>
        <protected>false</protected>
        <recipients>
            <recipient>Guidebook</recipient>
            <type>role</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>DA_Email_Templates/Service_Changed</template>
    </alerts>
    <fieldUpdates>
        <fullName>Form_Approval_Stage_Submitted_for_approv</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Submitted for approval</literalValue>
        <name>Update form approval stage-Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SA_Approval_clear_Change_NeedsApproval</fullName>
        <field>Change_Needs_Approval__c</field>
        <literalValue>0</literalValue>
        <name>SA Approval - clear Change NeedsApproval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status_Changes_need_appr</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Changes Needs Approval</literalValue>
        <name>Update Approval Status-Changes need appr</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Form_Approval_Stage_Manager_appro</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Manager Approved</literalValue>
        <name>Update form approval stage-Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Form_Approval_Stage_Rejected</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update form approval stage-Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Owner_to_Dementia_Connect_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Dementia_Connect</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Owner to Dementia Connect Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_operation_manager_email</fullName>
        <field>Operations_Manager__c</field>
        <formula>Opps_email_formula__c</formula>
        <name>Update operation manager email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>BDR Service Now Open</fullName>
        <actions>
            <name>BDR_Service_Now_Open_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Change 416 Notify service owner that service is now open.</description>
        <formula>AND((ISPICKVAL(PRIORVALUE(service_status__c) ,&apos;Accepted&apos;)) , ( ISPICKVAL(service_status__c, &apos;Open&apos;) ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Quarterly Alert for Operation Managers</fullName>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Services__c.Last_Reviewed__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Services__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Internal Service</value>
        </criteriaItems>
        <description>Operations Managers to receive a notification to review services records in their locality on a quarterly basis to ensure accuracy of the data.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Review_Service_email</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Services__c.Last_Reviewed__c</offsetFromField>
            <timeLength>120</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Review Service Reminder</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Services__c.Last_Reviewed__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Triggers six months after Last Review date on a service</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Review_Service_email</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Services__c.Last_Reviewed__c</offsetFromField>
            <timeLength>180</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Review Service Reminder %2810 months%29</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Services__c.Last_Reviewed__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Triggers 10 months after Last Review date on a service</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Review_Service_email</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Services__c.Last_Reviewed__c</offsetFromField>
            <timeLength>300</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Review Service Reminder2</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Services__c.Last_Reviewed__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Triggers six, nine and 12 months after Last Review date on a service</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Review_Service_email</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Services__c.Last_Reviewed__c</offsetFromField>
            <timeLength>180</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Review_Service_email</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Services__c.Last_Reviewed__c</offsetFromField>
            <timeLength>270</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Review_Service_email</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Services__c.Last_Reviewed__c</offsetFromField>
            <timeLength>365</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SA - Review changes to External Service%2FActivity</fullName>
        <actions>
            <name>Service_Activity_External_Service_changes_need_to_reviewed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Services__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>External Service</value>
        </criteriaItems>
        <criteriaItems>
            <field>Services__c.Core_Record_Set__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Services__c.Display_on_public_website__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Changes to  external record type with either Core Record Set or Display on public website set, need to be reviewed by the Services/Activity administrator.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SA - Review changes to Service%2FActivity</fullName>
        <actions>
            <name>Service_Activity_changes_need_reviewed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Changes to  Service/Activity with either Core Record Set or Display on public website set, made by someone other than a System Administrator, need to be reviewed by the Services/Activity administrator.</description>
        <formula>( Core_Record_Set__c   ||  Display_on_public_website__c ) &amp;&amp;  LastModifiedBy.Profile.Name  &lt;&gt; &quot;System Administrator&quot; &amp;&amp;  LastModifiedBy.Profile.Name  &lt;&gt; &quot;Guidebook Administrator&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SA_Servcies_Database_Reminder</fullName>
        <actions>
            <name>Servcies_Database_Reminder</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Services__c.Live_on_CRS__c</field>
            <operation>equals</operation>
            <value>true</value>
        </criteriaItems>
        <criteriaItems>
            <field>Services__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Internal Service</value>
        </criteriaItems>
        <description>Reminder if service is updated to update the Services Database</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Owner of Core External services</fullName>
        <actions>
            <name>Update_Owner_to_Dementia_Connect_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Services__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>External Service</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update operation manager email</fullName>
        <actions>
            <name>Update_operation_manager_email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK(Operated_By__c))&amp;&amp;  RecordType.DeveloperName=&apos;Internal&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
