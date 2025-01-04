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
import flixel.util.FlxTimer;
import haxe.EntryPoint;

private var END_COLOR_O:FlxColor = 0xE00400FF;
private var END_COLOR_X:FlxColor = 0xE0FF0000;

class Board extends FlxGroup
{
	private var xs: Int;
	private var ys: Int;

	private var row_height: Int;
	private var col_width: Int;

	private var matching_space:FlxSprite;
	private var map:Array<Array<Bool>>;
	public var blocks:Array<Array<Cracker>>;
	private var crackers:FlxTypedGroup<Cracker>;
	private var selector:Selector;
	public var rebuilding:Bool = false;
	public var rebuild_speed:Float = .25;
	public var moving:Bool = false;
	private var moved:Bool = false;
	private var rng:FlxRandom;

	private var new_blocks:Array<Array<Cracker>>;
	private var new_xs:Int;
	private var new_ys:Int;
	
	private var has_match (get, default):Bool;
	
	public var score (get, set):Int;
	private var _score:Int;
	private var combo_score:Int;
	private var combo_count:Int;

	private var points_per_fish:Int = 5;
	private var cost_per_move:Int = -1;
	private var moves:Int = 0;
	private var end_only:Bool = false;

	private var closing:Bool = false;
	private var matching:Bool = false;
	private var dragged:Bool = false;

	function get_score():Int
	{
		if(_score >= 0)
			return _score;
		return 0;
	}

	function set_score(newScore:Int):Int
	{
		if(newScore >= 0)
			_score = newScore;
		else
			_score = 0;
		Reg.Score = _score;
		return _score;
	}

	function get_has_match()
	{
		if(matching) return false;
		if(moved) {
			matching = true;
			FlxTimer.wait(.05, () -> {
				if(is_match())
					FlxTimer.wait(.05, () -> {
						matching = false;
					});
				else
					matching = false;
			});
		}
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
		Reg.HiScoreSet = false;
		matching_space = new FlxSprite(_location.x, _location.y);
		matching_space.width = _width;
		matching_space.height = _height;
		score = 0;
		
		combo_score = 0;
		combo_count = 0;
		
		xs = x_size;
		ys = y_size;
		map = [[for (_ in 0...xs) false], [for (_ in 0...ys) false]];
		
		row_height = Std.int(_height / ys);
		col_width = Std.int(_width / xs);

		matching_space.makeGraphic(_width, _height, FlxColor.TRANSPARENT);
		FlxSpriteUtil.fill(matching_space, FlxColor.TRANSPARENT);
		add(matching_space);

		crackers = new FlxTypedGroup<Cracker>();
		add(crackers);
		rng = new FlxRandom(Reg.Levels);


		blocks = new Array<Array<Cracker>>();
		for (r in 0...xs){
			blocks[r] = new Array<Cracker>();
			for(c in 0...ys){
				var block = new Cracker(rng.int(0, Cracker.Max), matching_space.x + r * col_width, matching_space.y + c * row_height);
				crackers.add(block);
				blocks[r][c]=block;
			}
		}
		
		selector = new Selector();
		add(selector);
		add(selector.toastText);
	}

	private function blocks_correct(speed:Float) 
	{	
		if(rebuilding) return false;
		var blocks_moved = false;
		for (r in 0...xs){
			for(c in 0...ys){
				var block = blocks[r][c];
				if(block == null) continue;
				if (Math.abs(block.x - (matching_space.x + r * col_width)) > 1)
				{
					block.x = FlxMath.lerp(block.x, matching_space.x + r * col_width, speed);
					blocks_moved = true;
				}
				else
					block.x = matching_space.x + r * col_width;
				if (Math.abs(block.y - (matching_space.y + c * row_height)) > 1)
				{
					block.y = FlxMath.lerp(block.y, matching_space.y + c * row_height, speed);
					blocks_moved = true;
				}
				else
					block.y = matching_space.y + c * row_height;
			}
		}
		if (blocks_moved)
			matching_space.visible = false;
		return !blocks_moved;
	}

