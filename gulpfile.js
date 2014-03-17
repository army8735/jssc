var gulp = require('gulp');
var fs = require('fs');
var path = require('path');

function remove(dir) {
  if(!fs.existsSync(dir)) {
    return;
  }
  fs.readdirSync(dir).forEach(function(f) {
    f = dir + path.sep + f;
    if(!fs.existsSync(f)) {
      return;
    }
    var stat = fs.statSync(f);
    if(stat.isDirectory()) {
      remove(f);
    }
    else if(stat.isFile()) {
      fs.unlinkSync(f);
    }
  });
  fs.rmdirSync(dir);
}
function copy(dir) {
  fs.readdirSync(dir).forEach(function(f) {
    f = dir + path.sep + f;
    var stat = fs.statSync(f);
    var target = f.replace('./node_modules/homunculus/web', '.');
    if(stat.isDirectory()) {
      fs.mkdirSync(target);
      copy(f);
    }
    else if(stat.isFile()) {
      console.log(f, '->', target);
      var s = fs.readFileSync(f, { encoding: 'utf-8' });
      fs.writeFileSync(target, s, { encoding: 'utf-8' });
    }
  });
}

gulp.task('default', function() {
  remove('./lexer');
  remove('./util');
  remove('./parser');
  copy('./node_modules/homunculus/web');
  remove('./parser');
});