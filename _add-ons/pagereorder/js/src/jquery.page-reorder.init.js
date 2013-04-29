// Generated by CoffeeScript 1.6.2
/*
Author:   Jannis Gundermann
Twitter:  @jannisg
Web:      http://jannisgundermann.com/

@license: Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
@see:     http://creativecommons.org/licenses/by-sa/3.0/
*/


(function() {
  $(function() {
    /* Feature Tests
    */

    var $flashBar, $sortable, $subs, $tree, active_class, eligible_class, flashes, hasDragAndDrop, icon_markup, ignore_class, namespace, useAjax;

    hasDragAndDrop = 'draggable' in document.createElement('span');
    if (!hasDragAndDrop) {
      return false;
    }
    /* Setup Flash Message JS Helper
    */

    /* Store Success/Error Templates.
    */

    flashes = {
      success: _.template("<div id=\"flash-msg\" class=\"success\">\n  <span class=\"icon\">8</span>\n  <span class=\"msg\"><%= message %></p>\n</div>"),
      error: _.template("<div id=\"flash-msg\" class=\"error\">\n  <span class=\"icon\">c</span>\n  <span class=\"msg\"><%= message %></p>\n</div>")
    };
    /* Cache the container.
    */

    $flashBar = $('#status-bar');
    /* Setup an event based system for showing flashes.
    */

    $flashBar.on('flash', function(e, data) {
      var $existingMessage, delay, html;

      delay = 50;
      if ($('#flash-msg').length) {
        delay = 150;
        $existingMessage = $('#flash-msg');
        $existingMessage.stop(true).fadeOut(delay, function() {
          return $existingMessage.remove();
        });
      }
      html = flashes[data.status]({
        message: data.message
      });
      $flashBar.prepend(html);
      $('#flash-msg').delay(delay).animate({
        'margin-top': '0'
      }, 900, 'easeOutBounce').delay(3000).animate({
        'margin-top': '-74px'
      }, 900, 'easeInOutBack', function() {
        return $(this).remove();
      });
      return void 0;
    });
    /* Vars
    */

    useAjax = true;
    $tree = $('#page-tree');
    $subs = $tree.find('.subpages');
    namespace = 'page-order';
    active_class = "" + namespace + "-active";
    ignore_class = "" + namespace + "-ignore";
    eligible_class = "" + namespace + "-sortable";
    icon_markup = "<div class=\"" + namespace + "\">\n  <div class=\"" + namespace + "__block\">\n    <div class=\"" + namespace + "__icon\">&#11021;</div>\n  </div>\n</div>";
    /* Prepare the #page-tree nodes
    */

    $tree.children().each(function() {
      var $sortable, slug, _ref;

      $sortable = $(this);
      slug = $.trim($sortable.find('.slug-preview').first().text());
      if (slug === "/") {
        return $sortable.addClass(ignore_class);
      } else {
        $sortable.addClass(eligible_class);
        return (_ref = $sortable.find('> .page-wrapper')) != null ? _ref.prepend(icon_markup) : void 0;
      }
    });
    /* Init the sortable plugin.
    */

    $sortable = $('#page-tree').sortable({
      items: "." + eligible_class,
      handle: "." + namespace + "__block"
    });
    /* Handle special events on sorting.
    */

    return $sortable.on({
      'dragstart': function(e) {
        $tree.addClass(active_class);
        return $subs.slideUp({
          duration: 350,
          easing: 'easeInExpo'
        });
      },
      'dragend': function(e) {
        $tree.removeClass(active_class);
        return $subs.slideDown({
          duration: 700,
          easing: 'easeOutExpo'
        });
      },
      'sortupdate': function(e) {
        var $page, location, order, orderJSON, page, pages, url;

        pages = $(this).find('> .page');
        order = (function() {
          var _i, _len, _results;

          _results = [];
          for (_i = 0, _len = pages.length; _i < _len; _i++) {
            page = pages[_i];
            $page = $(page);
            _results.push({
              index: $page.index(),
              url: $.trim($page.find('.slug-preview').first().text())
            });
          }
          return _results;
        })();
        orderJSON = JSON.stringify(order);
        if (useAjax) {
          url = '/TRIGGER/pagereorder/reorder_folders';
          $.ajax(url, {
            type: 'GET',
            data: {
              order: orderJSON
            },
            success: function(data, status, jqxhr) {
              return $flashBar.triggerHandler('flash', {
                status: 'success',
                message: 'Page order saved successfully!'
              });
            },
            error: function(jqxhr, status, error) {
              return $flashBar.triggerHandler('flash', {
                status: 'error',
                message: 'There was an error saving your page order. Please try again or ask for help in the forums.'
              });
            }
          });
        } else {
          location = window.location;
          url = "" + location.protocol + "//" + location.host + "/TRIGGER/pagereorder/reorder_folders?order=" + orderJSON;
          window.location = url;
        }
        return void 0;
      }
    });
  });

}).call(this);
