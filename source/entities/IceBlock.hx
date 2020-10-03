package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class IceBlock extends MiniEntity
{
    private var sprite:Image;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "ice";
        sprite = new Image("graphics/iceblock.png");
        graphic = sprite;
        mask = new Hitbox(10, 10);
    }

    override public function update() {
        super.update();
    }
}
