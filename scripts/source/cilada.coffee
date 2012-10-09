window.requestAnimFrame = (->
  window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or
  window.oRequestAnimationFrame or window.msRequestAnimationFrame or (callback, element) ->
    window.setTimeout callback, 1000 / 60;
)();

window.AudioContext = (->
  window.AudioContext or window.webkitAudioContext or window.mozAudioContext or window.oAudioContext or window.msAudioContext
)();

window.DeviceOrientationEvent = (->
  window.DeviceOrientationEvent or window.webkitDeviceOrientationEvent or window.mozDeviceOrientationEvent or
  window.oDeviceOrientationEvent or window.msDeviceOrientationEvent
)();

window.DeviceMotionEvent = (->
  window.DeviceMotionEvent or window.webkitDeviceMotionEvent or window.mozDeviceMotionEvent or
  window.oDeviceMotionEvent or window.msDeviceMotionEvent
)();

b2Vec2            = Box2D.Common.Math.b2Vec2
b2BodyDef         = Box2D.Dynamics.b2BodyDef
b2Body            = Box2D.Dynamics.b2Body
b2FixtureDef      = Box2D.Dynamics.b2FixtureDef
b2Fixture         = Box2D.Dynamics.b2Fixture
b2World           = Box2D.Dynamics.b2World
b2PolygonShape    = Box2D.Collision.Shapes.b2PolygonShape
b2CircleShape     = Box2D.Collision.Shapes.b2CircleShape
b2DebugDraw       = Box2D.Dynamics.b2DebugDraw
b2ContactListener = Box2D.Dynamics.b2ContactListener

config =
  debug: false
  width: 700
  height: 432
  scale: 30
  ball:
    iniX: 30
    iniY: 35
    radius: 15
  walls:
    qnt: 6
    width: 15

ball      = null
walls     = []
holes     = []
mallandro = null

game =
  alive: false
  win:   false

$canvas = $ 'canvas'
ctx     = $canvas[0].getContext '2d'
audio   = null
world   = null
fixDef  = null
bodyDef = null
contact = null
hasAccelerationDevice  = false
hasAccelerationSupport = false

# dimensionando o canvas
$canvas.attr
  'width': config.width
  'height': config.height

# botao de inicio do jogo
$('#begin').click (event) ->
  event.preventDefault()
  beginGame()

init = ->
  # testa se tem suporte/hardware de aceletometro
  return if not hasAccelerometer()
  setTimeout ->
    if not hasAccelerationSupport
      $('#prompt p, #prompt button').remove()
      $('#prompt').append '<p class="no-support"><strong>Pôôo meu irmão!!</strong><br />Seu computador não tem <strong>Acelerômetro</strong>!<br />Buy a mac ;)</p>'
  , 20

  # criando o mundo (gravidade, allowSleep)
  world   = new b2World new b2Vec2(0, 0), true
  fixDef  = new b2FixtureDef
  bodyDef = new b2BodyDef
  # criando os objetos do jogo
  # parede superior
  walls.push new Wall 0, 0, config.width, config.walls.width
  # parede inferior
  walls.push new Wall 0, config.height - config.walls.width, config.width, config.walls.width
  # parede esquerda
  walls.push new Wall 0, 0, config.walls.width, config.height
  # parede direita
  walls.push new Wall config.width - config.walls.width, 0, config.width, config.height

  # paredes internas do labirinto
  w = config.walls.width
  h = config.height * 0.8

  for i in [1..config.walls.qnt]
    x = i * ((config.width - config.walls.width) / (config.walls.qnt + 1))
    y = if i % 2 is 0 then config.height * 0.2 else 0
    walls.push new Wall x, y, w, h

  # criando buracos
  r = config.ball.radius
  holes.push new Hole 80,  150, r
  holes.push new Hole 35,  300, r
  holes.push new Hole 170, 390, r
  holes.push new Hole 135, 240, r
  holes.push new Hole 175, 70,  r
  holes.push new Hole 270, 150, r
  holes.push new Hole 301, 375, r
  holes.push new Hole 371, 250, r
  holes.push new Hole 330, 46,  r
  holes.push new Hole 468, 110, r
  holes.push new Hole 440, 370, r
  holes.push new Hole 540, 320, r
  holes.push new Hole 620, 180, r
  holes.push new Hole 667, 130, r
  holes.push new Hole 643, 390, r, true

  # criando bola
  ball = new Ball config.ball.iniX, config.ball.iniY, config.ball.radius
  # crinado mallandro
  mallandro = new Mallandro
  # carregando efeitos sonoros
  loadSounds()
  # capturando eventos do acelerometro
  orientation = false

  if window.DeviceOrientationEvent?
    window.addEventListener 'deviceorientation', (orientData) ->
      ball.impulse.x = orientData.gamma / config.scale / 2
      ball.impulse.y = orientData.beta / config.scale / 2
      orientation = true

  if window.DeviceMotionEvent? and not orientation
    window.addEventListener 'devicemotion', (event) ->
      ball.impulse.x = event.accelerationIncludingGravity.x / config.scale * (-3)
      ball.impulse.y = event.accelerationIncludingGravity.y / config.scale * 3

  # listener de colisoes
  contact = new b2ContactListener
  contact.BeginContact = (contact) ->
    if contact.GetFixtureA().GetBody().GetUserData() instanceof Wall
      ball.play()
    else
      ball.playDead()
      game.alive = false
      game.win = true if contact.GetFixtureB().GetBody().GetUserData().winHole

  world.SetContactListener contact

  # setup debug draw
  if config.debug
    debugDraw = new b2DebugDraw()
    debugDraw.SetSprite ctx
    debugDraw.SetDrawScale config.scale
    debugDraw.SetFillAlpha 0.3
    debugDraw.SetLineThickness 1.0
    debugDraw.SetFlags b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit
    world.SetDebugDraw debugDraw

