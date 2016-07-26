co = require 'co'
mysql = require 'mysql'
configure = require './configure'
htmlReporter = require './reporter/htmlReporter'
fs = require 'fs'

gitPool = mysql.createPool configure.GIT_MYSQL_CONFIG

getGitLogs = (commitID)->
  sql = "select * from #{configure.GIT_MYSQL_CONFIG.tableName} where commitID = '#{commitID}'"
  rows = yield new Promise (resolve, reject)->
    gitPool.query sql, (err, rows)->
      if err
        reject err
      else
        resolve rows
  # 必定以commit为单位获取，最多只有一行
  row = rows[0]
  return row

getFileStats = (filePath)->
  new Promise (resolve, reject)->
    fs.stat filePath, (err, stats)->
      if err
        reject "没有找到对应的commit记录"
      else
        resolve stats
    
getFileContent = (filePath)->
  new Promise (resolve, reject)->
    fs.readFile filePath, 'utf-8', (err, html)->
      if err
        reject err
      else
        resolve html


module.exports = (req, res)->
  dir = res.app.get('static_dir')
  commitID = req.params.commitID

  co ->
    if not commitID
      throw '缺少commit参数!'
    log = yield getGitLogs commitID
    if not log
      throw "没有找到对应的commit记录 #{commitID}"
    filePath = "#{dir}/static/#{log.logs}"
    stats = yield getFileStats filePath
    html = yield getFileContent filePath
    res.send html
  .catch (e)->
    console.log 'catch error', e
    res.render 'error.jade',
      errorMessage: e
  return
