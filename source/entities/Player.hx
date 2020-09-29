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
    public static inline var SPEED = 100;

    public static var sfx:Map<String, Sfx> = null;

    public var sprite(default, null):Spritemap;
    private var velocity:Vector2;
    private var isDead:Bool;
    private var canMove:Bool;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "player";
        sprite = new Spritemap("graphics/player.png", 10, 10);
        sprite.add("idle", [1]);
        sprite.play("idle");
        mask = new Hitbox(10, 10);
        graphic = sprite;
        velocity = new Vector2();
        isDead = false;
        canMove = false;
        var allowMove = new Alarm(0.3, function() {
            canMove = true;
        });
        addTween(allowMove, true);

        if(sfx == null) {
            sfx = [
                "die" => new Sfx("audio/die.wav"),
            ];
        }
    }

    override public function update() {
        if(!isDead) {
            if(canMove) {
                movement();
            }
            animation();
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
    }

    public function die() {
        visible = false;
        collidable = false;
        isDead = true;
        explode();
        stopSounds();
        sfx["die"].play();
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
        if(Main.inputCheck("left")) {
            velocity.x = -SPEED;
        }
        else if(Main.inputCheck("right")) {
            velocity.x = SPEED;
        }
        else {
            velocity.x = 0;
        }
        if(Main.inputCheck("up")) {
            velocity.y = -SPEED;
        }
        else if(Main.inputCheck("down")) {
            velocity.y = SPEED;
        }
        else {
            velocity.y = 0;
        }
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
    }

    override public function moveCollideX(_:Entity) {
        return true;
    }

    override public function moveCollideY(_:Entity) {
        return true;
    }

    private function animation() {
    }
}
