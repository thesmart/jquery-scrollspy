
/**!
 * Extend jquery with a scrollspy plugin.
 * This watches elements and fires events when they are scrolled partially into viewport.
 *
 * throttle() and getTime() taken from Underscore.js
 * https://github.com/jashkenas/underscore
 *
 * @author Copyright 2013 John Smart
 * @license https://raw.github.com/thesmart/jquery-scrollspy/master/LICENSE
 * @see https://github.com/thesmart
 * @version 0.2.0
 */
(function($) {
  var $window, THROTTLE_MS, bindSpy, checkIntersect, childCoordinates, getTime, newUid, onSlow, parentCoordinates, throttle, viewPortCoordinates, _uid;
  THROTTLE_MS = 200;
  $window = $(window);
  _uid = 0;

  /*
   * unique id generator
   */
  newUid = function() {
    var id;
    id = "uid-" + _uid;
    _uid += 1;
    return id;
  };

  /*
   * Get ms since epoch
   * @license https://raw.github.com/jashkenas/underscore/master/LICENSE
   * @returns {number}
   */
  getTime = Date.now || function() {
    return new Date().getTime();
  };

  /*
   * Used to slow the ridiculously fast scroll and resize events.
   *
   * Returns a function, that, when invoked, will only be triggered at most once
   * during a given window of time. Normally, the throttled function will run
   * as much as it can, without ever going more than once per `wait` duration;
   * but if you'd like to disable the execution on the leading edge, pass
   * `{leading: false}`. To disable execution on the trailing edge, ditto.
   * @license https://raw.github.com/jashkenas/underscore/master/LICENSE
   * @returns {Function}
   */
  throttle = function(func, wait, options) {
    var args, context, later, previous, result, timeout;
    if (options == null) {
      options = {};
    }
    context = void 0;
    args = void 0;
    result = void 0;
    timeout = null;
    previous = 0;
    later = function() {
      previous = (options.leading === false ? 0 : getTime());
      timeout = null;
      result = func.apply(context, args);
      context = args = null;
    };
    return function() {
      var now, remaining;
      now = getTime();
      if (!previous && options.leading === false) {
        previous = now;
      }
      remaining = wait - (now - previous);
      context = this;
      args = arguments;
      if (remaining <= 0) {
        clearTimeout(timeout);
        timeout = null;
        previous = now;
        result = func.apply(context, args);
        context = args = null;
      } else {

      }
      if (!timeout && options.trailing !== false) {
        timeout = setTimeout(later, remaining);
      }
      return result;
    };
  };

  /*
   * provides a unique throttled event handler
   */
  onSlow = function(jQuery, event, fn, wait) {
    var handlers, throttleFn;
    handlers = jQuery.data("scrollSpy:onSlow:" + event);
    if (handlers) {
      handlers.push(fn);
      return this;
    }
    handlers = [fn];
    jQuery.data("scrollSpy:onSlow:" + event, handlers);
    throttleFn = throttle(function() {
      return $.each(handlers, function(i, handler) {
        handler.call();
        return true;
      });
    }, wait);
    jQuery.on(event, throttleFn);
  };

  /*
   * Calculate rectangle coordinates of the viewport
   */
  viewPortCoordinates = function() {
    var coordinates;
    coordinates = {};
    coordinates.top = $window.scrollTop();
    coordinates.left = $window.scrollLeft();
    coordinates.bottom = coordinates.top + $window.height();
    coordinates.right = coordinates.left + $window.width();
    return coordinates;
  };

  /*
   * Calculate rectangle coordinates of a scrollable parent element
   */
  parentCoordinates = function($el) {
    var coordinates, offsets, padding;
    offsets = $el.offset();
    padding = $el.css(['paddingTop', 'paddingRight', 'paddingBottom', 'paddingLeft']);
    $.each(padding, function(key, px) {
      padding[key] = px ? parseFloat(px.slice(0, -2)) : 0;
      if (isNaN(padding[key])) {
        return padding[key] = 0;
      }
    });
    coordinates = {};
    coordinates.top = offsets.top + padding.paddingTop;
    coordinates.left = offsets.left + padding.paddingLeft;
    coordinates.right = coordinates.left + $el.width();
    coordinates.bottom = coordinates.top + $el.height();
    return coordinates;
  };

  /*
   * Calculate rectangle coordinates of an element
   */
  childCoordinates = function($el) {
    var coordinates, offsets;
    offsets = $el.offset();
    coordinates = {};
    coordinates.top = offsets.top;
    coordinates.left = offsets.left;
    coordinates.right = coordinates.left + $el.outerWidth();
    coordinates.bottom = coordinates.top + $el.outerHeight();
    return coordinates;
  };

  /*
   * Calculate if two rectangular elements intersect
   * @param {Object} coordinates of an element
   * @param {Object} coordinates of an element
   * @returns {boolean}    True if intersecting / overlapping
   */
  checkIntersect = function(a, b) {
    return a.left < b.right && a.right > b.left && a.top < b.bottom && a.bottom > b.top;
  };

  /*
   * Binds the spying logic to a contect necessary for element intersection calculations
   */
  bindSpy = function(uid, $parent, selector) {
    return function() {
      var $children, pCoords;
      if ($parent === $window) {
        $children = $(selector);
        pCoords = viewPortCoordinates();
      } else {
        if (typeof selector === 'string') {
          $children = $parent.find(selector);
        } else if (selector) {
          $children = $(selector);
        }
        pCoords = parentCoordinates($parent);
      }
      $children.each(function(i, child) {
        var $child, cCoords, hasEntered, isIntersected;
        $child = $(child);
        hasEntered = $child.data("scrollSpy:" + uid);
        cCoords = childCoordinates($child);
        isIntersected = checkIntersect(pCoords, cCoords);
        $child.data("scrollSpy:" + uid, isIntersected);
        if (isIntersected && !hasEntered) {
          $child.triggerHandler('scrollSpy:enter');
        } else if (hasEntered && !isIntersected) {
          $child.triggerHandler('scrollSpy:exit');
        }
      });
      return true;
    };
  };

  /*
   * Enables ScrollSpy on elements matching the selector
   * NOTE: only call after DOM is loaded
   *
   * @param {string} selector    A selector statement.
   * @param {Object=} options    Optional.
   *             * throttle {number} internal. scroll event throttling. throttling. Default: 100 ms
   *             * parent {Element|jQuery} a parent scrollable element to track. Default: undefined|null
   */
  $.scrollSpy = function(selector, options) {
    var $parent, $selector, spyFn, uid;
    if (options == null) {
      options = {};
    }
    options.throttle || (options.throttle = THROTTLE_MS);
    if (options.parent) {
      if (options.parent === window) {
        $parent = $window;
      } else if (options.parent.length && options.parent[0] === window) {
        $parent = $window;
      } else {
        $parent = $(options.parent).first();
      }
    } else {
      $parent = $window;
    }
    if (typeof selector === 'string') {
      $selector = $parent.find(selector);
    } else {
      $selector = $(selector);
      selector = $selector;
    }
    uid = newUid();
    spyFn = bindSpy(uid, $parent, selector);
    setTimeout(function() {
      onSlow($parent, 'scroll', spyFn, options.throttle);
      onSlow($window, 'resize', spyFn, options.throttle);
      spyFn();
    }, 1);
    return $selector;
  };

  /*
   * Enables ScrollSpy on elements in a jQuery collection
   * e.g. $('.scrollSpy').scrollSpy()
   * NOTE: only call after DOM is loaded
   */
  $.fn.scrollSpy = function(selector, options) {
    if (options == null) {
      options = {};
    }
    this.each(function(i, parent) {
      options.parent = parent;
      return $.scrollSpy(selector, options);
    });
    return this;
  };

  /*
   * Listen for window throttled resize events
   * e.g. $.resizeSpy().on('resizeSpy:resize', fn)
   * NOTE: only call after DOM is loaded
   */
  $.resizeSpy = function(options) {
    $.resizeSpy = function() {
      return $window;
    };
    options.throttle || (options.throttle = THROTTLE_MS);
    onSlow($window, 'resize', function() {
      $window.triggerHandler('resizeSpy:resize');
      return $window.triggerHandler('scrollSpy:resize');
    }, options.throttle);
    return $window;
  };
})(jQuery);