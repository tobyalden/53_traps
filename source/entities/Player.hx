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
    public static inline var ACCEL = 750;
    public static inline var GROUND_ACCEL = 750 * 3;
    public static inline var FLAP_ACCEL_MULTIPLIER = 4;
    public static inline var OFF_GROUND_FLAP_MULTIPLIER = 1.2;
    public static inline var DECEL = ACCEL;
    public static inline var GROUND_DECEL = GROUND_ACCEL;
    public static inline var MAX_SPEED_IN_AIR = 150;
    public static inline var MAX_SPEED_ON_GROUND = 70;
    public static inline var GRAVITY = 250;
    public static inline var FLAP_POWER = 100;
    public static inline var MAX_FALL_SPEED = 300;
    public static inline var MAX_RISE_SPEED = 300;

    public static var sfx:Map<String, Sfx> = null;

    public var sword(default, null):Sword;
    public var sprite(default, null):Spritemap;
    private var velocity:Vector2;
    private var isDead:Bool;
    private var canMove:Bool;
    private var wallJumpCooldown:Alarm;

    public function new(x:Float, y:Float) {
        super(x, y);
        this.sword = new Sword(this);
        name = "player";
        layer = -3;
        sprite = new Spritemap("graphics/player.png", 16, 16);
        sprite.add("idle", [1]);
        sprite.add("flap", [0, 1, 2, 3, 1], 8, false);
        sprite.add("run", [1, 3], 4);
        sprite.play("idle");
        mask = new Hitbox(9, 13);
        sprite.x = -4;
        sprite.y = -2;
        graphic = sprite;
        velocity = new Vector2();
        isDead = false;
        canMove = false;
        var allowMove = new Alarm(0.3, function() {
            canMove = true;
        });
        addTween(allowMove, true);

        wallJumpCooldown = new Alarm(0.33);
        addTween(wallJumpCooldown);

        if(sfx == null) {
            sfx = [
                "jump" => new Sfx("audio/jump.wav"),
                "slide" => new Sfx("audio/slide.wav"),
                "run" => new Sfx("audio/run.wav"),
                "skid" => new Sfx("audio/skid.wav"),
                "die" => new Sfx("audio/die.wav"),
                "save" => new Sfx("audio/save.wav"),
                "attack" => new Sfx("audio/attack.wav"),
                "flap1" => new Sfx("audio/flap1.wav"),
                "flap2" => new Sfx("audio/flap2.wav"),
                "flap3" => new Sfx("audio/flap3.wav")
            ];
        }
    }

    override public function update() {
        if(!isDead) {
            if(canMove) {
                movement();
                combat();
            }
            animation();
            collisions();
        }
        super.update();
    }

    private function collisions() {
        var checkpoint = collide("checkpoint", x, y);
        if(Main.inputPressed("down") && checkpoint != null) {
            cast(checkpoint, Checkpoint).flash();
            sfx["save"].play();
        }
        if(collide("hazard", x, y) != null) {
            die();
        }
        if(collide("enemy", x, y) != null) {
            die();
        }
        if(collide("endtrigger", x, y) != null && canMove) {
            canMove = false;
            stopSounds();
            cast(HXP.scene, GameScene).curtain.fadeIn(1);
            var fadeOut = new Alarm(1, function() {
                GameScene.stopAmbience();
                HXP.scene = new Ending();
            });
            addTween(fadeOut, true);
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
        GameScene.deathCount++;
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
        if(isOnGround()) {
            if(Main.inputCheck("left")) {
                velocity.x -= GROUND_ACCEL * HXP.elapsed;
            }
            else if(Main.inputCheck("right")) {
                velocity.x += GROUND_ACCEL * HXP.elapsed;
            }
            else {
                velocity.x = MathUtil.approach(velocity.x, 0, GROUND_DECEL * HXP.elapsed);
            }
            velocity.x = MathUtil.clamp(velocity.x, -MAX_SPEED_ON_GROUND, MAX_SPEED_ON_GROUND);
        }
        else {
            if(Main.inputCheck("left")) {
                velocity.x -= ACCEL * HXP.elapsed;
            }
            else if(Main.inputCheck("right")) {
                velocity.x += ACCEL * HXP.elapsed;
            }
            else {
                velocity.x = MathUtil.approach(velocity.x, 0, DECEL * HXP.elapsed);
            }
            velocity.x = MathUtil.clamp(velocity.x, -MAX_SPEED_IN_AIR, MAX_SPEED_IN_AIR);
        }

        velocity.y = MathUtil.clamp(velocity.y, -MAX_RISE_SPEED, MAX_FALL_SPEED);

        if(Main.inputPressed("jump")) {
            sprite.play("flap", true);
            if(isOnGround()) {
                sfx['flap1'].play();
                velocity.y = -FLAP_POWER * OFF_GROUND_FLAP_MULTIPLIER + velocity.y / 3;
            }
            else {
                sfx['flap3'].play();
                velocity.y = -FLAP_POWER + velocity.y / 3;
            }
            if(Main.inputCheck("left")) {
                velocity.x -= ACCEL * FLAP_ACCEL_MULTIPLIER * HXP.elapsed;
            }
            else if(Main.inputCheck("right")) {
                velocity.x += ACCEL * FLAP_ACCEL_MULTIPLIER * HXP.elapsed;
            }
        }
        velocity.y += GRAVITY * HXP.elapsed;
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
    }

    private function combat() {
        if(Main.inputPressed("attack")) {
            sword.attack();
        }
    }

    override public function moveCollideX(_:Entity) {
        return true;
    }

    override public function moveCollideY(_:Entity) {
        velocity.y = 0;
        return true;
    }

    private function animation() {
        if(isOnGround()) {
            if(velocity.x != 0) {
                sprite.play("run");
                if(!sfx["run"].playing) {
                    sfx["run"].loop();
                }
            }
            else {
                sprite.play("idle");
                sfx["run"].stop();
            }
        }
        else {
            sfx["run"].stop();
        }
        if(velocity.x > 0) {
            sprite.flipX = false;
        }
        else if(velocity.x < 0) {
            sprite.flipX = true;
        }
    }
}
