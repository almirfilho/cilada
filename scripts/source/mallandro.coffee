class Mallandro

  constructor: ->
    @ieieBuffer      = null
    @raaaBuffer      = null
    @salsiFufuBuffer = null
    @pegadinhaBuffer = null

  play: (buffer) ->
    if buffer?
      @sound        = audio.createBufferSource()
      @sound.buffer = buffer
      @sound.connect audio.destination
      @sound.noteOn 0

  ieie: -> @play @ieieBuffer
  raaa: -> @play @raaaBuffer
  salsiFufu: -> @play @salsiFufuBuffer
  pegadinha: -> @play @pegadinhaBuffer