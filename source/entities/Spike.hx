package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;

class Spike extends MiniEntity
{
    public static inline var FLOOR = 0;
    public static inline var CEILING = 1;
    public static inline var LEFT_WALL = 2;
    public static inline var RIGHT_WALL = 3;

    public var orientation(default, null):Int;
    private var glow:VarTween;

    public function new(x:Float, y:Float, orientation:Int, length:Int)
    {
        super(x, y);
        this.orientation = orientation;
        type = "hazard";
        var sprite:TiledImage;
        if(orientation == FLOOR) {
            sprite = new TiledImage("graphics/spike_floor.png", length, 4);
            setHitbox(length, 4);
        }
        else if(orientation == CEILING) {
            sprite = new TiledImage("graphics/spike_ceiling.png", length, 4);
            setHitbox(length, 4);
        }
        else if(orientation == LEFT_WALL) {
            sprite = new TiledImage("graphics/spike_leftwall.png", 4, length);
            setHitbox(4, length);
        }
        else { // RIGHT_WALL
            sprite = new TiledImage("graphics/spike_rightwall.png", 4, length);
            setHitbox(4, length);
        }
        sprite.alpha = 1;
        graphic = sprite;

        glow = new VarTween(TweenType.PingPong);
        addTween(glow);
        glow.tween(sprite, 'alpha', 0.8, 1, Ease.sineInOut);
    }
}
