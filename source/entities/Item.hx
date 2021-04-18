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
    private var carrier:MiniEntity;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "item";
        sprite = new Image("graphics/item.png");
        graphic = sprite;
        velocity = new Vector2();
        mask = new Hitbox(15, 15);
    }

    public function setCarrier(newCarrier:MiniEntity) {
        carrier = newCarrier;
    }

    public function setVelocity(newVelocity:Vector2) {
        velocity = newVelocity;
    }

    override public function update() {
        //collidable = carrier == null;
        if(carrier != null) {
            //moveTo(carrier.centerX - width / 2, carrier.y - height);
        }
        else {
            velocity.y += Player.GRAVITY * HXP.elapsed;
            velocity.y = Math.min(velocity.y, Player.MAX_FALL_SPEED);
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
        }
        super.update();
    }

    override public function moveCollideX(_:Entity) {
        velocity.x = 0;
        return true;
    }

    override public function moveCollideY(_:Entity) {
        velocity /= 2;
        return true;
    }
}
