// tipsy, facebook style tooltips for jquery
// version 1.0.0a
// (c) 2008-2010 jason frame [jason@onehackoranother.com]
// released under the MIT license

(function($) {
    
    function maybeCall(thing, ctx) {
        return (typeof thing == 'function') ? (thing.call(ctx)) : thing;
    };
    
    function Tipsy(element, options) {
        this.$element = $(element);
        this.options = options;
        this.enabled = true;
        this.fixTitle();
    };
    
    Tipsy.prototype = {
        position: function(){
            var $tip = this.tip();

            var pos = $.extend({}, this.$element.offset(), {
                width: this.$element[0].offsetWidth,
                height: this.$element[0].offsetHeight
            });

            var actualWidth = $tip[0].offsetWidth,
            actualHeight = $tip[0].offsetHeight,
            gravity = maybeCall(this.options.gravity, this.$element[0]);

            var tp;
            switch (gravity.charAt(0)) {
                case 'n':
                    tp = {
                        top: pos.top + pos.height + this.options.offset,
                        left: pos.left + pos.width / 2 - actualWidth / 2
                    };
                    break;
                case 's':
                    tp = {
                        top: pos.top - actualHeight - this.options.offset,
                        left: pos.left + pos.width / 2 - actualWidth / 2
                    };
                    break;
                case 'e':
                    tp = {
                        top: pos.top + pos.height / 2 - actualHeight / 2,
                        left: pos.left - actualWidth - this.options.offset
                    };
                    break;
                case 'w':
                    tp = {
                        top: pos.top + pos.height / 2 - actualHeight / 2,
                        left: pos.left + pos.width + this.options.offset
                    };
                    break;
            }

            if (gravity.length == 2) {
                if (gravity.charAt(1) == 'w') {
                    tp.left = pos.left + pos.width / 2 - 15;
                } else {
                    tp.left = pos.left + pos.width / 2 - actualWidth + 15;
                }
            }

            //console.log(tp);
            $tip.css(tp);

            $tip.removeClass('tipsy-n tipsy-s tipsy-e tipsy-w tipsy-ne tipsy-nw tipsy-se tipsy-sw')
            $tip.addClass('tipsy-' + gravity);

            $tip.find('.tipsy-arrow')[0].className = 'tipsy-arrow tipsy-arrow-' + gravity.charAt(0);
        },

        show: function() {
            var title = this.getTitle();
            if (title && this.enabled) {
                var $tip = this.tip();
                
                $tip.find('.tipsy-inner')[this.options.html ? 'html' : 'text'](title);
                $tip[0].className = 'tipsy'; // reset classname in case of dynamic gravity
                $tip.remove().css({
                    top: 0,
                    left: 0,
                    visibility: 'hidden',
                    display: 'block'
                }).prependTo(document.body);
                
                this.position();

                if (this.options.className) {
                    $tip.addClass(maybeCall(this.options.className, this.$element[0]));
                }
                
                if (this.options.fade) {
                    $tip.stop().css({
                        opacity: 0,
                        display: 'block',
                        visibility: 'visible'
                    }).animate({
                        opacity: this.options.opacity
                    });
                } else {
                    $tip.css({
                        visibility: 'visible',
                        opacity: this.options.opacity
                    });
                }
            }
        },
        
        hide: function() {
            if (this.options.fade) {
                this.tip().stop().fadeOut(function() {
                    $(this).remove();
                });
            } else {
                this.tip().remove();
            }
        },
        
        fixTitle: function() {
            var $e = this.$element;
            if ($e.attr('title') || typeof($e.attr('original-title')) != 'string') {
                $e.attr('original-title', $e.attr('title') || '').removeAttr('title');
            }
        },
        
        getTitle: function() {
            var title, $e = this.$element, o = this.options;
            this.fixTitle();
            var title, o = this.options;
            if (typeof o.title == 'string') {
                title = $e.attr(o.title == 'title' ? 'original-title' : o.title);
            } else if (typeof o.title == 'function') {
                title = o.title.call($e[0]);
            }
            title = ('' + title).replace(/(^\s*|\s*$)/, "");
            return title || o.fallback;
        },
        
        tip: function() {
            if (!this.$tip) {
                this.$tip = $('<div class="tipsy"></div>').html('<div class="tipsy-arrow"></div><div class="tipsy-inner"></div>');
            }
            return this.$tip;
        },
        
        validate: function() {
            if (!this.$element[0].parentNode) {
                this.hide();
                this.$element = null;
                this.options = null;
            }
        },
        
        enable: function() {
            this.enabled = true;
        },
        disable: function() {
            this.enabled = false;
        },
        toggleEnabled: function() {
            this.enabled = !this.enabled;
        }
    };
    
    $.fn.tipsy = function(options) {
        
        if (options === true) {
            return this.data('tipsy');
        } else if (typeof options == 'string') {
            var tipsy = this.data('tipsy');
            if (tipsy) tipsy[options]();
            return this;
        }
        
        options = $.extend({}, $.fn.tipsy.defaults, options);
        
        function get(ele) {
            var tipsy = $.data(ele, 'tipsy');
            if (!tipsy) {
                tipsy = new Tipsy(ele, $.fn.tipsy.elementOptions(ele, options));
                $.data(ele, 'tipsy', tipsy);
            }
            return tipsy;
        }
        
        function enter() {
            var tipsy = get(this);
            tipsy.hoverState = 'in';
            if (options.delayIn == 0) {
                tipsy.show();
            } else {
                tipsy.fixTitle();
                setTimeout(function() {
                    if (tipsy.hoverState == 'in') tipsy.show();
                }, options.delayIn);
            }
        };
        
        function leave() {
            var tipsy = get(this);
            tipsy.hoverState = 'out';
            if (options.delayOut == 0) {
                tipsy.hide();
            } else {
                setTimeout(function() {
                    if (tipsy.hoverState == 'out') tipsy.hide();
                }, options.delayOut);
            }
        };
        
        if (!options.live) this.each(function() {
            get(this);
        });
        
        if (options.trigger != 'manual') {
            var binder   = options.live ? 'live' : 'bind',
            eventIn  = options.trigger == 'hover' ? 'mouseenter' : 'focus',
            eventOut = options.trigger == 'hover' ? 'mouseleave' : 'blur';
            this[binder](eventIn, enter)[binder](eventOut, leave);
        }
        
        return this;
        
    };
    
    $.fn.tipsy.defaults = {
        className: null,
        delayIn: 0,
        delayOut: 0,
        fade: false,
        fallback: '',
        gravity: 'n',
        html: false,
        live: false,
        offset: 0,
        opacity: 0.8,
        title: 'title',
        trigger: 'hover'
    };
    
    // Overwrite this method to provide options on a per-element basis.
    // For example, you could store the gravity in a 'tipsy-gravity' attribute:
    // return $.extend({}, options, {gravity: $(ele).attr('tipsy-gravity') || 'n' });
    // (remember - do not modify 'options' in place!)
    $.fn.tipsy.elementOptions = function(ele, options) {
        return $.metadata ? $.extend({}, options, $(ele).metadata()) : options;
    };
    
    $.fn.tipsy.autoSocialStreet = function(){
        var $this = $(this);

        prefer = $this.data('gravity');
        var dirNS = 'n' == prefer[0] || 's' == prefer[0] ? prefer[0] : false;
        var dirEW = !dirNS ? prefer[0] : prefer.length > 1 ? prefer[1] : false;

        var tipsy = $this.data('tipsy');
        var $tip = tipsy.tip();

        var tipWidth = $tip[0].offsetWidth,
        tipHeight = $tip[0].offsetHeight;

        var MARGIN = 15;
        var boundTop = $(document).scrollTop() + MARGIN,
        boundBottom = $(document).scrollTop() + $(window).height() - MARGIN,
        boundLeft = $(document).scrollLeft() + MARGIN,
        boundRight = $(document).scrollLeft() + $(window).width() - MARGIN;

        if ($this.offset().top + (dirEW ? this.offsetHeight/2 : 0) - tipHeight < boundTop) dirNS = 'n';
        if ($this.offset().top + this.offsetHeight - (dirEW ? this.offsetHeight/2 : 0) + tipHeight > boundBottom) dirNS = 's';

        if ($this.offset().left + (dirNS ? this.offsetWidth/2 : 0) - tipWidth < boundLeft) dirEW = 'w';
        if ($this.offset().left + this.offsetWidth - (dirNS ? this.offsetWeight/2 : 0) + tipWidth > boundRight) dirEW = 'e';

        //console.log((dirNS ? dirNS : '') + (dirEW ? dirEW : ''));
        return (dirNS ? dirNS : '') + (dirEW ? dirEW : '');
    }

    $.fn.tipsy.elementGravity = function() {
        return $(this).data('gravity');
    };
   
})(jQuery);