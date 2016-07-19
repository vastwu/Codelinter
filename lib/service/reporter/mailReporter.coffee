nodemailer = require 'nodemailer'
configure = require '../configure'

transporter = nodemailer.createTransport
  host: configure.MAIL_HOST
  port: configure.MAIL_PORT

###
testMail = (from, to, subject, text, html)->
  mailOptions =
    from: from #'"WuSen" <wusen@yidian-inc.com>' # sender address 
    to: to # 'wusen@yidian-inc.com' # list of receivers 
    subject: subject #'Hello' # Subject line 
    text: text # 'plain: Hello world' # plaintext body 
    html: html # '<b>html: Hello world</b>' # html body 
  transporter.sendMail mailOptions, (err, info)->
    console.log 'maildone', err, info
###

module.exports = (data, app, from, to)->
  app.render 'mail.jade', data, (err, html)->
    #console.log err, html
    #res.send html
    #return
    if err
      html = err
    mailOptions =
      from: from #'"WuSen" <wusen@yidian-inc.com>' # sender address 
      to: to # 'wusen@yidian-inc.com' # list of receivers 
      subject: "CodeLint" #'Hello' # Subject line 
      #text: text # 'plain: Hello world' # plaintext body 
      html: html # '<b>html: Hello world</b>' # html body 

    transporter.sendMail mailOptions, (err, info)->
      console.log 'maildone', err, info
