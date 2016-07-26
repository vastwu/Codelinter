fs = require 'fs'

module.exports = (data, app)->
  dir = app.get('static_dir')
  app.render 'reporter.jade', data, (err, html)->
    date = new Date(data.createtime)
    day = date.getDate()
    month = date.getMonth()
    year = date.getFullYear()
    savePath = "#{dir}/static/#{year}_#{month}_#{day}"
    saveFileName = "#{data.commitID}.html"
    fs.stat savePath, (err, stats)->
      if err
        fs.mkdirSync savePath
      fs.writeFile "#{savePath}/#{saveFileName}", html, 'utf-8'
