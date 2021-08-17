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
    public var isShattered(default, null):Bool;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "pot";
        layer = -20;
        sprite = new Spritemap("graphics/pot.png", 15, 20);
        sprite.add("idle", [0]);
        sprite.add("shattered", [1]);
        sprite.play("idle");
        graphic = sprite;
        mask = new Hitbox(15, 20);
    }

    public function shatter() {
        isShattered = true;
    }

    override public function update() {
        sprite.play(isShattered ? "shattered" : "idle");
        super.update();
    }
}
