package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Lava extends MiniEntity
{
    public function new(x:Float, y:Float, width:Int, height:Int) {
        super(x, y);
        layer = -20;
        type = "lava";
        var sprite = new TiledImage('graphics/lava.png', width, height);
        graphic = sprite;
        mask = new Hitbox(width, height);
    }
}

