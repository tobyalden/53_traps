package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Jumper extends MiniEntity
{
    public static inline var SPEED = 50;
    public static inline var GRAVITY = 400;
    public static inline var JUMP_POWER = 180;
    public static inline var JUMP_POWER_X = 50;
    public static inline var JUMP_DELAY = 0.5;

    private var sprite:Spritemap;
    private var activated:Bool;
    private var velocity:Vector2;
    private var jumpTimer:Alarm;

    public function new(x:Float, y:Float) {
        super(x, y);
        layer = -5;
        type = "hazard";
        sprite = new Spritemap("graphics/jumper.png", 10, 15);
        sprite.add("idle", [0]);
        sprite.add("prejump", [1]);
        sprite.play("idle");
        sprite.y = -3;
        graphic = sprite;
        mask = new Hitbox(10, 12);
        activated = false;
        velocity = new Vector2(0, 0);
        jumpTimer = new Alarm(JUMP_DELAY, function() {
            velocity.y = -JUMP_POWER;
            var player = scene.getInstance("player");
            //if(centerX > player.centerX) {
                //velocity.x = -JUMP_POWER_X;
            //}
            //else {
                //velocity.x = JUMP_POWER_X;
            //}
        });
        addTween(jumpTimer);
    }

    override public function update() {
        var player = scene.getInstance("player");
        if(scene.camera.x + HXP.width > x) {
            activated = true;
        }
        if(activated) {
            if(isOnGround() && velocity.y == 0) {
                if(!jumpTimer.active) {
                    jumpTimer.start();
                }
            }
            else {
                velocity.y += GRAVITY * HXP.elapsed;
                velocity.y = Math.min(velocity.y, Player.MAX_FALL_SPEED);
            }
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["walls", "item"]);
        }
        sprite.play(jumpTimer.active && jumpTimer.percent >= 0.5 ? "prejump" : "idle");
        super.update();
    }

    override public function moveCollideX(_:Entity) {
        velocity.x = 0;
        return true;
    }

    override public function moveCollideY(_:Entity) {
        if(velocity.y > 0) {
            velocity.x = 0;
        }
        velocity.y = 0;
        return true;
    }
}
