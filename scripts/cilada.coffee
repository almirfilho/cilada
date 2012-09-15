window.requestAnimFrame = (->
  window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or
  window.oRequestAnimationFrame or window.msRequestAnimationFrame or (callback, element) ->
    window.setTimeout callback, 1000 / 60;
)();

b2Vec2         = Box2D.Common.Math.b2Vec2
b2BodyDef      = Box2D.Dynamics.b2BodyDef
b2Body         = Box2D.Dynamics.b2Body
b2FixtureDef   = Box2D.Dynamics.b2FixtureDef
b2Fixture      = Box2D.Dynamics.b2Fixture
b2World        = Box2D.Dynamics.b2World
b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape
b2CircleShape  = Box2D.Collision.Shapes.b2CircleShape
b2DebugDraw    = Box2D.Dynamics.b2DebugDraw

config =
  width: 700
  height: 432
  scale: 30
  walls: 7
  wallWidth: 0.5

ball =
  iniX: 1
  iniY: 1
  radius: 0.5
  newPosition: null
  obj: null

$canvas = $ 'canvas'
ctx     = $canvas[0].getContext '2d'
world   = null

# dimensionando o canvas
$canvas.attr
  'width': config.width
  'height': config.height

# centralizando o canvas
$canvas.css
  'top': "-webkit-calc(50% - #{config.height/2}px)"
  'left': "-webkit-calc(50% - #{config.width/2}px)"

init = () ->
  # criando o mundo (gravidade, allowSleep)
  world = new b2World new b2Vec2(0, 0), true

  # criando objeto de atualizacao de posicao da bola
  ball.newPosition = new b2Vec2 ball.iniX, ball.iniY

  # criando os objetos
  fixDef = new b2FixtureDef
  fixDef.density = 1.0
  fixDef.friction = 0.5
  fixDef.restitution = 0.4

  # parede inferior
  fixDef.shape = new b2PolygonShape
  fixDef.shape.SetAsBox canvas.width / config.scale / 2, config.wallWidth / 2

  bodyDef = new b2BodyDef
  bodyDef.type = b2Body.b2_staticBody
  bodyDef.position.x = canvas.width / config.scale / 2
  bodyDef.position.y = (canvas.height / config.scale) - config.wallWidth / 2
  world.CreateBody( bodyDef ).CreateFixture( fixDef )

  # parede superior
  bodyDef.position.x = canvas.width / config.scale / 2
  bodyDef.position.y = config.wallWidth / 2
  world.CreateBody( bodyDef ).CreateFixture( fixDef )

  # parede esquerda
  fixDef.shape.SetAsBox config.wallWidth / 2, canvas.height / config.scale / 2
  bodyDef.position.x = config.wallWidth / 2
  bodyDef.position.y = canvas.height / config.scale / 2
  world.CreateBody( bodyDef ).CreateFixture( fixDef )

  # parede direita
  bodyDef.position.x = canvas.width / config.scale - config.wallWidth / 2
  bodyDef.position.y = canvas.height / config.scale / 2
  world.CreateBody( bodyDef ).CreateFixture( fixDef )

  # paredes do labirinto
  for i in [1...config.walls]
    bodyDef.position.x = (canvas.width / config.scale - config.wallWidth) / config.walls * i + config.wallWidth / 2
    bodyDef.position.y = canvas.height / config.scale / 2

    if i % 2 is 0 then bodyDef.position.y += 3 else bodyDef.position.y -= 3
    world.CreateBody( bodyDef ).CreateFixture( fixDef )

  # criando bola
  fixDef.density = 0.5
  fixDef.friction = 1
  fixDef.restitution = 0
  fixDef.shape = new b2CircleShape ball.radius

  bodyDef.type = b2Body.b2_dynamicBody
  bodyDef.position.x = ball.iniX
  bodyDef.position.y = ball.iniY
  bodyDef.linearDamping = 1
  bodyDef.userData =
    name: 'bola!'

  ball.obj = world.CreateBody bodyDef
  ball.obj.CreateFixture fixDef

  # setup debug draw
  debugDraw = new b2DebugDraw()
  debugDraw.SetSprite ctx
  debugDraw.SetDrawScale config.scale
  debugDraw.SetFillAlpha 0.3
  debugDraw.SetLineThickness 1.0
  debugDraw.SetFlags b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit
  world.SetDebugDraw debugDraw

update = () ->
  # frequencia, velocidade das iterações, posição das iterações
  world.Step 1 / 60, 10, 10

  # movimentando a bola
  ball.obj.ApplyImpulse ball.newPosition, ball.obj.GetWorldCenter()

  world.DrawDebugData()
  world.ClearForces()
  requestAnimFrame update

init()
requestAnimFrame update

# capturando eventos do acelerometro
orientation = false

if window.DeviceOrientationEvent

  window.addEventListener 'deviceorientation', (orientData) ->
    ball.newPosition.x = orientData.gamma / config.scale / 2
    ball.newPosition.y = orientData.beta / config.scale / 2
    orientation = true

if window.DeviceMotionEvent and not orientation

  window.addEventListener 'devicemotion', (event) ->
    ball.newPosition.x = event.accelerationIncludingGravity.x / config.scale * (-3)
    ball.newPosition.y = event.accelerationIncludingGravity.y / config.scale * 3
    orientation = true