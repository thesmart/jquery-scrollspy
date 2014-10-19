$(window).ready(->
  $('.box').on('scrollSpy:enter', ->
    $(this).addClass('entered')
    $(this).removeClass('exited')
  )
  $('.box').on('scrollSpy:exit', ->
    $(this).removeClass('entered')
    $(this).addClass('exited')
  )
  $('#overflow-1').scrollSpy('.box', throttle: 800)
  $('#overflow-2').scrollSpy('.box', throttle: 800)
)