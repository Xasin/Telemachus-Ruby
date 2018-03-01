require 'json'

require 'net/http'

module Telemachus
	class Connection
		def initialize(addr = "127.0.0.1:8085")
			@data = Hash.new();
			@HTTPAddr = URI("http://#{addr}/telemachus/datalink");
		end

		def _run(command, params = nil)
			command += "[#{params}]" if params;

			uri = @HTTPAddr.encode_www_form({run: command});

			begin
				Net::HTTP.get(uri);
			rescue
			end
		end

		def [](key)
			uri = @HTTPAddr.encode_www_form({a: key});
			begin
				resp = Net::HTTP.get_response(uri);
				return JSON.parse(resp.body)["a"];
			end
		end
	end
end
