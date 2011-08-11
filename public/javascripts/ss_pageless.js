function Pageless(opt_options)
{
    var options = opt_options || {};

    if (options['container'] == undefined) {
        options['container'] = window;
    }
    if (options['currentPage'] == undefined) {
        options['currentPage'] = 1;
    }
    if (options['totalPages'] == undefined) {
        options['totalPages'] = 1;
    }
    if (options['distance'] == undefined) {
        options['distance'] = 100;
    }
    if (options['loaderContainer'] == undefined){
        options['loaderContainer'] = options['container']
    }
    if(options['loaderHtml'] == undefined){
        options['loaderHtml'] = '\
            <div id="pageless-loader" style="display:none;text-align:center;width:100%;">\
            <div class="msg" style="color:#e9e9e9;font-size:2em">Loading...</div>\
            <!--<img src="' + this.loaderImage_ + '" alt="loading more results' + this.totalPages_ + '" style="margin:10px auto" />-->\
            </div>';
    }

    this.setValues(options);


    this.loader_ = $(this.loaderHtml_);
    var $loaderContainer = $(this.loaderContainer_);

    var oldLoader = $loaderContainer.find('#pageless-loader')
    if(oldLoader.length <= 0){
        $loaderContainer.append(this.loader_);
    }
}

Pageless.prototype.setValues = function(options){
    this.container_ = options['container'];
    this.container_dom_ = $(this.container_);
    this.currentPage_ = options['currentPage'];
    this.totalPages_ = options['totalPages'];
    this.url_ = options['url'];
    this.parameterFunction_ = options['parameterFunction'];
    this.distance_ = options['distance'];
    this.loaderHtml_ = options['loaderHtml'];
    this.loaderContainer = options['loaderContainer'];

    this.isLoading_ = false;
};

Pageless.prototype.loading = function (bool) {
    (this.isLoading_ = bool)//TODO
    ? (this.loader_ && this.loader_.fadeIn('normal'))
    : (this.loader_ && this.loader_.fadeOut('normal'));
};

Pageless.prototype.distanceToBottom = function () {
    return (this.container_ === window)
    ? $(document).height()
    - this.container_dom_.scrollTop()
    - this.container_dom_.height()
    : this.container_dom_[0].scrollHeight
    - this.container_dom_.scrollTop()
    - this.container_dom_.height();
};

Pageless.prototype.watch = function(){
    if(this.totalPages_ <= this.currentPage_){
        stop();
        return;
    }
    else if(!this.isLoading_ && (this.distanceToBottom() < this.distance_)) {
        this.loading(true);

        // move to next page
        this.currentPage_++;

        params = {}

        if($.isFunction(this.parameterFunction_)){
            params = this.parameterFunction_();
        }

        $.extend(params, {
            page: this.currentPage_
        });

        var that = this;
        $.get( that.url_, params, function (data) {
            that.loader_ ? that.loader_.before(data) : element.append(data);//TODO
            that.loading(false);
        });
    }
};

Pageless.prototype.start = function(){
    var that = this;
    this.container_dom_.bind('scroll.ss_pageless', this.watch(that));
    this.container_dom_.bind('resize.ss_pageless', function(){
        this.watch;
    });
};

Pageless.prototype.stop= function(){
    this.container_dom_.unbind('scroll.ss_pageless');
    this.container_dom_.unbind('resize.ss_pageless');
};



