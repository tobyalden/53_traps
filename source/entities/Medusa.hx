package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Medusa extends MiniEntity
{
    public static inline var HORIZONTAL_SPEED = 75;
    public static inline var SINE_WAVE_SPEED = 3;
    public static inline var SINE_WAVE_SIZE = 35;

    private var sprite:Image;
    private var age:Float;
    private var startY:Float;

    public function new(x:Float, y:Float) {
        super(x, y);
        layer = -5;
        type = "hazard";
        sprite = new Image("graphics/medusa.png");
        graphic = sprite;
        mask = new Hitbox(15, 15);
        age = Math.random() * Math.PI * 2;
        startY = y;
    }

    override public function update() {
        age += HXP.elapsed;
        y = startY + Math.cos(age * SINE_WAVE_SPEED) * SINE_WAVE_SIZE;
        moveBy(-HORIZONTAL_SPEED * HXP.elapsed, 0);
        super.update();
    }
}

