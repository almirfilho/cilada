class Wall

  constructor: (@x, @y, @width, @height) ->
    fixDef.density     = 1.0
    fixDef.friction    = 0.5
    fixDef.restitution = 0.4
    fixDef.shape       = new b2PolygonShape
    fixDef.shape.SetAsBox @width / config.scale / 2, @height / config.scale / 2

    bodyDef.type       = b2Body.b2_staticBody
    bodyDef.position.x = (@x / config.scale) + @width / config.scale / 2
    bodyDef.position.y = (@y / config.scale) + @height / config.scale / 2
    bodyDef.userData   = @

    @b2Obj = world.CreateBody bodyDef
    @b2Obj.CreateFixture fixDef

  draw: (shadow = null) ->
    ctx.fillStyle = '#8C4600'
    ctx.save()

    if shadow is 'block'
      ctx.shadowColor   = '#663300'
      ctx.shadowBlur    = 0
      ctx.shadowOffsetX = 0
      ctx.shadowOffsetY = 10

    else if shadow is 'shadow'
      ctx.shadowColor   = 'black'
      ctx.shadowBlur    = 10
      ctx.shadowOffsetX = 0
      ctx.shadowOffsetY = 12

    ctx.fillRect @x, @y, @width, @height
    ctx.restore()