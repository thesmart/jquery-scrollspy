$(window).ready(->
  $('.box').on('scrollSpy:enter', ->
    $(this).addClass('entered')
    $(this).removeClass('exited')
  )
  $('.box').on('scrollSpy:exit', ->
    $(this).removeClass('entered')
    $(this).addClass('exited')
  )
  $(window).scrollSpy('#demo-1 .box', throttle: 3000)
  $('#demo-2').scrollSpy('.box', throttle: 3000)
)