update = () ->
  if game.alive
    # frequencia, velocidade das iterações, posição das iterações
    world.Step 1 / 60, 10, 10
    # movimentando a bola
    ball.move()
    # redesenhando o canvas
    if config.debug
      # renderizacao de teste do box2D
      world.DrawDebugData()
    else
      ctx.clearRect 0, 0, config.width, config.height
      # wall.draw('shadow') for wall in walls
      # hole.draw() for hole in holes
      # wall.draw('block') for wall in walls
      ball.draw()
      wall.draw() for wall in walls

    world.ClearForces()
    requestAnimFrame update

  else
    endGame()

beginGame = ->
  if not game.alive
    # escondendo menu
    $('#prompt').animate({top: '-60%'}, 450, 'swing', ->
      # animando serginho mallandro
      $('#malandro').animate {top: '5%'}, 400
      # escondendo overlay
      $('#overlay').fadeOut( 600, ->
        # mostrando balao
        $('#balloon .body').html 'Ié Ié!!'
        $('#balloon').show()
        mallandro.ieie()

        setTimeout ->
          $('#balloon').hide()
          $('#malandro').animate({top: '100%'}, 400, 'swing', ->
            # setando estado inicial do jogo
            game.alive = true
            game.win   = false
            ball.resetPosition()
            # iniciando jogo
            requestAnimFrame update
          )
        , 800
      )
    )

endGame = ->
  [msg, time] = if game.win then ['Glu glu ié ié!', 800] else ['Ráááá!', 2200]

  setTimeout ->
    $('#malandro').animate {top: '5%'}, 300
    $('#balloon .body').html msg
    $('#balloon').fadeIn 'slow'
    if game.win then mallandro.ieie() else mallandro.pegadinha()

    setTimeout ->
      $('#overlay').fadeIn( 600, ->
        $('#balloon').hide()
        $('#malandro').animate({top: '45%'}, 400, 'swing', ->
          $('#prompt').animate {top: '25%'}, 450
        )
      )
    , time
  , 600

loadSounds = ->

  if window.AudioContext?
    # criando instancia de audio context
    audio = new AudioContext()
    # carregando som da bola batendo
    requestBounce = new XMLHttpRequest()
    requestBounce.open 'GET', 'sounds/bounce.wav', true
    requestBounce.responseType = 'arraybuffer'

    requestBounce.onload = ->
      audio.decodeAudioData requestBounce.response, (buffer) ->
        ball.bounceBuffer = buffer
      , ->
        alert 'erro ao ler audio bounce.wav'

    requestBounce.send()

    # carregando som da bola caindo
    requestDie = new XMLHttpRequest()
    requestDie.open 'GET', 'sounds/die.mp3', true
    requestDie.responseType = 'arraybuffer'

    requestDie.onload = ->
      audio.decodeAudioData requestDie.response, (buffer) ->
        ball.dieBuffer = buffer
      , ->
        alert 'erro ao ler audio die.mp3'

    requestDie.send()

    # carregando som ieie (mallandro)
    requestIeie = new XMLHttpRequest()
    requestIeie.open 'GET', 'sounds/ieie.mp3', true
    requestIeie.responseType = 'arraybuffer'

    requestIeie.onload = ->
      audio.decodeAudioData requestIeie.response, (buffer) ->
        mallandro.ieieBuffer = buffer
      , ->
        alert 'erro ao ler audio ieie.mp3'

    requestIeie.send()

    # carregando som pegadinha (mallandro)
    requestPegadinha = new XMLHttpRequest()
    requestPegadinha.open 'GET', 'sounds/pegadinha.mp3', true
    requestPegadinha.responseType = 'arraybuffer'

    requestPegadinha.onload = ->
      audio.decodeAudioData requestPegadinha.response, (buffer) ->
        mallandro.pegadinhaBuffer = buffer
      , ->
        alert 'erro ao ler audio ieie.mp3'

    requestPegadinha.send()

  else
    ball.bounceBuffer         = $('<audio src="sounds/bounce.wav" preload></audio>').appendTo('body')[0]
    ball.dieBuffer            = $('<audio src="sounds/die.ogg" preload></audio>').appendTo('body')[0]
    mallandro.ieieBuffer      = $('<audio src="sounds/ieie.ogg" preload></audio>').appendTo('body')[0]
    mallandro.pegadinhaBuffer = $('<audio src="sounds/pegadinha.ogg" preload></audio>').appendTo('body')[0]

hasAccelerometer = ->
  if not (window.DeviceOrientationEvent? or window.DeviceMotionEvent?)
    $('#prompt p, #prompt button').remove()
    $('#prompt').append '<p class="no-support"><strong>Pôôo meu irmão!!</strong><br />Seu navegador não tem suporte a <strong>Acelerômetro</strong>!<br />Tente no <span class="chrome">Google Chrome</span> ou <span class="firefox">Mozilla Firefox</span> ;)</p>'
    false

  if window.DeviceOrientationEvent?
    window.addEventListener 'deviceorientation', (orientData) ->
      hasAccelerationDevice = true

  if window.DeviceMotionEvent?
    window.addEventListener 'devicemotion', (event) ->
      hasAccelerationDevice = true

  hasAccelerationSupport = true
  true

init()