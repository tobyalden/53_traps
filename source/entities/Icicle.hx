package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Icicle extends MiniEntity
{
    public static inline var FALL_RANGE = 10;
    public static inline var VANISH_TIME = 1;

    private var sprite:Image;
    private var velocity:Vector2;
    private var isFalling:Bool;
    private var isFallingUpwards:Bool;
    private var vanishTimer:Alarm;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "hazard";
        sprite = new Image("graphics/icicle.png");
        graphic = sprite;
        velocity = new Vector2();
        mask = new Hitbox(10, 10);
        isFalling = false;
        isFallingUpwards = false;
        vanishTimer = new Alarm(VANISH_TIME, function() {
            scene.remove(this);
        });
        addTween(vanishTimer);
    }

    override public function update() {
        var player = scene.getInstance("player");
        if(cast(scene, GameScene).isEvil) {
            if(
                Math.abs(centerX - player.centerX) < FALL_RANGE
                && (scene.collideLine(
                    "walls",
                    Std.int(centerX), Std.int(centerY),
                    Std.int(player.centerX), Std.int(player.centerY)
                ) == null || (cast(scene, GameScene).isEvil && centerY > player.centerY))
            ) {
                if(!isFalling && centerY > player.centerY) {
                    isFallingUpwards = true;
                }
                isFalling = true;
            }
        }
        else {
            if(
                Math.abs(centerX - player.centerX) < FALL_RANGE
                && scene.collideLine(
                    "walls",
                    Std.int(centerX), Std.int(centerY),
                    Std.int(player.centerX), Std.int(player.centerY)
                ) == null
            ) {
                isFalling = true;
            }
        }
        if(isFalling) {
            if(isFallingUpwards) {
                velocity.y -= Player.GRAVITY * HXP.elapsed;
            }
            else {
                velocity.y += Player.GRAVITY * HXP.elapsed;
            }
            velocity.y = MathUtil.clamp(
                velocity.y, -Player.MAX_FALL_SPEED, Player.MAX_FALL_SPEED
            );
        }
        if(isFallingUpwards) {
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed);
        }
        else {
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
        }
        super.update();
    }

    override public function moveCollideY(_:Entity) {
        velocity.y = 0;
        if(!vanishTimer.active) {
            vanishTimer.start();
        }
        return true;
    }
}
