
<div dc-scroll-top cq-focus-visibility>

    <form novalidate>

        <div style="display:table-row">
            <h1 ng-hide="smallContainer" style="display:table-cell;width:100%;vertical-align:top;padding-right:8px">Category Descriptions</h1>
            <div style="display:table-cell">
                <button class="btn btn-sm btn-primary" tabindex="1" onclick="goBack()" aria-label="return to previous page"><span class="fa fa-chevron-left"></span> Back</button>
            </div>
        </div>

        <div class="panel panel-default search-panel" ng-style="{'margin-top':smallContainer?'0px':'12px'}">

            <div class="panel-body" style="text-align:left" ng-style="{'margin-top':smallContainer?'0px':'12px'}">

                <ul class="catg-select" cq-focus-capture="list" role="group" aria-label="service category descriptions">
                    <li ng-repeat="catg in categories" tabindex="1">
                        <label for="{{catg.id}}"><span aria-label="{{catg.label}}. {{catg.description}}" id="{{catg.id}}" dc-category-desciption="{{catg.id}}"></span></label>
                    </li>
                </ul>
            </div>

        </div>
    </form>
</div>

