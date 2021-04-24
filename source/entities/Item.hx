package entities;

import haxe.Serializer;
import haxe.Unserializer;
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

    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var carrier:MiniEntity;

    public function serialize() {
        var serializer = new Serializer();
        serializer.serialize({x: x, y: y, name: name});
        return serializer.toString();
    }

    static public function unserialize(serializedItem:String):Item {
        var unserializer = new Unserializer(serializedItem);
        var unserializedItem = unserializer.unserialize();
        if(unserializedItem.name == "pot") {
            return new Pot(unserializedItem.x, unserializedItem.y);
        }
        else {
            return new Item(unserializedItem.x, unserializedItem.y);
        }
    }

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "item";
        name = "item";
        sprite = new Spritemap("graphics/item.png");
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
            if(!isOnGround()) {
                velocity.y += Player.GRAVITY * HXP.elapsed;
            }
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
        velocity.x = velocity.x / 2;
        if(Math.abs(velocity.x) < 10) {
            velocity.x = 0;
        }

        velocity.y = -velocity.y / 2;
        if(Math.abs(velocity.y) < 10) {
            velocity.y = 0;
        }
        return true;
    }
}

