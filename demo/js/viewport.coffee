$(window).ready(->
  $('.box').on('scrollSpy:enter', ->
    $(this).addClass('entered')
    $(this).removeClass('exited')
  )
  $('.box').on('scrollSpy:exit', ->
    $(this).removeClass('entered')
    $(this).addClass('exited')
  )
  $.scrollSpy('.box', throttle: 1000)
)