
require 'pocketsphinx-ruby'
require_relative 'Lib/baseInterface'

$game = Telemachus::Connection.new

$commands = {
	"stability on"		=> ["f.sas[true]",   "stability assist activated"],
	"stability off"	=> ["f.sas[false]",  "stability assist deactivated"],
	"lights on"			=> ["f.light[true]", "lights activated"],
	"lights off"		=> ["f.light[false]", "lights deactivated"],
	"full throttle"	=> ["f.setThrottle[1]"],
	"half throttle"	=> ["f.setThrottle[0.5]"],
	"cut throttle"		=> ["f.setThrottle[0]"],

	"cut throttle and stage" 	=> [["f.setThrottle[0]","f.stage"], "Staging confirmed"],
	"full throttle and stage" 	=> [["f.setThrottle[1]","f.stage"], "staging confirmed"],
}

{"forwards" => "prograde", "backwards" => "retrograde", "up" => "radial plus", "down" => "radial minus", "left" => "normal plus", "other left" => "normal minus"}.each do |mjkey, mjcommand|
	$commands["face " + mjkey] = ["mj.#{mjcommand.downcase.gsub(/ /,"")}", "Stability direction #{mjcommand}"];
end


config = Pocketsphinx::Configuration::Grammar.new do
	sentence "computer"
	$commands.each do |k, v|
		puts "Adding command '#{k}'"
		sentence "#{k}"
	end
end

config['logfn'] = "/dev/null"
config['vad_threshold'] = 3.4;

def speak(msg)
	`espeak "#{msg}"`
end

$lastActive = Time.new(0);
Pocketsphinx::LiveSpeechRecognizer.new(config ).recognize do |speech|
	if(speech == "computer") then
		$active = Time.now();
		speak "Yes"
	elsif (Time.now - $active).to_f < 10 then
		if($commands.has_key? speech) then
			command = $commands[speech];
			$game._run(command[0]);
			speak(command[1] || speech);
		end

		$active = Time.now();
	end
end
