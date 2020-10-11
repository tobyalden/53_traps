package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Exit extends MiniEntity
{
    public static inline var INITIAL_VELOCITY = 200;

    private var velocity:Vector2;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "exit";
        var sprite = new Image('graphics/exit.png');
        graphic = sprite;
        mask = new Hitbox(50, 50);
    }
}
