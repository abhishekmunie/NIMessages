fs            = require 'fs'
path          = require 'path'
http          = require 'http'
crypto        = require 'crypto'
child_process = require 'child_process'

express = require 'express'

favicon        = require 'serve-favicon'
logger         = require 'morgan'
bodyParser     = require 'body-parser'
errorHandler   = require 'errorhandler'

config =
  pow_host: 'identityserver'
  net_service_name: 'Identity Server'

app = express()
spawn = child_process.spawn
netService = undefined

if 'development' is app.get('env')
  $ = require 'NodObjC'
  # First you import the "Foundation" framework
  $.framework('Foundation')
  # Setup the recommended NSAutoreleasePool instance
  pool = $.NSAutoreleasePool('alloc')('init')


app.set 'port', process.env.PORT or process.env.C9_PORT or process.env.VCAP_APP_PORT or process.env.VMC_APP_PORT or 0
app.use favicon __dirname + '/www/favicon.ico'
app.use logger 'dev'
app.use bodyParser.json()
app.use bodyParser.urlencoded extended: true
app.use express.static path.join __dirname, 'www'


app.post '/generate/identity', (req, res) ->
  clientName   = req.param 'name'
  emailAddress = req.param 'email'
  pass         = req.param 'pass'
  bitSize      = req.param 'bitSize'
  clientName   = 'JohnAppleseed' if clientName == ''
  emailAddress = 'johnappleseed@example.com' if emailAddress == ''
  pass         = 'test' if pass == ''


  crypto.randomBytes 32, (ex, buf) ->
    clientFileName = buf.toString 'hex'
    # clientFileName = 'identity'

    console.log 'Generating Identity\n======================================================'
    console.log 'Name:', clientName
    console.log 'Email:', emailAddress
    console.log 'Pass:', pass
    console.log 'Bit Size:', bitSize
    genCert = spawn 'sh', ['gencert.sh', clientFileName, "email:#{emailAddress}", clientName, emailAddress, pass, bitSize]
    genCert.stdout.pipe process.stdout
    genCert.stderr.pipe process.stderr
    genCert.on 'close', (code) ->
      unless code == 0
        console.error "grep process exited with code #{code}"
        res.send err: code: code
        return
      console.log 'Successful.\n------------------------------------------------------'
      res.sendFile "#{clientFileName}.p12",
        root: __dirname + '/cert/',
        dotfiles: 'deny'
      , (err) ->
        console.error err if err
        fs.unlink "cert/#{clientFileName}.p12", (err) ->
          console.error err if err

if 'development' is app.get('env')
  app.use errorHandler()

publishNetService = (port) ->
  # NSObject = $.NSClassFromString $('NSObject')
  MyNetServiceDelegate = $.NSObject.extend 'MyNetServiceDelegate'

  MyNetServiceDelegate.addMethod 'netServiceWillPublish:', 'v@:@', (self, _cmd, sender) ->
    console.log 'Net Service will Publish:', sender
  MyNetServiceDelegate.addMethod 'netService:didNotPublish:', 'v@:@:@', (self, _cmd, sender, errorDict) ->
    console.log 'Net Service', sender, 'did not Publish:', errorDict
  MyNetServiceDelegate.addMethod 'netServiceDidPublish:', 'v@:@', (self, _cmd, sender) ->
    console.log 'Net Service did Publish:', sender
  MyNetServiceDelegate.addMethod 'netServiceDidStop:', 'v@:@', (self, _cmd, sender) ->
    console.log 'Net Service did Stop:', sender

  # impl =
  #   'netServiceWillPublish:': (self, _cmd, sender) ->
  #     console.log 'Net Service will Publish:', sender
  # MyNetServiceDelegate.addProtocol('MyNetServiceDelegate', impl)

  MyNetServiceDelegate.register()

  myNetServiceDelegate = MyNetServiceDelegate('alloc')('init')
  # myNetServiceDelegate('retain')

  netService = $.NSNetService('alloc')('initWithDomain', $(''),
   'type', $('_http._tcp.'),
   'name', $(config.net_service_name),
   'port', port)
  netService('setDelegate', myNetServiceDelegate)
  netService('publishWithOptions', 0)

cleanUp = ->

  if 'development' is app.get('env')
    netService.stop()
    pool('drain')

server = app.listen app.get('port'), ->
  host = server.address().address
  port = server.address().port

  console.log 'App listening on port: %s', port

  if 'development' is app.get('env') and process.platform is 'darwin' and config.pow_host
    powFile = path.resolve process.env['HOME'], ".pow/#{config.pow_host}"
    powHost = config.pow_host
    fs.writeFile powFile, port, (err) ->
      return console.error err if err
      console.log "Hosted on: #{powHost}.dev"
      publishNetService(port)
      unhost = ->
        try
          fs.unlinkSync powFile
          console.log "Unhosted from: #{powHost}.dev"
          cleanUp()
        catch e
          return console.error err if err
        return
      process.on 'SIGINT', -> unhost(); process.exit(); return
      process.on 'exit', (code) -> unhost(); return
      return


# p12     = require('node-openssl-p12').createClientSSL
# p12options =
#   bitSize: bitSize
#   clientFileName: clientFileName
#   C:'EX'
#   ST: 'ExampleST'
#   L: 'ExampleL'
#   O: 'ExampleO'
#   OU: 'ExampleOU'
#   CN: clientName
#   emailAddress: emailAddress
#   clientPass: pass
#   days: 365

# p12(p12options).done (options, sha1fingerprint) ->
# .fail (err) ->
#     console.log err
#     res.send err


# pem           = require 'pem'
# NICA = fs.readFileSync 'NetIdentity.key',
#   encoding: 'utf8'
# pem.createCertificate
#   serviceKey: NICA
#   commonName: "email:dog@example.com"
#   days: 365
# , (err, result) ->
#   return console.error err if err?
#   {certificate, csr, clientKey, serviceKey} = result
#   console.log "Certificate:\n", certificate
#   console.log "Client Key:\n", clientKey
#   console.log "Service Key:\n", serviceKey
