
<div dc-scroll-top cq-focus-visibility>

    <div>
        <h1 ng-show="title">{{title}}</h1>
    </div>

    <div class="panel panel-default search-panel " ng-style="{'margin-top':smallContainer?'0px':'12px'}">

        <div class="panel-body" style="text-align:center" ng-style="{'margin-top':smallContainer?'0px':'12px'}">

            <form novalidate>

                <p style="width:100%;text-align: center;" id="dco-lbl-1">Find services near{{smallContainer?'':' this postcode or place'}}</p>
                <input type="text" class="form-control" ng-model="address" required aria-labelledby="dco-lbl-1" placeholder=" {{smallContainer?'e.g.':'for example'}} &apos;sw19 1ae&apos; or &apos;wimbledon&apos; " ng-disabled=" statetransitioning">

                <div cq-alert dismiss="false"></div>

                <p style="margin-bottom: 8px" ng-style="{'margin-top':smallContainer?'6px':'18px'}" id="dco-svc-types-lable">(Optional) To find only specific service types tick them below</p>
                <ul class="catg-select" cq-focus-capture="list" role="group" aria-label="Optionally filter by service type">
                    <li ng-repeat="catg in categories">
                        <label for="{{catg.id}}"><input id="{{catg.id}}" type="checkbox" ng-model="catg.selected" ng-disabled="stateTransitioning">&nbsp;&nbsp;<span dc-category={{catg.id}}></span></label>
                    </li>
                </ul>
                <div ng-class="pull-clear"></div>
                <ul class="catg-select" cq-focus-capture="list" role="group" aria-label="Search for Alzheimer's Society Services only'">
                    <div ng-show="alzheimersOnly" style="padding-bottom: 12px;margin-bottom: 14px;border-bottom: 1px solid #b3d9e7"></div>
                    <li ng-show="alzheimersOnly">
                        <label for="alz1"><input id="alz1" type="checkbox" ng-model="alzOnly" ng-disabled="stateTransitioning">&nbsp;&nbsp;<span aria-hidden="true" title="Show Alzheimers Society Services only">Show Alzheimer&apos;s Society Services Only</span></label>
                    </li>
                    <div ng-style="{'margin-top':smallContainer?'0px':'8px'}">
                        <button class="btn btn-primary" ng-click="runSearch()" ng-disabled="stateTransitioning"><i class="fa fa-search"></i> Search</button>
                    </div>
                </ul>
                <div ng-class="pull-clear"></div>
                <div ng-show="providedBy" class="pull-left" ">
                    <span style=" color #428bca;">
                    Provided by</span> <a href="http://www.alzheimers.org.uk" style="font-weight: bold;">Alzheimer's Society</a>
                </div>
                <div class="pull-right">
                    <a style="color: #777;" ui-sref="root.disclaimer()"><span class="fa fa-info-circle"></span>&nbsp;disclaimer</a>
                    &nbsp;
                    &nbsp;
                    <a style="color: #777;" ui-sref="root.faq()"><span class="fa fa-question-circle"></span>&nbsp;faq</a>
                </div>
                <br />
                <br />
                <div ng-class="pull-clear"></div>
                <div style="color: #777; font-size:10px; margin-bottom: -5px; float:none; display: block; ">                    
                    <span class="fa fa-copyright"></span><span>
                        Alzheimer's Society. Registered office at Devon House, 58 St Katharine's Way, London E1W 1LB<br />
                        Alzheimer's Society is a registered Charity No. 296645. Registered as a company limited by guarantee and registered in England No. 2115499
                    </span>
                </div>

            </form>
        </div>
    </div>
</div>

