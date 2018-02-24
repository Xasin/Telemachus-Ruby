require 'websocket-client-simple'
require 'json'

module Telemachus
	class BasicConnection
		def initialize(addr = "127.0.0.1:8085")
			@data = Hash.new();
			@address = "ws://#{addr}/datalink"

			_configure_socket();
			@guardThread = Thread.new do
				loop do
					sleep 0.5

					if((Time.now - @lastReceived).to_f > 0.75)
						_configure_socket();
					end
				end
			end


			nil
		end

		def _configure_socket()
			base = self

			@socket.close if @socket;

			@socket = WebSocket::Client::Simple.connect(@address) do |socket|
				socket.on :message do |msg|
					base._handle_message(msg.data);
				end

				socket.on :error do |e|
					puts "Socket had an error!! #{e}"
					base._configure_socket
				end

				socket.on :open do
					puts "Socket was opened!"
					socket.send({:+ => ["p.paused"], rate: 500}.to_json)
				end

				socket.on :close do
					puts "Socket was closed!"
				end
			end

			@lastReceived = Time.now() + 1;
			puts "Socket reconfigured!"
		end

		def _handle_message(data)
			@lastReceived = Time.now();
			@data = JSON.parse(data);
		rescue
		end

		def _run(command, params = nil)
			command += "[#{params}]" if params;

			argString = { run: [command].flatten }.to_json;
			@socket.send(argString);
		end

		def +(topic)
			@socket.send({:+ => [topic].flatten}.to_json)
		end
		def -(topic)
			@socket.send({:- => [topic].flatten}.to_json)
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