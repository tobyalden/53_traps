package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Clothes extends MiniEntity
{
    public static inline var INITIAL_VELOCITY = 200;

    private var velocity:Vector2;

    public function new(source:Entity, spriteName:String) {
        super(source.centerX, source.centerY);
        var sprite = new Image('graphics/${spriteName}.png');
        sprite.centerOrigin();
        graphic = sprite;
        velocity = new Vector2(Math.random() > 0.1 ? -0.1 : 1, -1);
        velocity.normalize(INITIAL_VELOCITY);
    }

    override public function update() {
        velocity.y += Player.GRAVITY * HXP.elapsed;
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed);
        super.update();
    }
}
