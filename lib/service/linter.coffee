coffeelint = require 'coffeelint'
jslinter = require 'jslint'
csslint = require('csslint').CSSLint
htmllint = require('htmllint')
jsonlint = require('jsonlint')
JadeLinter = require('jadelint').Linter
log = require './log'

makeInsertSpaceFn = (max)->
  (n)->
    n = n.toString()
    insertNumber = max - n.length
    if insertNumber > 0
      insert = new Array(insertNumber + 1).join(' ')
      return insert + n
    else
      return n

getCloseRow = (rows, n, delta)->
  #console.log 'n:', n, delta
  # 填充n个空格，n为最大行数的位数
  space = (n + delta + 1).toString().length
  insertFn = makeInsertSpaceFn(space)
  arr = for i in [n - delta...n + delta + 1]
    # 文件行数从1开始，从文件数组中取值时从0开始
    # 小于0的和超出最后一行的不需要
    if i + 1 > 0 and rows[i]
      "#{insertFn(i + 1)}   #{rows[i]}"
    else
      ""
  arr = arr.filter (text)-> text
  return arr
###
# errors 标准格式
#  lineNumber: 行号 
#  level: 错误级别， error or warn
#  message: 错误信息提示
#  code: 相关代码, 可以通过行号来构建，不用特意填写
# support:
#   .json
#   .html
#   .css
#   .js
#   .coffee
#   .jade
###
module.exports = (code, extname)->
  try
    switch extname
      when '.json'
        try
          jsonlint.parse code
          errors = []
        catch e
          errMsg = e.toString()
          line = errMsg.match(/on line ([\d]*):/)
          if line
            line = line[1]
          errors = [
            lineNumber: line
            level: 'error'
            message: errMsg
          ]
      when '.html'
        reports = yield htmllint code,
          'indent-style': 'spaces'
          'indent-width': 2
          'tag-self-close': yes
        errors = for err in reports
          lineNumber: err.line
          level: 'error'
          message: err.rule
      when '.css'
        report = csslint.verify code
        errors = for err in report.messages
          lineNumber: err.line
          level: if err.type is 'warning' then 'warn' else 'error'
          message: "【#{err.rule.browsers}】：#{err.message}"
      when '.coffee'
        errors = coffeelint.lint code,
          max_line_length:
            value: 200
      when '.js'
        linter = jslinter.load()
        linted = jslinter.linter.doLint linter, code,
          sloppy: yes
          indent: 2
          predef: ["module", "require"]
          maxerr: 500
          node: yes
        errors = linted.errors
          .filter (item)-> item
          .map (item)->
            lineNumber: item.line
            level: 'error'
            message: item.reason
      when '.jade'
        linter = new JadeLinter null, code
        # error格式标准化
        errors = linter.lint()
          .filter (item)->
            item.level is 'error' or item.level is 'warn'
          .map (item)->
            # jadelint检查出来的行号总是多一行，不知道为什么
            # 此处-1
            lineNumber: item.line - 1
            level: item.level
            message: item.name
      else
        return undefined
    #log errors
    codeArray = code.split '\n'
    for err in errors
      if err.lineNumber
        arr = getCloseRow codeArray, err.lineNumber, 3
        err.code = arr.join('\n')
    return errors
  catch e
    log 'err', e
    return null

