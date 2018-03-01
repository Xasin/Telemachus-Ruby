require 'websocket-client-simple'
require 'json'

module Telemachus
	class BasicConnection
		def initialize(addr = "127.0.0.1:8085")
			@data = Hash.new();
			@address = "ws://#{addr}/datalink"
		end

		def _run(command, params = nil)
			command += "[#{params}]" if params;

			argString = { run: [command].flatten }.to_json;
			@socket.send(argString);
		end

		def [](key)
			return @data[key]
		end
	end

	class Connection < BasicConnection
		def stage!
			_run("f.stage")
		end

		def abort!
			_run("f.abort")
		end
	end
end
