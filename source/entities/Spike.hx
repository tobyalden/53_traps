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
    public var length(default, null):Int;
    private var glow:VarTween;
    private var sprite:TiledImage;

    public function new(x:Float, y:Float, orientation:Int, length:Int)
    {
        super(x, y);
        this.orientation = orientation;
        this.length = length;
        type = "hazard";
        if(orientation == FLOOR) {
            sprite = new TiledImage("graphics/spike_floor.png", length, 5);
            setHitbox(length, 5);
        }
        else if(orientation == CEILING) {
            sprite = new TiledImage("graphics/spike_ceiling.png", length, 5);
            setHitbox(length, 5);
        }
        else if(orientation == LEFT_WALL) {
            sprite = new TiledImage("graphics/spike_leftwall.png", 5, length);
            setHitbox(5, length);
        }
        else { // RIGHT_WALL
            sprite = new TiledImage("graphics/spike_rightwall.png", 5, length);
            setHitbox(5, length);
        }
        sprite.alpha = 1;
        graphic = sprite;

        glow = new VarTween(TweenType.PingPong);
        addTween(glow);
        glow.tween(sprite, 'alpha', 0.8, 1, Ease.sineInOut);
    }
}
