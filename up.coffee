#!/usr/bin/env coffee

{spawn} = require 'child_process'
http = require 'http'

PORT = process.env.UP_PORT
PORT ?= 3333

debug = ->
if process.env.debug?
  debug = (doit) -> doit()


# Model Terminal
class ModelTerminal
  constructor: (@data) ->

  recv: (data) ->
    @data += data

mt = new ModelTerminal
listen = (req, resp) ->
  resp.statusCode = 200
  resp.write mt.data
  resp.end()
server = http.createServer listen
server.listen(PORT)
process.stderr.write "Listening on http://localhost:#{PORT}/\n"


child = spawn 'ksh', ['-i']
child.stdout.on 'data', (data) ->
  mt.recv data
  process.stdout.write data
child.stderr.on 'data', (data) ->
  mt.recv data
  process.stderr.write data
process.stdin.on 'data', (data) ->
  child.stdin.write data
process.stdin.on 'end', ->
  debug -> process.stdout.write '\x1b[33mEND\x1b[m'
  child.stdin.end()
child.on 'exit', ->
  process.stdout.write '\x1b[31mEXIT\x1b[m\n'
  process.exit()
process.stdin.resume()
