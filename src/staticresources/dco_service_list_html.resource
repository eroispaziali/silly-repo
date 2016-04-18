
<div ng-repeat="item in pageHolder.content" ng-view>

    <div>
        <h2 class="title">
            <a analytics-on analytics-event="{{item.National_Service__c?item.Name:item.Service_Web_Name__c}}" ui-sref="root.detail({serviceId: item.Id})">{{item.National_Service__c?item.Name:item.Service_Web_Name__c}}</a>
        </h2>
        <ul class="meta clearfix">
            <li ng-hide="item.National_Service__c"><em title="Geographic distance">{{item.distance}} {{item.distance==1?'mile':'miles'}}</em><span class="sr-only"> from {{currentSearch.place}}</span></li>
            <li ng-show="item.National_Service__c"><b>National</b><span class="sr-only"> service</span></li>
            <li ng-hide="item.National_Service__c"><span class="fa fa-map-marker" title="Address" aria-hidden="true"></span><span class="sr-only">address</span><span>&nbsp;{{item|dcAddress}}  <b ng-bind-html="item|dcPostcode"></b></span></li>
            <li ng-show="item.National_Service__c && item.service_telephone__c"><span class="fa fa-phone" title="Telephone number" aria-hidden="true"><span class="sr-only">telephone number</span></span>&nbsp;{{item.service_telephone__c}}</li>
            <li ng-show="item.National_Service__c && (item.service_type__c=='Online forum' || item.service_type__c=='Website')">
                <span class="fa fa-globe" title="Website" aria-hidden="true"><span class="sr-only">website url</span></span>&nbsp;
                <a style="color: #777;" href="{{item.service_website__c|cqNormalizeLink}}" target="_blank">{{item.service_website__c}}</a>
            </li>
        </ul>

        <ul class="meta clearfix" ng-show="!alzOnly">
            <li><div>Service provided by:<span ng-show="item.Record_Type_Name__c == 'Internal'">&nbsp;Alzheimer's Society</span><span ng-show="item.Record_Type_Name__c == 'External'">&nbsp;{{item.Operated_By__r.Name}}</span></div></li>
        </ul>
        <div class="body">{{item.service_description__c}}</div>

        <ul ng-show="!item.National_Service__c" class="meta clearfix">
            <li ng-show="item.getCategories().length&&item.getCategories().length == 1 && !showHelp"><span style="color: #777;"><span class="sr-only">service type</span><span dc-category="{{item.getCategories()[0].id}}"></span></span></li>
            <li ng-show="item.getCategories().length&&item.getCategories().length > 1 && !showHelp"><span style="color: #777;"><span class="sr-only">service type</span><span dc-category-icons="item.getCategories()"></span> <span>{{item.service_type__c}}</span></span></li>
            <li ng-show="item.getCategories().length&&item.getCategories().length == 1 && showHelp"><a style="color: #777;" ui-sref="root.category()"><span class="sr-only">service type</span><span dc-category="{{item.getCategories()[0].id}}"></span></a></li>
            <li ng-show="item.getCategories().length&&item.getCategories().length > 1 && showHelp"><a style="color: #777;" ui-sref="root.category()"><span class="sr-only">service type</span><span dc-category-icons="item.getCategories()"></span> <span>{{item.service_type__c}}</span></a></li>
            <li ng-show="item.Parking__c"><span class="parking" title="Parking" aria-hidden="true">P</span><span class="sr-only">parking</span><span>&nbsp;{{item.Parking__c}}</span></li>
            <li ng-show="item.Toilet_Facilities__c"><span class="fa fa-male" title="Toilet facilities" aria-hidden="true"></span><span class="fa fa-female" title="Toilet facilities"></span><span class="sr-only">toilet facilities</span><span>&nbsp;{{item.Toilet_Facilities__c}}</span></li>
            <li ng-show="item.Accessibility__c"><span class="fa fa-wheelchair" title="Accessibility" style="font-weight:bold;" aria-hidden="true"></span><span class="sr-only">accessibility</span><span>&nbsp;{{item.Accessibility__c}}</span></li>
        </ul>
    </div>

</div>

