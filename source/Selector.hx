package;

import flixel.FlxG;
import flixel.FlxSprite;

class Selector extends FlxSprite
{
	private var selection_x:Int;
	private var selection_y:Int;
	public var blocks:Array<Array<Cracker>>;
	
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

		selection_x = 0;
		selection_y = 0;
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.pressed.SPACE)
		{
			color = 0x0000FF;
		}
		else
		{
			color = 0xFF0000;
		}

		if(Reg.PS == null) return;
		if(Reg.PS.board == null) return;
		if(Reg.PS.board.rebuilding) {
			selection_x = 0;
			selection_y = 0;
			return;
		}
		
		blocks = Reg.PS.board.blocks;
		setPosition(
			blocks[selection_x][selection_y].x,
			blocks[selection_x][selection_y].y
		);
		super.update(elapsed);
	}

}
