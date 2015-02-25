mix = ->
  $('#container-gallery').mixItUp()
$(document).ready(mix)


fancy = ->
  $('.fancybox').fancybox(
    'type':'image',
    keys: ->
      next: ->
        40
      prev: ->
        38


  )
$(document).ready(fancy)

gallery_controls = (e) ->
  switch(e.which)
    when 37
      #left
      $('a#prev-btn').trigger 'click'
    when 39
      #right
      $('a#next-btn').trigger 'click'
    else
      return
  e.preventDefault()
  return
$(document).on 'keydown', gallery_controls
#when user presses a key, triggers our fxn


goToByScroll = (id) ->
  $('html,body').animate(scrollTop: $(id).offset().top, 'slow')