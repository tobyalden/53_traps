package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Item extends MiniEntity
{
    //public static inline var SPEED = 100;

    private var sprite:Image;
    private var velocity:Vector2;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "item";
        sprite = new Image("graphics/item.png");
        graphic = sprite;
        velocity = new Vector2();
        mask = new Hitbox(16, 16);
    }

    override public function update() {
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
        super.update();
    }

    override public function moveCollideX(_:Entity) {
        return true;
    }

    override public function moveCollideY(_:Entity) {
        return true;
    }
}

