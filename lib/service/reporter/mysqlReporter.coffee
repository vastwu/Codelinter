configure = require '../configure'
mysql = require 'mysql'

gitPool = mysql.createPool configure.GIT_MYSQL_CONFIG

module.exports = (data)->
  data.logs = JSON.stringify data.logs
  gitPool.query "INSERT INTO #{configure.GIT_MYSQL_CONFIG.tableName} SET ?", data, (err, result, fields) ->
    console.log 'sql done', err, result
