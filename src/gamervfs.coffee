agent = require 'superagent'
prefixer = require './prefixer.coffee'
ClanError = require './ClanError.coffee'

# TODO support getting/setting/deleting all keys at once

module.exports =  (appCredentials, gamerCred, domain)->

	getValue: (key, cb)->
		unless key? then key=''
		agent
		.get "/v3.0/gamer/vfs/#{domain}/#{key}"
		.use prefixer
		.set appCredentials
		.auth gamerCred.gamer_id, gamerCred.gamer_secret
		.end (err, res)->
			if err? then cb(err)
			else
				if res.error then cb new ClanError res.status, res.body
				else cb null, res.body

	get: (key, cb)->
		unless key? then key=''
		agent
		.get "/v1/gamer/vfs/#{domain}/#{key}"
		.use prefixer
		.set appCredentials
		.auth gamerCred.gamer_id, gamerCred.gamer_secret
		.end (err, res)->
			if err? then cb(err)
			else
				if res.error then cb new ClanError res.status, res.body
				else cb null, res.body

	setValue: (key, value, cb)->
		unless key? then key=''
		agent
		.put "/v3.0/gamer/vfs/#{domain}/#{key}"
		.use prefixer
		.type 'json'
		.send value
		.set appCredentials
		.auth gamerCred.gamer_id, gamerCred.gamer_secret
		.end (err, res)->
			if err? then cb(err)
			else
				if res.error then cb new ClanError res.status, res.body
				else cb null, res.body

	set: (key, value, cb)->
		unless key? then key=''
		agent
		.put "/v1/gamer/vfs/#{domain}/#{key}"
		.use prefixer
		.type 'json'
		.send JSON.stringify value
		.set appCredentials
		.auth gamerCred.gamer_id, gamerCred.gamer_secret
		.end (err, res)->
			if err? then cb(err)
			else
				if res.error then cb new ClanError res.status, res.body
				else cb null, res.body

	deleteValue: (key, cb)->
		unless key? then key=''
		agent
		.del "/v3.0/gamer/vfs/#{domain}/#{key}"
		.use prefixer
		.set appCredentials
		.auth gamerCred.gamer_id, gamerCred.gamer_secret
		.end (err, res)->
			if err? then cb(err)
			else
				if res.error then cb new ClanError res.status, res.body
				else cb null, res.body

	del: (key, cb)->
		unless key? then key=''
		agent
		.del "/v1/gamer/vfs/#{domain}/#{key}"
		.use prefixer
		.set appCredentials
		.auth gamerCred.gamer_id, gamerCred.gamer_secret
		.end (err, res)->
			if err? then cb(err)
			else
				if res.error then cb new ClanError res.status, res.body
				else cb null, res.body

	setBinary: (key, cb)->
		unless key? then cb new new Error("setBinary needs a key to be able to upload data")
		agent
		.put "/v3.0/gamer/vfs/#{domain}/#{key}?binary"
		.use prefixer
		.type 'json'
		.set appCredentials
		.auth gamerCred.gamer_id, gamerCred.gamer_secret
		.end (err, res)->
			if err? then cb(err)
			else
				if res.error then cb new ClanError res.status, res.body
				else cb null, res.body

