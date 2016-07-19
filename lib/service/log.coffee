Util = require 'util'

log = ()->
  for a in arguments
    if typeof a is 'object'
      console.log Util.inspect a,
        depth: 4
        colors: yes
    else
      console.log a

module.exports = log
