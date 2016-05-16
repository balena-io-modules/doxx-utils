Combinatorics = require('js-combinatorics')

exports.walkFiles = walkFiles = (fn) ->
  return (options) ->
    return (files, metalsmith, done) ->
      for file of files
        fn(file, files, metalsmith, options)
      done()

exports.walkTree = ({ visitNode, buildNextArgs }) ->
  self = (node, restArgs...) ->
    visitNode(node, restArgs...)
    if node.children?
      nextArgs = if buildNextArgs? then buildNextArgs(node, restArgs...) else restArgs
      for child in node.children
        self(child, nextArgs...)

  return self

compareCombinations = (a, b) ->
  la = a.length
  lb = b.length
  # longer has higher specificity
  if la != lb
    return lb - la
  # later items have lower priority
  # so the combination that skips higher index items has higher specificity
  for i in [0...la]
    if a[i] != b[i]
      return a[i] - b[i]
  return 0

exports.searchOrder = searchOrder = (variables) ->
  count = variables?.length
  return [] if not count

  idx = [0...count]
  combinations = Combinatorics.power(idx)
  .toArray()
  .filter (a) -> !!a.length
  .sort(compareCombinations)

  return combinations.map (c) ->
    c.map (i) -> variables[i]
    .join('+')

exports.defaultPartialsSearch = walkFiles (file, files, metalsmith, options) ->
  partialsSearchFieldName = options?.partialsSearchFieldName or '$partials_search'

  obj = files[file]
  return if not obj.dynamic
  obj.dynamic[partialsSearchFieldName] ?= searchOrder(obj.dynamic.variables)
