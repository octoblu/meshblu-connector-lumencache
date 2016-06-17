http = require 'http'

class StopRamp
  constructor: ({@connector}) ->
    throw new Error 'StopRamp requires connector' unless @connector?

  do: ({data}, callback) =>
    return callback @_userError(422, 'data.id is required') unless data?.id?

    command = "[" + data.id + ",260]"
    @connector.sendCommand command, (err, results) =>
      return callback @_userError(422, err) if err?
      callback null

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = StopRamp
