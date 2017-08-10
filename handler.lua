-- Extending the Base Plugin handler is optional, as there is no real
-- concept of interface in Lua, but the Base Plugin handler's methods
-- can be called from your child implementation and will print logs
-- in your `error.log` file (where all logs are printed).
local BasePlugin = require "kong.plugins.base_plugin"
local testAuthHandler = BasePlugin:extend()
local http = require "resty.http"

-- Your plugin handler's constructor. If you are extending the
-- Base Plugin handler, it's only role is to instanciate itself
-- with a name. The name is your plugin name as it will be printed in the logs.
function testAuthHandler:new()
	testAuthHandler.super.new(self, "testAuth")
end

function testAuthHandler:init_worker(config)
	-- Eventually, execute the parent implementation
	-- (will log that your plugin is entering this context)
	testAuthHandler.super.init_worker(self)

	-- Implement any custom logic here
end

function testAuthHandler:certificate(config)
	-- Eventually, execute the parent implementation
	-- (will log that your plugin is entering this context)
	testAuthHandler.super.certificate(self)

	-- Implement any custom logic here
end

function testAuthHandler:rewrite(config)
	-- Eventually, execute the parent implementation
	-- (will log that your plugin is entering this context)
	testAuthHandler.super.rewrite(self)

	-- Implement any custom logic here
end

function testAuthHandler:access(config)
	-- Eventually, execute the parent implementation
	-- (will log that your plugin is entering this context)
	testAuthHandler.super.access(self)

	ngx.req.read_body()
	local h = ngx.req.get_uri_args()

	-- Check for required values
	local client_id = h["client_id"]
	local client_secret = h["client_secret"]
	local token = h["token"]
	if client_id == nil then
		ngx.say("missing id")
		ngx.exit(400)
	elseif client_secret == nil then
		ngx.say("missing secret")
		ngx.exit(400)
	elseif token == nil then
		ngx.say("missing token")
		ngx.exit(400)
	end

	-- begin subquery
	local queryString = string.format("?client_id=%s&client_secret=%s&token=%s",
		client_id, client_secret, token)
	local uri = "http://localhost:8080/openid-connect-server-webapp/introspect"
	local params = {
		method = "GET",
		headers = ngx.req.get_headers(),
		query = queryString
	}
	local client=http.new()
	res, err = client:request_uri(uri, params)
	if res then
		-- valid result
		if string.find(res.body, "\"active\":false") then
			-- inactive token
			ngx.say("bad token")
			ngx.exit(401)
		end
		ngx.req.set_header("tokenInfo", res.body)
	else
		ngx.say(err)
		ngx.exit(400)
	end
end

function testAuthHandler:header_filter(config)
	-- Eventually, execute the parent implementation
	-- (will log that your plugin is entering this context)
	testAuthHandler.super.header_filter(self)

	-- Implement any custom logic here
end

function testAuthHandler:body_filter(config)
	-- Eventually, execute the parent implementation
	-- (will log that your plugin is entering this context)
	testAuthHandler.super.body_filter(self)

	-- Implement any custom logic here
end

function testAuthHandler:log(config)
	-- Eventually, execute the parent implementation
	-- (will log that your plugin is entering this context)
	testAuthHandler.super.log(self)

	-- Implement any custom logic here
end

-- This module needs to return the created table, so that Kong
-- can execute those functions.
return testAuthHandler