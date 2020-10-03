package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Player extends MiniEntity
{
    public static inline var RUN_ACCEL = 450 / 1.5;
    public static inline var RUN_ACCEL_TURN_MULTIPLIER = 2;
    public static inline var RUN_DECEL = RUN_ACCEL * RUN_ACCEL_TURN_MULTIPLIER;
    public static inline var ICE_MAX_SPEED_MULTIPLIER = 1.5;
    public static inline var ICE_ACCEL_MULTIPLIER = 1 / 2;
    public static inline var ICE_DECEL_MULTIPLIER = 1 / 12;
    public static inline var AIR_ACCEL = 500 / 1.5;
    public static inline var AIR_DECEL = 460 / 1.5;
    public static inline var MAX_RUN_SPEED = 120;
    public static inline var MAX_AIR_SPEED = 160;
    public static inline var GRAVITY = 500;
    public static inline var JUMP_POWER = 160;
    public static inline var JUMP_CANCEL_POWER = 40;
    public static inline var MAX_FALL_SPEED = 270;
    public static inline var RUN_SPEED_APPLIED_TO_JUMP_POWER = 1 / 6;

    public static var sfx:Map<String, Sfx> = null;

    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var isDead:Bool;
    private var canMove:Bool;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "player";
        layer = -3;
        sprite = new Spritemap("graphics/player.png", 8, 12);
        sprite.add("idle", [0]);
        sprite.add("run", [1, 2, 3, 2], 8);
        sprite.add("jump", [4]);
        sprite.add("skid", [6]);
        sprite.play("idle");
        mask = new Hitbox(6, 12);
        sprite.x = -1;
        sprite.flipX = false;
        graphic = sprite;
        velocity = new Vector2();
        isDead = false;
        canMove = false;
        var allowMove = new Alarm(0.2, function() {
            canMove = true;
        });
        addTween(allowMove, true);
        if(sfx == null) {
            sfx = [
                "jump" => new Sfx("audio/jump.wav"),
                "slide" => new Sfx("audio/slide.wav"),
                "run" => new Sfx("audio/run.wav"),
                "skid" => new Sfx("audio/skid.wav"),
                "die" => new Sfx("audio/die.wav"),
                "save" => new Sfx("audio/save.wav")
            ];
        }
    }

    override public function update() {
        if(!isDead) {
            if(canMove) {
                movement();
            }
            animation();
            if(canMove) {
                sound();
            }
            collisions();
        }
        super.update();
    }

    private function collisions() {
        if(collide("hazard", x, y) != null) {
            die();
        }
    }

    private function stopSounds() {
        sfx["run"].stop();
        sfx["slide"].stop();
    }

    public function die() {
        visible = false;
        collidable = false;
        isDead = true;
        explode();
        stopSounds();
        sfx["die"].play(0.8);
        var fadeOut = new Alarm(0.25, function() {
            cast(HXP.scene, GameScene).curtain.fadeIn(0.25);
            var reset = new Alarm(0.25, function() {
                HXP.scene = new GameScene();
            });
            addTween(reset, true);
        });
        addTween(fadeOut, true);
    }

    private function movement() {
        var accel:Float = isOnGround() ? RUN_ACCEL : AIR_ACCEL;
        if(
            isOnGround() && !isOnIce() && (
                Main.inputCheck("left") && velocity.x > 0
                || Main.inputCheck("right") && velocity.x < 0
            )
        ) {
            accel *= RUN_ACCEL_TURN_MULTIPLIER;
        }
        var decel:Float = isOnGround() ? RUN_DECEL : AIR_DECEL;
        if(isOnIce()) {
            accel *= ICE_ACCEL_MULTIPLIER;
            decel *= ICE_DECEL_MULTIPLIER;
        }
        if(Main.inputCheck("left") && !isOnLeftWall()) {
            velocity.x -= accel * HXP.elapsed;
        }
        else if(Main.inputCheck("right") && !isOnRightWall()) {
            velocity.x += accel * HXP.elapsed;
        }
        else if(!isOnWall()) {
            velocity.x = MathUtil.approach(
                velocity.x, 0, decel * HXP.elapsed
            );
        }
        var maxSpeed:Float = isOnGround() ? MAX_RUN_SPEED : MAX_AIR_SPEED;
        if(isOnIce()) {
            maxSpeed *= ICE_MAX_SPEED_MULTIPLIER;
        }
        velocity.x = MathUtil.clamp(velocity.x, -maxSpeed, maxSpeed);

        if(isOnGround()) {
            velocity.y = 0;
            if(Main.inputPressed("jump")) {
                velocity.y = -(
                    JUMP_POWER
                    + Math.abs(velocity.x * RUN_SPEED_APPLIED_TO_JUMP_POWER)
                );
                sfx["jump"].play();
            }
        }
        else {
            if(Main.inputReleased("jump")) {
                velocity.y = Math.max(velocity.y, -JUMP_CANCEL_POWER);
            }
            velocity.y += GRAVITY * HXP.elapsed;
            velocity.y = Math.min(velocity.y, MAX_FALL_SPEED);
        }
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
    }

    override public function moveCollideX(_:Entity) {
        velocity.x = 0;
        return true;
    }

    override public function moveCollideY(_:Entity) {
        velocity.y = 0;
        return true;
    }

    private function animation() {
        if(!canMove) {
            if(isOnGround()) {
                sprite.play("idle");
            }
            else {
                sprite.play("jump");
            }
        }
        else if(!isOnGround()) {
            sprite.play("jump");
            if(velocity.x < 0) {
                sprite.flipX = true;
            }
            else if(velocity.x > 0) {
                sprite.flipX = false;
            }
        }
        else if(velocity.x != 0) {
            if(
                (velocity.x > 0 && Main.inputCheck("left")
                || velocity.x < 0 && Main.inputCheck("right"))
                && !isOnIce()
            ) {
                sprite.play("skid");
                if(!sfx["skid"].playing) {
                    sfx["skid"].play();
                }
            }
            else {
                sprite.play("run");
            }
            sprite.flipX = velocity.x < 0;
        }
        else {
            sprite.play("idle");
        }
    }

    private function sound() {
        if(isOnGround() && Math.abs(velocity.x) > 0 && !sfx["skid"].playing) {
            if(!sfx["run"].playing) {
                sfx["run"].loop();
            }
        }
        else {
            sfx["run"].stop();
        }
    }
}
