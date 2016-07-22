###
@files server端配置
###
conf = require './defaultConfigure'

debug_api =
  # 开发用测试环境
  #apiUri: "http://10.111.0.33:9100"
  isRunning: yes
  logLevel: 0
  logAppCode: 'debug'
  defaultPort: 3024
  # 线上
  #apiUri: "http://lc2.haproxy.yidian.com:9100"
  # QA的api环境，一般用于本地代码+qa环境排查api问题
  apiUri: "http://10.111.0.153:9100"
  #apiUri: "http://192.168.11.140:9100"
  #apiUri: "http://10.103.16.66:9100"
  #apiUri: "http://10.103.34.19:9100"
  # 测试视频相关服务 154
  #apiUri: "http://videotest.yidianzixun.com:10100"
  #stat_apiUri: "http://wemedia.ha.in.yidian.com:9988"
  #settlement_apiUri: "http://10.111.0.153:9100"
  #settlement_apiUri: "http://10.103.16.66:9300"
  #upload_apiUri: "http://static_image_api.ha.in.yidian.com:8082/image/image.php?action=insert&type=test"
  #stat_apiUri: "http://10.103.34.19:9988"
session_maxAge: 5 * 1000
  #a1_apiUri: 'http://10.103.16.14:1234/?target=http://a1.go2yd.com/Website'
  a1_apiUri: 'http://a1.go2yd.com/Website'
  a4_apiUri: 'http://a4.go2yd.com/Website'
  # 内网超慢，需要转发接口
  #a4_apiUri: 'http://10.103.16.14:1234/?target=http://a4.go2yd.com/Website'
  redis_enable: yes
  #redis_apiUri: '10.103.16.66'
  #redis_port: '16379'
  redis_expire: 5

# test-normal
TESTING_IP = '10.103.34.19'
test_api =
  # 手工测试
  manual:
    logAppCode: 'manual'
    defaultPort: 3090
    apiUri: "http://#{TESTING_IP}:9100"
    settlement_apiUri: "http://#{TESTING_IP}:9300"
    upload_apiUri: "http://static_image_api.ha.in.yidian.com:8082/image/image.php?action=insert&type=test"
    session_maxAge: 5
    redis_apiUri: TESTING_IP
    redis_port: '16379'
    redis_expire: 10
  # 自动化测试用接口环境
  normal:
    logAppCode: 'normal'
    defaultPort: 3091
    apiUri: "http://#{TESTING_IP}:9101"
    settlement_apiUri: "http://#{TESTING_IP}:9301"
    upload_apiUri: "http://static_image_api.ha.in.yidian.com:8082/image/image.php?action=insert&type=test"
    session_maxAge: 5
    redis_apiUri: TESTING_IP
    redis_port: '16379'
    redis_expire: 1
  # 审核测试环境
  audittest:
    logAppCode: 'audit'
    defaultPort: 3094
    apiUri: "http://#{TESTING_IP}:9104"
    settlement_apiUri: "http://#{TESTING_IP}:9304"
    upload_apiUri: "http://static_image_api.ha.in.yidian.com:8082/image/image.php?action=insert&type=test"
    session_maxAge: 5
    redis_apiUri: TESTING_IP
    redis_port: '16379'
    redis_expire: 1

# stable-normal
# 稳定版监控master
STABLE_API = '10.103.16.66'
stable_api =
  # 手工测试
  manual:
    logAppCode: 'manual'
    defaultPort: 3090
    apiUri: "http://#{STABLE_API}:9100"
    settlement_apiUri: "http://#{STABLE_API}:9300"
    upload_apiUri: "http://static_image_api.ha.in.yidian.com:8082/image/image.php?action=insert&type=test"
    session_maxAge: 5
    redis_apiUri: STABLE_API
    redis_port: '16379'
    redis_expire: 10
  # 自动化测试用接口环境
  normal:
    logAppCode: 'normal'
    defaultPort: 3091
    apiUri: "http://#{STABLE_API}:9101"
    settlement_apiUri: "http://#{STABLE_API}:9301"
    upload_apiUri: "http://static_image_api.ha.in.yidian.com:8082/image/image.php?action=insert&type=test"
    session_maxAge: 5
    redis_apiUri: STABLE_API
    redis_port: '16379'
    redis_expire: 1
  # 审核测试环境
  audittest:
    logAppCode: 'audit'
    defaultPort: 3094
    apiUri: "http://#{STABLE_API}:9104"
    settlement_apiUri: "http://#{STABLE_API}:9304"
    upload_apiUri: "http://static_image_api.ha.in.yidian.com:8082/image/image.php?action=insert&type=test"
    session_maxAge: 5
    redis_apiUri: STABLE_API
    redis_port: '16379'
    redis_expire: 1

module.exports = (type, subType)->
  switch type
    when 'debug'
      debug_api
    when 'test'
      test_api[subType]
    when 'stable'
      stable_api[subType]


NODE_ENV = process.env.NODE_ENV or ''

is_debug = NODE_ENV is 'development'
is_test = NODE_ENV.indexOf('test') > -1
is_stable = NODE_ENV.indexOf('stable') > -1

coverConfig = null
if is_debug
 coverConfig = debug_api
 conf.runningMode = 'debug'
else if is_test
 args = NODE_ENV.split('-')
 coverConfig = test_api[args[1]]
 conf.runningMode = 'test'
else if is_stable
 args = NODE_ENV.split('-')
 coverConfig = stable_api[args[1]]
 conf.runningMode = 'stable'

if coverConfig
 console.log "!!!!api domain for #{NODE_ENV}"
 for key, value of coverConfig
   conf[key] = value

module.exports = conf


