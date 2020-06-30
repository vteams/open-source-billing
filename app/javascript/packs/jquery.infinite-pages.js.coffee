###
jQuery Infinite Pages v0.2.0
https://github.com/magoosh/jquery-infinite-pages

Released under the MIT License
###

#
# Built with a class-based template for jQuery plugins in Coffeescript:
# https://gist.github.com/rjz/3610858
#

(($, window) ->
# Define the plugin class
  class InfinitePages

    # Default settings
    defaults:
      debug: false  # set to true to log messages to the console
      navSelector: 'a[rel=next]'
      buffer: 1000  # 1000px buffer by default
      loading: null # optional callback when next-page request begins
      success: null # optional callback when next-page request finishes
      error:   null # optional callback when next-page request fails
      context: window # context to define the scrolling container
      state:
        paused:  false
        loading: false

# Constructs the new InfinitePages object
#
# container - the element containing the infinite table and pagination links
    constructor: (container, options) ->
      @options = $.extend({}, @defaults, options)
      @$container = $(container)
      @$table = $(container).find('table')
      @$context = $(@options.context)
      @init()

# Setup and bind to related events
    init: ->

# Debounce scroll event to improve performance
      scrollTimeout = null
      scrollHandler = (=> @check())

      @$context.scroll ->
        if scrollTimeout
          clearTimeout(scrollTimeout)
          scrollTimeout = null
        scrollTimeout = setTimeout(scrollHandler, 250)

# Internal helper for logging messages
    _log: (msg) ->
      console?.log(msg) if @options.debug

# Check the distance of the nav selector from the bottom of the window and fire
# load event if close enough
    check: ->
      nav = @$container.find(@options.navSelector)
      if nav.size() == 0
        @_log "No more pages to load"
      else
        windowBottom = @$context.scrollTop() + @$context.height()
        distance = nav.offset().top - windowBottom

        if @options.state.paused
          @_log "Paused"
        else if @options.state.loading
          @_log "Waiting..."
        else if (distance > @options.buffer)
          @_log "#{distance - @options.buffer}px remaining..."
        else
          @next() # load the next page

# Load the next page
    next: ->
      if @options.state.done
        @_log "Loaded all pages"
      else
        @_loading()

        $.getScript(@$container.find(@options.navSelector).attr('href'))
          .done(=> @_success())
          .fail(=> @_error())

    _loading: ->
      @options.state.loading = true
      @_log "Loading next page..."
      if typeof @options.loading is 'function'
        @$container.find(@options.navSelector).each(@options.loading)

    _success: ->
      @options.state.loading = false
      @_log "New page loaded!"
      if typeof @options.success is 'function'
        @$container.find(@options.navSelector).each(@options.success)

    _error: ->
      @options.state.loading = false
      @_log "Error loading new page :("
      if typeof @options.error is 'function'
        @$container.find(@options.navSelector).each(@options.error)

# Pause firing of events on scroll
    pause: ->
      @options.state.paused = true
      @_log "Scroll checks paused"

# Resume firing of events on scroll
    resume: ->
      @options.state.paused = false
      @_log "Scroll checks resumed"
      @check()

  # Define the plugin
  $.fn.extend infinitePages: (option, args...) ->
    @each ->
      $this = $(this)
      data = $this.data('infinitepages')

      if !data
        $this.data 'infinitepages', (data = new InfinitePages(this, option))
      if typeof option == 'string'
        data[option].apply(data, args)

) window.jQuery, window
