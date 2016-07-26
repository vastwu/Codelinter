configure = require '../configure'
mysql = require 'mysql'

gitPool = mysql.createPool configure.GIT_MYSQL_CONFIG

module.exports = (sourceData)->
  data = {}
  Object.assign data, sourceData
  data.logs = ''
  date = new Date(data.createtime)
  day = date.getDate()
  month = date.getMonth()
  year = date.getFullYear()
  savePath = "#{year}_#{month}_#{day}/#{data.commitID}.html"
  data.logs = savePath
  gitPool.query "INSERT INTO #{configure.GIT_MYSQL_CONFIG.tableName} SET ?", data, (err, result, fields) ->
    console.log 'sql done', err, result
