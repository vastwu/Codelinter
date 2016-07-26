http = require 'http'
Path = require 'path'
fs = require 'fs'
URL = require 'url'
express = require "express"
bodyParser = require 'body-parser'
co = require 'co'
GitHelper = require './GitHelper'
log = require './log'
reporter = require './reporter'
serveStatic = require 'serve-static'


IS_DEBUG = process.env.NODE_ENV is 'development'

# 常量
PORT = process.env.PORT

GitHelper.conf 'HOST', 'https://git.yidian-inc.com:8021'
GitHelper.conf 'TOKEN', 'WX3V4h-gLxnxEVfxLZC-'

app = express()
app.set 'view engine', 'jade'
app.set 'views', Path.join(__dirname, '/view')

app.set 'static_dir', Path.join(__dirname, '../client')
app.use serveStatic(app.get('static_dir'))

app.use bodyParser.json()
app.all '/git', require('./git')
app.get '/test', require('./test')
app.get '/commit/:commitID?', require('./commit')

app.listen(PORT)


###
GitHelper.api('projects/489/repository/commits/master').then (body)->
  console.log 'done', body
###

console.log "Server running at http://127.0.0.1:#{PORT}"





