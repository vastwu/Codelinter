fs = require 'fs'
co = require 'co'
Path = require 'path'
log = require './log'
configure = require './configure'
linter = require './linter'
mysqlReporter = require './reporter/mysqlReporter'
htmlReporter = require './reporter/htmlReporter'
mailReporter = require './reporter/mailReporter'


module.exports = (req, res)->
  productName = "productName"
  branchName = "branchName"
  commitID = "commitID#{Date.now()}"
  owner = "owner"
  homepage = "homepage"

  testDir = Path.join(__dirname, '../../test')
  fileArray = fs.readdirSync testDir
  fileArray = fileArray.map (path)->
    "#{testDir}/#{path}"
  co ->
    lintedFiles = for filePath in fileArray
      code = fs.readFileSync filePath, 'utf-8'
      errors = yield linter code, Path.extname(filePath)
      # errors可能为null,表示不支持的文件类型
      count =
        error: 0
        warning: 0
        notSupport: no
      if Array.isArray(errors)
        for err in errors
          if err.level is 'error'
            count.error++
          else
            count.warning++
      else
        count.notSupport = yes
      oneData =
        path: filePath
        filePath: "#{homepage}/blob/#{branchName}/#{filePath}"
        count: count
        errors: errors
      oneData

    renderData =
      productName: productName
      branchName: branchName
      commitID: commitID
      createtime: Date.now()
      owner: owner
      logs: lintedFiles

    #mysqlReporter renderData
    mailReporter renderData, req.app, 'wusen@yidian-inc.com', 'wusen@yidian-inc.com', res
    htmlReporter renderData, res
  .catch (err)->
    log err
    res.end 'err'
