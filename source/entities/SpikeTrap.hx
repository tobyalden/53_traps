package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class SpikeTrap extends MiniEntity
{
    public static inline var TRIGGER_DELAY = 0.25;
    public static inline var RETRACT_DELAY = 0.75;

    private var sprite:Image;
    //private var vanishTimer:Alarm;

    public function new(x:Float, y:Float) {
        super(x, y);
        //type = "walls";
        sprite = new Image("graphics/spiketrap.png");
        graphic = sprite;
        mask = new Hitbox(10, 10);
        //vanishTimer = new Alarm(VANISH_TIME, function() {
            //scene.remove(this);
        //});
        //addTween(vanishTimer);
    }

    override public function update() {
        var player = scene.getInstance("player");
    }
}
