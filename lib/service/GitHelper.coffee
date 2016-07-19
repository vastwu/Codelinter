request = require 'request'
log = require './log'

CONFIG = {}


send = (url)->
  log "git: #{url} start"
  return new Promise (resolve, reject)-> request url, (err, response, body)->
    if not err
      try
        jsonBody = JSON.parse body
      catch
        resolve body
        return
      resolve jsonBody
    else
      reject err

Helper =
  conf: (key, value)->
    CONFIG[key] = value

  api: (path)->
    if path.indexOf('?') > -1
      url = "#{CONFIG.HOST}/api/v3/#{path}&private_token=#{CONFIG.TOKEN}"
    else
      url = "#{CONFIG.HOST}/api/v3/#{path}?private_token=#{CONFIG.TOKEN}"
    return send url

  getProject: (projectID)->
    return new GitProject projectID

GitProject = (projectID)->
  @getBranch = (branchName)->
    return new GitBranch projectID, branchName
  return

GitBranch = (projectID, branchName)->
  @getCommit = (commitID)->
    return new GitCommit projectID, branchName, commitID

  @getFile = (filePath = '')->
    return new GitFile projectID, branchName, filePath
  return

GitCommit = (projectID, branchName, commitID)->
  path = "/projects/#{projectID}/repository/commits/#{commitID}"

  @getContent = (withDiff = no)->
    _path = path
    if withDiff
      _path += '/diff'
    return Helper.api _path
  return

GitFile = (projectID, branchName, filePath)->
  path = "/projects/#{projectID}/repository/files?ref=#{branchName}&file_path=#{filePath}"
  @getContent = ()->
    return Helper.api(path).then (body)->
      c = new Buffer(body.content, 'base64')
      body.content = c.toString()
      return body
  return

Helper.GitProject = GitProject
Helper.GitBranch = GitBranch
Helper.GitCommit = GitCommit
Helper.GitFile = GitFile

module.exports = Helper
