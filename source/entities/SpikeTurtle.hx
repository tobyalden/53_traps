package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class SpikeTurtle extends MiniEntity
{
    public static inline var SPEED = 30;

    private var sprite:Spritemap;
    private var activated:Bool;
    private var velocity:Vector2;

    public function new(x:Float, y:Float) {
        super(x, y);
        layer = -5;
        type = "hazard";
        sprite = new Spritemap("graphics/spiketurtle.png", 20, 20);
        sprite.add("walk", [0, 1], 8);
        sprite.play("walk");
        sprite.x = -3;
        sprite.y = -10;
        graphic = sprite;
        mask = new Hitbox(12, 10);
        activated = false;
        velocity = new Vector2(-SPEED, 0);
    }

    override public function update() {
        var player = scene.getInstance("player");
        if(scene.camera.x + HXP.width > x) {
            activated = true;
        }
        if(activated) {
            if(isOnGround()) {
                velocity.y = 0;
            }
            else {
                velocity.y += Player.GRAVITY * HXP.elapsed;
                velocity.y = Math.min(velocity.y, Player.MAX_FALL_SPEED);
            }
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["walls", "item"]);
        }
        super.update();
    }

    override public function moveCollideX(_:Entity) {
        velocity.x = -velocity.x;
        sprite.flipX = !sprite.flipX;
        return true;
    }
}


