<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BDR_Acceptance_Submission</fullName>
        <description>BDR Initial Acceptance Submission - Notification to OM/SIM/ROM</description>
        <protected>false</protected>
        <recipients>
            <field>Area_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Operations_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>SIM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BDR_Email_Templates/BDR_Init_Acceptance_Email_Tmplt_VF</template>
    </alerts>
    <alerts>
        <fullName>BDR_Accepted_Legal_Notification</fullName>
        <description>BDR Accepted Legal Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Legal</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BDR_Email_Templates/BDR_Legal_Notification_Email_Tmplt_VF</template>
    </alerts>
    <alerts>
        <fullName>BDR_CEO_Rejection</fullName>
        <description>BDR CEO Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Area_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BDM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BDR_Email_Templates/BDR_Approval_Rejection_Email_Template_VF</template>
    </alerts>
    <alerts>
        <fullName>BDR_Finance_Notification</fullName>
        <description>BDR Finance Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Regional_Accountant__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BDR_Email_Templates/BDR_Finance_Notification_Email_Tmplt_VF</template>
    </alerts>
    <alerts>
        <fullName>BDR_IG_Notification</fullName>
        <description>BDR IG Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>rowenna.fielding@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BDR_Email_Templates/BDR_IG_Notification_Email_Tmplt_VF</template>
    </alerts>
    <alerts>
        <fullName>BDR_IT_Notification</fullName>
        <description>BDR IT Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>ashley.hanson@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ray.cross@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BDR_Email_Templates/BDR_IT_Notification_Email_Template_VF</template>
    </alerts>
    <alerts>
        <fullName>BDR_LM_SIM_Notification</fullName>
        <description>BDR-LM-SIM Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Locality_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>SIM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BDR_Email_Templates/BDR_Notification</template>
    </alerts>
    <alerts>
        <fullName>BDR_Legal_Notification</fullName>
        <description>BDR Legal Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>alex.morley@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>chloe.jones@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lilly.hamilton@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BDR_Email_Templates/BDR_Legal_Notification_Email_Tmplt_VF</template>
    </alerts>
    <alerts>
        <fullName>BDR_POD_Notification</fullName>
        <description>BDR POD Notification</description>
        <protected>false</protected>
        <recipients>
            <field>HR_Advisor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BDR_Email_Templates/BDR_HR_Notification_Email_Template_VF</template>
    </alerts>
    <alerts>
        <fullName>BDR_Property_Notification</fullName>
        <description>BDR Property Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>quentin.padgett@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ramona.hotea@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BDR_Email_Templates/BDR_Property_Notification_Email_Tmplt_VF</template>
    </alerts>
    <alerts>
        <fullName>BDR_Reporting_Notification</fullName>
        <ccEmails>Operationsdata@alzheimers.org.uk</ccEmails>
        <description>BDR Reporting Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>clare.lucas@alzheimers.org.uk</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/BDR_Opps_Notification_Email_Template_VF</template>
    </alerts>
    <alerts>
        <fullName>BDR_Service_Editable_Property</fullName>
        <description>BDR Service Editable Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Operations_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BDR_Email_Templates/BDR_Service_Now_Editable</template>
    </alerts>
    <alerts>
        <fullName>BDR_Stage_Approval_Acceptance</fullName>
        <description>BDR Stage Approval Acceptance</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Area_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Operations_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>SIM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BDR_Email_Templates/BDR_Initial_Accepted_Email_Template_VF</template>
    </alerts>
    <alerts>
        <fullName>BDR_Stage_Approval_Final_Rejection</fullName>
        <description>BDR Stage Approval Final Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Area_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BDM__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Operations_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>SIM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BDR_Email_Templates/BDR_Approval_Rejection_Email_Template_VF</template>
    </alerts>
    <alerts>
        <fullName>BDR_Stage_Approval_Proposed</fullName>
        <description>BDR Stage Approval Proposed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Area_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BDM__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Operations_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>SIM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BDR_Email_Templates/BDR_Proposed_Approved_Email_Template_VF</template>
    </alerts>
    <alerts>
        <fullName>BDR_Stage_Approval_Proposed_Rejection</fullName>
        <description>BDR Stage Approval Proposed Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Area_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BDM__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Operations_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>SIM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BDR_Email_Templates/BDR_Approval_Rejection_Email_Template_VF</template>
    </alerts>
    <alerts>
        <fullName>BDR_Stage_Approval_Recall</fullName>
        <description>BDR Stage Approval Recall</description>
        <protected>false</protected>
        <recipients>
            <field>Area_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BDM__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Operations_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>SIM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BDR_Email_Templates/BDR_Approval_Recalled_Email_Template_VF</template>
    </alerts>
    <alerts>
        <fullName>BDR_Stage_Approval_Rejection</fullName>
        <description>BDR Stage Approval Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Area_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Operations_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>SIM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BDR_Email_Templates/BDR_Approval_Rejection_Email_Template_VF</template>
    </alerts>
    <alerts>
        <fullName>BDR_Stage_Approval_Successful</fullName>
        <description>BDR Stage Approval Successful</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Area_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>BDM__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Locality_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Operations_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BDR_Email_Templates/BDR_Approval_Successful_Email_Tmplt_VF</template>
    </alerts>
    <fieldUpdates>
        <fullName>BDR_Acceptance_Update</fullName>
        <field>Status__c</field>
        <literalValue>Accepted</literalValue>
        <name>BDR Acceptance Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BDR_Clear_Notification_Action</fullName>
        <field>Notification_Action__c</field>
        <name>BDR Clear Notification Action</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BDR_Clear_Notification_Operation</fullName>
        <description>Clear the notification pending flag for Operations. Be sure to include the Space (&apos; &apos;) char in the substitute formula</description>
        <field>Notifications_Pending__c</field>
        <formula>SUBSTITUTE(Notifications_Pending__c, &quot;Operations&quot;,&quot;&quot;)</formula>
        <name>BDR Clear Notification Pending Operation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BDR_Clear_Notification_Pending</fullName>
        <field>Notifications_Pending__c</field>
        <name>BDR Clear Notification Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BDR_Clear_Notification_Pending_Finance</fullName>
        <field>Notifications_Pending__c</field>
        <formula>SUBSTITUTE(Notifications_Pending__c, &quot;Finance&quot;,&quot;&quot;)</formula>
        <name>BDR Clear Notification Pending Finance</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BDR_Clear_Notification_Pending_HR</fullName>
        <description>Clear the notification pending flag for HR Advisor. Be sure to include the Space (&apos;  &apos;) char in the substitute formula</description>
        <field>Notifications_Pending__c</field>
        <formula>SUBSTITUTE(Notifications_Pending__c, &quot;HR_Advisor&quot;,&quot;&quot;)</formula>
        <name>BDR Clear Notification Pending HR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BDR_Clear_Notification_Pending_IG</fullName>
        <field>Notifications_Pending__c</field>
        <formula>SUBSTITUTE(Notifications_Pending__c, &quot;IG&quot;,&quot;&quot;)</formula>
        <name>BDR Clear Notification Pending IG</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BDR_Clear_Notification_Pending_IT</fullName>
        <description>Clear the notification pending flag for IT.</description>
        <field>Notifications_Pending__c</field>
        <formula>SUBSTITUTE(Notifications_Pending__c, &quot;IT&quot;,&quot;&quot;)</formula>
        <name>BDR Clear Notification Pending IT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BDR_Clear_Notification_Pending_Legal</fullName>
        <description>Clear the notification flag for legal notifications</description>
        <field>Notifications_Pending__c</field>
        <formula>SUBSTITUTE(Notifications_Pending__c, &quot;Legal&quot;,&quot;&quot;)</formula>
        <name>BDR Clear Notification Pending Legal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BDR_Clear_Notification_Pending_Property</fullName>
        <description>Clear the flag for Property notifications</description>
        <field>Notifications_Pending__c</field>
        <formula>SUBSTITUTE(Notifications_Pending__c, &quot;Property&quot;,&quot;&quot;)</formula>
        <name>BDR Clear Notification Pending Property</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BDR_Clear_Notification_Pending_Svc_Edit</fullName>
        <description>Clear the notification pending flag for OM. Be sure to include the Space (&apos;  &apos;) char in the substitute formula. Tells the OM services can be edited</description>
        <field>Notifications_Pending__c</field>
        <formula>SUBSTITUTE(Notifications_Pending__c, &quot;SVC_ACCESS&quot;,&quot;&quot;)</formula>
        <name>BDR Clear Notification Pending Svc Edit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BDR_Proposed_Update</fullName>
        <field>Status__c</field>
        <literalValue>Proposed</literalValue>
        <name>BDR Proposed Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BDR_Set_Notification_Action</fullName>
        <description>Set the flag that triggers conditional notifications</description>
        <field>Notification_Action__c</field>
        <formula>&quot;Y&quot;</formula>
        <name>BDR Set Notification Action</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BDR_Successful_Update</fullName>
        <field>Status__c</field>
        <literalValue>Live</literalValue>
        <name>BDR Successful Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>BDR Notify Finance</fullName>
        <actions>
            <name>BDR_Finance_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>BDR_Clear_Notification_Pending_Finance</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BDR__c.Notification_Action__c</field>
            <operation>contains</operation>
            <value>Y</value>
        </criteriaItems>
        <criteriaItems>
            <field>BDR__c.Notifications_Pending__c</field>
            <operation>contains</operation>
            <value>Finance</value>
        </criteriaItems>
        <description>Notify Finance when a BDR is accepted by the BDM, and the tender documents are being prepared, or when the user selects optional notification</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BDR Notify HR</fullName>
        <actions>
            <name>BDR_POD_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>BDR_Clear_Notification_Pending_HR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BDR__c.Notification_Action__c</field>
            <operation>contains</operation>
            <value>Y</value>
        </criteriaItems>
        <criteriaItems>
            <field>BDR__c.Notifications_Pending__c</field>
            <operation>contains</operation>
            <value>HR_Advisor</value>
        </criteriaItems>
        <description>Notify HR when a BDR is accepted by the BDM, and the tender documents are being prepared</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BDR Notify IG</fullName>
        <actions>
            <name>BDR_IG_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>BDR_Clear_Notification_Pending_IG</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BDR__c.Notification_Action__c</field>
            <operation>contains</operation>
            <value>Y</value>
        </criteriaItems>
        <criteriaItems>
            <field>BDR__c.Notifications_Pending__c</field>
            <operation>contains</operation>
            <value>IG</value>
        </criteriaItems>
        <description>Notify IG when a BDR is accepted by the BDM, and the tender documents are being prepared</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BDR Notify IT</fullName>
        <actions>
            <name>BDR_IT_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>BDR_Clear_Notification_Pending_IT</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>BDR__c.Notification_Action__c</field>
            <operation>contains</operation>
            <value>Y</value>
        </criteriaItems>
        <criteriaItems>
            <field>BDR__c.Notifications_Pending__c</field>
            <operation>contains</operation>
            <value>IT</value>
        </criteriaItems>
        <description>Notify IT when a BDR is submitted that has IT Service delivery implications</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BDR Notify Legal</fullName>
        <actions>
            <name>BDR_Legal_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>BDR_Clear_Notification_Pending_Legal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BDR__c.Notification_Action__c</field>
            <operation>contains</operation>
            <value>Y</value>
        </criteriaItems>
        <criteriaItems>
            <field>BDR__c.Notifications_Pending__c</field>
            <operation>contains</operation>
            <value>Legal</value>
        </criteriaItems>
        <description>Notify Legal when a BDR is accepted by the BDM, and the tender documents are being prepared</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BDR Notify Operations</fullName>
        <actions>
            <name>BDR_Reporting_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>BDR_Clear_Notification_Operation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BDR__c.Notification_Action__c</field>
            <operation>contains</operation>
            <value>Y</value>
        </criteriaItems>
        <criteriaItems>
            <field>BDR__c.Notifications_Pending__c</field>
            <operation>contains</operation>
            <value>Operations</value>
        </criteriaItems>
        <description>Notify Operations when a BDR is accepted by the BDM, and reporting implications</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BDR Notify Property</fullName>
        <actions>
            <name>BDR_Property_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>BDR_Clear_Notification_Pending_Property</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BDR__c.Notification_Action__c</field>
            <operation>contains</operation>
            <value>Y</value>
        </criteriaItems>
        <criteriaItems>
            <field>BDR__c.Notifications_Pending__c</field>
            <operation>contains</operation>
            <value>Property</value>
        </criteriaItems>
        <description>Notify Property when a BDR is accepted by the BDM, and the tender documents are being prepared</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BDR Notify Service Editable</fullName>
        <actions>
            <name>BDR_Service_Editable_Property</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>BDR_Clear_Notification_Pending_Svc_Edit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BDR__c.Notification_Action__c</field>
            <operation>contains</operation>
            <value>Y</value>
        </criteriaItems>
        <criteriaItems>
            <field>BDR__c.Notifications_Pending__c</field>
            <operation>contains</operation>
            <value>SVC_ACCESS</value>
        </criteriaItems>
        <description>Notify OM when BDR associated Services are set to editable by the owner</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BDR Set Successful</fullName>
        <actions>
            <name>BDR_Stage_Approval_Successful</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BDR__c.Status__c</field>
            <operation>equals</operation>
            <value>Live</value>
        </criteriaItems>
        <description>Send an email alert when a BDR is set to successful and is now Live</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
