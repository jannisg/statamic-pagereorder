$ ->

  ### Feature Tests ###
  hasDragAndDrop = ('draggable' of document.createElement('span') )

  # Bail if we don't have a device that supports the HTML5 Drag and Drop API
  return false unless hasDragAndDrop

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
    $sortable = $ @
    slug  = $.trim $sortable.find('.slug-preview').first().text()

    if slug is "/"
      # Home link isn't sortable, so let's add a hook on it to signify this.
      $sortable.addClass ignore_class

    else
      $sortable.addClass eligible_class

      # Prepend the generated markup to each sortable's row.
      $sortable.find('> .page-wrapper')?.prepend icon_markup
      
  ### Init the sortable plugin. ###
  $sortable = $('#page-tree').sortable
    items: ".#{eligible_class}"
    handle: ".#{namespace}__block"

  ### Handle special events on sorting. ###
  $sortable.on
    'dragstart': (e) ->
      # Assign active class to $tree.
      $tree.addClass active_class

      # Hide subpages
      $subs.slideUp()

    'dragend': (e) ->
      # Remove active class to $tree.
      $tree.removeClass active_class

      # Show subpages
      $subs.slideDown()

    'sortupdate': (e) ->
      # console.log "Sorting..."
      pages = $(@).find('> .page')

      # Create array of objects storing our new order.
      order = for page in pages
        $page = $ page

        index: $page.index()
        url  : $.trim $page.find('.slug-preview').first().text()

      # Store a JSON String of our new order.
      orderJSON = JSON.stringify order

      # Build a URL to ping.
      location = window.location
      url = "#{location.protocol}//#{location.host}"

      # Action the request to trigger the reodering.
      window.location = "#{url}/TRIGGER/pagereorder/reorder_folders?order=#{orderJSON}"

      # Send JSON to PHP function.
      # $.ajax '/TRIGGER/ordash/reorder_folders',
      #   type: 'POST'
      #   data:
      #     order: orderJSON
      #   complete: (jqxhr, status) ->
      #     console.log "Complete:", jqxhr, status

      undefined

