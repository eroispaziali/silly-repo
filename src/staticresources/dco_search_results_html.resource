
<div dc-scroll-top cq-focus-visibility>

    <div dc-tip-tour></div>

    <div class="clearfix">
        <h1 class="pull-left" tabindex="-1">{{title}}</h1>
        <div class="pull-right">
            <div class="pull-left" ng-hide="smallContainer" cq-page-controls="pageSizeButton" for="service-panel" style="margin-right:10px"></div>
            <div class="pull-left" cq-page-controls="prevButton" for="service-panel" style="margin-right:4px"></div>
            <div class="pull-left" cq-page-controls="nextButton" for="service-panel"></div>
        </div>
    </div>


    <div dc-category-popover="selectedCategories"></div>
    <div dc-distance-popover="selectedDistance"></div>

    <div class="panel panel-default service-panel panelSearchBar" id="search-bar">
        <div class="panel-heading">

            <div class="panel-title" style="display:table-row;vertical-align: top;">

                <div ng-hide="smallContainer" class="search-block" style="display:table-cell;width:100%">

                    <div class="input-group" style="width:100%">
                        <span class="input-group-btn">
                            <button class="btn-norm btn dco-BarControl" cq-popover="{id:'dcCategoryPopover'}" ng-disabled="stateTransitioning">
                                <span dc-category-text="selectedCategories"></span> <span class="fa fa-caret-down" style="color:#555;position: relative;top:1px;"></span>
                            </button>
                        </span>
                        <span class="input-group-btn ">
                            <button class="btn-norm btn dco-BarControl" cq-popover="{id:'dcDistancePopover'}" ng-disabled="stateTransitioning">
                                <span dc-distance-text="selectedDistance"></span>  <span class="fa fa-caret-down" style="color:#555;position: relative;top:1px;left:1px"></span>
                            </button>
                        </span>
                        <input type="text" class="form-control input-mid dco-BarControl" ng-model="placedata.selectedPlace" cq-return-key="selectPlace()" aria-label="change the search location" ng-disabled="stateTransitioning" />
                        <span class="input-group-btn">
                            <button class="btn btn-norm dco-BarControl" type="button" ng-click="selectPlace()" ng-disabled="stateTransitioning">&nbsp;<span class="fa fa-search"></span><span ng-show="largeContainer"> search</span></button>
                        </span>
                    </div>
                </div>                
                <div style="display:table-cell;vertical-align: top;text-align:left; padding:3px 0 0 0;width:100%">
                    <div ng-show="smallContainer"><button class='btn btn-sm btn-primary' ng-click="newSearch()" ng-disabled="stateTransitioning"><span class="fa fa-chevron-left"></span> Search</button></div>
                </div>

                <div style="display:table-cell;vertical-align: top;padding:3px 0 0 8px">
                    <div ng-show="smallContainer"><span dc-distance-select="selectedDistance"></span></div>
                </div>

            </div>

            <div cq-alert="low" dismiss="false" fadeout="true"></div>

        </div>
    </div>

    <div class="panel panel-default service-panel" id="service-panel" cq-paginate="serviceList as pageHolder" cq-page="page">

        <div ng-if="!pageHolder.content.length" ng-class="{opacity0:stateTransitioning}">
            <div style="text-align: center;font-size: 110%;margin-top:20px">
                No {{pageHolder.pageRequest.query.cat|dcSearchCatFormatter}} were found within {{pageHolder.pageRequest.query.dist}} miles of {{pageHolder.pageRequest.query.place}}<br>
                You can use the controls in the bar above to modify the search
            </div>
        </div>

        <div ui-view class="panel-body service-list"></div>

        <div class="panel-footer clearfix">

            <div class="pull-right ">
                <span cq-page-controls="pageNumberAndCount" ng-hide="smallContainer"></span>&nbsp;
                <span cq-page-controls="prevButton,nextButton"></span>
            </div>
            <span ng-hide="smallContainer" cq-page-controls="elementRangeAndCount"></span>
            <span cq-page-controls="pageNumberAndCount" ng-show="smallContainer"></span>
            <div ng-class="pull-clear"></div>
            <br />
            <div ng-show="providedBy" class="pull-left" >
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
        </div>

    </div>
</div>
