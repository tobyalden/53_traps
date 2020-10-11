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
import haxepunk.utils.*;
import openfl.Assets;

class MainMenu extends Scene
{
    //public static inline var MAP_TILE_SIZE = 16;

    public static var sfx:Map<String, Sfx> = null;
    private var curtain:Curtain;
    private var message:Text;
    private var canMove:Bool;
    private var bob:VarTween;
    private var flasher:VarTween;

    override public function begin() {
        addGraphic(new Image("graphics/mainmenu.png"), 1);
        curtain = add(new Curtain());
        curtain.fadeOut();
        message = new Text(
            'Press Z or Space',
            0, HXP.height / 2, HXP.width, 0,
            {color: 0xFFFFFF, align: TextAlignType.CENTER, leading: 0}
        );
        message.font = "font/CompassGold.ttf";
        addGraphic(message);
        canMove = true;
        var allowMove = new Alarm(0.5, function() {
            canMove = true;
        });
        addTween(allowMove, true);
        bob = new VarTween(TweenType.PingPong);
        addTween(bob);
        bob.tween(message, 'y', HXP.height / 2 + 10, 1, Ease.sineInOut);
        flasher = new VarTween(TweenType.PingPong);
        addTween(flasher);
        if(sfx == null) {
            sfx = [
                "start" => new Sfx("audio/start.wav")
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
            curtain.fadeIn();
            flasher.tween(message, 'alpha', 0, 0.1, Ease.sineInOut);
            var reset = new Alarm(1, function() {
                GameScene.lives = 99;
                GameScene.floorNumber = 1;
                HXP.scene = new FloorTitle();
            });
            addTween(reset, true);
            sfx["start"].play(0.5);
        }
        super.update();
    }
}

