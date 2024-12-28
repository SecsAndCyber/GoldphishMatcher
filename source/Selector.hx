package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;

class Selector extends FlxSprite
{
	private var selection_x:Int;
	private var selection_y:Int;
	public var blocks:Array<Array<Cracker>>;
	
	public var toastText:FlxText;
	
	public var SelectionX(get, set):Int;

	function get_SelectionX() {
		return selection_x;
	  }
	function set_SelectionX(newX) {
		selection_x = (newX + blocks.length) % blocks.length;
		return selection_x;
	}
	
	public var SelectionY(get, set):Int;

	function get_SelectionY() {
		return selection_y;
	  }
	function set_SelectionY(newY) {
		selection_y = (newY + blocks[0].length) % blocks[0].length;
		return selection_y;
	}

	public function new()
	{
		super();
		loadGraphic("assets/Selector.png");
		
		toastText = new FlxText(0,20 * Reg.UI_Scale, 0, "TOAST", 64 * Reg.UI_Scale);
		toastText.alignment = CENTER;
		toastText.visible = false;


		selection_x = 0;
		selection_y = 0;
	}

	public function toast(text:String)
	{
		trace(text);
		toastText.text = text;
		toastText.x = (FlxG.width) / 2 -(toastText.width / 2);
		toastText.y = y;
		toastText.visible = true;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if(toastText.visible)
		{
			toastText.y = FlxMath.lerp(toastText.y, -1 * toastText.height, elapsed);
			if(toastText.y < -0.75 * toastText.height)
			{
				toastText.visible = false;
			}
		}
		if (FlxG.keys.pressed.SPACE)
		{
			color = 0x0000FF;
		}
		else
		{
			color = 0xFF0000;
		}

		if(Reg.PS == null || Reg.PS.board == null || Reg.PS.board.moving || Reg.PS.board.rebuilding) {
			color = 0xFFFFFF;
			return;
		}
		blocks = Reg.PS.board.blocks;
		SelectionX = selection_x;
		SelectionY = selection_y;
		if(blocks[selection_x][selection_y] == null) { trace("Null!",selection_x, selection_y); return; }
		setPosition(
			blocks[selection_x][selection_y].x,
			blocks[selection_x][selection_y].y
		);
	}

}
