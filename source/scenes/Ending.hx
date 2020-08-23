package scenes;

import entities.*;
import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.text.*;
import haxepunk.graphics.text.TextAlignType;
import haxepunk.graphics.tile.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import openfl.Assets;

class Ending extends Scene
{
    //public static inline var MAP_TILE_SIZE = 16;

    public static var sfx:Map<String, Sfx> = null;
    private var curtain:Curtain;
    private var message:Text;
    private var canMove:Bool;

    override public function begin() {
        addGraphic(new Image("graphics/ending.png"), 1);
        curtain = add(new Curtain());
        curtain.fadeOut(1);
        var totalTime = timeRound(GameScene.totalTime);
        var deathText = "deaths";
        if(GameScene.deathCount == 1) {
            deathText = "death";
        }
        message = new Text(
            'END\n\n${totalTime} seconds\n${GameScene.deathCount} ${deathText}',
            0, 10, 180, 180,
            {color: 0x000000, align: TextAlignType.CENTER, leading: 0}
        );
        addGraphic(message);
        canMove = false;
        var allowMove = new Alarm(0.25, function() {
            canMove = true;
        });
        addTween(allowMove, true);
        if(sfx == null) {
            sfx = [
                "exitending" => new Sfx("audio/exitending.wav")
            ];
        }
    }

    private function timeRound(number:Float, precision:Int = 2) {
        number *= Math.pow(10, precision);
        return Math.round(number) / Math.pow(10, precision);
    }

    override public function update() {
        if(canMove && Main.inputPressed("jump")) {
            canMove = false;
            curtain.fadeIn(1);
            var reset = new Alarm(1, function() {
                HXP.scene = new MainMenu();
            });
            addTween(reset, true);
            sfx["exitending"].play();
        }
        super.update();
    }
}
