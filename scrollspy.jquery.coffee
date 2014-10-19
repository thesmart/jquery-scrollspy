###*!
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
###

(($) ->

  # defaults
  THROTTLE_MS = 200

  # bound to the window one which the script is linked
  $window = $(window)

  # unique id generator
  _uid = 0
  newUid = ->
    id = "uid-#{_uid}"
    _uid += 1
    return id

  # Get ms since epoch
  # @license https://raw.github.com/jashkenas/underscore/master/LICENSE
  # @returns {number}
  getTime = (Date.now or ->
    new Date().getTime()
  )

  # Used to slow the ridiculously fast scroll and resize events.
  #
  # Returns a function, that, when invoked, will only be triggered at most once
  # during a given window of time. Normally, the throttled function will run
  # as much as it can, without ever going more than once per `wait` duration;
  # but if you'd like to disable the execution on the leading edge, pass
  # `{leading: false}`. To disable execution on the trailing edge, ditto.
  # @license https://raw.github.com/jashkenas/underscore/master/LICENSE
  # @returns {Function}
  throttle = (func, wait, options = {}) ->
    context = undefined
    args = undefined
    result = undefined
    timeout = null
    previous = 0
    later = ->
      previous = (if options.leading is false then 0 else getTime())
      timeout = null
      result = func.apply(context, args)
      context = args = null
      return

    return ->
      now = getTime()
      previous = now if not previous and options.leading is false
      remaining = wait - (now - previous)
      context = this
      args = arguments
      if remaining <= 0
        clearTimeout timeout
        timeout = null
        previous = now
        result = func.apply(context, args)
        context = args = null
      else
      timeout = setTimeout(later, remaining) if not timeout and options.trailing isnt false
      result

  # provides a unique throttled event handler
  onSlow = (jQuery, event, fn, wait) ->
    # keep a list of all handlers
    handlers = jQuery.data("scrollSpy:onSlow:#{event}")
    if handlers
      handlers.push(fn)
      return this

    handlers = [fn]
    jQuery.data("scrollSpy:onSlow:#{event}", handlers)

    throttleFn = throttle(->
      $.each(handlers, (i, handler)->
        handler.call()
        true
      )
    , wait)
    jQuery.on(event, throttleFn)
    return

  # Calculate rectangle coordinates of the viewport
  viewPortCoordinates = ->
    coordinates = {}
    coordinates.top = $window.scrollTop()
    coordinates.left = $window.scrollLeft()
    coordinates.bottom = coordinates.top + $window.height()
    coordinates.right = coordinates.left + $window.width()
    coordinates

  # Calculate rectangle coordinates of a scrollable parent element
  parentCoordinates = ($el) ->
    offsets = $el.offset()
    padding = $el.css(['paddingTop', 'paddingRight', 'paddingBottom', 'paddingLeft'])
    $.each(padding, (key, px) ->
      padding[key] = if px then parseFloat(px.slice(0,-2)) else 0
      padding[key] = 0 if isNaN(padding[key])
    )
    coordinates = {}
    coordinates.top = offsets.top + padding.paddingTop
    coordinates.left = offsets.left + padding.paddingLeft
    coordinates.right = coordinates.left + $el.width()
    coordinates.bottom = coordinates.top + $el.height()
    coordinates

  # Calculate rectangle coordinates of an element
  childCoordinates = ($el) ->
    offsets = $el.offset()
    coordinates = {}
    coordinates.top = offsets.top
    coordinates.left = offsets.left
    coordinates.right = coordinates.left + $el.outerWidth()
    coordinates.bottom = coordinates.top + $el.outerHeight()
    coordinates

  # Calculate if two rectangular elements intersect
  # @param {Object} coordinates of an element
  # @param {Object} coordinates of an element
  # @returns {boolean}    True if intersecting / overlapping
  checkIntersect = (a, b) ->
    return a.left < b.right and a.right > b.left and a.top < b.bottom and a.bottom > b.top

  # Binds the spying logic to a contect necessary for element intersection calculations
  bindSpy = ($parent, selector) ->
    # unique id for this container - makes a channel for the specific parent element
    uid = newUid()

    return ->
      if $parent == $window
        $children = $('body').find(selector)
        pCoords = viewPortCoordinates()
      else
        $children = $parent.find(selector)
        pCoords = parentCoordinates($parent)

      $children.each((i, child) ->
        $child = $(child)
        hasEntered = $child.data("scrollSpy:#{uid}")
        cCoords = childCoordinates($child)
        isIntersected = checkIntersect(pCoords, cCoords)
        $child.data("scrollSpy:#{uid}", isIntersected)

        if isIntersected and not hasEntered
          # entered
          $child.triggerHandler('scrollSpy:enter')
        else if hasEntered and not isIntersected
          # exited
          $child.triggerHandler('scrollSpy:exit')
        return
      )
      true

  # Enables ScrollSpy on elements matching the selector
  # NOTE: only call after DOM is loaded
  #
  # @param {string} selector    A selector statement.
  # @param {Object=} options    Optional.
  #             * throttle {number} internal. scroll event throttling. throttling. Default: 100 ms
  #             * parent {Element|jQuery} a parent scrollable element to track. Default: undefined|null
  $.scrollSpy = (selector, options = {}) ->
    throw new Error('jQuery.scrollSpy - selector must be a string') unless typeof selector == 'string'

    # defaults
    options.throttle ||= THROTTLE_MS

    # pick a scrolling context
    if options.parent
      if options.parent == window
        $parent = $window
      else if options.parent.length and options.parent[0] == window
        $parent = $window
      else
        $parent = $(options.parent).first()
    else
      $parent = $window

    # only spy once per scrolling element
    isInit = $parent.data('scrollSpy:init')
    return $(selector) if isInit
    $parent.data('scrollSpy:init', true)

    # bind the scroll handler
    spyFn = bindSpy($parent, selector)

    setTimeout(->
      # throttle scroll & resize events, which fire like crazy fast
      onSlow($parent, 'scroll', spyFn, options.throttle)
      onSlow($window, 'resize', spyFn, options.throttle)
      spyFn()
      return
    , 1)
    parent

  # Enables ScrollSpy on elements in a jQuery collection
  # e.g. $('.scrollSpy').scrollSpy()
  # NOTE: only call after DOM is loaded
  $.fn.scrollSpy = (selector, options = {}) ->
    this.each((i, parent) ->
      options.parent = parent
      $.scrollSpy(selector, options)
    )
    this

  # Listen for window throttled resize events
  # e.g. $.resizeSpy().on('resizeSpy:resize', fn)
  # NOTE: only call after DOM is loaded
  $.resizeSpy = (options) ->
    # lock from multiple calls
    $.resizeSpy = ->
      return $window

    options.throttle ||= THROTTLE_MS

    onSlow($window, 'resize', ->
      $window.triggerHandler('resizeSpy:resize');
      $window.triggerHandler('scrollSpy:resize');
    , options.throttle)
    $window

  return
)(jQuery);