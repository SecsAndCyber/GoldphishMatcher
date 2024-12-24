package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import haxe.EntryPoint;

private var END_COLOR_O:FlxColor = 0xE00400FF;
private var END_COLOR_X:FlxColor = 0xE0FF0000;

class Board extends FlxGroup
{
	private var xs: Int;
	private var ys: Int;

	private var row_height: Int;
	private var col_width: Int;

	private var background:FlxSprite;
	private var map:Array<Array<Bool>>;
	public var blocks:Array<Array<Cracker>>;
	private var crackers:FlxTypedGroup<Cracker>;
	private var selector:Selector;
	public var rebuilding:Bool = false;
	private var rng:FlxRandom;

	private var new_blocks:Array<Array<Cracker>>;
	private var new_xs: Int;
	private var new_ys: Int;
	
	private var has_match (get, default):Bool;

	function get_has_match() {
		for (c in 0...xs){
			if(map[0][c]) return true;
		}
		for(r in 0...ys){
			if(map[1][r]) return true;
		}		
		return false;
	  }

	public function new(x_size:Int = 3, y_size:Int = 3, _location:FlxPoint, _width:Int, _height:Int)
	{
		super();
		background = new FlxSprite(_location.x, _location.y);
		background.width=_width;
		background.height=_height;
		
		xs = x_size;
		ys = y_size;
		
		row_height = Std.int(_height / ys);
		col_width = Std.int(_width / xs);

		background.makeGraphic(_width, _height, FlxColor.GRAY);
		add(background);

		crackers = new FlxTypedGroup<Cracker>();
		add(crackers);
		rng = new FlxRandom(Reg.Levels);

		map = [
			[for(_ in 0...xs) false],
			[for(_ in 0...ys) false]
		];

		blocks = new Array<Array<Cracker>>();
		for (r in 0...xs){
			blocks[r] = new Array<Cracker>();
			for(c in 0...ys){
				var block = new Cracker(rng.int(0, Cracker.Max), background.x + r * col_width,background.y + c * row_height);
				crackers.add(block);
				blocks[r][c]=block;
			}
		}
		
		selector = new Selector();
		add(selector);
	}

	private function blocks_correct() {	
		if(rebuilding) return false;
		var moved = false;
		for (r in 0...xs){
			for(c in 0...ys){
				var block = blocks[r][c];
				if(Math.abs(block.x - (background.x + r * col_width)) > 1)
				{
					block.x = FlxMath.lerp(block.x, background.x + r * col_width, .075);
					moved = true;
				}
				if(Math.abs(block.y - (background.y + c * row_height)) > 1)
				{
					block.y = FlxMath.lerp(block.y, background.y + c * row_height, .075);
					moved = true;
				}
			}
		}
		return !moved;
	}

	override public function update(elapsed:Float)
	{
		if(!blocks_correct()) return;
		if(!has_match){
			if (FlxG.keys.pressed.SPACE)
			{
				// Space pressed, move board state
				var SourceX:Int = selector.SelectionX;
				var SourceY:Int = selector.SelectionY;
				var TargetX:Int = SourceX;
				var TargetY:Int = SourceY;
				var clicked:Bool= false;
				if (FlxG.keys.justPressed.UP)
				{
					TargetY = (ys + SourceY + 1) % ys;
					clicked = true;
				}
				if (FlxG.keys.justPressed.DOWN)
				{
					TargetY = (ys + SourceY - 1) % ys;
					clicked = true;
				}
				if (FlxG.keys.justPressed.LEFT)
				{
					TargetX = (xs + SourceX + 1) % xs;
					clicked = true;
				}
				if (FlxG.keys.justPressed.RIGHT)
				{
					TargetX = (xs + SourceX - 1) % xs;
					clicked = true;
				}
				if(clicked){
					var _X = blocks[SourceX][SourceY].x;
					var _Y = blocks[SourceX][SourceY].y;
					var deltaX = SourceX - TargetX;
					var deltaY = SourceY - TargetY;
					var tmpBlockTarget = blocks[TargetX][TargetY];
					while(tmpBlockTarget.x != _X || tmpBlockTarget.y != _Y)
					{
						var tmpBlockSource = blocks[SourceX][SourceY];
						var tmpsourceX = tmpBlockSource.x;
						var tmpsourceY = tmpBlockSource.y;
						var tmptargetX = tmpBlockTarget.x;
						var tmptargetY = tmpBlockTarget.y;
						blocks[TargetX][TargetY] = tmpBlockSource;
						blocks[TargetX][TargetY].setPosition(tmptargetX, tmptargetY);
						blocks[SourceX][SourceY] = tmpBlockTarget;
						blocks[SourceX][SourceY].setPosition(tmpsourceX, tmpsourceY);
						SourceX = TargetX;
						SourceY = TargetY;
						TargetX = (xs + SourceX - deltaX) % xs;
						TargetY = (ys + SourceY - deltaY) % ys;
						tmpBlockTarget = blocks[TargetX][TargetY];
					}
					// selector.SelectionX += deltaX;
					// selector.SelectionY += deltaY;
					if(is_match())
					{
						trace("Match made!");
					}
				}
			}
			else
			{
				// Space not pressed, move selection
				if (FlxG.keys.justPressed.UP)
				{
					selector.SelectionY -= 1;
				}
				if (FlxG.keys.justPressed.DOWN)
				{
					selector.SelectionY += 1;
				}
				if (FlxG.keys.justPressed.LEFT)
				{
					selector.SelectionX -= 1;
				}
				if (FlxG.keys.justPressed.RIGHT)
				{
					selector.SelectionX += 1;
				}
			}
		}
		else{	
			draw_matched_lines();
		}
		super.update(elapsed);
	}

