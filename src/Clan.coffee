agent = require 'superagent'
unless agent.Request.prototype.use?
	agent.Request.prototype.use = (fn)->
		fn(@)
		@

Endpoints = require './endpoints.coffee'
prefixer = require './prefixer.coffee'
ClanError = require './ClanError.coffee'


Clan = module.exports = (apikey, apisecret, endpoint=null)->

	Endpoints.set endpoint if endpoint?

	appCredentials = {'x-apikey': apikey, 'x-apisecret': apisecret}

	createGamerCredentials: (gamer)->
		{gamer_id: gamer.gamer_id, gamer_secret: gamer.gamer_secret}

	loginAnonymous: (options, cb)->
		agent.post '/v1/login/anonymous'
			.use prefixer
			.send {options}
			.set appCredentials
			.end (err, res)->
				if err? then cb(err)
				else
					if res.error then cb new ClanError res.status, res.error
					else cb null, res.body, true

	login: (network, id, secret, options, cb)->
		if typeof options is "function"
			cb = options
			options = null

		if network?
			agent
			.post '/v1/login'
			.use prefixer
			.send {network, id, secret, options}
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

	resumeSession: (gamer_id, gamer_secret, cb)->
		@login "anonymous", gamer_id, gamer_secret, {preventRegistration :true}, cb

	loginWithShortCode: (shortcode, cb)->
		@login "restore", "", shortcode, {preventRegistration :true}, cb

	runBatch: (domain, batchName, params, cb)->
		agent
		.post "/v1/batch/#{domain}/#{batchName}"
		.use prefixer
		.set appCredentials
		.send params
		.end (err, res)->
			if err? then cb(err)
			else
				if res.error then cb new ClanError res.status, res.body
				else cb null, res.body

	vfs: (domain='private')->
		require('./gamevfs.coffee')(appCredentials, domain)

	indexes: (domain='private')->
		require('./indexes.coffee')(appCredentials, domain)

	# the mailBody will be parsed to replace occurences of [[SHORTCODE]] by actual shortcode
	sendResetMailPassword: ( userEmail, mailSender, mailTitle, mailBody, cb)->
		textBody = "[[SHORTCODE]]"
		htmlBody = null
		if typeof mailBody == "object"
			if mailBody.html == true
				htmlBody = mailBody.body
			else
				textBody = mailBody.body
		else
			textBody = mailBody
		body = 
			from: mailSender
			title: mailTitle
			body: textBody
		if htmlBody != null then body.html = htmlBody

		agent
		.post "/v1/login/#{userEmail}"
		.use prefixer
		.set appCredentials
		.send body
		.end (err, res)->
			if err? then cb(err)
			else
				if res.error then cb new ClanError res.status, res.body
				else cb null, res.body

	userExists: (network, id, cb)->
		agent
		.get "/v1/users/#{network}/#{encodeURIComponent(id)}"
		.use prefixer
		.set appCredentials
		.end (err, res)->
			if err? then cb(err)
			else
				if res.error then cb new ClanError res.status, res.body
				else cb null, res.body		

	withGamer: (gamer)->
		creds = this.createGamerCredentials gamer

		transactions: (domain='private')->
			require('./transactions.coffee')(appCredentials, creds, domain)

		gamervfs: (domain='private')->
			require('./gamervfs.coffee')(appCredentials, creds, domain)

		friends: (domain='private')->
			require('./friends.coffee')(appCredentials, creds, domain)

		profile: ()->
			require('./profile.coffee')(appCredentials, creds)

		properties: (domain='private')->
			require('./properties.coffee')(appCredentials, creds, domain)

		leaderboards: (domain='private')->
			require('./leaderboards.coffee')(appCredentials, creds, domain)

		matches: (domain='private')->
			require('./matches.coffee')(appCredentials, creds, domain)

		kv: (domain='private')->
			require('./kvstore.coffee')(appCredentials, creds, domain)

		events: (domain='private')->
			require('./event.coffee')(appCredentials, creds, domain)

		achievements: (domain='private')->
			require('./achievements.coffee')(appCredentials, creds, domain)

		referral: (domain='private')->
			require('./referral.coffee')(appCredentials, creds, domain)

		store: ()->
			require('./store.coffee')(appCredentials, creds)

		runBatch: (domain, batchName, params, cb)->
			agent
			.post "/v1/gamer/batch/#{domain}/#{batchName}"
			.use prefixer
			.set appCredentials
			.auth creds.gamer_id, creds.gamer_secret
			.send params
			.end (err, res)->
				if err? then cb(err)
				else
					if res.error then cb new ClanError res.status, res.body
					else cb null, res.body

		outline: (cb)->
			agent
			.get '/v1/gamer/outline'
			.use prefixer
			.set appCredentials
			.auth creds.gamer_id, creds.gamer_secret
			.end (err, res)->
				if err? then cb(err)
				else
					if res.error then cb new ClanError res.status, res.body
					else cb null, res.body

		convertTo: (network, id, secret, cb)->
			agent
			.post '/v1/gamer/convert'
			.use prefixer
			.set appCredentials
			.auth creds.gamer_id, creds.gamer_secret
			.send {network, id, secret}
			.end (err, res)->
				if err? then cb(err)
				else
					if res.error then cb new ClanError res.status, res.body
					else cb null, res.body

		link: (network, id, secret, cb)->
			agent
			.post 'v1/gamer/link'
			.use prefixer
			.set appCredentials
			.auth creds.gamer_id, creds.gamer_secret
			.send {network, id, secret}
			.end (err, res)->
				if err? then cb(err)
				else
					if res.error then cb new ClanError res.status, res.body
					else cb null, res.body

		unlink: (network, cb)->
			agent
			.post 'v1/gamer/unlink'
			.use prefixer
			.set appCredentials
			.auth creds.gamer_id, creds.gamer_secret
			.send {network}
			.end (err, res)->
				if err? then cb(err)
				else
					if res.error then cb new ClanError res.status, res.body
					else cb null, res.body

		logout: (cb)->
			agent
			.post '/v1/gamer/logout'
			.use prefixer
			.set appCredentials
			.auth creds.gamer_id, creds.gamer_secret
			.end (err, res)->
				if err? then cb(err)
				else
					if res.error then cb new ClanError res.status, res.body
					else cb null, res.body

		changeEmail: (newEmailAddress, cb)->
			agent
			.post '/v1/gamer/email'
			.use prefixer
			.set appCredentials
			.auth creds.gamer_id, creds.gamer_secret
			.send {email:newEmailAddress}
			.end (err, res)->
				if err? then cb(err)
				else
					if res.error then cb new ClanError res.status, res.body
					else cb null, res.body

		changePassword: (newPassword, cb)->
			agent
			.post '/v1/gamer/password'
			.use prefixer
			.set appCredentials
			.auth creds.gamer_id, creds.gamer_secret
			.send {password:newPassword}
			.end (err, res)->
				if err? then cb(err)
				else
					if res.error then cb new ClanError res.status, res.body
					else cb null, res.body

		listUsers: (filter, limit, skip, cb)->
			agent
			.get "/v1/gamer?q=#{encodeURIComponent(filter)}&limit=#{limit}&skip=#{skip}"
			.use prefixer
			.set appCredentials
			.auth creds.gamer_id, creds.gamer_secret
			.end (err, res)->
				if err? then cb(err)
				else
					if res.error then cb new ClanError res.status, res.body
					else cb null, res.body

	privateDomain: 'private'
