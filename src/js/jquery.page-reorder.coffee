if typeof window.DEBUG is 'undefined' then window.DEBUG = true

(($) ->

  ###
  # SUPPORT CHECKS BEFORE INIT
  ###

  # Feature Tests
  hasDragAndDrop = ('draggable' of document.createElement('span') )

  # Bail if we don't have a device that supports the HTML5 Drag and Drop API
  return false unless hasDragAndDrop

  ###
  # FLASH MESSAGE JS HELPER
  ###

  class Flash
    constructor: ->
      # Store Success/Error Templates.
      @tmpl =
        success: _.template """
                            <div id="flash-msg" class="page-order__flash success">
                              <span class="icon page-order__flash-icon ss-check"></span>
                              <span class="msg page-order__flash-msg"><%= message %></p>
                            </div>
                            """
        error:   _.template """
                            <div id="flash-msg" class="page-order__flash error">
                              <span class="icon page-order__flash-icon ss-alert"></span>
                              <span class="msg page-order__flash-msg"><%= message %></p>
                            </div>
                            """
      # Cache the container.
      @container = $('#status-bar')

      console.log('Flash :: @container', @container) if DEBUG

      # Bind the flash messages into the DOM unless we don't have the flash container.
      @bindEvents() if @container.length

    bindEvents: ->
      console.log('Flash :: bindEvents') if DEBUG
      # Setup an event based system for showing flashes.
      @container.on 'flash', (e, data) =>

        # delay for the appearance of the new flash message.
        delay = 50

        # Check if we have any existing messages, if so remove them.
        if $('#flash-msg').length
          # Increase the delay to be the fadeOut animation time.
          delay = 150
          # Remove existing flash message by fading it out.
          $existingMessage = $ '#flash-msg'
          $existingMessage.stop(true).fadeOut delay, ->
            $existingMessage.remove()

        # Generate markup with template.
        html = @tmpl[data.status]({message: data.message})

        # Add markup to the container
        @container.prepend html

        # Animate the message.
        $('#flash-msg')
          .delay(delay)
          .animate({'margin-top' : '0'}, 900, 'easeOutBounce')
          .delay(3000)
          .animate {'margin-top' : '-74px'}, 900, 'easeInOutBack', ->
            $(@).remove()

        undefined

    trigger: (data) ->
      console.log('Flash :: trigger', data) if DEBUG
      # Public API method to send off Flash messages.
      @container.triggerHandler 'flash', data

  ###
  # VARIABLES
  ###
  $tree = $('#page-tree')
  $subs = $tree.find('.subpages')

  sortableOptions = {}
  namespace      = 'page-order'

  active_class   = "#{namespace}-active"
  ignore_class   = "#{namespace}-ignore"
  eligible_class = "#{namespace}-sortable"

  icon_markup    = """
                   <div class="#{namespace}">
                     <div class="#{namespace}__block">
                       <div class="#{namespace}__icon">&#11021;</div>
                     </div>
                   </div>
                   """

  ###
  # REORDERING TOP-LEVEL PAGES
  ###

  class Reorder
    constructor: (@list, @itemSelector, @options) ->
      @options = $.extend {}, sortableOptions, @options

      # API Vars
      @API_URL = "/TRIGGER/pagereorder/#{@API_KEYWORD}"

      # Find child nodes of @list
      # These should be the re-orderable items.
      @children = @list.children()

      # Find lists of subpages (if any).
      @subs = @list.find '.subpages'

      # Store a copy of the tree.
      @source = @list.html()

      @bootstrap() if @list? and @itemSelector? and @API_URL?

    bootstrap: ->
      console.log('Reorder :: bootstrap') if DEBUG

      # During bootstrap we will attach classes as needed and do any DOM changes
      # to the document before the plugin is initiated.

      for child in @children

        # Node Data.
        $child  = $ child
        isSortable = $child.find('.page-delete').length

        if isSortable
          $child.addClass eligible_class

          # Prepend the generated markup to each sortable's row.
          $child.find('> .page-wrapper')?.prepend icon_markup

        else
          # Pages aren't sortable, so let's add a hook on it to signify this.
          $child.addClass ignore_class


      # After bootstrap routine, run init.
      @init()

    init: ->
      console.log('Reorder :: init') if DEBUG

      # Initialise the jQuery Sortable plugin.
      @$sortable = @list.sortable
        items:  ".#{@itemSelector}"
        handle: "> .page-wrapper > .page-order > .#{namespace}__block"

      console.log('Reorder :: @$sortable =', @$sortable) if DEBUG

      # Bind the events.
      @bindEvents()

    reset: ->
      console.log('Reorder :: reset') if DEBUG

      # Called in the event of an error, where we want to reinstant the document
      # state to before any drag and drop related changes.
      @list.html @source

      # Destroy to avoid memory leaks.
      @$sortable.sortable('destroy') if @$sortable?

      # Then restart.
      @init()

    bindEvents: ->
      console.log('Reorder :: bindEvents') if DEBUG

      # Bind the events fired by the jQuery plugin.
      @$sortable.on
        'dragstart': (e) =>
          console.log('Reorder :: bindEvents :: dragstart') if DEBUG

          e.stopPropagation()

          # Assign active class to @list.
          @list.addClass active_class

          # Hide subpages
          console.log('Reorder :: bindEvents :: dragstart :: @subs', @subs) if DEBUG
          if @subs?
            @subs.slideUp duration: 350, easing: 'easeInExpo'

          # Grab the source in case we need to revert to it later.
          @source = @list.html()

        'dragend': (e) =>
          console.log('Reorder :: bindEvents :: dragend') if DEBUG

          e.stopPropagation()

          # Remove active class to $tree.
          @list.removeClass active_class

          # Show subpages
          if @subs?
            @subs.slideDown duration: 700, easing: 'easeOutExpo'

    send: ->
      console.log('Reorder :: send') if DEBUG

      # Send reordering results to the API endpoint.
      if @order?

        request = $.post @API_URL, { order: JSON.stringify(@order) }
        request.done (data) =>
          console.log('Reorder :: send :: request.done', data) if DEBUG

          data = JSON.parse(data)

          # Send Flash message based on outcome. Success or failure.
          Flash.trigger
            status:  data.status
            message: data.message

          # On Success we need to update all links in the new data.
          if data.status is "success" and data.linkage?
            links = data.linkage

            # Loop through links, updating all existing paths that match old and
            # replace this with the new path if new != old.
            for link in links when link.old isnt link.new
              # Find..
              anchors = @list.find "a[href*='#{link.old}']"
              # ..and replace href.
              a.href = a.href.replace "#{link.old}", "#{link.new}" for a in anchors

              # Must also find all data-path elements and replace the new subpath.
              pathRegex     = new RegExp("#{link.old}", "gi")
              pathElements  = @list.find "[data-path*='#{link.old}']"

              for element in pathElements
                $el = $ element
                path = $el.data('path')

                if pathRegex.test path
                  newPath = path.replace "#{link.old}", "#{link.new}"
                  $el.attr 'data-path', newPath

          # Revert HTML on error
          @reset() if data.status is 'error'

        request.fail (data) =>
          console.log('Reorder :: send :: request.fail', data) if DEBUG
          # Show Flash Message for errors.
          Flash.trigger
            status:  'error',
            message: 'There was an error saving your page order. Please try again.'

          # Revert HTML on error
          @reset();

        request.always (data) =>
          # Always remove any @order values.
          @order = undefined


  class ReorderTopLevel extends Reorder
    constructor: ->
      @API_KEYWORD = 'reorder'
      super

    bindEvents: ->
      console.log('ReorderTopLevel :: bindEvents') if DEBUG

      @$sortable.on
        'sortupdate': (e) =>
          console.log('ReorderTopLevel :: sortupdate') if DEBUG

          e.stopPropagation()

          pages = $(e.currentTarget).find('> .page')

          # Create array of objects storing our new order.
          @order = for page in pages
            $page = $ page

            # Return an object to turn into JSON
            index: $page.index()
            url:   $.trim $page.find('.slug-preview').first().text()

          @send()

      super

  class ReorderSubpages extends Reorder
    constructor: ->
      @API_KEYWORD = 'reordersubpages'
      super

    bindEvents: ->
      console.log('ReorderSubpages :: bindEvents') if DEBUG

      @$sortable.on
        'sortupdate': (e) =>
          console.log('ReorderSubpages :: sortupdate') if DEBUG

          e.stopPropagation()

          pages = $(e.currentTarget).find('> .page')

          # Create array of objects storing our new order.
          @order = for page in pages
            $page = $ page

            # Return an object to turn into JSON
            index: $page.index()
            url  : $.trim $page.find('.slug-preview').first().text()

          console.log('ReorderSubpages :: sortupdate :: order', @order) if DEBUG

          @send()

      super

  ###
  # INSTANCES
  ###

  # Flash Messaging
  Flash = new Flash()

  # Top Level Pages
  Master = new ReorderTopLevel( $tree, eligible_class )

  # All Subpage trees
  Subpages = []
  for subpageTree in $subs
    Subpages.push new ReorderSubpages( $(subpageTree), eligible_class )
) jQuery