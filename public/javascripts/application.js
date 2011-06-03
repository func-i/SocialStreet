$.fn.serializeObject = function()
{
    var o = {};
    var a = this.serializeArray();
    $.each(a, function() {
        if (o[this.name] !== undefined) {
            if (!o[this.name].push) {
                o[this.name] = [o[this.name]];
            }
            o[this.name].push(this.value || '');
        } else {
            o[this.name] = this.value || '';
        }
    });
    return o;
};

$(function() {
  $('.remove-parent').live('click', function(event) {
    var $this = $(this);
    var parentSelector = $this.data('parent-selector');
    if (parentSelector) {
      $this.closest(parentSelector).remove();
    }
    $this.trigger('ss:removed');
    return false;
  });
})