_ = require 'underscore-plus'
{Emitter} = require 'emissary'
Deprecation = require './deprecation'

global.__grimDeprecations__  = []

grim =
  getDeprecations: ->
    _.clone(global.__grimDeprecations__)

  clearDeprecations: ->
    global.__grimDeprecations__ = []

  logDeprecations: ->
    deprecations = grim.getDeprecations()
    deprecations.sort (a, b) -> b.getCallCount() - a.getCallCount()

    console.warn "\nCalls to deprecated functions\n-----------------------------"
    for deprecation in deprecations
      console.warn "(#{deprecation.getCallCount()}) #{deprecation.getOriginName()} : #{deprecation.getMessage()}", deprecation

  deprecate: (message) ->
    stack = Deprecation.generateStack()[1..] # Don't include the callsite for the grim.deprecate method
    methodName = Deprecation.getFunctionNameFromCallsite(stack[0])
    unless deprecation = global.__grimDeprecations__.find((d) -> d.getOriginName() == methodName)
      deprecation = new Deprecation(message)
      global.__grimDeprecations__.push(deprecation)
    deprecation.addStack(stack)
    grim.emit("updated")

Emitter.extend(grim)
module.exports = grim
