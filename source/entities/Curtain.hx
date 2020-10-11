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

    public function new() {
        super(0, 0);
        sprite = new ColoredRect(HXP.width * 4, HXP.height * 4, 0x000000);
        sprite.alpha = 0;
        graphic = sprite;
        layer = -999;
    }

    override public function update() {
        x = scene.camera.x - HXP.width;
        y = scene.camera.y - HXP.height;
        super.update();
    }

    public function fadeOut() {
        sprite.alpha = 0;
    }

    public function fadeIn() {
        sprite.alpha = 1;
    }
}


