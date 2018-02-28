
require 'pocketsphinx-ruby'
require_relative 'Lib/baseInterface'

require 'net/http'

$game = Telemachus::Connection.new

$commands = {
	"stability on"		=> ["f.sas[true]",   "stability assist activated"],
	"stability off"	=> [["f.sas[false]","mj.smartassoff"],  "stability assist deactivated"],

	"lights on"			=> ["f.light[true]", "lights activated"],
	"lights off"		=> ["f.light[false]", "lights deactivated"],

	"full thrust"		=> ["f.setThrottle[1]"],
	"cut thrust"		=> ["f.setThrottle[0]"],

	"stage craft"		=> ["f.stage", "staging confirmed"]
}

{"forwards" => "prograde", "backwards" => "retrograde", "up" => "radial plus", "down" => "radial minus", "left" => "normal plus", "other left" => "normal minus", "node" => "node"}.each do |mjkey, mjcommand|
	$commands["face " + mjkey] = ["mj.#{mjcommand.downcase.gsub(/ /,"")}", "Stability direction #{mjcommand}"];
end


config = Pocketsphinx::Configuration::Grammar.new("Lib/Control.JSGF");

config['logfn'] = "/dev/null"
config['vad_threshold'] = 3.4;

def speak(msg)
	`espeak "#{msg}"`
end

Net::HTTP.get(URI("http://127.0.0.1:8085/telemachus/datalink?run=mj.radialplus"));

Pocketsphinx::LiveSpeechRecognizer.new(config).recognize do |speech|

	print "Processing: '#{speech}': "

	speech.gsub!(/computer /, "");
	speech.gsub!(/ confirm/, "");

	speech.split(" and ").each do |c|
		print "#{c}, "

		if($commands.has_key? c) then
			command = $commands[c];
			$game._run(command[0]);
			speak(command[1] || c);
		end
	end

	puts " done!"
end
