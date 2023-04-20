
function update() {
	if (FlxG.keys.justPressed.SIX) {
		var state = new ModState("ScriptDownloadingState");
		FlxG.switchState(state);
	}
}