(function($){
  $.fn.playback = function() {

    return this.each(function(){
      $('.container', $(this)).children().wrapAll('<div class=control/>');

      var elem = $(this),
          control = $('.control', elem),
          total = control.children().size(),
          width = control.children().outerWidth(),
          height = control.children().outerHeight(),
          start = 0,
          next = 0,
          prev = 0,
          current = 0,
          active;

      function animate(direction) {
        if (!active) {
          active = true;

          prev = current;
          switch(direction) {
            case 'next':
              next = current + 1;
              next = total === next ? 0 : next;
            break;
            case 'prev':
              next = current - 1;
              next = next === -1 ? total-1 : next;
            break;
          }
          current = next;

          nextElem = control.children(':eq('+ next +')', elem);
          prevElem = control.children(':eq('+ prev +')', elem);

          nextElem.css({ zIndex: 100 });
          nextElem.css({ display: 'block' });

          function showNextElem() {
            nextElem.css({ zIndex: 0 });
            $('.old', nextElem).addClass('hide');
            $('.new', nextElem).addClass('show');
          }
          function hidePrevElem() {
            prevElem.css({ zIndex: 0 });
            $('.old', prevElem).removeClass('hide');
            $('.new', prevElem).removeClass('show');
          }

          switch(direction) {
            case 'next':
              control.animate({ height: nextElem.outerHeight() }, 200, function() {
                prevElem.css({ display: 'none' });
                hidePrevElem();
                showNextElem();
              });
            break;
            case 'prev':
              showNextElem();
              control.animate({ height: nextElem.outerHeight() }, 200, function() {
                hidePrevElem();
              });
              prevElem.css({ display: 'none' });
            break;
          }
          active = false;
        }
      }

      if (start > total) {
        start = total - 1;
      }

      $('.container', elem).css({
        overflow: 'hidden',
        position: 'relative'
      });

      control.children().css({
        position: 'absolute',
        top: 0,
        left: control.children().outerWidth(),
        zIndex: 0,
        display: 'none'
      });

      control.css({
        position: 'relative',
        width: (width + width + width),
        height: height,
        left: -width
      });

      $('.container', elem).css({ display: 'block' });
      control.children(':eq(' + start + ')').show();

      $('body').keydown(function(e) {
        if(e.keyCode == 37) {
          animate('prev');
        }
        else if(e.keyCode == 39) {
          animate('next');
        }
      });
    });
  };
})(jQuery);
