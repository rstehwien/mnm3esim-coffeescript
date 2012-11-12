child_proc = require 'child_process'
path       = require 'path'
fs = require 'fs'

which = require 'which'
_      = require 'underscore'
async  = require 'async'
colors = require 'colors'
which = require 'which'

# Colors configuration
colors.setTheme
	silly:    'rainbow'
	input:    'grey'
	verbose:  'cyan'
	prompt:   'grey'
	info:     'green'
	data:     'grey'
	help:     'cyan'
	warn:     'yellow'
	debug:    'blue'
	error:    'red'

class CakeUtils
	@setPkgName: (pkg_name) ->
		@pkg_name   = pkg_name
		@src_path   = path.join '.', 'src'
		@lib_path   = path.join '.', 'lib'
		@build_path = path.join '.', 'build'
		@js_path    = @build_path #path.join build_path, 'js'
		@bndl_path  = path.join @lib_path, "#{@pkg_name}-bundle.js"
		@min_path   = path.join @lib_path, "#{@pkg_name}-bundle.min.js"

	# Log to console if non-empty string.
	#
	# @param [String] data String to print.
	#
	@print: (data) ->
		data = "[#{data.join ', '}]" if Array.isArray data
		data = (data ? "").toString().replace /[\r\n]+$/, ""
		console.log data if data

	@printCallback: (err, data) =>
		@print err ? data ? "Done.".info

	# ----------------------------------
	# child_process helpers
	# ----------------------------------

	# Spawn with log pipes to stdout, stderr.
	#
	# @param [String] or [Array<String>] cmd or [cmd, opts...]
	# @param [Object]         [opts]    (Optional) options.
	# @param [Function]       callback  Callback on process end (or null).
	#
	@spawn: (allArgs...) =>
		# Manually unpack arguments.
		argsLen   = allArgs.length
		cmd       = if _.isArray allArgs[0] then allArgs[0][0] else allArgs[0]
		args      = if _.isArray allArgs[0] then allArgs[0][1..] else []
		opts      = if argsLen is 3 then allArgs[1] else {}
		callback  = if argsLen > 2 then allArgs[argsLen - 1] else null

		cmd = which?.sync(cmd)

		@print [cmd, args.join " "].join " "
		ps = child_proc.spawn cmd, args, opts
		ps.stdout.pipe process.stdout
		ps.stderr.pipe process.stderr
		ps.on "exit", callback if callback

	# Exec with log hooks to stdout, stderr.
	#
	# @param [String] or [Array<String>] cmd or [cmd, opts...]
	# @param [Object]   [opts]    (Optional) options.
	# @param [Function] callback  Callback on process end (printCallback).
	#
	@exec: (allArgs...) =>
		# Manually unpack arguments.
		argsLen   = allArgs.length
		cmd       = if _.isArray allArgs[0] then allArgs[0].join " " else allArgs[0]
		opts      = if argsLen is 3 then allArgs[1] else {}
		callback  = if argsLen > 1 then allArgs[argsLen - 1] else null
		callback  = @printCallback unless callback

		@print cmd
		child_proc.exec cmd, opts, (error, stdout, stderr) ->
			if error
				console.error error.stack
			else
				process.stderr.write stderr if stderr
				process.stdout.write stdout if stdout
			callback?()


	# ----------------------------------
	# file system helpers
	# ----------------------------------
	@fileExists: (p) => 
		(try fs.statSync p)?.isFile() ? false

	@dirExists: (p) => 
		(try fs.statSync p)?.isDirectory() ? false

	@paths: (p) => 
		(try path.join(p, cp) for cp in fs.readdirSync p) ? []

	@removePath: (path, cb) =>
		if @dirExists path then @removeDir path, cb
		else if @fileExists path then @removeFile path, cb
		else cb?()

	@removeFile: (path, cb) =>
		try fs.unlink path, cb
		catch e then cb?()

	@removeDir: (dir, cb) =>
		@removeDirContents dir, -> 
			try fs.rmdir dir, cb
			catch e then cb?()

	@removeDirContents: (dir, cb) =>
		async.forEach((@paths dir), (@removePath), cb)

	# ----------------------------------
	# Commands
	# ----------------------------------

	@clean: (callback) =>
		paths = [@build_path, @bndl_path, @min_path]
		@print "Clean #{paths.join ', '}"
		async.forEach(paths, (@removePath), callback)

	@compile: (callback) =>
		@print "Compile #{@src_path} to #{@js_path}"
		@exec "coffee --compile --output #{@js_path} #{@src_path}", callback

	@bundle: (callback) =>
		@print "Bundle #{@src_path} to #{@bndl_path}"
		@exec "coffee --join #{@bndl_path} --compile --output #{@lib_path} #{@src_path}", callback

	@minify: (callback) =>
		@print "Minify #{@bndl_path} as #{@min_path}"
		@exec "uglifyjs -o #{@min_path} #{@bndl_path}", callback

	@test: (callback) =>
		@print "Run mocha tests in ./test using ./test/mocha.opts"
		@exec "mocha", callback

	@docs: (callback) =>
		args = "#{@src_path}/*.coffee"
		@print "Create documents from #{args}"
		@exec "docco  #{args}", callback

	# ----------------------------------
	# Quick Tasks
	# ----------------------------------

	@tclean: ->
		@clean => console.log("cleaned")

	@tcompile: ->
		@clean => @compile => console.log("compiled")

	@tbundle: ->
		@clean => @compile => @bundle => console.log("bundled")

	@tbuild: ->
		@clean => @compile => @bundle => @minify => console.log("built")

	@ttest: ->
		@clean => @compile => @bundle => @minify => @test => console.log("tested")

	@tdocs: ->
		@docs => console.log("docs generated")

module.exports =
	CakeUtils: CakeUtils
