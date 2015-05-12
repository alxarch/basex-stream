gulp = require "gulp"
coffee = require "gulp-coffee"
{log} = require "gulp-util"

gulp.task "coffee", ->
	gulp.src "./src/**/*.coffee"
	.pipe coffee
		bare: yes
	.on "error", log
	.pipe gulp.dest "./lib/"