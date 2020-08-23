package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Curtain extends MiniEntity
{
    static public var sprite:ColoredRect;
    private var fader:VarTween;

    public function new() {
        super(0, 0);
        sprite = new ColoredRect(180, 180, 0x000000);
        graphic = sprite;
        layer = -999;
        fader = new VarTween();
        addTween(fader);
    }

    override public function update() {
        followCamera = scene.camera;
        super.update();
    }

    public function fadeOut(fadeTime:Float) {
        //fader.tween(sprite, "alpha", 0, fadeTime, Ease.sineOut);
        fader.tween(sprite, "alpha", 0, fadeTime);
    }

    public function fadeIn(fadeTime:Float) {
        //fader.tween(sprite, "alpha", 1, fadeTime, Ease.sineIn);
        fader.tween(sprite, "alpha", 1, fadeTime);
    }
}


