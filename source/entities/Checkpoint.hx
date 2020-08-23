package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.GameScene;

class Checkpoint extends MiniEntity
{
    public var sprite:Spritemap;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "checkpoint";
        sprite = new Spritemap("graphics/checkpoint.png", 8, 16);
        sprite.add("idle", [0, 4, 8, 12, 8, 4], 12);
        sprite.add("flash", [1, 5, 9], 18, false);
        sprite.play("idle");
        setHitbox(8, 16);
        graphic = sprite;

        layer = -104;
    }

    public override function update() {
        if(sprite.complete) {
            sprite.play("idle");
        }
        super.update();
    }

    public function flash() {
        sprite.play("flash");
        GameScene.currentCheckpoint = new Vector2(x + 1, y + 4);
    }
}
