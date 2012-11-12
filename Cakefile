cu = require('./cakeutils').CakeUtils
cu.setPkgName "mnm3esim"

# ----------------------------------
# Tasks
# ----------------------------------
task 'clean', 'Clean the build', ->
  cu.tclean()

task 'compile', 'Compile CoffeeScript source files', ->
  cu.tcompile()

task 'bundle', "Creates #{cu.bndl_path}", ->
  cu.tbundle()

task 'build', "Creates #{cu.bndl_path} & #{cu.min_path}", ->
  cu.tbuild()

task 'test', "Run tests", ->
  cu.ttest()

task 'docs', 'Generate annotated source code with Docco', ->
  cu.tdocs()

