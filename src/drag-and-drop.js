/*
* @ngdoc module
* @name Html55DragDrop
* @description HTML5-based Drag and Drop module. Currently in a relatively basic form that allows for Drag and Drop
               between lists of items or inside an item
*/


(function() {
  var mod;

  mod = angular.module("Html5DragDrop", []);

  /*
  * @ngdoc service
  * @name Html55DragDrop.service:ddHelperService
  * @function
  *
  * @description Factory used for coordinating different Drag & Drop directives on the page. "Channel" is a named set
  *   of draggable/droppable areas of the page. When an item starts being dragged from a Channel, corresponding Drop Channels
  *   are activated (meaning you can drop items onto them).
  *
  */


  mod.provider('ddHelperService', function() {
    var _helperCover;
    _helperCover = '<div class="dd-helper-cover"></div>';
    return {
      $get: function() {
        var activateChannelListeners, currDraggable, deactivateChannelListeners;
        currDraggable = null;
        activateChannelListeners = {};
        deactivateChannelListeners = {};
        return {
          /*
           * @ngdoc method
           * @name Html5DragDrop.service:ddHelperService#getDragElement
           * @methodOf Html5DragDrop.service:ddHelperService
           * @function
           *
           * @description Get the current item being dragged
           *
           * @returns {Element|null} element Element being dragged
          */

          getDragElement: function() {
            return currDraggable;
          },
          /*
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
          */

          setHelperCoverElement: function(html) {
            return _helperCover = html;
          },
          /*
           * @ngdoc method
           * @name Html5DragDrop.service:ddHelperService#getHelperCover
           * @methodOf Html5DragDrop.service:ddHelperService
           * @function
           *
           * @description Gets the cover helper
           *
           * @returns {null}
          */

          getHelperCoverElement: function() {
            return _helperCover;
          },
          /*
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
          */

          setDragElement: function(element) {
            if (element == null) {
              element = null;
            }
            return currDraggable = element;
          },
          /*
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
          */

          onChannelActivate: function(channel, listener) {
            if (activateChannelListeners[channel] == null) {
              activateChannelListeners[channel] = [];
            }
            activateChannelListeners[channel].push(listener);
          },
          /*
           * @ngdoc method
           * @name Html5DragDrop.service:ddHelperService#onChannelDeactivate
           * @methodOf Html5DragDrop.service:ddHelperService
           * @function
           *
           * @description Add a function to run when a particular channel is deactivated. E.g. removing drop listeners.
           *
           * @param {string} channel Channel name
           * @param {function} listener Function to run when this channel is deactivated
           *
           * @returns {null}
          */

          onChannelDeactivate: function(channel, listener) {
            if (deactivateChannelListeners[channel] == null) {
              deactivateChannelListeners[channel] = [];
            }
            deactivateChannelListeners[channel].push(listener);
          }
        };
        /*
        * @ngdoc method
        * @name Html5DragDrop.service:ddHelperService#removeOnChannelActivate
        * @methodOf Html5DragDrop.service:ddHelperService
        * @function
        *
        * @description Removes any functions set to be run when onChannelActivate fires. Use this function when removing entire channels from the DOM to prevent memory links.
        *
        * @param {string} channel Channel name
        *
        * @returns {null}
        */

      },
      removeOnChannelActivate: function(channel) {
        activateChannelListeners[channel] = null;
        return delete activateChannelListeners[channel];
      },
      /*
       * @ngdoc method
       * @name Html5DragDrop.service:ddHelperService#removeOnChannelDeactivate
       * @methodOf Html5DragDrop.service:ddHelperService
       * @function
       *
       * @description Removes any functions set to be run when onChannelDeactivate fires. Use this function when removing entire channels from the DOM to prevent memory links.
       *
       * @param {string} channel Channel name
       *
       * @returns {null}
      */

      removeOnChannelDeactivate: function(channel) {
        deactivateChannelListeners[channel] = null;
        return delete deactivateChannelListeners[channel];
      },
      /*
       * @ngdoc method
       * @name Html5DragDrop.service:ddHelperService#activateChannel
       * @methodOf Html5DragDrop.service:ddHelperService
       * @function
       *
       * @description Activate a channel by invoking the activation listeners associated with it. This should only be run internally when dragging starts
       *
       * @param {string} channel Channel name
       * @param {Element} element Element being dragged that activates this channel
       *
       * @returns {null}
      */

      activateChannel: function(channel, element) {
        var fn, _i, _len, _ref;
        this.setDragElement(element);
        _ref = activateChannelListeners[channel];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          fn = _ref[_i];
          fn();
        }
      },
      /*
       * @ngdoc method
       * @name Html5DragDrop.service:ddHelperService#deactivateChannel
       * @methodOf Html5DragDrop.service:ddHelperService
       * @function
       *
       * @description Deactivate a channel by invoking the deactivation listeners associated with it. This should only run internally when dragging ends.
       *
       * @param {string} channel Channel name
       *
       * @returns {null}
      */

      deactivateChannel: function(channel) {
        var fn, _i, _len, _ref;
        this.setDragElement();
        _ref = deactivateChannelListeners[channel];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          fn = _ref[_i];
          fn();
        }
      },
      /*
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
      */

      getCoords: function(evt) {
        var _ref, _ref1;
        return {
          x: ((_ref = evt.originalEvent) != null ? _ref.pageX : void 0) || evt.pageX,
          y: ((_ref1 = evt.originalEvent) != null ? _ref1.pageY : void 0) || evt.pageY
        };
      },
      /*
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
      */

      getBox: function(element) {
        var offset;
        if (!(offset = element.offset())) {
          return;
        }
        return {
          top: offset.top,
          left: offset.left,
          bottom: offset.top + element.outerHeight(),
          right: offset.left + element.outerWidth()
        };
      },
      /*
       * @ngdoc method
       * @name Html5DragDrop.service:ddHelperService#contains
       * @methodOf Html5DragDrop.service:ddHelperService
       * @function
       *
       * @description Determine if a box (getBox(element) contains a coord map (getCoords(event))
       *
       * @param {Object} box Box coordinates from getBox(element) method
       * @param {Object} coords Coordinates from getCoords(event) method
       *
       * @returns {boolean} boolean
      */

      contains: function(box, coords) {
        return coords.x < box.right && coords.x > box.left && coords.y < box.bottom && coords.y > box.top;
      },
      /*
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
      */

      isWithin: function(element, evt) {
        return this.contains(this.getBox(element), this.getCoords(evt));
      },
      /*
       * @ngdoc method
       * @name Html5DragDrop.service:ddHelperService#isBetween
       * @methodOf Html5DragDrop.service:ddHelperService
       * @function
       *
       * @description Takes a mouse event and a collection and determines which items in the collection the mouse is "over". "Over" includes the element the mouse is actually over and either the element before or the element after, depending on where the mouse is in relation to the element it is actually over.
       *
       * @param {String} direction 'horizontal' or 'vertical'
       * @param {Array} collection jQuery collection of elements
       * @param {Element} over jQuery element
       * @param {Event} evt Event object
       *
       * @returns {Object} elements Object with 'first' and 'last' elements that the event is between
      */

      isBetween: function(direction, collection, over, evt) {
        var coords, firstElement, lastElement, targetBox;
        if (!(targetBox = this.getBox(over))) {
          return;
        }
        if (!(coords = this.getCoords(evt))) {
          return;
        }
        targetBox.middleX = (targetBox.right - targetBox.left) / 2 + targetBox.left;
        targetBox.middleY = (targetBox.bottom - targetBox.top) / 2 + targetBox.top;
        firstElement = lastElement = null;
        if (!this.contains(targetBox, coords)) {
          return;
        }
        if (direction === 'horizontal' && coords.x > targetBox.middleX || direction === 'vertical' && coords.y > targetBox.middleY) {
          lastElement = over;
          firstElement = over.next().filter(collection);
        } else {
          firstElement = over;
          lastElement = over.prev().filter(collection);
        }
        return {
          first: firstElement,
          last: lastElement
        };
      }
    };
  });

  /*
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
  */


  mod.directive('ddDraggable', function($parse, $rootScope, $document, $timeout, ddHelperService) {
    if (window.jQuery && window.jQuery.event.props.indexOf('dataTransfer' === -1)) {
      angular.element.event.props.push("dataTransfer");
    }
    return function(scope, element, attrs) {
      var body, dragData;
      dragData = null;
      body = $document.find('body');
      if (attrs.ddChannel == null) {
        attrs.ddChannel = 'ddDefaultChannel';
      }
      if (attrs.ddDragClass == null) {
        attrs.ddDragClass = 'dd-dragging';
      }
      element.attr("draggable", true);
      scope.$watch(attrs.ddDragData, function(newValue) {
        return dragData = newValue;
      });
      element.on('dragstart', function(e) {
        var coords, cover, dragEl, helperEl;
        dragEl = angular.element(this);
        dragEl.data('ddDragData', dragData);
        e.dataTransfer.setData("text/plain", scope.$$id);
        ddHelperService.activateChannel(attrs.ddChannel, this);
        if (!attrs.ddDragging) {
          dragEl.addClass(attrs.ddDragClass);
        } else {
          angular.element("[dd-dragging='" + attrs.ddDragging + "']").addClass(attrs.ddDragClass);
        }
        if (attrs.ddDragHelper) {
          helperEl = angular.element($parse(attrs.ddDragHelper)(scope));
          coords = $parse(attrs.ddDragHelperCoords)(scope) || {
            x: 0,
            y: 0
          };
          cover = angular.element(ddHelperService.getHelperCoverElement());
          helperEl.css({
            position: 'absolute',
            'z-index': -10000,
            top: 0,
            left: 0
          });
          if (cover.length) {
            body.append(cover);
          }
          body.append(helperEl);
          e.dataTransfer.setDragImage(helperEl[0], coords.x, coords.y);
          $timeout((function() {
            helperEl.remove();
            cover.remove();
            e.dataTransfer.dropEffect = 'move';
          }), 0, false);
        }
      });
      element.on("dragend", function(e) {
        var fn;
        if (!attrs.ddDragging) {
          dragEl.removeClass(attrs.ddDragClass);
        } else {
          angular.element("[dd-dragging='" + attrs.ddDragging + "']").removeClass(attrs.ddDragClass);
        }
        ddHelperService.deactivateChannel(attrs.ddChannel);
        if (e.dataTransfer && e.dataTransfer.dropEffect !== "none") {
          if (attrs.ddOnDropSuccess) {
            fn = $parse(attrs.ddOnDropSuccess);
            scope.$apply(function() {
              fn(scope, {
                $event: e
              });
            });
          }
        }
      });
      element.on('$destroy', function() {
        return element.off;
      });
    };
  });

  mod.directive('ddDroppable', function($parse, $rootScope, $document, $timeout, $log, ddHelperService) {
    return function(scope, element, attrs) {
      var actionClasses, addMarkers, betweenItems, dropModel, onDragEnter, onDragLeave, onDragOver, onDrop, removeMarkers, sortDir, sortWithin;
      sortWithin = dropModel = betweenItems = null;
      scope.$watch(attrs.ddDroppable, function(newModel) {
        return dropModel = newModel;
      });
      sortDir = attrs.ddSort;
      if (!(sortDir && /vertical|horizontal/.test(sortDir))) {
        throw 'dd-sort attribute must be either "vertical" or "horizontal"';
      }
      attrs.ddChannel = attrs.ddChannel || 'ddDefaultChannel';
      actionClasses = {
        ddDropTargetClass: attrs.ddDropTargetClass || 'drop-target',
        ddDragEnterClass: attrs.ddDragEnterClass || 'drag-enter',
        ddDragSortClass: attrs.ddDragSortClass || 'drag-sort'
      };
      removeMarkers = function(elements) {
        if (!elements) {
          return;
        }
        elements.first.removeClass(actionClasses.ddDragSortClass + '-before');
        return elements.last.removeClass(actionClasses.ddDragSortClass + '-after');
      };
      addMarkers = function(elements) {
        if (!elements) {
          return;
        }
        elements.first.addClass(actionClasses.ddDragSortClass + '-before');
        return elements.last.addClass(actionClasses.ddDragSortClass + '-after');
      };
      onDragOver = function(e) {
        var oldBetween;
        if (e.preventDefault) {
          e.preventDefault();
        }
        if (e.stopPropagation) {
          e.stopPropagation();
        }
        e.dataTransfer.dropEffect = 'move';
        if (sortDir) {
          oldBetween = betweenItems;
          betweenItems = ddHelperService.isBetween(sortDir, sortWithin, angular.element(e.target).closest(sortWithin), e);
          if (!betweenItems) {
            return removeMarkers(oldBetween);
          }
          if (betweenItems.first.is(oldBetween != null ? oldBetween.first : void 0) && betweenItems.last.is(oldBetween != null ? oldBetween.last : void 0)) {
            return;
          }
          removeMarkers(oldBetween);
          addMarkers(betweenItems);
        }
        return false;
      };
      onDragEnter = function(e) {
        e.dataTransfer.dropEffect = 'move';
        if (!sortDir) {
          element.addClass(actionClasses.ddDragEnterClass);
        }
      };
      onDragLeave = function(e) {
        if (!ddHelperService.isWithin(element, e)) {
          element.removeClass(actionClasses.ddDragEnterClass);
          if (betweenItems) {
            removeMarkers(betweenItems);
            betweenItems = null;
          }
        }
      };
      onDrop = function(e) {
        var dragData, dragModel, dragModelIndex, dropModelIndex, el, _ref, _ref1;
        if (e.preventDefault) {
          e.preventDefault();
        }
        if (e.stopPropagation) {
          e.stopPropagation();
        }
        el = angular.element(ddHelperService.getDragElement());
        dragData = el.data('ddDragData');
        dragModel = $parse(el.attr('dd-draggable'))(el.scope());
        if (sortDir && betweenItems) {
          removeMarkers(betweenItems);
          dragModelIndex = dragModel.indexOf(dragData);
          dropModelIndex = -1;
          if ((_ref = betweenItems.first) != null ? _ref.length : void 0) {
            dropModelIndex = sortWithin.index(betweenItems.first);
          } else if ((_ref1 = betweenItems.last) != null ? _ref1.length : void 0) {
            dropModelIndex = sortWithin.index(betweenItems.last);
            if (betweenItems.last.length && !betweenItems.first.length) {
              dropModelIndex += 1;
            }
            if (dropModelIndex === -1) {
              /* this shouldn't happen*/

              debugger;
            }
          }
          if (dropModel === dragModel) {
            scope.$apply(function() {
              dragModel.splice(dragModelIndex, 1);
              dropModel.splice(dropModelIndex - (dragModelIndex < dropModelIndex ? 1 : 0), 0, dragData);
              if (attrs.ddOnDrop) {
                return $parse(attrs.ddOnDrop)(scope, {
                  data: dragData,
                  $event: e
                });
              }
            });
          } else {
            true;
          }
          betweenItems = null;
        } else {
          scope.$apply(function() {
            dragModel.splice(dragModel.indexOf(dragData), 1);
            dropModel.push(dragData);
            if (attrs.ddOnDrop) {
              return $parse(attrs.ddOnDrop)(scope, {
                data: dragData,
                $event: e
              });
            }
          });
        }
        element.removeClass(actionClasses.ddDragEnterClass);
      };
      ddHelperService.onChannelActivate(attrs.ddChannel, function() {
        element.on("dragover", onDragOver);
        element.on("dragenter", onDragEnter);
        element.on("dragleave", onDragLeave);
        element.on("drop", onDrop);
        element.addClass(actionClasses.ddDropTargetClass);
        return sortWithin = element.children('[ng-repeat]');
      });
      ddHelperService.onChannelDeactivate(attrs.ddChannel, function() {
        element.off("dragover", onDragOver);
        element.off("dragenter", onDragEnter);
        element.off("dragleave", onDragLeave);
        element.off("drop", onDrop);
        element.removeClass(actionClasses.ddDropTargetClass);
        return sortWithin = null;
      });
      element.on('$destroy', function() {
        ddHelperService.removeOnChannelDeactivate(attrs.ddChannel);
        ddHelperService.removeOnChannelActivate(attrs.ddChannel);
        return element.off;
      });
    };
  });

}).call(this);
