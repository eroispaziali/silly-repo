
<div style="padding:0 4px;display:none" ng-style="{display:'block'}" ng-view dc-scroll-top cq-focus-visibility>

    <div style="display:table-row">
        <h1 ng-hide="smallContainer" tabindex="-1" style="display:table-cell;width:100%;vertical-align:top;padding-right:8px">{{serviceModel.National_Service__c?serviceModel.Name:serviceModel.Service_Web_Name__c}}</h1>
        <div style="display:table-cell">
            <button ng-show="currentSearch" class="btn btn-sm btn-primary" cq-sref="^.results" aria-label="return to search results" ng-disabled="stateTransitioning"><span class="fa fa-chevron-left"></span> Back</button>
            <button ng-show="!currentSearch && serviceModel.service_postcode__c" class="btn btn-sm btn-primary" ng-click="findMore()" ng-disabled="stateTransitioning"><span class="fa fa-search"></span> More near here</button>
        </div>
    </div>
    <div style="display:table-row">
        <h1 ng-show="smallContainer" tabindex="-1" style="margin-top:6px">{{serviceModel.National_Service__c?serviceModel.Name:serviceModel.Service_Web_Name__c}}</h1>
    </div>
    <div class="detail-panel" style="margin-bottom: 6px">

        <div style="margin: 8px 0 14px 0">
            <p>{{serviceModel.service_description__c}}</p>
        </div>

        <div class="service-details clearfix">

            <div ng-class="{'pull-left':!smallContainer}" ng-show="(serviceModel.Funder_restriction__c && serviceModel.Record_Type_Name__c == 'Internal')||serviceModel.service_targetclientgroup__c||(serviceModel.Service_Criteria__c && serviceModel.Record_Type_Name__c == 'External')">
                <h2>Who Is This Service For</h2>
                <div class="service-details-list">
                    <div ng-show="serviceModel.Service_Criteria__c && serviceModel.Record_Type_Name__c == 'External'"><span class="fa fa-circle" style="font-size: xx-small; position: relative; top:-2px;"></span><span>{{serviceModel.Service_Criteria__c}}</span></div>
                    <div ng-show="serviceModel.service_targetclientgroup__c"><span class="fa fa-circle" style="font-size: xx-small; position: relative; top:-2px;"></span><span>{{serviceModel.service_targetclientgroup__c}}</span></div>
                    <div ng-show="serviceModel.Referral_only__c ? 'true' : ''"><span class="fa fa-circle" style="font-size: xx-small; position: relative; top:-2px;"></span><span>{{serviceModel.Referral_only__c ? "Referral only." : ""}}</span></div>
                    <div ng-show="serviceModel.Funder_restriction__c && serviceModel.Record_Type_Name__c == 'Internal'"><span class="fa fa-circle" style="font-size: xx-small; position: relative; top:-2px;"></span><span>{{serviceModel.Funder_restriction__c}}</span></div>
                </div>
            </div>

            <div ng-class="{'pull-left':!smallContainer}" ng-show="serviceModel.Contact_first_name__c||serviceModel.Contact_last_name__c||serviceModel.service_telephone__c||serviceModel.service_email__c||serviceModel.service_website__c">
                <h2>Contact Information</h2>
                <div class="service-details-list">
                    <div ng-show="serviceModel.service_telephone__c">
                        <span style="font-weight:bold;" class="fa fa-phone" title="Contact Telephone"><span class="sr-only">contact telephone</span></span>
                        <span> <a href="tel:{{serviceModel.service_telephone__c}}">{{serviceModel.service_telephone__c}}</a><span ng-show="serviceModel.Operated_By__r.Office_Contact_Hours__c"> ({{serviceModel.Operated_By__r.Office_Contact_Hours__c}})</span></span>
                    </div>
                    <div ng-show="serviceModel.service_email__c">
                        <span style="font-weight:bold;" class=" fa fa-envelope-o" title="Contact Email Address"><span class="sr-only">contact email</span></span>
                        <span> <a href="mailto:{{serviceModel.service_email__c}}">{{serviceModel.service_email__c}}</a></span>
                    </div>
                    <div ng-show="serviceModel.service_website__c">
                        <span class="fa fa-globe" title="Contact Website"><span class="sr-only">service web site</span></span>
                        <span> <a href="{{serviceModel.service_website__c|cqNormalizeLink}}" target="_blank">{{serviceModel.service_website__c}}</a></span>
                    </div>
                </div>
            </div>
            <div ng-class="{'pull-clear':!smallContainer}" ng-show="(serviceModel.Funder_restriction__c||serviceModel.service_targetclientgroup__c)&&(serviceModel.Contact_first_name__c||serviceModel.Contact_last_name__c||serviceModel.service_telephone__c||serviceModel.service_email__c||serviceModel.service_website__c)"></div>
            <div ng-class="{'pull-left':!smallContainer}" ng-show="serviceModel.National_Service__c == false&&(serviceModel.Parking__c != null||serviceModel.Toilet_Facilities__c != null||serviceModel.Accessibility__c != null||serviceModel.Opening_Times_Guidebook__c != null||serviceModel.Record_Type_Name__c == 'External')">
                <h2>Amenities <span ng-show="serviceModel.service_operationhourscomment__c != null||servicemodel.record_type_name__c=='External' ">and Opening Times</span></h2>
                <div class="service-details-list">
                    <div ng-show="serviceModel.Parking__c">
                        <span title="Parking" style="cursor:default;"><span class="parking">P</span></span>
                        <span ng-show="serviceModel.Parking__c.toLowerCase() == 'yes-on site'">Parking on site</span>
                        <span ng-show="serviceModel.Parking__c.toLowerCase() == 'yes-off site'">Parking off site</span>
                        <span ng-show="serviceModel.Parking__c.toLowerCase() == 'yes'">Parking available</span>
                        <span ng-hide="serviceModel.Parking__c.toLowerCase().indexOf('yes') > -1">{{serviceModel.Parking__c}}</span>
                    </div>
                    <div ng-show="serviceModel.Toilet_Facilities__c">
                        <span style=" white-space:nowrap;">
                            <p class="fa fa-male" style="width: 8px;" title="Toilet facilities" aria-hidden="true"></p><p class="fa fa-female" style="width:8px;" title="Toilet facilities"></p>
                        </span>
                        <span ng-show="serviceModel.Toilet_Facilities__c.toLowerCase() == 'yes'">Toilet facilities available</span>
                        <span ng-show="serviceModel.Toilet_Facilities__c.toLowerCase() == 'no'">Toilet facilities not available</span>
                        <span ng-hide="serviceModel.Toilet_Facilities__c.toLowerCase() == 'yes' || serviceModel.Toilet_Facilities__c.toLowerCase() == 'no'">{{serviceModel.Toilet_Facilities__c}}</span>
                    </div>
                    <div ng-show="serviceModel.Accessibility__c">
                        <span class="fa fa-wheelchair" title="Accessibility" style="font-weight:bold; position: relative; left: 3px;" aria-hidden="true"></span>
                        <span ng-show="serviceModel.Accessibility__c.toLowerCase() == 'yes'">Accessible</span>
                        <span ng-show="serviceModel.Accessibility__c.toLowerCase() == 'no'">Not Accessible</span>
                        <span ng-hide="serviceModel.Accessibility__c.toLowerCase() == 'yes' || serviceModel.Accessibility__c.toLowerCase() == 'no'">{{serviceModel.Accessibility__c}}</span>
                    </div>
                    <div ng-show="serviceModel.Refreshments__c">
                        <span class="fa fa-coffee" title="Refreshments" aria-hidden="true"></span>
                        <span ng-show="serviceModel.Refreshments__c.toLowerCase() == 'yes'">Refreshments available</span>
                        <span ng-show="serviceModel.Refreshments__c.toLowerCase() == 'no'">Refreshments not available</span>
                        <span ng-hide="serviceModel.Refreshments__c.toLowerCase() == 'yes' || serviceModel.Refreshments__c.toLowerCase() == 'no'">{{serviceModel.Refreshments__c}}</span>
                    </div>
                    <div ng-show="serviceModel.Opening_Times_Guidebook__c && serviceModel.Record_Type_Name__c == 'Internal'">
                        <span class="fa fa-clock-o" title="Opening Times" aria-hidden="true"></span><span>Please contact the local office for details of opening times</span>
                    </div>
                    <div ng-show="serviceModel.Record_Type_Name__c == 'External'">
                        <span class="fa fa-clock-o" title="Opening Times" aria-hidden="true"></span><span>For opening times please contact the service provider</span>
                    </div>
                </div>
            </div>
            <div ng-class="{'pull-left':!smallContainer}" ng-show="serviceModel.Record_Type_Name__c == 'Internal'">
                <h2>Service Provided By</h2>
                <div class="service-details-list">
                    <div style="display:table-row">
                        <img ng-src="{{CODEBASE_ROOT}}img/alzsoc{{NAME_SEP}}jpg" /><span>Alzheimer's Society</span>
                    </div>
                </div>
            </div>
            <div class="clearfix">
                <div ng-class="{'pull-left':!smallContainer}" ng-show="serviceModel.Record_Type_Name__c == 'External'">
                    <h2>Service Provided by</h2>
                    <div class="service-details-list">
                        <div style="display:table-row">
                            <span>{{serviceModel.Operated_By__r.Name}}</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="clearfix" aria-hidden="true">
                <div id="cqc"></div>
            </div>
            <div class="clearfix" ng-show="serviceModel.service_postcode__c">
                <h2 ng-show="smallContainer">Service Location</h2>
                <p class="pull-left"><span class="fa fa-map-marker" title="Service address" aria-hidden="true"></span><span class="sr-only">service address</span>&nbsp;<span>{{serviceModel|dcAddress}}</span> <span ng-bind-html="serviceModel|dcPostcode"></span>&nbsp;&nbsp;&nbsp;&nbsp;</p>
                <p class="pull-left" ng-show="!serviceModel.National_Service__c&&(currentSearch && drivingData)"><span class="fa fa-car" title="Distance by road" aria-hidden="true"></span><span class="sr-only">distance by road</span><span>&nbsp;{{drivingData.distance.text}} from {{currentSearch.place}}</span></p>
            </div>
        </div>
    </div>
    <div cq-map="map" aria-hidden="true" ng-show="(serviceModel.Location__Latitude__s||serviceModel.Default_Location__r)  && resizeMap() "></div>

    <br />
    <div ng-show="providedBy" class="pull-left">
        <span style="color: #428bca;">Provided by</span> <a href="http://www.alzheimers.org.uk" style="font-weight: bold;">Alzheimer's Society</a>
    </div>
    <div class="pull-right">
        <a style="color: #777;" ui-sref="root.disclaimer()"><span class="fa fa-info-circle"></span>&nbsp;disclaimer</a>
        &nbsp;
        &nbsp;
        <a style="color: #777;" ui-sref="root.faq()"><span class="fa fa-question-circle"></span>&nbsp;faq</a>
    </div>
    <div ng-class="pull-clear"></div>
    <br />
    <div class="pull-left" style=" width: 100%; color: #777; font-size:10px; text-align: center;">
        <br />
        <span class="fa fa-copyright"></span>2015 Alzheimer's Society. Registered office at Devon House, 58 St Katharine's Way, London E1W 1LB<br />
        Alzheimer's Society is a registered Charity No. 296645. Registered as a company limited by guarantee and registered in England No. 2115499
    </div>
    <br />
    <br />