	override public function update(elapsed:Float)
	{
		if(closing) return;
		if (Reg.Loss)
		{
			Reg.HiScoreSet = false;
			matching_space.loadGraphic("assets/GameBackground-5.png");
			selector.toast("Failed");
			Reg.Sounds.level_lost();
			closing = true;
			FlxG.camera.fade(FlxColor.BLACK, 3, () -> {
				Reg.saveScore();
				FlxTimer.wait(.5, () -> { // Move back to menu
					FlxG.switchState(new MenuState());
				});
			});
			return;
		}
		if(!blocks_correct(rebuild_speed)) return;
		if(matching) return;
		super.update(elapsed);
		moving = false;
		if(!has_match && !moved){
			matching_space.visible = false;
			selector.visible = true;
			combo_score = 0;
			combo_count = 0;
			#if !android
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
					swap_spots(TargetX, TargetY, SourceX, SourceY);
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
			if (FlxG.mouse.justReleased)
			{
				dragged = false;
				for (r in 0...xs){
					for(c in 0...ys){
						var block = blocks[r][c];
						if(FlxG.mouse.overlaps(block) && !moving)
						{
							if((selector.SelectionX == r && Math.abs(selector.SelectionY - c)==1) || 
								(selector.SelectionY == c && Math.abs(selector.SelectionX - r)==1))
							{
								var SourceX:Int = selector.SelectionX;
								var SourceY:Int = selector.SelectionY;
								var TargetX:Int = r;
								var TargetY:Int = c;

								swap_spots(SourceX, SourceY, TargetX, TargetY);
							}
							else
							{
								selector.SelectionX = r;
								selector.SelectionY = c;
							}
						}
					}
				}
			}
			if (FlxG.mouse.pressed && FlxG.mouse.justMoved && !dragged)
			{
				for (r in 0...xs){
					for(c in 0...ys){
						var block = blocks[r][c];
						if(FlxG.mouse.overlaps(block) && !moving)
						{
							if((selector.SelectionX == r && Math.abs(selector.SelectionY - c)==1) || 
								(selector.SelectionY == c && Math.abs(selector.SelectionX - r)==1))
							{
								dragged = true;
								var SourceX:Int = r;
								var SourceY:Int = c;
								var TargetX:Int = selector.SelectionX;
								var TargetY:Int = selector.SelectionY;

								swap_spots(TargetX, TargetY,SourceX, SourceY);
							}
							else
							{
								selector.SelectionX = r;
								selector.SelectionY = c;
							}
						}
					}
				}

			}
			#end
		}
		if (has_match)
		{
			matching_space.visible = true;
			handle_match_state();
		}
	}

	public function swap_spots(SourceX:Int, SourceY:Int, TargetX:Int, TargetY:Int)
	{
		moving = true;
		rebuild_speed = .25;
		var deltaX = SourceX - TargetX;
		var deltaY = SourceY - TargetY;
		var tmpBlockTarget:Cracker = blocks[TargetX][TargetY];
		var tmpBlockSource:Cracker = blocks[SourceX][SourceY];
		if(deltaX == 0)
			Reg.Sounds.row_shift();
		else
			Reg.Sounds.col_shift();
		blocks[SourceX][SourceY] = null;
		moves += 1;
		score = score + cost_per_move;
		var steps:Int = 0;
		while(tmpBlockTarget != null)
		{
			blocks[TargetX][TargetY] = tmpBlockSource;
			tmpBlockSource = tmpBlockTarget;
			SourceX = TargetX;
			SourceY = TargetY;
			TargetX = (xs + SourceX - deltaX) % xs;
			TargetY = (ys + SourceY - deltaY) % ys;
			tmpBlockTarget = blocks[TargetX][TargetY];
			steps += 1 ;
		}
		blocks[TargetX][TargetY] = tmpBlockSource;
		moved = true;
	}

