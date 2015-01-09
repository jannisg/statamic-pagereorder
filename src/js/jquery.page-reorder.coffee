$ ->

  ### Feature Tests ###
  hasDragAndDrop = ('draggable' of document.createElement('span') )

  # Bail if we don't have a device that supports the HTML5 Drag and Drop API
  return false unless hasDragAndDrop

  ### Setup Flash Message JS Helper ###

  ### Store Success/Error Templates. ###
  flashes =
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

  ### Cache the container. ###
  $flashBar = $ '#status-bar'

  ### Setup an event based system for showing flashes. ###
  $flashBar.on 'flash', (e, data) ->

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
    html = flashes[data.status]({message: data.message})

    # Add markup to the container
    $flashBar.prepend html

    # Animate the message.
    $('#flash-msg')
      .delay(delay)
      .animate({'margin-top' : '0'}, 900, 'easeOutBounce')
      .delay(3000)
      .animate {'margin-top' : '-74px'}, 900, 'easeInOutBack', ->
        $(@).remove()

    undefined

  ### Vars ###
  $tree = $('#page-tree')
  $subs = $tree.find('.subpages')

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

  ### Prepare the #page-tree nodes ###
  $tree.children().each ->
    # Node Data.
    $sortable  = $ @
    isSortable = $sortable.find('.page-delete').length
    # slug       = $.trim $sortable.find('.slug-preview').first().text()

    if isSortable
      $sortable.addClass eligible_class

      # Prepend the generated markup to each sortable's row.
      $sortable.find('> .page-wrapper')?.prepend icon_markup

    else
      # Pages aren't sortable, so let's add a hook on it to signify this.
      $sortable.addClass ignore_class

  # Store the original HTML source, we will revert to this on error.
  # We grab the html on dragstart before the dom is changed.
  _source = ''

  ### Init the sortable plugin. ###
  $sortable = null

  do init_sortable = ->
    $sortable = $('#page-tree').sortable
      items: ".#{eligible_class}"
      handle: ".#{namespace}__block"

  # Re-init the sortable bindings.
  reinit_sortable = ->

    # Revert the HTML source to before the drag/drop.
    $tree.html _source

    # Destroy to avoid memory leaks.
    $sortable.sortable('destroy')

    # Then restart.
    do init_sortable


  ### Handle special events on sorting. ###
  $sortable.on
    'dragstart': (e) ->
      # Assign active class to $tree.
      $tree.addClass active_class

      # Hide subpages
      $subs.slideUp duration: 350, easing: 'easeInExpo'

      # Grab the source in case we need to revert to it later.
      _source = $tree.html()

    'dragend': (e) ->
      # Remove active class to $tree.
      $tree.removeClass active_class

      # Show subpages
      $subs.slideDown duration: 700, easing: 'easeOutExpo'

    'sortupdate': (e) ->
      # console.log "Sorting..."
      pages = $(@).find('> .page')

      # Create array of objects storing our new order.
      order = for page in pages
        $page = $ page

        # Return an object to turn into JSON
        index: $page.index()
        url  : $.trim $page.find('.slug-preview').first().text()

      # Store a JSON String of our new order.
      orderJSON = JSON.stringify order

      # Send JSON to PHP function using AJAX
      url = '/TRIGGER/pagereorder/reorder'

      $.ajax url,
        type: 'POST'
        data:
          order: orderJSON

        complete: (jqxhr) ->
          # Parse the JSON return data.
          message = $.parseJSON( jqxhr.responseText ) if jqxhr.responseText

          # Send Flash message based on outcome. Success of failure.
          $flashBar.triggerHandler 'flash', message

          # On Success we need to update all links in the new data.
          if message.status is "success" and message.linkage?
            links = message.linkage

            # Loop through links, updating all existing paths that match old and
            # replace this with the new path if new != old.
            for link in links when link.old isnt link.new
              # Find and replace.
              anchors = $tree.find "a[href*='#{link.old}']"
              a.href = a.href.replace "#{link.old}", "#{link.new}" for a in anchors

          # Revert HTML on error
          do reinit_sortable if message.status is 'error'


        error: (jqxhr, status, error) ->
          # Show Flash Message for errors.
          $flashBar.triggerHandler 'flash',
            status: 'error',
            message: 'There was an error saving your page order. Please try again.'

          # Revert HTML on error
          do reinit_sortable

      undefined

