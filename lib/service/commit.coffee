co = require 'co'
mysql = require 'mysql'
configure = require './configure'
htmlReporter = require './reporter/htmlReporter'

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
  if row
    row.logs = JSON.parse row.logs
  return row

module.exports = (req, res)->
  co ->
    commitID = req.params.commitID
    if commitID
      log = yield getGitLogs commitID
      if not log
        throw "没有找到对应的commit记录 #{commitID}"

      renderData = log
    else
      throw '缺少commit参数!'

    htmlReporter renderData, res
  .catch (e) ->
    console.log e
    res.render 'error.jade',
      errorMessage: e.toString()