	public function handle_match_state():Void
	{
		if(rebuilding) return;
		rebuilding = true;
		rebuild_speed = .05;
		new_xs = xs;
		for (c in 0...xs){
			if(map[0][c])
			{
				FlxSpriteUtil.drawLine(matching_space, blocks[c][0].getMidpoint().x - matching_space.x, blocks[c][0].getMidpoint().y - matching_space.y,
					blocks[c][ys - 1].getMidpoint().x - matching_space.x, blocks[c][ys - 1].getMidpoint().y - matching_space.y, {
					thickness: 50,
					color: 0xFFFFFFFF
				});
				new_xs -= 1;
			}
			else
			{
				#if debug
				FlxSpriteUtil.drawLine(matching_space, blocks[c][0].getMidpoint().x - matching_space.x, blocks[c][0].getMidpoint().y - matching_space.y,
					blocks[c][ys - 1].getMidpoint().x - matching_space.x, blocks[c][ys - 1].getMidpoint().y - matching_space.y, {
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
				FlxSpriteUtil.drawLine(matching_space, blocks[0][r].getMidpoint().x - matching_space.x, blocks[0][r].getMidpoint().y - matching_space.y,
					blocks[xs - 1][r].getMidpoint().x - matching_space.x, blocks[xs - 1][r].getMidpoint().y - matching_space.y, {
					thickness: 50,
					color: 0xFFFFFFFF
				});
				new_ys -= 1;
			}
			else
			{
				#if debug
				FlxSpriteUtil.drawLine(matching_space, blocks[0][r].getMidpoint().x - matching_space.x, blocks[0][r].getMidpoint().y - matching_space.y,
					blocks[xs - 1][r].getMidpoint().x - matching_space.x, blocks[xs - 1][r].getMidpoint().y - matching_space.y, {
					thickness: 10,
					color: 0xFFB92323
				});
				#end
			}
		}
		if(new_ys > 0 && new_xs > 0)
		{
			var rebuild_delay = .2;
			if(end_only)
				rebuild_delay = .5;
			FlxTimer.wait(rebuild_delay, () ->{ // Rebuilding board
				var selected_point = new FlxPoint(selector.SelectionX,selector.SelectionY);
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
				map = [
					[for(_ in 0...xs) false],
					[for(_ in 0...ys) false]
				];
				blocks = new_blocks;
				xs = new_xs;
				ys = new_ys;
				
				selector.blocks = blocks;
				selector.SelectionX = Std.int(selected_point.x);
				selector.SelectionY = Std.int(selected_point.y);
				FlxSpriteUtil.fill(matching_space, FlxColor.TRANSPARENT);
				rebuilding = false;
				moved = true;
			});
		}
		else
		{
			FlxSpriteUtil.fill(matching_space, FlxColor.TRANSPARENT);
			FlxTimer.wait(.5, () ->
			{ // Moving to next level
				if(Reg.HiScore.exists(Reg.Levels))
				{
					if (Reg.HiScore[Reg.Levels] < Reg.Score)
					{
						Reg.HiScoreSet = true;
						Reg.HiScore[Reg.Levels] = Reg.Score;
					}
				}
				else
				{
					Reg.HiScoreSet = true;
					Reg.HiScore[Reg.Levels] = Reg.Score;
				}

				Reg.saveScore();
				Reg.PS.remove(this);
				Reg.PS.popup();
			});
		}
	}

	public function get_game_state():Array<Array<Int>>
	{
		var columns:Array<Int>	= [for (_ in 0...xs) 1];
		var rows:Array<Int> 	= [for (_ in 0...ys) 1];
		var cracker_counts = new Map<Int,Int>();
		// Check rows
		for (c in 0...xs){
			for(r in 0...ys){
				var cracker_value:Int = blocks[c][r].Value;
				rows[r] *= cracker_value;
				columns[c] *= cracker_value;
				if(!cracker_counts.exists(cracker_value))
				{
					cracker_counts[cracker_value] = 1;
				}
				else
				{
					cracker_counts[cracker_value] += 1;
				}
			}
		}

		// Test for softlock
		var _loss = Lambda.count(cracker_counts) == 4;
		for (count in cracker_counts) {
			if(count != 1) _loss = false;
		}
		Reg.Loss = _loss;

		return [rows, columns];
	}

	public function is_match():Bool
	{
		var sweep_up:Bool = true;
		var game_state:Array<Array<Int>> = get_game_state();
		var rows:Array<Int> = game_state[0];
		var columns:Array<Int> = game_state[1];
		var scored:Bool = false;
		end_only = true;
		var mini_combo:Int = 1;
		var points_gained:Int = 0;

		for (i in 0...ys){
			if(xs > 1 || sweep_up)
				map[1][i] = rows[i] == Math.pow(blocks[0][i].Value, xs);
			if(xs > 1 && map[1][i])
			{
				if(i+1 != ys) end_only = false;
				points_gained += Reg.Levels * points_per_fish * mini_combo;
				scored = true;
				mini_combo += 1;
			}
		}

		for (i in 0...xs){
			if(ys > 1 || sweep_up)
				map[0][i] = columns[i] == Math.pow(blocks[i][0].Value, ys);
			if(ys > 1 && map[0][i])
			{
				if(i+1 != xs) end_only = false;
				points_gained += Reg.Levels * points_per_fish * mini_combo;
				scored = true;
				mini_combo += 1;
			}
		}
		if(points_gained > 0)
		{
			combo_count += 1;
			combo_score += points_gained * combo_count;
			score += combo_score;
			Reg.Sounds.score(combo_count);
			selector.toast(Std.string(combo_score));
		}
		moved = false;
		return scored;
	}
}
