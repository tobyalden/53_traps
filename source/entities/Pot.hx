package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Pot extends Item
{
    public function new(x:Float, y:Float) {
        super(x, y);
        sprite = new Image("graphics/pot.png");
        graphic = sprite;
        mask = new Hitbox(15, 25);
    }

    override public function update() {
        super.update();
    }
}
