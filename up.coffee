#!/usr/bin/env coffee

{spawn} = require 'child_process'
http = require 'http'

# https://npmjs.org/package/pty.js
pty = require 'pty.js'

PORT = process.env.UP_PORT
PORT ?= 3333

debug = ->
if process.env.debug?
  debug = (doit) -> doit()


# Model Terminal
class ModelTerminal
  constructor: (@data='') ->

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

master = pty.spawn 'ksh', ['-i']
master.on 'data', (data) ->
  mt.recv data
  process.stdout.write data
process.stdin.on 'data', (data) ->
  master.write data
process.stdin.on 'end', ->
  debug -> process.stdout.write '\x1b[33mEND\x1b[m'
  master.end() # :todo: really?
master.on 'end', ->
  process.stdout.write '\x1b[31mEXIT\x1b[m\n'
  process.exit()
process.stdin.resume()
