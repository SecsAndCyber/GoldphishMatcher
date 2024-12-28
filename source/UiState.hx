package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.input.mouse.FlxMouse;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.group.FlxGroup;
import flixel.math.FlxRandom;
import haxe.Timer;

using flixel.util.FlxSpriteUtil;

class UiState extends FlxState
{
	private var title:FlxText;
	private var copyright:FlxText;
	private var fishes:FlxGroup;
	private var fish:Array<FlxSprite>;
	private var fish_rng:FlxRandom;

	override public function create():Void
	{
		super.create();
		Reg.loadScore();
		fish_rng = new FlxRandom(Reg.Levels);
		FlxG.mouse.visible = !Reg.hideMouse;

		fish = new Array<FlxSprite>();
		for (index in 0...Reg.Levels)
		{
			fish[index] = new FlxSprite(
								Reg.fish_location.x - index * (Reg.fish_speed + fish_rng.int(Std.int(FlxG.width / -2), Std.int(FlxG.width / 2))),
								Reg.fish_location.y + index * Reg.fish_speed
								);
			fish[index].loadGraphic("assets/HappyGoldfishCookieSquare.png");
			add(fish[index]);
		}

		title = new FlxText(0,20 * Reg.UI_Scale, 0, "Goldphish\nMatch", 64 * Reg.UI_Scale);
		title.alignment = CENTER;
		title.screenCenter(X);
		add(title);
		
		copyright = new FlxText(50,FlxG.height-50*Reg.UI_Scale,0, "Copyright 2024 S1air Coding", 36 * Reg.UI_Scale);
		copyright.alignment = CENTER;
		copyright.screenCenter(X);
		add(copyright);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		for (index in 0...fish.length)
		{
			fish[index].x += Reg.fish_speed * (Reg.Levels*elapsed);
			fish[index].y = (Reg.fish_speed + Math.sin(Timer.stamp())*Reg.fish_speed) * Reg.UI_Scale + index * Reg.fish_speed;
			if(fish[index].x > FlxG.width)
				fish[index].x = -1 * fish[index].width - index * Reg.fish_speed;
			
			Reg.fish_location.x = fish[0].x;
			Reg.fish_location.y = fish[0].y;
		}
	}
}