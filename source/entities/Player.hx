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
    public static inline var THROW_POWER = 100;
    public static inline var JUMP_POWER = 160;
    public static inline var CROUCH_JUMP_POWER = 120;
    public static inline var JUMP_CANCEL_POWER = 40;
    public static inline var MAX_FALL_SPEED = 270;
    public static inline var RUN_SPEED_APPLIED_TO_JUMP_POWER = 1 / 6;
    public static inline var INVINCIBLE_TIME = 2;
    public static inline var MAX_HEALTH = 3;

    public static var sfx:Map<String, Sfx> = null;

    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var isDead:Bool;
    private var isCrouching:Bool;
    private var wasCrouching:Bool;
    private var canMove:Bool;
    private var hitbox:Hitbox;
    private var health:Int;
    private var invincibleTimer:Alarm;
    private var carriedItem:Item;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "player";
        type = "player";
        layer = -10;
        sprite = new Spritemap("graphics/player.png", 8, 12);
        sprite.add("idle", [0]);
        sprite.add("run", [1, 2, 3, 2], 8);
        sprite.add("jump", [4]);
        sprite.add("skid", [6]);
        sprite.add("crouch", [19]);
        sprite.add("idle_underwear", [10]);
        sprite.add("run_underwear", [11, 12, 13, 12], 8);
        sprite.add("jump_underwear", [14]);
        sprite.add("skid_underwear", [16]);
        sprite.add("crouch_underwear", [18]);
        sprite.add("idle_naked", [20]);
        sprite.add("run_naked", [21, 22, 23, 22], 8);
        sprite.add("jump_naked", [24]);
        sprite.add("skid_naked", [26]);
        sprite.add("crouch_naked", [17]);
        sprite.play("idle");
        hitbox = new Hitbox(6, 12);
        mask = hitbox;
        sprite.x = -1;
        sprite.flipX = false;
        graphic = sprite;
        velocity = new Vector2();
        isDead = false;
        isCrouching = false;
        wasCrouching = false;
        health = MAX_HEALTH;
        invincibleTimer = new Alarm(INVINCIBLE_TIME);
        addTween(invincibleTimer);
        carriedItem = null;
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
                "save" => new Sfx("audio/save.wav"),
                "takehit" => new Sfx("audio/takehit.wav")
            ];
        }
    }

    override public function update() {
        if(!isDead) {
            if(canMove) {
                movement();
            }
            if(Main.inputPressed("action")) {
                if(carriedItem != null) {
                    carriedItem.setCarrier(null);
                    var throwVelocity = new Vector2(sprite.flipX ? -THROW_POWER : THROW_POWER, -THROW_POWER);
                    throwVelocity.add(velocity);
                    carriedItem.setVelocity(throwVelocity);
                    carriedItem = null;
                }
                else {
                    var item = collide("item", x, y + 1);
                    if(item != null) {
                        carriedItem = cast(item, Item);
                        carriedItem.setCarrier(this);
                    }
                }
            }
            animation();
            if(canMove) {
                sound();
            }
            collisions();
        }
        super.update();
        wasCrouching = isCrouching;
    }

    private function collisions() {
        if(collide("hazard", x, y) != null) {
            takeHit();
        }
        if(collide("exit", x, y) != null) {
            collidable = false;
            cast(scene, GameScene).onExit();
        }
    }

    private function takeHit() {
        if(invincibleTimer.active) {
            return;
        }
        health -= 1;
        sfx["takehit"].play();
        animation();
        cast(scene, GameScene).pause(1);
        if(health == 0) {
            HXP.alarm(1, function() {
                die();
            });
        }
        else {
            tossClothes(health == 2 ? "dress" : "underwear");
        }
        invincibleTimer.start();
    }

    private function tossClothes(clothesName:String) {
        scene.add(new Clothes(this, clothesName));
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
        cast(scene, GameScene).onDeath();
    }

    private function movement() {
        isCrouching = Main.inputCheck("down");
        if(isCrouching && !wasCrouching) {
            hitbox = new Hitbox(6, 10);
            y += 2;
            sprite.y = -2;
            mask = hitbox;
        }
        else if(!isCrouching && wasCrouching) {
            hitbox = new Hitbox(6, 12);
            y -= 2;
            sprite.y = 0;
            mask = hitbox;
        }
        var accel:Float = isOnGround() ? RUN_ACCEL : AIR_ACCEL;
        if(
            isOnGround() && !isOnIce() && !isCrouching && (
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
        if(
            Main.inputCheck("left")
            && !isOnLeftWall()
            && !(isOnGround() && isCrouching)
        ) {
            velocity.x -= accel * HXP.elapsed;
        }
        else if(
            Main.inputCheck("right")
            && !isOnRightWall()
            && !(isOnGround() && isCrouching)
        ) {
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
                var jumpPower = isCrouching ? CROUCH_JUMP_POWER : JUMP_POWER;
                velocity.y = -(
                    jumpPower
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
        if(carriedItem != null) {
            carriedItem.collidable = false;
        }
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["walls", "item"]);
        if(carriedItem != null) {
            carriedItem.collidable = true;
            carriedItem.moveTo(Math.floor(centerX - carriedItem.width / 2), Math.floor(y - carriedItem.height));
        }
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
        var animationSuffix = "_naked";
        if(health == 3) {
            animationSuffix = "";
        }
        else if(health == 2) {
            animationSuffix = "_underwear";
        }
        if(invincibleTimer.active) {
            sprite.visible = Math.round(invincibleTimer.percent * 100) % 2 == 0;
        }
        else {
            sprite.visible = true;
        }
        if(!canMove) {
            if(isOnGround()) {
                sprite.play("idle" + animationSuffix);
            }
            else {
                sprite.play("jump" + animationSuffix);
            }
        }
        else if(isCrouching) {
            sprite.play("crouch" + animationSuffix);
        }
        else if(!isOnGround()) {
            sprite.play("jump" + animationSuffix);
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
                sprite.play("skid" + animationSuffix);
                if(!sfx["skid"].playing) {
                    sfx["skid"].play();
                }
            }
            else {
                sprite.play("run" + animationSuffix);
            }
            sprite.flipX = velocity.x < 0;
        }
        else {
            sprite.play("idle" + animationSuffix);
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
