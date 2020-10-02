package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class SpikeBall extends MiniEntity
{
    //private var sprite:Image;
    private var startPoint:Vector2;
    private var age:Float;
    private var radius:Int;
    private var orbitRadius:Int;
    private var orbitSpeed:Int;

    public function new(startPoint:Vector2) {
        super(0, 0);
        this.startPoint = startPoint;
        type = "hazard";
        //sprite = new Image("graphics/orb.png");
        //graphic = sprite;
        age = Math.random() * Math.PI * 2;
        //radius = 6 + Random.randInt(3);
        //orbitRadius = 25 + Random.randInt(25);
        //orbitSpeed = 2 + Random.randInt(4);
        radius = 7;
        orbitRadius = HXP.choose(30, 50);
        orbitSpeed = HXP.choose(3, -3);
        var hitbox = new Circle(radius);
        mask = hitbox;
    }

    override public function update() {
        age += HXP.elapsed;
        var orbitAxis = new Vector2(
            startPoint.x - radius, startPoint.y - radius
        );
        var orbitArm = new Vector2(orbitRadius, 0);
        orbitArm.rotate(age * orbitSpeed);
        moveTo(orbitAxis.x + orbitArm.x, orbitAxis.y + orbitArm.y);
    }

    override public function render(camera:Camera) {
        super.render(camera);
        Draw.lineThickness = 2;
        Draw.setColor(0xFFFFFF);
        Draw.line(
            x + radius - scene.camera.x, y + radius - scene.camera.y,
            startPoint.x - scene.camera.x, startPoint.y - scene.camera.y
        );
        Draw.setColor(0xFF0000);
        Draw.circleFilled(x + radius - scene.camera.x, y + radius - scene.camera.y, radius);
    }
}



