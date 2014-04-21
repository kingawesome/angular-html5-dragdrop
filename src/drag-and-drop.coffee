###
* @ngdoc module
* @name Html55DragDrop
* @description HTML5-based Drag and Drop module. Currently in a relatively basic form that allows for Drag and Drop
               between lists of items or inside an item
###
mod = angular.module("Html5DragDrop", [])

###
* @ngdoc service
* @name Html55DragDrop.service:ddHelperService
* @function
*
* @description Factory used for coordinating different Drag & Drop directives on the page. "Channel" is a named set
*   of draggable/droppable areas of the page. When an item starts being dragged from a Channel, corresponding Drop Channels
*   are activated (meaning you can drop items onto them).
*
###
mod.provider('ddHelperService', ->

  _helperCover = '<div class="dd-helper-cover"></div>'

  $get: ->
    # Contains current item being dragged
    currDraggable = null
    # Key = channel name, value = array of listeners
    activateChannelListeners = {}
    deactivateChannelListeners = {}

    ###
     * @ngdoc method
     * @name Html5DragDrop.service:ddHelperService#getDragElement
     * @methodOf Html5DragDrop.service:ddHelperService
     * @function
     *
     * @description Get the current item being dragged
     *
     * @returns {Element|null} element Element being dragged
    ###
    getDragElement: ->
      currDraggable

    ###
     * @ngdoc method
     * @name Html5DragDrop.service:ddHelperService#setHelperCover
     * @methodOf Html5DragDrop.service:ddHelperService
     * @function
     *
     * @description The helper cover element is unfortunately needed because HTML5 D&D API allows you to use
     *  a custom helper image. That can either be an image URL or it can be a DOM element that is copied and
     *  made into an image. The problem is that the DOM element being used needs to be visible at the time it
     *  is copied. The coverHelper is an element underwhich the "helper" DOM element can be placed so it does
     *  not flash on the screen and become visible to the user.
     *
     * @param {string} html HTML to be used as the cover helper
     * adp
     *
     * @returns {null}
    ###
    setHelperCoverElement: (html) ->
      _helperCover = html

    ###
     * @ngdoc method
     * @name Html5DragDrop.service:ddHelperService#getHelperCover
     * @methodOf Html5DragDrop.service:ddHelperService
     * @function
     *
     * @description Gets the cover helper
     *
     * @returns {null}
    ###
    getHelperCoverElement: () ->
      _helperCover

    ###
     * @ngdoc method
     * @name Html5DragDrop.service:ddHelperService#setDragElement
     * @methodOf Html5DragDrop.service:ddHelperService
     * @function
     *
     * @description Update the current drag element. Defaults to null
     *
     * @param {Element} element Current drag element
     *
     * @returns {Element|null} element Element being dragged
    ###
    setDragElement: (element = null) ->
      currDraggable = element

    ###
     * @ngdoc method
     * @name Html5DragDrop.service:ddHelperService#onChannelActivate
     * @methodOf Html5DragDrop.service:ddHelperService
     * @function
     *
     * @description Add a function to run when a particular channel is activated. E.g. adding drop listeners.
     *
     * @param {string} channel Channel name
     * @param {function} listener Function to run when this channel is activated
     *
     * @returns {null}
    ###
    onChannelActivate: (channel, listener) ->
      activateChannelListeners[channel] ?= []
      activateChannelListeners[channel].push listener
      return

    ###
     * @ngdoc method
     * @name Html5DragDrop.service:ddHelperService#onChannelDeactivate
     * @methodOf Html5DragDrop.service:ddHelperService
     * @function
     *
     * @description Add a function to run when a particular channel is deactivated. E.g. removing drop listeners.
     *
     * @param {string} channel Channel name
     * @param {function} listener Function to run when this channel is activated
     *
     * @returns {null}
    ###
    onChannelDeactivate: (channel, listener) ->
      deactivateChannelListeners[channel] ?= []
      deactivateChannelListeners[channel].push listener
      return

    ###
     * @ngdoc method
     * @name Html5DragDrop.service:ddHelperService#activateChannel
     * @methodOf Html5DragDrop.service:ddHelperService
     * @function
     *
     * @description Activate a channel. This should only be run internally when dragging starts
     *
     * @param {string} channel Channel name
     * @param {Element} element Element being dragged that activates this channel
     *
     * @returns {null}
    ###
    activateChannel: (channel, element) ->
      @setDragElement element
      fn() for fn in activateChannelListeners[channel]
      return
    ###
     * @ngdoc method
     * @name Html5DragDrop.service:ddHelperService#deactivateChannel
     * @methodOf Html5DragDrop.service:ddHelperService
     * @function
     *
     * @description Deactivate a channel. This should only run internally when dragging ends.
     *
     * @param {string} channel Channel name
     *
     * @returns {null}
    ###
    deactivateChannel: (channel) ->
      @setDragElement()
      fn() for fn in deactivateChannelListeners[channel]
      return

    ###
     * @ngdoc method
     * @name Html5DragDrop.service:ddHelperService#getCoords
     * @methodOf Html5DragDrop.service:ddHelperService
     * @function
     *
     * @description Get coordinates of event object
     *
     * @param {Event} event
     *
     * @returns {Object} object x/y coordinates of event
    ###
    getCoords: (evt) ->
      x: evt.originalEvent?.pageX or evt.pageX
      y: evt.originalEvent?.pageY or evt.pageY


    ###
     * @ngdoc method
     * @name Html5DragDrop.service:ddHelperService#getBox
     * @methodOf Html5DragDrop.service:ddHelperService
     * @function
     *
     * @description Get the outter box positions
     *
     * @param {element} element
     *
     * @returns {Object} object top, left, bottom, right positions in object
    ###
    getBox: (element) ->
      return unless offset = element.offset()
      top: offset.top
      left: offset.left
      bottom: offset.top + element.outerHeight()
      right: offset.left + element.outerWidth()

    ###
     * @ngdoc method
     * @name Html5DragDrop.service:ddHelperService#contains
     * @methodOf Html5DragDrop.service:ddHelperService
     * @function
     *
     * @description Determine if a box (getBox(element) contains a coord map (coords(event))
     *
     * @param {Object} box Box coordinates from getBox(element) method
     * @param {Object} coords Coordinates from getCoords(event) method
     *
     * @returns {boolean} boolean
    ###
    contains: (box, coords) ->
      coords.x < box.right && coords.x > box.left && coords.y < box.bottom && coords.y > box.top

    ###
     * @ngdoc method
     * @name Html5DragDrop.service:ddHelperService#isWithin
     * @methodOf Html5DragDrop.service:ddHelperService
     * @function
     *
     * @description Determine if an element is "under" an event
     *
     * @param {Element} element Element to determine
     * @param {event} evt Event with coordinates (such as a mouse event)
     *
     * @returns {boolean} boolean
    ###
    isWithin: (element, evt) ->
      @contains @getBox(element), @getCoords(evt)

    ###
     * @ngdoc method
     * @name Html5DragDrop.service:ddHelperService#isBetween
     * @methodOf Html5DragDrop.service:ddHelperService
     * @function
     *
     * @description Takes a mouse event and a collection and determines which items in the collection the mouse is over.
     *
     * @param {String} direction 'horizontal' or 'vertical'
     * @param {Array} collection jQuery collection of elements
     * @param {Element} over jQuery element
     * @param {Event} evt Event object
     *
     * @returns {Object} elements Object with 'first' and 'last' elements that the event is between
    ###
    isBetween: (direction, collection, over, evt) ->
      return unless targetBox = @getBox over
      return unless coords = @getCoords evt
      targetBox.middleX = (targetBox.right - targetBox.left) / 2 + targetBox.left
      targetBox.middleY = (targetBox.bottom - targetBox.top) / 2 + targetBox.top

      firstElement = lastElement = null

      return unless @contains(targetBox, coords)

      if direction == 'horizontal' && coords.x > targetBox.middleX or
      direction == 'vertical' && coords.y > targetBox.middleY
        lastElement = over
        firstElement = over.next().filter(collection)
      else
        firstElement = over
        lastElement = over.prev().filter(collection)

      first: firstElement
      last: lastElement
)

###
 * @ngdoc directive
 * @name Html5DragDrop.directive:ddDraggable
 * @restrict A
 *
 * @description Hooks up HTML 5 Drag & Drop capability. Must be used in combination with ddDroppable so you can
 *  drop the dragged item onto a droppable area.
 * 
 * @requires $parse 
 * @requires $rootScope
 * @requires $document 
 * @requires $timeout
 * @requires ddHelperService
 *
###
mod.directive('ddDraggable', ($parse, $rootScope, $document, $timeout, ddHelperService) ->

  # Make sure jQuery passes the dataTransfer property on events
  angular.element.event.props.push "dataTransfer" if window.jQuery and window.jQuery.event.props.indexOf 'dataTransfer' == -1

  (scope, element, attrs) ->
    dragData = null
    body = $document.find('body')

    # We must have a channel attached
    attrs.ddChannel ?= 'ddDefaultChannel'
    attrs.ddDragClass ?= 'dd-dragging'

    # Turn on HTML 5 draggable
    element.attr "draggable", true

    # Update the dragData as needed
    scope.$watch attrs.ddDragData, (newValue) ->
      dragData = newValue

    # Native 'dragstart' event
    element.on 'dragstart', (e) ->
      dragEl = angular.element(@)
      # Attach the drag data and activate the channel
      dragEl.data 'ddDragData', dragData
      # We have to set the drag data for FireFox to honor drag/drop
      e.dataTransfer.setData("text/plain", scope.$$id)
      ddHelperService.activateChannel attrs.ddChannel, @

      # Add drag class
      if !attrs.ddDragging
        dragEl.addClass attrs.ddDragClass
      else
        angular.element("[dd-dragging='#{attrs.ddDragging}']").addClass attrs.ddDragClass

      # By default draggable will make an image of the element being dragged. Set ddDragHelper to create a custom helper
      if attrs.ddDragHelper
        # Create helper element
        helperEl = angular.element($parse(attrs.ddDragHelper)(scope))
        # Get coords. This is relative to the mouse pointer
        coords = $parse(attrs.ddDragHelperCoords)(scope) or
        x: 0
        y: 0

        # TODO: HARD CODE ABSOLUTE POSITION AS WELL AS PLACEMENT WHEN IT POPS ONTO THE SCREEN (PROBABLY TOP-LEFT TO MAKE SURE IT'S ENTIRELY VISIBLE)
        # Need to insert the coverup element
        cover = angular.element ddHelperService.getHelperCoverElement()
        helperEl.css(
          position: 'absolute'
          'z-index': -10000
          top: 0
          left: 0
        )

        body.append cover if cover.length
        body.append helperEl
        e.dataTransfer.setDragImage helperEl[0], coords.x, coords.y
#        e.dataTransfer.dropEffect = 'move'
        $timeout (->
          helperEl.remove()
          cover.remove()
          e.dataTransfer.dropEffect = 'move'
          return
        ), 0, false
      return

    # undo some things when dropping the element
    element.on "dragend", (e) ->
      if !attrs.ddDragging
        dragEl.removeClass attrs.ddDragClass
      else
        angular.element("[dd-dragging='#{attrs.ddDragging}']").removeClass attrs.ddDragClass

      ddHelperService.deactivateChannel attrs.ddChannel

      # remove from where it was dragged


      # TODO: RESEARCH THIS ONE
      if e.dataTransfer and e.dataTransfer.dropEffect isnt "none"
        if attrs.ddOnDropSuccess
          fn = $parse(attrs.ddOnDropSuccess)
          scope.$apply ->
            fn scope,
              $event: e

            return

      return

)

mod.directive('ddDroppable', ($parse, $rootScope, $document, $timeout, $log, ddHelperService) ->

  (scope, element, attrs) ->

    sortWithin = dropModel = betweenItems = null

    scope.$watch(attrs.ddDroppable, (newModel) ->
      dropModel = newModel
    )
    # Get ddSort and make sure it's valid
    sortDir = attrs.ddSort

    throw 'dd-sort attribute must be either "vertical" or "horizontal"' unless sortDir && /vertical|horizontal/.test(sortDir)


    # TODO: MOVE ALL THESE CONFIG ITEMS TO ddHelperService
    attrs.ddChannel = attrs.ddChannel or 'ddDefaultChannel'

    actionClasses =
      ddDropTargetClass: attrs.ddDropTargetClass or 'drop-target'
      ddDragEnterClass: attrs.ddDragEnterClass or 'drag-enter'
      ddDragSortClass: attrs.ddDragSortClass or 'drag-sort'

    removeMarkers = (elements) ->
      return unless elements
      elements.first.removeClass actionClasses.ddDragSortClass + '-before'
      elements.last.removeClass actionClasses.ddDragSortClass + '-after'

    addMarkers = (elements) ->
      return unless elements
      elements.first.addClass actionClasses.ddDragSortClass + '-before'
      elements.last.addClass actionClasses.ddDragSortClass + '-after'


    # Called when the channel is active and item is dragged over droppable. Repeats call when dragging
    onDragOver = (e) ->
      e.preventDefault()  if e.preventDefault # Necessary. Allows us to drop.
      e.stopPropagation()  if e.stopPropagation
      e.dataTransfer.dropEffect = 'move'

      # determine if we are doing sorting or not
      if sortDir
        oldBetween = betweenItems
        # sort stuff here
        betweenItems = ddHelperService.isBetween(sortDir, sortWithin, angular.element(e.target).closest(sortWithin), e)
        return removeMarkers(oldBetween) unless betweenItems
        return if betweenItems.first.is(oldBetween?.first) && betweenItems.last.is(oldBetween?.last)

        removeMarkers oldBetween
        addMarkers betweenItems

      false
    # Called one time when draggable enters element
    onDragEnter = (e) ->
      e.dataTransfer.dropEffect = 'move'
      if !sortDir
        element.addClass actionClasses.ddDragEnterClass

      return
    onDragLeave = (e) ->
      # Calculate if we are actually still over element (this event sometimes fires seemingly incorrectly)
      if !ddHelperService.isWithin element, e
        element.removeClass actionClasses.ddDragEnterClass
        # remove markers as needed
        if betweenItems
          removeMarkers betweenItems
          betweenItems = null
      return
    # Called on drop event
    onDrop = (e) ->

      e.preventDefault()  if e.preventDefault # Necessary. Allows us to drop.
      e.stopPropagation()  if e.stopPropagation # Necessary. Allows us to drop.

      el = angular.element ddHelperService.getDragElement()
      dragData = el.data('ddDragData')
      dragModel = $parse(el.attr('dd-draggable'))(el.scope())

      if sortDir && betweenItems
        # remove markers as needed
        removeMarkers betweenItems

        dragModelIndex = dragModel.indexOf(dragData)
        dropModelIndex = -1
        # If we have a "first" item, insert after it, otherwise insert before the "last" item
        console.log betweenItems
        if betweenItems.first?.length
          dropModelIndex = sortWithin.index(betweenItems.first)
        else if betweenItems.last?.length
          dropModelIndex = sortWithin.index(betweenItems.last)
          # If we are on the LAST element of the set
          if betweenItems.last.length && !betweenItems.first.length
            dropModelIndex += 1

          if dropModelIndex == -1
            ### this shouldn't happen ###
            debugger

        # dragging and dropping between the same arrays
        if dropModel == dragModel
          scope.$apply ->
            dragModel.splice dragModelIndex, 1
            dropModel.splice dropModelIndex - (if dragModelIndex < dropModelIndex then 1 else 0), 0, dragData
            if attrs.ddOnDrop
              $parse(attrs.ddOnDrop)(scope, {data: dragData, $event: e})
        else
          true

        betweenItems = null
      else
        scope.$apply ->
          dragModel.splice dragModel.indexOf(dragData), 1
          dropModel.push dragData
          if attrs.ddOnDrop
            $parse(attrs.ddOnDrop)(scope, {data: dragData, $event: e})

      element.removeClass actionClasses.ddDragEnterClass
      return

    # Register with this channel
    ddHelperService.onChannelActivate attrs.ddChannel, ->
      element.on "dragover", onDragOver
      element.on "dragenter", onDragEnter
      element.on "dragleave", onDragLeave
      element.on "drop", onDrop
      element.addClass actionClasses.ddDropTargetClass
      # setup the sortWithin items
      sortWithin = element.children('[ng-repeat]')

    # Register with this channel
    ddHelperService.onChannelDeactivate attrs.ddChannel, ->
      element.off "dragover", onDragOver
      element.off "dragenter", onDragEnter
      element.off "drop", onDrop
      element.removeClass actionClasses.ddDropTargetClass
      # reset sortWithin
      sortWithin = null
)
