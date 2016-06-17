{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-lumencache:index')
serialport      = require 'serialport'
SerialPort      = serialport.SerialPort

class Connector extends EventEmitter
  constructor: ->
    @port = ''

  isOnline: (callback) =>
    callback null, running: true

  close: (callback) =>
    debug 'on close'
    callback()

  onConfig: (device={}) =>
    { @options } = device
    debug 'on config', @options
    return unless @options?
    @setUpSerialPort() if @port != @options.port?

  setUpSerialPort: () =>
    return debug "Port undefined!" unless @options.port?
    @port = @options.port
    serialOptions =
      baudrate : 38400

    @client = new SerialPort @port, serialOptions

    @client.on 'open',() =>
      @client.on 'data', (data) =>
        debug 'Data received', data
        @emit 'message', {
          devices: ['*']
          payload:
            serial_in: data.toString()
        }
        @client.flush()

  sendCommand: (command, callback) =>
    debug 'Sending Command', command
    return callback new Error 'Serial Port not connected' unless @client?
    @client.write command, (err, results) =>
      debug 'error ', err if err?
      debug 'results ', results
      callback err, results

  start: (device, callback) =>
    debug 'started'
    @onConfig device
    callback()

module.exports = Connector
