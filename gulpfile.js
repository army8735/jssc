var gulp = require('gulp');
var clean = require('gulp-clean');
var util = require('gulp-util');
var es = require('event-stream');

var fs = require('fs');
var path = require('path');

function mkdir(dir) {
  if(!fs.existsSync(dir)) {
    var parent = path.dirname(dir);
    mkdir(parent);
    fs.mkdirSync(dir);
  }
}

gulp.task('clean', function() {
  return gulp.src(['./lexer/*', './util/*'])
    .pipe(clean())
});
gulp.task('copy', function() {
  return gulp.src('./node_modules/homunculus/web/**/*.js')
    .pipe(function() {
      return es.map(function (file, cb) {
        var target = file.path.replace('/node_modules/homunculus/web'.replace(/\//g, path.sep), '');
        mkdir(path.dirname(target));
        util.log(path.relative(file.cwd, file.path), '->', path.relative(file.cwd, target));
        var content = file._contents;
        content = content.toString('utf-8');
        fs.writeFileSync(target, content, { encoding: 'utf-8' });
        cb(null, file);
      });
    }())
});

gulp.task('default', ['clean', 'copy'], function() {
  return gulp.src('./parser')
    .pipe(clean())
});