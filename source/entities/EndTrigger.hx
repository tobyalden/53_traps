package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class EndTrigger extends MiniEntity
{
    private var sprite:ColoredRect;

    public function new(x:Float, y:Float, width:Int, height:Int) {
        super(x, y);
        type = "endtrigger";
        mask = new Hitbox(width, height);
        sprite = new ColoredRect(width, height, 0xFF0000);
        sprite.alpha = 0.5;
        graphic = sprite;
    }

    override public function update() {
        super.update();
    }
}
