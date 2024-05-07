extends Control


# INIT VARS
var time_begin
var time_delay
var effect
var recording
var state
var runTimeDict
var curTimeDict
var current_playtime

# IMPORTS
"""
$AudioStreamPlayer
$AudioStreamInstrumental
$RunTimeLabel
$CurTimeLabel
$PlayButton
$RecordButton
"""

# AUDIO STREAM PLAYERS

var Vocal
var Instrumental
var Mixdown



func secToTime(sec):
	var tTimeDict = {
		"MIN" : 0,
		"SEC" : 0
	}
	sec = roundf(sec)
	if sec > 59:
		tTimeDict["MIN"] =  round(sec/60)
		tTimeDict["SEC"] = fmod(sec, 60.0)
	else:
		tTimeDict["SEC"] = fmod(sec, 60.0)
	return tTimeDict 

func updateTime():
	runTimeDict = secToTime($AudioStreamInstrumental.stream.get_length()) 
	curTimeDict = secToTime(current_playtime)
	
	var run_time_text = " / " + str(int(runTimeDict["MIN"])) + ":" + str(int(runTimeDict["SEC"])) 
	var cur_time_text = str(int(curTimeDict["MIN"])) + ":" + str(int(curTimeDict["SEC"])) 

	$RunTimeLabel.text = run_time_text
	$CurTimeLabel.text = cur_time_text

func _ready():
	var index = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(index, 0)
func audioStop():
	$AudioStreamInstrumental.stop()
	$AudioStreamPlayer.stop()
func updateRefresh(_state):
	updateTime()
	
	match _state:
		"RECORDING":
			$RecordButton.text = "Stop"
			state = "RECORDING"
		
		"STOPPED":
			$RecordButton.text = "Record"
			$PlayButton.text = "Play"
			state = "STOPPED"
		"PLAYING":
			$PlayButton.text = "Stop"
			state = "PLAYING"			
		_:
			pass
			
	$StateLabel.text = state
func audioPlay(pos):
	
	
	match pos:
		0:
			$AudioStreamPlayer.seek(0.0)
			$AudioStreamInstrumental.seek(0.0)
			$AudioStreamPlayer.play()
			$AudioStreamInstrumental.play()	
		
		1:
			audioStop()
			$AudioStreamInstrumental.seek(0.0)
			$AudioStreamInstrumental.play()				
		_:
			$AudioStreamPlayer.play()
			$AudioStreamInstrumental.play()			

func _process(delta):
	current_playtime = $AudioStreamInstrumental.get_playback_position()	
	updateTime()
	
func _on_play_button_pressed():
	if $AudioStreamInstrumental.playing:
		updateRefresh("STOPPED")
		audioStop()
	else :
		$AudioStreamPlayer.stream = recording
		updateRefresh("PLAYING")
		audioPlay(0)
func _on_record_button_pressed():
	recording = null
	if effect.is_recording_active(): # IF RECORDING AND PRESSED
		
		updateRefresh("STOPPED") # CHANGING LABELS AND STATE
		recording = effect.get_recording() # STORING RECORDING
		effect.set_recording_active(false) # TURN OFF RECORDING
		audioStop()
	else:							 # IF NOT RECORDING
		updateRefresh("RECORDING") # CHANGE LABELS AND STATE
		effect.set_recording_active(true) # TURN ON RECORDING
		audioPlay(1) # PLAY AUDIO STREAMS
	pass		
func _on_vox_v_slider_value_changed(value):
	$AudioStreamPlayer.volume_db = value
func _on_instrumental_v_slider_value_changed(value):
	$AudioStreamInstrumental.volume_db = value


func _on_save_button_pressed():
	#var save_path = 
	recording.save_to_wav()
	pass
