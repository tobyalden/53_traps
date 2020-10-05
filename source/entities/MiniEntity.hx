package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;

class MiniEntity extends Entity
{
    public function new(x:Float, y:Float) {
        super(x, y);
    }

    private function isOnGround() {
        return collide("walls", x, y + 1) != null;
    }

    private function isOnIce() {
        return collide("ice", x, y + 1) != null;
    }

    private function isOnCeiling() {
        return collide("walls", x, y - 1) != null;
    }

    private function isOnWall() {
        return isOnRightWall() || isOnLeftWall();
    }

    private function isOnRightWall() {
        return collide("walls", x + 1, y) != null;
    }

    private function isOnLeftWall() {
        return collide("walls", x - 1, y) != null;
    }

    private function getHeadingTowards(e:Entity) {
        return new Vector2(e.centerX - centerX, e.centerY - centerY);
    }

    private function explode(numExplosions:Int = 50) {
        var directions = new Array<Vector2>();
        for(i in 0...numExplosions) {
            var angle = (2/numExplosions) * i;
            directions.push(new Vector2(Math.cos(angle), Math.sin(angle)));
            directions.push(new Vector2(-Math.cos(angle), Math.sin(angle)));
            directions.push(new Vector2(Math.cos(angle), -Math.sin(angle)));
            directions.push(new Vector2(-Math.cos(angle), -Math.sin(angle)));
        }
        var count = 0;
        for(direction in directions) {
            direction.scale(0.8 * Random.random);
            direction.normalize(
                Math.max(0.1 + 0.2 * Random.random, direction.length)
            );
            var explosion = new Particle(
                centerX, centerY, directions[count], 1, 1
            );
            explosion.layer = -99;
            scene.add(explosion);
            count++;
        }

#if desktop
        Sys.sleep(0.02);
#end
        scene.camera.shake(1, 4);
    }
}
