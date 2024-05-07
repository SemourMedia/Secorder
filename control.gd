extends Control


# INIT VARS
var time_begin
var time_delay
var effect
var recording 
var state # RECORDING, STOPPED, PLAYING
var run_time_dictionary: Dictionary # 1:55  = MIN = 1, SEC = 55
var current_time_dictionary:Dictionary # 1:55  = MIN = 1, SEC = 55
var current_playtime: float # in seconds float

# # # # # # # IMPORTS # # # # # # # #

# AUDIO STREAM PLAYERS
@onready var asp_record = $Audio/ASP_Record
@onready var asp_vocal = $Audio/ASP_Vocal
@onready var asp_instrumental = $Audio/ASP_Instrumental
@onready var asp_mixdown = $Audio/ASP_Mixdown

# LABELS
@onready var label_state = $Labels/Label_State
@onready var label_run_time = $Labels/Label_RunTime
@onready var label_current_time = $Labels/Label_CurrentTime

# SLIDERS
@onready var slider_instrumental = $Sliders/Slider_Instrumental
@onready var slider_vocals = $Sliders/Slider_Vocals
@onready var slider_mixdown = $Sliders/Slider_Mixdown

# INPUT | TEXT INPUT
@onready var input_mixdown = $Input/Input_Mixdown
@onready var input_vocal = $Input/Input_Vocal
@onready var input_instrumental = $Input/Input_Instrumental

# BUTTTONS
@onready var button_record = $Buttons/Button_Record
@onready var button_play = $Buttons/Button_Play
#@onready var button_save_mixdown = $Buttons/Button_SaveMixdown
#@onready var button_save_vocals = $Buttons/Button_SaveVocals
#@onready var button_import_instrumental = $Buttons/Button_ImportInstrumental



# # # # # # # FUNCTIONS # # # # # # # #

# RETURN FUNCTIONS
func secToTime(sec):
	var temp_time_dictionary = {"MIN" : 0,"SEC" : 0} # INIT TEMP TIME DICTIONARY VALUE 
	sec = roundf(sec)
	if sec > 59:
		temp_time_dictionary["MIN"] = round(sec/60) # HOW DO I MAKE THIS ALWAYS ROUND DOWN
		temp_time_dictionary["SEC"] = fmod(sec, 60.0)
	else:
		temp_time_dictionary["SEC"] = fmod(sec, 60.0)
	return temp_time_dictionary 

# VOID FUNCTIONS
func updateTime():
	
	if asp_instrumental.stream.get_length() != null:
		run_time_dictionary = secToTime(asp_instrumental.stream.get_length()) 
		current_time_dictionary = secToTime(current_playtime)
	else:
		pass
	
	var run_time_text = " / " + str(int(run_time_dictionary["MIN"])) + ":" + str(int(run_time_dictionary["SEC"])) 
	var cur_time_text = str(int(current_time_dictionary["MIN"])) + ":" + str(int(current_time_dictionary["SEC"])) 

	label_run_time.text = run_time_text
	label_current_time.text = cur_time_text
func audioStop():
	asp_instrumental.stop()
	asp_vocal.stop()
func updateRefresh(_state):
	updateTime()
	
	match _state:
		"RECORDING":
			button_record.text = "Stop"
			state = "RECORDING"
		
		"STOPPED":
			button_record.text = "Record"
			button_play.text = "Play"
			state = "STOPPED"
		"PLAYING":
			button_play.text = "Stop"
			state = "PLAYING"			
		_:
			pass
			
	label_state.text = state
func audioPlay(pos):
	match pos:
		0:
			asp_vocal.seek(0.0)
			asp_instrumental.seek(0.0)
			asp_vocal.play()
			asp_instrumental.play()	
		
		1:
			audioStop()
			asp_instrumental.seek(0.0)
			asp_instrumental.play()				
		_:
			asp_vocal.play()
			asp_instrumental.play()			

# MAIN FUNCTIONS
func _ready():
	var index = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(index, 0)
func _process(delta):
	current_playtime = asp_instrumental.get_playback_position()	
	updateTime()

# 	CONNECTION FUNCTIONS
#		CF		SLIDERS
func _on_slider_instrumental_value_changed(value):
	asp_instrumental.volume_db = value
func _on_slider_vocals_value_changed(value):
	asp_vocal.volume_db = value
func _on_slider_mixdown_value_changed(value):
	asp_mixdown.volume_db = value
#		CF		BUTTONS 	| MAIN
func _on_button_record_pressed():
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
func _on_button_play_pressed():
	if asp_instrumental.playing:
		updateRefresh("STOPPED")
		audioStop()
	else :
		asp_vocal.stream = recording
		updateRefresh("PLAYING")
		audioPlay(0)
#		CF		BUTTONS 	| SAVE / LOAD
func _on_button_save_mixdown_pressed():
	pass # Replace with function body.
func _on_button_save_vocals_pressed():
	if(recording != null): 
		recording
func _on_button_import_instrumental_pressed():
	pass # Replace with function body.


### TEST
func test():
	AudioStream.new()
