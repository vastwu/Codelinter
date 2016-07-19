var gulp = require('gulp');
var rsync = require('gulp-rsync');

// 上线预发布环境文件
gulp.task('deploy', function() {
  var deployList = [
    // 一般情况下该目录无需重复部署
    //'../node_modules/**',
    'lib/**',
    'app.js',
    'test/**',
    'processes.json'
  ]
  return gulp.src(deployList)
    .pipe(rsync({
      hostname: '10.103.16.10',
      username: 'wusen',
      root: './',
      destination: '~/code/codelint'
    }))
});

