package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import openfl.Assets;

class Level extends Entity
{
    public static inline var TILE_SIZE = 4;

    private var walls:Grid;
    private var tiles:Tilemap;
    public var entities(default, null):Array<MiniEntity>;

    public function new(levelName:String) {
        super(0, 0);
        type = "walls";
        loadLevel(levelName);
        updateGraphic();
        mask = walls;
    }


    override public function update() {
        super.update();
    }

    private function loadLevel(levelName:String) {
        // Load solid geometry
        var xml = Xml.parse(Assets.getText('levels/${levelName}.oel'));
        var fastXml = new haxe.xml.Fast(xml.firstElement());
        var segmentWidth = Std.parseInt(fastXml.node.width.innerData);
        var segmentHeight = Std.parseInt(fastXml.node.height.innerData);
        walls = new Grid(segmentWidth, segmentHeight, TILE_SIZE, TILE_SIZE);
        for (r in fastXml.node.walls.nodes.rect) {
            walls.setRect(
                Std.int(Std.parseInt(r.att.x) / TILE_SIZE),
                Std.int(Std.parseInt(r.att.y) / TILE_SIZE),
                Std.int(Std.parseInt(r.att.w) / TILE_SIZE),
                Std.int(Std.parseInt(r.att.h) / TILE_SIZE)
            );
        }

        // Load entities
        entities = new Array<MiniEntity>();
        if(fastXml.hasNode.objects) {
            for(e in fastXml.node.objects.nodes.player) {
                var player = new Player(
                    Std.parseInt(e.att.x), Std.parseInt(e.att.y)
                );
                entities.push(player);
            }
            for(e in fastXml.node.objects.nodes.enemy) {
                var enemy = new Bat(
                    Std.parseInt(e.att.x), Std.parseInt(e.att.y)
                );
                entities.push(enemy);
            }
            for(e in fastXml.node.objects.nodes.spike_floor) {
                var spike = new Spike(
                    Std.parseInt(e.att.x), Std.parseInt(e.att.y),
                    Spike.FLOOR, Std.parseInt(e.att.width)
                );
                entities.push(spike);
            }
            for(e in fastXml.node.objects.nodes.spike_ceiling) {
                var spike = new Spike(
                    Std.parseInt(e.att.x), Std.parseInt(e.att.y),
                    Spike.CEILING, Std.parseInt(e.att.width)
                );
                entities.push(spike);
            }
            for(e in fastXml.node.objects.nodes.spike_leftwall) {
                var spike = new Spike(
                    Std.parseInt(e.att.x), Std.parseInt(e.att.y),
                    Spike.LEFT_WALL, Std.parseInt(e.att.height)
                );
                entities.push(spike);
            }
            for(e in fastXml.node.objects.nodes.spike_rightwall) {
                var spike = new Spike(
                    Std.parseInt(e.att.x), Std.parseInt(e.att.y),
                    Spike.RIGHT_WALL, Std.parseInt(e.att.height)
                );
                entities.push(spike);
            }
            for(e in fastXml.node.objects.nodes.checkpoint) {
                var checkpoint = new Checkpoint(
                    Std.parseInt(e.att.x), Std.parseInt(e.att.y)
                );
                entities.push(checkpoint);
            }
            for(e in fastXml.node.objects.nodes.endtrigger) {
                var endTrigger = new EndTrigger(
                    Std.parseInt(e.att.x), Std.parseInt(e.att.y),
                    Std.parseInt(e.att.width), Std.parseInt(e.att.height)
                );
                entities.push(endTrigger);
            }
        }
    }

    public function updateGraphic() {
        tiles = new Tilemap(
            'graphics/stone.png',
            walls.width, walls.height, walls.tileWidth, walls.tileHeight
        );
        for(tileX in 0...walls.columns) {
            for(tileY in 0...walls.rows) {
                if(walls.getTile(tileX, tileY)) {
                    tiles.setTile(tileX, tileY, tileX + tileY * walls.columns);
                }
            }
        }
        graphic = tiles;
    }
}

