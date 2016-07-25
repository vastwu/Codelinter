Path = require 'path'
co = require 'co'
GitHelper = require './GitHelper'
log = require './log'
linter = require './linter'
mysqlReporter = require './reporter/mysqlReporter'
mailReporter = require './reporter/mailReporter'


module.exports = (req, res)->
  res.end '1'
  co ->
    action = req.headers['x-gitlab-event']
    gitBody = req.body
    if gitBody.object_kind is 'push'
      branchName = gitBody.ref.split('/').pop()
      productName = gitBody.repository.name
      homepage = gitBody.repository.homepage
      projectID = gitBody.project_id
      commitID = gitBody.after
      owner = gitBody.user_email
      commits = gitBody.commits

      project = GitHelper.getProject projectID
      branch = project.getBranch branchName

      changedFiles = {}
      for commit in commits
        # 单次commit
        c = branch.getCommit commit.id
        commitFiles = yield c.getContent yes
        for filePath in commitFiles
          # 单次commit可能涉及多个文件
          if not filePath.deleted_file
            changedFiles[filePath.new_path] = 1

      # to array
      fileArray = for path of changedFiles
        path
      fileArray = fileArray.sort (a, b)->
        if a > b then -1 else 1
      log fileArray
      #fileArray = ['lib/client/report/main.coffee']

      lintedFiles = for filePath in fileArray
        #code = fs.readFileSync filePath, 'utf-8'
        gitFile = branch.getFile filePath
        file = yield gitFile.getContent()
        code = file.content
        errors = yield linter code, Path.extname(filePath)
        outLimit = no
        if errors.length > 100
          # 只截取100个
          errors = errors.slice 0, 100
          outLimit = yes
        # errors可能为null,表示不支持的文件类型
        count =
          error: 0
          warning: 0
          notSupport: no
        if errors is undefined
          # 真的不支持
          count.notSupport = yes
        else if errors is null
          # 解析错误
          count.notSupport = yes
        else
          for err in errors
            if err.level is 'error'
              count.error++
            else
              count.warning++
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
        owner: owner
        createtime: Date.now()
        logs: lintedFiles
        outLimit: outLimit

      mailReporter renderData, req.app, owner, owner
      mysqlReporter renderData

    res.end('end')

  .catch (err)->
    log err
    res.end('err', err.toString())
