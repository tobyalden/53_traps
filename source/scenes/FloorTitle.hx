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

class FloorTitle extends Scene
{
    public static var sfx:Map<String, Sfx> = null;
    private var curtain:Curtain;

    override public function begin() {
        curtain = add(new Curtain());
        var playerIcon = new Image("graphics/player_icon.png");
        addGraphic(playerIcon, 0, HXP.width / 2 - 30, HXP.height / 2 - 9);
        var message = new Text(
            'x ${GameScene.lives}',
            0, HXP.height / 2 - 10, HXP.width, 0,
            {color: 0xFFFFFF, align: TextAlignType.CENTER, leading: 0}
        );
        message.font = "font/CompassGold.ttf";
        addGraphic(message);
        var message2 = new Text(
            'FLOOR ${GameScene.floorNumber}',
            -7, HXP.height / 2 - 50, HXP.width, 0,
            {color: 0xFFFFFF, align: TextAlignType.CENTER, leading: 0}
        );
        message2.font = "font/CompassGold.ttf";
        addGraphic(message2);
        if(sfx == null) {
            sfx = [
                "start" => new Sfx("audio/start.wav")
            ];
        }
        HXP.alarm(2, function() {
            curtain.fadeIn();
            HXP.alarm(0.5, function() {
                HXP.scene = new GameScene();
            });
        });
    }

    override public function update() {
        super.update();
    }
}