	public function draw_matched_lines():Void
	{
		if(rebuilding) return;
		new_xs = xs;
		for (c in 0...xs){
			if(map[0][c])
			{
				#if debug
				FlxSpriteUtil.drawLine(background,
					blocks[c][0].getMidpoint().x - background.x, blocks[c][0].getMidpoint().y - background.y,
					blocks[c][ys - 1].getMidpoint().x - background.x, blocks[c][ys - 1].getMidpoint().y - background.y, {
					thickness: 50,
					color: 0xFFFFFFFF
				});
				#end
				new_xs -= 1;
			}
			else
			{
				#if debug
				FlxSpriteUtil.drawLine(background,
					blocks[c][0].getMidpoint().x - background.x, blocks[c][0].getMidpoint().y - background.y,
					blocks[c][ys - 1].getMidpoint().x - background.x, blocks[c][ys - 1].getMidpoint().y - background.y, {
					thickness: 10,
					color: 0xFFB92323
				});
				#end
			}
		}
		new_ys = ys;
		for(r in 0...ys){
			if(map[1][r])
			{
				#if debug
				FlxSpriteUtil.drawLine(background,
					blocks[0][r].getMidpoint().x - background.x,blocks[0][r].getMidpoint().y - background.y,
					blocks[xs - 1][r].getMidpoint().x - background.x,blocks[xs - 1][r].getMidpoint().y - background.y, {
					thickness: 50,
					color: 0xFFFFFFFF
				});
				#end
				new_ys -= 1;
			}
			else
			{
				#if debug
				FlxSpriteUtil.drawLine(background,
					blocks[0][r].getMidpoint().x - background.x,blocks[0][r].getMidpoint().y - background.y,
					blocks[xs - 1][r].getMidpoint().x - background.x,blocks[xs - 1][r].getMidpoint().y - background.y, {
					thickness: 10,
					color: 0xFFB92323
				});
				#end
			}
		}
		rebuilding = true;
		if(new_ys > 0 && new_xs > 0)
		{
			var selected_point = new FlxPoint(0,0);
			trace("Rebuild as ",new_xs,new_ys);
			new_blocks = new Array<Array<Cracker>>();
			var new_r = 0;
			for (r in 0...xs){
				if(!map[0][r])
				{
					new_blocks[new_r] = new Array<Cracker>();
				}
				for(c in 0...ys){
					var block = blocks[r][c];
					if(map[1][c] || map[0][r])
						crackers.remove(block);
					else{
						new_blocks[new_r].push(block);
						if(selector.SelectionX == r && selector.SelectionY == c)
						{
							selected_point.x = new_r;
							selected_point.y = new_blocks[new_r].length - 1;
						}
					}
				}
				if(!map[0][r])
				{
					new_r += 1;
				}
			}
			FlxG.camera.fade(FlxColor.BLACK, .3, () -> {
				blocks = new_blocks;
				xs = new_xs;
				ys = new_ys;
				if(is_match())
				{
					trace("Rebuilding has new match made!");
				}
				selector.blocks = blocks;
				selector.SelectionX = Std.int(selected_point.x);
				selector.SelectionY = Std.int(selected_point.y);
				FlxSpriteUtil.fill(background, FlxColor.GRAY);
				FlxG.camera.fade(FlxColor.BLACK, .3, true, () -> {
					rebuilding = false;
				});
			});
			
		}
		else
		{
			Reg.Levels += 1;
			Reg.saveScore();
			FlxG.camera.fade(FlxColor.BLACK, 3, () -> {FlxG.switchState(new MenuState());});
		}
	}

	public function get_game_state():Array<Array<Int>>
	{
		var columns:Array<Int>	= [for (_ in 0...xs) 1];
		var rows:Array<Int> 	= [for (_ in 0...ys) 1];
		// Check rows
		for (c in 0...xs){
			for(r in 0...ys){
				rows[r] *= blocks[c][r].Value;
				columns[c] *= blocks[c][r].Value;
			}
		}
		return [rows, columns];
	}

	public function is_match():Bool
	{
		var game_state:Array<Array<Int>> = get_game_state();
		var rows:Array<Int> = game_state[0];
		var columns:Array<Int> = game_state[1];

		for (i in 0...ys){
			map[1][i] = rows[i] == Math.pow(blocks[0][i].Value, xs);
			if(rows[i] == Math.pow(blocks[0][i].Value, xs))
			{
				trace("Row",i,"is matched");
				map[1][i] = true;
			}
			else
			{
				trace("Row",i,"is not matched", rows[i], Math.pow(blocks[0][i].Value, xs));
			}
		}

		for (i in 0...xs){
			map[0][i] = columns[i] == Math.pow(blocks[i][0].Value, ys);
			if(columns[i] == Math.pow(blocks[i][0].Value, ys))
			{
				trace("Column",i,"is matched");
				map[0][i] = true;
			}
			else
			{
				trace("Column",i,"is not matched", columns[i], Math.pow(blocks[i][0].Value, ys));
			}
		}

		return false;
	}
}
