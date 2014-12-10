agent = require 'superagent'
unless agent.Request.prototype.use?
	agent.Request.prototype.use = (fn)->
		fn(@)
		@

prefixer = require './prefixer.coffee'
ClanError = require './ClanError.coffee'

module.exports = (apikey, apisecret)->

	appCredentials = {'x-apikey': apikey, 'x-apisecret': apisecret}

	_auth = (request)->
		request.set 'x-apikey', apikey
		request.set 'x-apisecret', apisecret
		request

	createGamerCredentials: (gamer)->
		{gamer_id: gamer.gamer_id, gamer_secret: gamer.gamer_secret}

	login: (network, id, secret, cb)->
		if network?
			agent
			.post '/v1/login'
			.use prefixer
			.send {network, id, secret}
			.set appCredentials
			.end (err, res)->
				if err? then cb(err)
				else
					if res.error then cb new ClanError res.status, res.body
					else cb null, res.body, false
		else
			cb = id
			agent
			.post '/v1/login/anonymous'
			.use prefixer
			.set appCredentials
			.end (err, res)->
				if err? then cb(err)
				else
					if res.error then cb new ClanError res.status, res.body
					else cb null, res.body, true

	logout: (gamerCred, cb)->
		agent
		.post '/v1/gamer/logout'
		.use prefixer
		.set appCredentials
		.auth gamerCred.gamer_id, gamerCred.gamer_secret
		.end (err, res)->
			if err? then cb(err)
			else
				if res.error then cb new ClanError res.status, res.body
				else cb null, res.body

	echo: (cb)->
		agent
		.get '/echo/index.html'
		.use prefixer
		.end (err, res)->
			cb(err)


	transactions: (domain)->
		require('./transactions.coffee')(appCredentials, domain)

	gamervfs: (domain)->
		require('./gamervfs.coffee')(appCredentials, domain)

	friends: ()->
		require('./friends.coffee')(appCredentials)

	properties: ()->
		require('./properties.coffee')(appCredentials)

	leaderboards: ()->
		require('./leaderboards.coffee')(appCredentials)

	event: (domain)->
		require('./event.coffee')(appCredentials, domain)

	privateDomain: 'private'
