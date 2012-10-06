class Ball

  constructor: (@x, @y, @radius) ->
    @position     = new b2Vec2 @x / config.scale, @y / config.scale
    @impulse      = new b2Vec2 0, 0
    @bounceBuffer = null
    @dieBuffer    = null

    fixDef.density     = 0.5
    fixDef.friction    = 1
    fixDef.restitution = 0
    fixDef.shape       = new b2CircleShape @radius / config.scale

    bodyDef.type          = b2Body.b2_dynamicBody
    bodyDef.position.x    = @position.x
    bodyDef.position.y    = @position.y
    bodyDef.linearDamping = 1
    bodyDef.userData      = @

    @b2Obj = world.CreateBody bodyDef
    @b2Obj.CreateFixture fixDef

  resetPosition: ->
    @position = new b2Vec2 config.ball.iniX / config.scale, config.ball.iniY / config.scale
    @b2Obj.SetPosition @position

  move: ->
    @b2Obj.ApplyImpulse @impulse, @b2Obj.GetWorldCenter()
    @position = @b2Obj.GetPosition()

  play: ->
    if @bounceBuffer?
      if window.AudioContext?
        @sound        = audio.createBufferSource()
        @sound.buffer = @bounceBuffer
        @gainNode     = audio.createGainNode()

        @sound.connect @gainNode
        @gainNode.connect audio.destination
        velocity = @b2Obj.GetLinearVelocity()
        @gainNode.gain.value = (velocity.x * velocity.x + velocity.y * velocity.y) / 40
        @sound.noteOn 0
      else
        @bounceBuffer.play()

  playDead: ->
    if @dieBuffer?
      if window.AudioContext?
        @sound        = audio.createBufferSource()
        @sound.buffer = @dieBuffer
        @sound.connect audio.destination
        @sound.noteOn 0
      else
        @dieBuffer.play()

  draw: ->
    if game.alive
      @x = @position.x * config.scale
      @y = @position.y * config.scale

      ctx.save()
      ctx.fillStyle = ctx.createRadialGradient @x, @y-3, 2, @x, @y, @radius
      ctx.fillStyle.addColorStop 0, '#eee'
      ctx.fillStyle.addColorStop 1, '#444'
      ctx.lineCap = 'round'

      ctx.beginPath()
      ctx.arc @x, @y, @radius, 0, Math.PI * 2, true
      ctx.closePath()

      ctx.shadowColor = 'rgba(0,0,0,0.7)'
      ctx.shadowBlur = 8
      ctx.shadowOffsetX = 1
      ctx.shadowOffsetY = 6
      ctx.fill()
      ctx.restore()