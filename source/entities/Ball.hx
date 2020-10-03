package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Ball extends MiniEntity
{
    public static inline var SPEED = 100;

    private var sprite:Image;
    private var velocity:Vector2;

    public function new(x:Float, y:Float, heading:Vector2) {
        super(x, y);
        type = "hazard";
        sprite = new Image("graphics/ball.png");
        graphic = sprite;
        velocity = heading;
        velocity.normalize(SPEED);
        mask = new Circle(5);
    }

    override public function update() {
        if(collide("ballspewer", x, y) == null) {
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
        }
        else {
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed);
        }
        super.update();
    }

    override public function moveCollideX(_:Entity) {
        if(collide("ballspewer", x, y) == null) {
            scene.remove(this);
        }
        return true;
    }

    override public function moveCollideY(_:Entity) {
        if(collide("ballspewer", x, y) == null) {
            scene.remove(this);
        }
        return true;
    }
}
