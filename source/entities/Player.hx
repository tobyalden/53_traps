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
    public static inline var RUN_ACCEL = 99999;
    public static inline var RUN_ACCEL_TURN_MULTIPLIER = 2;
    public static inline var RUN_DECEL = RUN_ACCEL * RUN_ACCEL_TURN_MULTIPLIER;
    public static inline var AIR_ACCEL = 250;
    public static inline var AIR_DECEL = AIR_ACCEL;
    public static inline var MAX_RUN_SPEED = 120;
    public static inline var MAX_AIR_SPEED = 130;
    public static inline var GRAVITY = 800;
    public static inline var GRAVITY_ON_WALL = 150;
    public static inline var JUMP_POWER = 250;
    public static inline var JUMP_CANCEL_POWER = JUMP_POWER;
    public static inline var WALL_JUMP_POWER_X = 130 / 1.1;
    public static inline var WALL_JUMP_POWER_Y = 130 / 1.1;
    public static inline var WALL_STICKINESS = 60;
    public static inline var MAX_FALL_SPEED = 999;
    public static inline var MAX_FALL_SPEED_ON_WALL = 200;

    public static var sfx:Map<String, Sfx> = null;

    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var isDead:Bool;
    private var canMove:Bool;

    public function new(x:Float, y:Float) {
        super(x, y);
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
        sprite.add("skid", [6]);
        sprite.play("idle");
        mask = new Hitbox(6 * scaleFactor, 12 * scaleFactor);
        sprite.x = -1;
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
        var checkpoint = collide("checkpoint", x, y);
        if(Main.inputPressed("down") && checkpoint != null) {
            cast(checkpoint, Checkpoint).flash();
            sfx["save"].play();
        }
        if(collide("hazard", x, y) != null) {
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
        var accel = isOnGround() ? RUN_ACCEL : AIR_ACCEL;
        if(
            isOnGround() && (
                Main.inputCheck("left") && velocity.x > 0
                || Main.inputCheck("right") && velocity.x < 0
            )
        ) {
            accel *= RUN_ACCEL_TURN_MULTIPLIER;
        }
        var decel = isOnGround() ? RUN_DECEL : AIR_DECEL;
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
            velocity.y += gravity * HXP.elapsed;
            velocity.y = Math.min(velocity.y, MAX_FALL_SPEED_ON_WALL);
            if(Main.inputPressed("jump")) {
                velocity.y = -WALL_JUMP_POWER_Y;
                velocity.x = (
                    isOnLeftWall() ? WALL_JUMP_POWER_X : -WALL_JUMP_POWER_X
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
        if(isOnGround()) {
            velocity.x = 0;
        }
        else if(isOnLeftWall()) {
            velocity.x = Math.max(velocity.x, -WALL_STICKINESS);
        }
        else if(isOnRightWall()) {
            velocity.x = Math.min(velocity.x, WALL_STICKINESS);
        }
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
            if(isOnWall()) {
                sprite.play("wall");
                sprite.flipX = isOnLeftWall();
            }
            else {
                sprite.play("jump");
                if(velocity.x < 0) {
                    sprite.flipX = true;
                }
                else if(velocity.x > 0) {
                    sprite.flipX = false;
                }
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
            sprite.flipX = velocity.x < 0;
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
            sfx["slide"].volume = Math.abs(velocity.y) / MAX_FALL_SPEED_ON_WALL;
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

    private function explode() {
        var numExplosions = 50;
        var directions = new Array<Vector2>();
        for(i in 0...numExplosions) {
            var angle = (2/numExplosions) * i;
            directions.push(new Vector2(Math.cos(angle), Math.sin(angle)));
            directions.push(new Vector2(-Math.cos(angle), Math.sin(angle)));
            directions.push(new Vector2(Math.cos(angle), -Math.sin(angle)));
            directions.push(new Vector2(-Math.cos(angle), -Math.sin(angle)));
        }
        var count = 0;
        for(direction in directions) {
            direction.scale(0.8 * Math.random());
            direction.normalize(
                Math.max(0.1 + 0.2 * Math.random(), direction.length)
            );
            var explosion = new Particle(
                centerX, centerY, directions[count], 1, 1
            );
            explosion.layer = -99;
            scene.add(explosion);
            count++;
        }

#if desktop
        Sys.sleep(0.02);
#end
        scene.camera.shake(1, 4);
    }
}
