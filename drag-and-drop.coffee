
###
Created with IntelliJ IDEA.
User: Ganaraj.Pr
Date: 11/10/13
Time: 11:27
To change this template use File | Settings | File Templates.
###

# Get the drag helper template
angular.module("ddDragDrop", [])

# Service to coordinate draggables/droppables
.factory('ddChannel', ->
    currChannel = null
    currDraggable = null
    activateChannelListeners = {}
    deactivateChannelListeners = {}


    getDragElement: ->
      currDraggable

    setDragElement: (element = null) ->
      currDraggable = element

    onChannelActivate: (channel, listener) ->
      activateChannelListeners[channel] = [] if !activateChannelListeners[channel]
      activateChannelListeners[channel].push listener

    onChannelDeactivate: (channel, listener) ->
      deactivateChannelListeners[channel] = [] if !deactivateChannelListeners[channel]
      deactivateChannelListeners[channel].push listener

    activateChannel: (channel, element) ->
      @setDragElement element
      fn() for fn in activateChannelListeners[channel]
    deactivateChannel: (channel) ->
      @setDragElement()
      fn() for fn in deactivateChannelListeners[channel]

    removeChannelListener: (channel, listener) ->
      channelListeners[channel]?.splice channelListeners.indexOf listener, 1

  )
.directive('ddDraggable', ($parse, $rootScope, $document, $timeout, ddChannel) ->

    # Make sure jQuery passes the dataTransfer property on events
    window.jQuery.event.props.push "dataTransfer" if window.jQuery and window.jQuery.event.props.indexOf 'dataTransfer' == -1

    (scope, element, attrs) ->
      dragData = null

      attrs.ddChannel = attrs.ddChannel or 'ddDefaultChannel'

      # reset any existing draggable attribute and use dd-draggable
      element.attr "draggable", true
      # TODO: this was going to be used for toggling draggable on/off, but I don't think this is needed right now
      #attrs.$observe "ddDraggable", (newValue) ->
      #  element.attr "draggable", newValue

      # grab the drag value
      scope.$watch attrs.ddDragData, (newValue) ->
        dragData = newValue

      # set up dragstart binding
      element.bind 'dragstart', (e) ->
        console.log 'dragStart'
        # add the dragData
        angular.element(@).data 'ddDragData', dragData
        ddChannel.activateChannel attrs.ddChannel, @

        if attrs.ddDragHelper
          el = angular.element($parse(attrs.ddDragHelper)(scope))
          coords = $parse(attrs.ddDragHelperCoords)(scope) or
          x: 0
          y: 0

          # TODO: HARD CODE ABSOLUTE POSITION AS WELL AS PLACEMENT WHEN IT POPS ONTO THE SCREEN (PROBABLY TOP-LEFT TO MAKE SURE IT'S ENTIRELY VISIBLE)
          $document.find("body").append el
          e.dataTransfer.setDragImage el[0], coords.x, coords.y
          $timeout (->
            el.remove()
#            el = null
            return
          ), 0
        return

      # undo some things when dropping the element
      element.bind "dragend", (e) ->

        console.log 'dragend'
        ddChannel.deactivateChannel attrs.ddChannel

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
.directive('ddDroppable', ($parse, $rootScope, $document, $timeout, $log, ddChannel) ->

    getCoords = (evt) ->
      x: evt.originalEvent?.clientX or evt.clientX
      y: evt.originalEvent?.clientY or evt.clientY
    getBox = (element) ->
      offset = element.offset()
      top: offset.top
      left: offset.left
      bottom: offset.top + element.outerHeight()
      right: offset.left + element.outerWidth()
    contains = (box, coords) ->
      coords.x < box.right && coords.x > box.left && coords.y < box.bottom && coords.y > box.top

    isWithin = (element, evt) ->
      contains getBox(element), getCoords(evt)


    isBetween = (direction, collection, over, evt) ->
      targetBox = getBox over
      coords = getCoords evt
      targetBox.middleX = (targetBox.right - targetBox.left) / 2 + targetBox.left
      targetBox.middleY = (targetBox.bottom - targetBox.top) / 2 + targetBox.top

      firstElement = lastElement = null

      return unless contains(targetBox, coords)

      if direction == 'horizontal'
        if coords.x > targetBox.middleX
          lastElement = over
          firstElement = over.next()
        else
          firstElement = over
          lastElement = over.prev()

      first: firstElement
      last: lastElement

    (scope, element, attrs) ->

      sortWithin = null
      dropModel = null
      scope.$watch(attrs.ddDroppable, (newModel) ->
        dropModel = newModel
      )
      # Get ddSort and make sure it's valid
      sortDir = attrs.ddSort
      betweenItems = null
      throw 'dd-sort attribute must be either "vertical" or "horizontal"' unless sortDir && /vertical|horizontal/.test(sortDir)

#      if !angular.isArray dropModel
#        $log('ddDroppable attribute needs to point to an available array')

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
        e.dataTransfer.dropEffect = "move"

        # determine if we are doing sorting or not
        if sortDir
          oldBetween = betweenItems
          # sort stuff here
          betweenItems = isBetween(sortDir, sortWithin, angular.element(e.target).closest(sortWithin), e)
          return removeMarkers(oldBetween) unless betweenItems
          return if betweenItems.first.is(oldBetween?.first) && betweenItems.last.is(oldBetween?.last)

          removeMarkers oldBetween
          addMarkers betweenItems

        false
      # Called one time when draggable enters element
      onDragEnter = (e) ->
        if !sortDir
          element.addClass actionClasses.ddDragEnterClass

        return
      onDragLeave = (e) ->
        # Calculate if we are actually still over element (this event sometimes fires seemingly incorrectly)
        if !isWithin element, e
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

        el = angular.element ddChannel.getDragElement()
        dragData = el.data('ddDragData')
        dragModel = el.scope()[el.attr('dd-draggable')]

        if sortDir && betweenItems
          # remove markers as needed
          removeMarkers betweenItems

          dragModelIndex = dragModel.indexOf(dragData)
          dropModelIndex = -1
          # If we have a "first" item, insert after it, otherwise insert before the "last" item
          if betweenItems.first?.length
            dropModelIndex = sortWithin.index(betweenItems.first)
          else if betweenItems.last?.length
            dropModelIndex = sortWithin.index(betweenItems.last)

          if dropModelIndex == -1
            ### this shouldn't happen ###
            debugger

          # dragging and dropping between the same arrays
          if dropModel == dragModel
            scope.$apply ->
              dragModel.splice dragModelIndex, 1
              dropModel.splice dropModelIndex - (if dragModelIndex < dropModelIndex then 1 else 0), 0, dragData
          else
            true

          betweenItems = null
        else
          scope.$apply ->
            dragModel.splice dragModel.indexOf(dragData), 1
            dropModel.push dragData

        element.removeClass actionClasses.ddDragEnterClass
        return

      # Register with this channel
      ddChannel.onChannelActivate attrs.ddChannel, ->
        element.bind "dragover", onDragOver
        element.bind "dragenter", onDragEnter
        element.bind "dragleave", onDragLeave
        element.bind "drop", onDrop
        element.addClass actionClasses.ddDropTargetClass
        # setup the sortWithin items
        sortWithin = element.children()

      # Register with this channel
      ddChannel.onChannelDeactivate attrs.ddChannel, ->
        element.unbind "dragover", onDragOver
        element.unbind "dragenter", onDragEnter
        element.unbind "drop", onDrop
        element.removeClass actionClasses.ddDropTargetClass
        # reset sortWithin
        sortWithin = null
  )
