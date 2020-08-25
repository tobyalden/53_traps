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
    public static inline var RUN_ACCEL = 2500;
    public static inline var RUN_ACCEL_TURN_MULTIPLIER = 2;
    public static inline var RUN_DECEL = RUN_ACCEL * RUN_ACCEL_TURN_MULTIPLIER;
    public static inline var AIR_ACCEL = 2000;
    public static inline var AIR_DECEL = AIR_ACCEL;
    public static inline var MAX_RUN_SPEED = 130;
    public static inline var MAX_AIR_SPEED = 140;
    public static inline var GRAVITY = 900;
    public static inline var GRAVITY_ON_WALL = 150;
    public static inline var JUMP_POWER = 250;
    public static inline var JUMP_CANCEL_POWER = JUMP_POWER / 2;
    public static inline var WALL_JUMP_POWER_X = 140;
    public static inline var WALL_JUMP_POWER_Y = 160;
    public static inline var WALL_STICKINESS = 1000;
    public static inline var MAX_FALL_SPEED = 1000;
    public static inline var MAX_FALL_SPEED_ON_WALL = 0;
    public static inline var WALL_CLIMB_ACCEL = 500;
    public static inline var WALL_DESCEND_ACCEL = 1000;
    public static inline var MAX_WALL_CLIMB_SPEED = 175;
    public static inline var MAX_WALL_DESCEND_SPEED = 200;

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
        var scaleFactor = 2;
        sprite = new Spritemap(
            "graphics/player.png", 8 * scaleFactor, 12 * scaleFactor
        );
        sprite.add("idle", [0]);
        sprite.add("run", [1, 2, 3, 2], 8);
        sprite.add("jump", [4]);
        sprite.add("wall", [5]);
        sprite.add("climb", [5, 7], 4);
        sprite.add("skid", [6]);
        sprite.play("idle");
        mask = new Hitbox(6 * scaleFactor, 12 * scaleFactor);
        sprite.x = -1 * scaleFactor;
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
                "attack" => new Sfx("audio/attack.wav")
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
            if(canMove) {
                sound();
            }
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
        var accel:Float = isOnGround() ? RUN_ACCEL : AIR_ACCEL;
        if(wallJumpCooldown.active) {
            accel *= wallJumpCooldown.percent;
        }
        if(
            isOnGround() && (
                Main.inputCheck("left") && velocity.x > 0
                || Main.inputCheck("right") && velocity.x < 0
            )
        ) {
            accel *= RUN_ACCEL_TURN_MULTIPLIER;
        }
        var decel:Float = isOnGround() ? RUN_DECEL : AIR_DECEL;
        if(wallJumpCooldown.active) {
            decel *= wallJumpCooldown.percent;
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
        var maxSpeed = isOnGround() ? MAX_RUN_SPEED : MAX_AIR_SPEED;
        velocity.x = MathUtil.clamp(velocity.x, -maxSpeed, maxSpeed);

        if(isOnGround()) {
            velocity.y = 0;
            if(Main.inputPressed("jump")) {
                velocity.y = -JUMP_POWER;
                sfx["jump"].play();
            }
        }
        else if(isOnWall()) {
            var gravity = velocity.y > 0 ? GRAVITY_ON_WALL : GRAVITY;
            if(!sword.canAttack()) {
                velocity.y = Math.max(0, velocity.y);
            }
            else if(Main.inputCheck("up") && velocity.y >= -MAX_WALL_CLIMB_SPEED) {
                velocity.y -= WALL_CLIMB_ACCEL * HXP.elapsed;
                velocity.y = MathUtil.clamp(
                    velocity.y, -MAX_WALL_CLIMB_SPEED, 0
                );
            }
            else if(Main.inputCheck("down")) {
                velocity.y += WALL_DESCEND_ACCEL * HXP.elapsed;
                velocity.y = Math.min(velocity.y, MAX_WALL_DESCEND_SPEED);
            }
            else {
                velocity.y += gravity * HXP.elapsed;
                velocity.y = Math.min(velocity.y, MAX_FALL_SPEED_ON_WALL);
            }
            if(Main.inputPressed("jump")) {
                velocity.y = -WALL_JUMP_POWER_Y;
                velocity.x = (
                    isOnLeftWall() ? WALL_JUMP_POWER_X : -WALL_JUMP_POWER_X
                );
                sfx["jump"].play();
                sprite.flipX = !sprite.flipX;
                wallJumpCooldown.start();
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

    private function combat() {
        if(Main.inputPressed("attack")) {
            sword.attack();
        }
    }

    override public function moveCollideX(_:Entity) {
        if(isOnGround()) {
            velocity.x = 0;
        }
        else if(isOnLeftWall()) {
            if(!Input.check("right")) {
                velocity.x = -WALL_STICKINESS;
            }
            velocity.x = Math.max(velocity.x, -WALL_STICKINESS);
        }
        else if(isOnRightWall()) {
            if(!Input.check("left")) {
                velocity.x = WALL_STICKINESS;
            }
            velocity.x = Math.min(velocity.x, WALL_STICKINESS);
        }
        return true;
    }

    override public function moveCollideY(_:Entity) {
        velocity.y = 0;
        return true;
    }

    private function animation() {
        if(!wallJumpCooldown.active && sword.canAttack()) {
            if(Input.check("left")) {
                sprite.flipX = true;
            }
            else if(Input.check("right")) {
                sprite.flipX = false;
            }
        }

        if(!canMove) {
            if(isOnGround()) {
                sprite.play("idle");
            }
            else {
                sprite.play("jump");
            }
        }
        else if(!isOnGround()) {
            if(isOnWall()) {
                if(velocity.y < 0) {
                    sprite.play("climb");
                }
                else {
                    sprite.play("wall");
                }
                sprite.flipX = isOnLeftWall();
            }
            else {
                sprite.play("jump");
            }
        }
        else if(velocity.x != 0) {
            if(
                velocity.x > 0 && Main.inputCheck("left")
                || velocity.x < 0 && Main.inputCheck("right")
            ) {
                sprite.play("skid");
                if(!sfx["skid"].playing) {
                    sfx["skid"].play();
                }
            }
            else {
                sprite.play("run");
            }
        }
        else {
            sprite.play("idle");
        }
    }

    private function sound() {
        if(isOnWall()) {
            if(!sfx["slide"].playing) {
                sfx["slide"].loop();
            }
            if(velocity.y > 0) {
                sfx["slide"].volume = velocity.y / MAX_WALL_DESCEND_SPEED;
            }
            else {
                sfx["slide"].volume = 0;
            }
        }
        else {
            sfx["slide"].stop();
        }
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
