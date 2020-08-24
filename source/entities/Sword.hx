package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Sword extends MiniEntity
{
    public static inline var ATTACK_COOLDOWN = 0.1;

    private var isAttacking:Bool;
    private var sprite:Image;
    private var player:Player;
    private var hitbox:Hitbox;
    private var attackCooldown:Alarm;

    public function new(player:Player) {
        super(0, 0);
        this.player = player;
        type = "sword";
        hitbox = new Hitbox(26, 28);
        mask = hitbox;
        sprite = new Image("graphics/sword.png");
        graphic = sprite;
        isAttacking = false;
        attackCooldown = new Alarm(ATTACK_COOLDOWN);
        addTween(attackCooldown);
    }

    public function canAttack() {
         return !isAttacking && !attackCooldown.active;
    }

    public function attack() {
        if(!canAttack()) {
            return;
        }
        isAttacking = true;
        Player.sfx["attack"].play();
        HXP.alarm(0.2, function() {
            isAttacking = false;
            attackCooldown.start();
        });
    }

    override public function update() {
        sprite.visible = isAttacking;
        collidable = isAttacking;
        if(!isAttacking) {
            sprite.flipX = player.sprite.flipX;
            if(player.isOnWall()) {
                sprite.flipX = !sprite.flipX;
            }
        }
        moveTo(player.x + (sprite.flipX ? -19 : 0), player.y - 4);
        hitbox.x = sprite.flipX ? 0 : 7;
        super.update();
    }
}

