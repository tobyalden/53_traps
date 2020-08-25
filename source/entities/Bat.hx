package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Bat extends MiniEntity
{
    public static inline var SPEED = 50;

    private var sprite:Spritemap;
    private var hitbox:Hitbox;
    private var isActive:Bool;
    private var velocity:Vector2;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "enemy";
        hitbox = new Hitbox(18, 15);
        mask = hitbox;
        sprite = new Spritemap("graphics/bat.png", 24, 24);
        sprite.add("idle", [0, 1, 2], 3);
        sprite.play("idle");
        sprite.x = -3;
        sprite.y = -3;
        graphic = sprite;
        isActive = false;
        velocity = new Vector2();
    }

    public function die() {
        scene.remove(this);
        explode(25);
        Player.sfx["die"].play(0.5);
    }

    override public function update() {
        if(collide("sword", x, y) != null) {
            die();
        }
        var player = scene.getInstance("player");
        if(getHeadingTowards(player).length < 100) {
            isActive = true;
        }
        if(isActive) {
            velocity = getHeadingTowards(player);
            velocity.normalize(SPEED);
            moveBy(
                velocity.x * HXP.elapsed, velocity.y * HXP.elapsed,
                ["walls", "enemy"]
            );
        }
        super.update();
    }
}


