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
    private var isAttacking:Bool;
    private var velocity:Vector2;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "hazard";
        hitbox = new Hitbox(18, 15);
        mask = hitbox;
        sprite = new Spritemap("graphics/bat.png", 24, 24);
        sprite.add("idle", [0, 1, 2], 3);
        sprite.play("idle");
        sprite.x = -3;
        sprite.y = -3;
        graphic = sprite;
        isAttacking = false;
        velocity = new Vector2();
    }

    public function attack() {
        if(isAttacking) {
            return;
        }
        isAttacking = true;
        Player.sfx["attack"].play();
        HXP.alarm(0.2, function() {
            isAttacking = false;
        });
    }

    override public function update() {
        var player = scene.getInstance("player");
        velocity = getHeadingTowards(player);
        velocity.normalize(SPEED);
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
        super.update();
    }
}


