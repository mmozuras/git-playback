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
          active,
          position,
          direction;

      function animate(direction) {
        if (!active) {
          active = true;
          switch(direction) {
            case 'next':
              prev = current;
              next = current + 1;
              next = total === next ? 0 : next;
              position = width*2;
              direction = -width*2;
              current = next;
            break;
            case 'prev':
              prev = current;
              next = current - 1;
              next = next === -1 ? total-1 : next;
              position = 0;
              direction = 0;
              current = next;
            break;
          }

          control.children(':eq('+ next +')').css({
            left: position,
            display: 'block'
          });

          control.animate({ left: direction }, 350, function(){
            control.css({ left: -width });

            control.children(':eq('+ next +')').css({
              left: width,
              zIndex: 5
            });

            control.children(':eq('+ prev +')').css({
              left: width,
              display: 'none',
              zIndex: 0
            });

            active = false;
          });
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
