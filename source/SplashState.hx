package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using flixel.util.FlxSpriteUtil;

class SplashState extends UiState
{
	private var play:FlxButton;

	override public function create():Void
	{
		super.create();

		play = new FlxButton(0, 0, onClickPlay);
		play.loadGraphic("assets/HaxeJam2024-logo-without-text.png");
		play.updateHitbox();
		play.x = (FlxG.width) / 2 -(play.width / 2);
		play.y = (FlxG.height) / 2 -(play.height / 2);
		add(play);

		FlxTimer.wait(3, () -> {advanceToMenu();});
	}

	private function onClickPlay():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, () -> {advanceToMenu();});
	}

	private function advanceToMenu():Void
	{
		FlxG.switchState(new MenuState());
	}
}
