cu = require('./cakeutils').CakeUtils
cu.setPkgName "mnm3esim"

# ----------------------------------
# Tasks
# ----------------------------------
task 'clean', 'Clean the build', ->
  cu.tclean()

task 'test', "Run tests", ->
  cu.test -> console.log("tested")

task 'watch:test', "Watch for changes and run tests", ->
  cu.watchTest()

task 'run', 'Run the main application', ->
  cu.run()

task 'debug', 'Debug the main application', ->
  cu.debug()

task 'compile', 'Compile CoffeeScript source files', ->
  cu.tcompile()

task 'bundle', "Creates #{cu.bndl_path}", ->
  cu.tbundle()

task 'build', "Creates #{cu.bndl_path} & #{cu.min_path}", ->
  cu.tbuild()

task 'docs', 'Generate annotated source code with Docco', ->
  cu.tdocs()


