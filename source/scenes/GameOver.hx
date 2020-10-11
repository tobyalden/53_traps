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

class GameOver extends Scene
{
    public static var sfx:Map<String, Sfx> = null;
    private var curtain:Curtain;
    private var isWin:Bool;

    public function new(isWin:Bool = false) {
        super();
        this.isWin = isWin;
    }

    override public function begin() {
        curtain = add(new Curtain());
        var message = new Text(
            isWin ? 'YOU WIN THE GAME' : 'GAME OVER',
            0, HXP.height / 2 - 10, HXP.width, 0,
            {color: 0xFFFFFF, align: TextAlignType.CENTER, leading: 0}
        );
        message.font = "font/CompassGold.ttf";
        addGraphic(message);
        if(sfx == null) {
            sfx = [
                "start" => new Sfx("audio/start.wav")
            ];
        }
        HXP.alarm(isWin ? 4 : 2, function() {
            curtain.fadeIn();
            HXP.alarm(0.5, function() {
                HXP.scene = new MainMenu();
            });
        });
    }

    override public function update() {
        super.update();
    }
}

