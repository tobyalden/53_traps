package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class BallSpewer extends MiniEntity
{
    public static inline var SPEW_INTERVAL = 1;

    private var sprite:Image;
    private var activated:Bool;
    private var spewTimer:Alarm;
    private var spewLeft:Bool;
    private var velocity:Vector2;

    public function new(x:Float, y:Float, spewLeft:Bool) {
        super(x, y);
        type = "ballspewer";
        this.spewLeft = spewLeft;
        sprite = new Image("graphics/ballspewer.png");
        sprite.alpha = 0.5;
        graphic = sprite;
        velocity = new Vector2();
        mask = new Hitbox(10, 10);
        activated = false;
        spewTimer = new Alarm(SPEW_INTERVAL, TweenType.Looping);
        spewTimer.onComplete.bind(function() {
            spew();
        });
        addTween(spewTimer);
    }

    private function spew() {
        var heading = new Vector2(spewLeft ? -1 : 1, 0);
        var ball = new Ball(x, y, heading);
        scene.add(ball);
    }

    override public function update() {
        var player = scene.getInstance("player");
        if(scene.camera.x + HXP.width > x) {
            if(!activated) {
                spew();
                spewTimer.start();
            }
            activated = true;
        }
        super.update();
    }
}
