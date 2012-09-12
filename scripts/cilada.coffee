config =
  width: 1000
  height: 500
  eventType: null

ball =
  newX: 0
  newY: 0
  x: config.width / 2
  y: config.height / 2

coffee_draw = (p) ->
  p.setup = ->
    p.size config.width, config.height

  p.draw = ->
    ball.x += ball.newX;
    ball.y += ball.newY;

    ball.x = 0 if ball.x < 0
    ball.x = config.width - 25 if ball.x > config.width - 25
    ball.y = 0 if ball.y < 0
    ball.y = config.height - 25 if ball.y > config.height - 25

    p.background 100
    p.ellipseMode p.CORNER
    p.ellipse ball.x, ball.y, 25, 25

$(document).ready ->

  canvas = $('canvas')[0]
  processing = new Processing canvas, coffee_draw

  if window.DeviceOrientationEvent

    window.addEventListener "deviceorientation", (orientData) ->
      ball.newX = orientData.gamma / 2
      ball.newY = orientData.beta / 2
      config.eventType = 'orientation'
    , true

  if window.DeviceMotionEvent and not config.eventType

    window.addEventListener "devicemotion", (event) ->
      ball.newX = event.accelerationIncludingGravity.x * (-3)
      ball.newY = event.accelerationIncludingGravity.y * 3
      config.eventType = 'motion'
    , true