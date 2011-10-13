function Pageless(opt_options)
{
    this.stop();
    this.init(opt_options);
}

Pageless.prototype.init = function(opt_options)
{
    var options = opt_options || {};

    if (options['container'] == undefined) {
        options['container'] = this.container_ || window;
    }
    if (options['currentPage'] == undefined) {
        options['currentPage'] = this.current_page_ || 1;
    }
    if (options['totalPages'] == undefined) {
        options['totalPages'] = this.totalPages_ || 1;
    }
    if (options['distance'] == undefined) {
        options['distance'] = this.distance_ || 100;
    }
    if (options['loaderContainer'] == undefined){
        options['loaderContainer'] = this.loaderContainer_ || options['container']
    }
    if(options['loaderHtml'] == undefined){
        options['loaderHtml'] = this.loaderHtml_ || '\
            <div id="pageless-loader" style="display:none;text-align:center;width:100%;">\
            <div class="msg" style="color:#e9e9e9;font-size:2em">Loading...</div>\
            <img src="' + '/images/load.gif' + '" alt="loading more results" style="margin:10px auto" />\
            </div>';
    }
    if (options['url'] == undefined) {
        options['url'] = this.url_ || "";//TODO
    }
    if (options['parameterFunction'] == undefined) {
        options['parameterFunction'] = this.parameterFunction_ || "";//TODO
    }
    if (options['iScroller'] == undefined) {
        options['iScroller'] = this.iScroller_ || null;
    }

    this.setValues(options);

    var $loaderContainer = $(this.loaderContainer_);

    var oldLoader = $loaderContainer.find('#pageless-loader')
    if(oldLoader.length <= 0){
        this.loader_ = $(this.loaderHtml_);
        $loaderContainer.append(this.loader_);
    }
    else{
        this.loader_ = oldLoader;
    }
};

Pageless.prototype.setValues = function(options){
    this.container_ = options['container'];
    this.container_dom_ = $(this.container_);
    this.currentPage_ = options['currentPage'];
    this.totalPages_ = options['totalPages'];
    this.url_ = options['url'];
    this.parameterFunction_ = options['parameterFunction'];
    this.distance_ = options['distance'];
    this.loaderHtml_ = options['loaderHtml'];
    this.loaderContainer_ = options['loaderContainer'];
    this.iScroller_ = options['iScroller'];

    this.isLoading_ = this.isLoading || false;
};

Pageless.prototype.loading = function (bool) {
    (this.isLoading_ = bool)//TODO
    ? (this.loader_ && this.loader_.fadeIn('normal'))
    : (this.loader_ && this.loader_.fadeOut('normal'));
};

Pageless.prototype.distanceToBottom = function () {
    if(this.container_ === window){
        return $('#end_of_body').offset().top
        + $('#end_of_body').height()
        - window.innerHeight
        - document.body.scrollTop;

    /*        return $(document).height()
        - this.container_dom_.scrollTop()
        - this.container_dom_.height();*/
    }
    else{
        if(this.iScroller_){
            return this.iScroller_.scrollerH - this.iScroller_.wrapperH + this.iScroller_.y;
        }
        else{

            return this.container_dom_[0].scrollHeight
            - this.container_dom_.scrollTop()
            - this.container_dom_.height();
        }
    }
};

Pageless.prototype.watch = function(that){
    if(that.totalPages_ <= that.currentPage_){
        that.stop();
        that.loading(false);
        return;
    }
    else if(!that.isLoading_ && (that.distanceToBottom() < that.distance_)) {
        that.loading(true);

        // move to next page
        that.currentPage_++;

        params = {}

        if($.isFunction(that.parameterFunction_)){
            params = that.parameterFunction_();
        }

        $.extend(params, {
            page: that.currentPage_
        });

        $.get( that.url_, params, function (data) {
            if(that.loader_){                
                that.loading(false);
                if(that.iScroller_){
                    that.iScroller_.refresh();
                }
            }
            else{
        }
        }, 'script');
    }
};

Pageless.prototype.reset = function(opt_options){
    this.init(opt_options);
    this.stop();
    this.loading(false);
    this.start();
};

Pageless.prototype.start = function(){
    var that = this;
    this.container_dom_.bind('scroll.ss_pageless', function(){
        that.watch(that);
    });
    this.container_dom_.bind('resize.ss_pageless', function(){
        that.watch(that);
    });
};

Pageless.prototype.stop= function(){
    if(this.container_dom_){
        this.container_dom_.unbind('scroll.ss_pageless');
        this.container_dom_.unbind('resize.ss_pageless');
    }
};



