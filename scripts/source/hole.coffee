class Hole

  constructor: (@x, @y, @radius, @winHole = false) ->
    fixDef.density     = 1
    fixDef.friction    = 1
    fixDef.restitution = 0
    fixDef.shape       = new b2CircleShape @radius / config.scale / 4

    bodyDef.type          = b2Body.b2_staticBody
    bodyDef.position.x    = @x / config.scale
    bodyDef.position.y    = @y / config.scale
    bodyDef.linearDamping = 1
    bodyDef.userData      = @

    @b2Obj = world.CreateBody bodyDef
    @b2Obj.CreateFixture fixDef

  draw: ->
    ctx.save()

    if @winHole
      ctx.fillStyle = ctx.createRadialGradient @x+2, @y+5, 12, @x+2, @y+5, @radius+5
      ctx.fillStyle.addColorStop 0, '#4C6600'
      ctx.fillStyle.addColorStop 1, 'black'
    else
      ctx.fillStyle = ctx.createRadialGradient @x+2, @y+5, 12, @x+2, @y+5, @radius+5
      ctx.fillStyle.addColorStop 0, '#713203'
      ctx.fillStyle.addColorStop 1, 'black'

    ctx.lineCap = 'round'
    ctx.beginPath()
    ctx.arc @x, @y, @radius, 0, Math.PI * 2, true
    ctx.closePath()
    ctx.fill()

    ctx.restore()