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
  debug: false
  width: 700
  height: 432
  scale: 30
  ball:
    iniX: 30
    iniY: 30
    radius: 15
  walls:
    qnt: 6
    width: 15

class CiladaObject

  constructor: ->


class Ball extends CiladaObject

  constructor: (x, y, @radius) ->
    @position = new b2Vec2 x / config.scale, y / config.scale
    @impulse  = new b2Vec2 0, 0

    # fixDef = new b2FixtureDef
    fixDef.density = 0.5
    fixDef.friction = 1
    fixDef.restitution = 0
    fixDef.shape = new b2CircleShape @radius / config.scale

    # bodyDef = new b2BodyDef
    bodyDef.type = b2Body.b2_dynamicBody
    bodyDef.position.x = @position.x
    bodyDef.position.y = @position.y
    bodyDef.linearDamping = 1
    bodyDef.userData =
      name: 'bola!'

    @b2Obj = world.CreateBody bodyDef
    @b2Obj.CreateFixture fixDef

  move: ->
    @b2Obj.ApplyImpulse @impulse, @b2Obj.GetWorldCenter()
    @position = @b2Obj.GetPosition()

  draw: ->
    ctx.fillStyle = 'red'
    ctx.lineCap = 'round'
    ctx.beginPath()
    ctx.arc @position.x*config.scale, @position.y*config.scale, ball.radius, 0, Math.PI * 2, true
    ctx.closePath()
    ctx.fill()

class Wall extends CiladaObject

  constructor: (@x, @y, @width, @height) ->
    fixDef.density = 1.0
    fixDef.friction = 0.5
    fixDef.restitution = 0.4
    fixDef.shape = new b2PolygonShape
    fixDef.shape.SetAsBox @width / config.scale / 2, @height / config.scale / 2

    bodyDef.type = b2Body.b2_staticBody
    bodyDef.position.x = (@x / config.scale) + @width / config.scale / 2
    bodyDef.position.y = (@y / config.scale) + @height / config.scale / 2

    @b2Obj = world.CreateBody bodyDef
    @b2Obj.CreateFixture fixDef

  draw: ->
    ctx.save()
    ctx.fillStyle = '#cccccc'
    ctx.fillRect @x, @y, @width, @height
    ctx.restore()

ball    = null
walls   = []
$canvas = $ 'canvas'
ctx     = $canvas[0].getContext '2d'
world   = null
fixDef  = null
bodyDef = null

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

  # criando bola
  ball = new Ball config.ball.iniX, config.ball.iniY, config.ball.radius

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
    ball.draw()
    wall.draw() for wall in walls

  world.ClearForces()
  requestAnimFrame update

init()
requestAnimFrame update

# capturando eventos do acelerometro
orientation = false

if window.DeviceOrientationEvent

  window.addEventListener 'deviceorientation', (orientData) ->
    ball.impulse.x = orientData.gamma / config.scale / 2
    ball.impulse.y = orientData.beta / config.scale / 2
    orientation = true

if window.DeviceMotionEvent and not orientation

  window.addEventListener 'devicemotion', (event) ->
    ball.impulse.x = event.accelerationIncludingGravity.x / config.scale * (-3)
    ball.impulse.y = event.accelerationIncludingGravity.y / config.scale * 3
    orientation = true