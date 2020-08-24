package scenes;

import entities.*;
import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import openfl.Assets;

class GameScene extends Scene
{
    public static inline var MAP_TILE_SIZE = 16;

    public static var currentCheckpoint:Vector2 = null;
    public static var totalTime:Float = 0;
    public static var deathCount:Float = 0;
    public static var sfx:Map<String, Sfx> = null;

    public var curtain(default, null):Curtain;
    private var level:Level;
    private var player:Player;

    override public function begin() {
        curtain = add(new Curtain());
        curtain.fadeOut(1);

        level = add(new Level("level"));
        for(entity in level.entities) {
            add(entity);
            if(entity.name == "player") {
                player = cast(entity, Player);
                add(player.sword);
                if(currentCheckpoint == null) {
                    currentCheckpoint = new Vector2(player.x, player.y);
                }
                else {
                    player.x = currentCheckpoint.x;
                    player.y = currentCheckpoint.y;
                }
            }
        }
        if(sfx == null) {
            sfx = [
                "restart" => new Sfx("audio/restart.wav")
            ];
        }
    }

    static public function stopAmbience() {
    }

    override public function update() {
        totalTime += HXP.elapsed;
        if(Main.inputPressed("restart")) {
            GameScene.currentCheckpoint = null;
            GameScene.totalTime = 0;
            GameScene.deathCount = 0;
            //stopAmbience();
            HXP.scene = new GameScene();
            sfx["restart"].play();
        }
        super.update();
        camera.setTo(
            Math.floor(player.centerX / 180) * HXP.width,
            Math.floor(player.centerY / 180) * HXP.height,
            0, 0
        );
    }
}
