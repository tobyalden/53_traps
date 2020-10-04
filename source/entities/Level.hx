package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import openfl.Assets;

typedef TileCoordinates = {
    var tileX:Int;
    var tileY:Int;
    var level:Level;
}

class Level extends Entity
{
    public static inline var TILE_SIZE = 10;
    public static inline var MIN_LEVEL_WIDTH = 320;
    public static inline var MIN_LEVEL_HEIGHT = 180;
    public static inline var MIN_LEVEL_WIDTH_IN_TILES = 32;
    public static inline var MIN_LEVEL_HEIGHT_IN_TILES = 18;
    public static inline var NUMBER_OF_ROOMS = 1;
    public static inline var NUMBER_OF_HALLWAYS = 4;
    public static inline var NUMBER_OF_SHAFTS = 1;

    public var walls(default, null):Grid;
    public var entities(default, null):Array<MiniEntity>;
    public var openSpots(default, null):Map<String, Array<TileCoordinates>>;
    private var levelType:String;
    private var tiles:Tilemap;

    public function new(x:Int, y:Int, levelType:String) {
        super(x, y);
        layer = 10;
        this.levelType = levelType;
        type = "walls";
        if(levelType == "start") {
            loadLevel('0');
        }
        else if(levelType == "room") {
            loadLevel('${
                Std.int(Math.floor(Random.random * NUMBER_OF_ROOMS))
            }');
        }
        else if(levelType == "hallway") {
            loadLevel('${
                Std.int(Math.floor(Random.random * NUMBER_OF_HALLWAYS))
            }');
        }
        else {
            // levelType == "shaft"
            loadLevel('${
                Std.int(Math.floor(Random.random * NUMBER_OF_SHAFTS))
            }');
        }
        if(Random.random < 0.5 && levelType != "start") {
            //flipHorizontally(walls);
        }

        updateGraphic();
        mask = walls;
    }


    override public function update() {
        super.update();
    }

    public function flipHorizontally(wallsToFlip:Grid) {
        // TODO: Flip entities as well
        for(tileX in 0...Std.int(wallsToFlip.columns / 2)) {
            for(tileY in 0...wallsToFlip.rows) {
                var tempLeft:Null<Bool> = wallsToFlip.getTile(tileX, tileY);
                // For some reason getTile() returns null instead of false!
                if(tempLeft == null) {
                    tempLeft = false;
                }
                var tempRight:Null<Bool> = wallsToFlip.getTile(
                    wallsToFlip.columns - tileX - 1, tileY
                );
                if(tempRight == null) {
                    tempRight = false;
                }
                wallsToFlip.setTile(tileX, tileY, tempRight);
                wallsToFlip.setTile(
                    wallsToFlip.columns - tileX - 1, tileY, tempLeft
                );
            }
        }
    }

    private function loadLevel(levelName:String) {
        // Load solid geometry
        var xml = Xml.parse(Assets.getText(
            'levels/${levelType}/${levelName}.oel'
        ));
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

        // Load optional geometry
        if(fastXml.hasNode.optionalWalls) {
            for (r in fastXml.node.optionalWalls.nodes.rect) {
                if(Random.random < 0.5) {
                    continue;
                }
                walls.setRect(
                    Std.int(Std.parseInt(r.att.x) / TILE_SIZE),
                    Std.int(Std.parseInt(r.att.y) / TILE_SIZE),
                    Std.int(Std.parseInt(r.att.w) / TILE_SIZE),
                    Std.int(Std.parseInt(r.att.h) / TILE_SIZE)
                );
            }
        }

        // Load player
        entities = new Array<MiniEntity>();
        if(fastXml.hasNode.objects) {
            for(e in fastXml.node.objects.nodes.player) {
                var player = new Player(
                    Std.parseInt(e.att.x), Std.parseInt(e.att.y) + 8
                );
                entities.push(player);
                break;
            }
        }

        // Create open spots
        openSpots = [
            "edges" => new Array<TileCoordinates>(),
            "on_ceiling" => new Array<TileCoordinates>(),
            "on_floor" => new Array<TileCoordinates>(),
            "on_floor_with_headroom" => new Array<TileCoordinates>(),
            "in_floor" => new Array<TileCoordinates>(),
            "near_center" => new Array<TileCoordinates>(),
            "walls" => new Array<TileCoordinates>()
        ];
        if(levelType == "start") {
            return;
        }
        for(tileX in 0...walls.columns) {
            for(tileY in 0...walls.rows) {
                if(
                    walls.getTile(tileX, tileY)
                    && tileY != 0
                    && tileY != walls.rows - 1
                    && (
                        !walls.getTile(tileX - 1, tileY, true)
                        || !walls.getTile(tileX + 1, tileY, true)
                        || !walls.getTile(tileX, tileY - 1, true)
                        || !walls.getTile(tileX, tileY + 1, true)
                    )
                ) {
                    openSpots["edges"].push({tileX: tileX, tileY: tileY, level: this});
                }
                if(
                    !walls.getTile(tileX, tileY)
                    && walls.getTile(tileX, tileY - 1, true)
                    && !walls.getTile(tileX, tileY + 1, true)
                    && !walls.getTile(tileX, tileY + 2, true)
                    && tileY != 0
                ) {
                    openSpots["on_ceiling"].push({tileX: tileX, tileY: tileY, level: this});
                }
                if(
                    !walls.getTile(tileX, tileY)
                    && !walls.getTile(tileX - 1, tileY)
                    && !walls.getTile(tileX + 1, tileY)
                    && walls.getTile(tileX, tileY + 1)
                    && walls.getTile(tileX - 1, tileY + 1)
                    && walls.getTile(tileX + 1, tileY + 1)
                ) {
                    openSpots["on_floor"].push({tileX: tileX, tileY: tileY, level: this});
                }
                if(
                    !walls.getTile(tileX, tileY)
                    && !walls.getTile(tileX - 1, tileY)
                    && !walls.getTile(tileX + 1, tileY)
                    && walls.getTile(tileX, tileY + 1)
                    && walls.getTile(tileX - 1, tileY + 1)
                    && walls.getTile(tileX + 1, tileY + 1)
                    && !walls.getTile(tileX, tileY - 1)
                    && !walls.getTile(tileX, tileY - 2)
                    && !walls.getTile(tileX, tileY - 3)
                    && !walls.getTile(tileX, tileY - 4)
                    && !walls.getTile(tileX, tileY - 5)
                ) {
                    openSpots["on_floor_with_headroom"].push({tileX: tileX, tileY: tileY, level: this});
                }
                if(
                    walls.getTile(tileX, tileY)
                    && !walls.getTile(tileX, tileY - 1, true)
                ) {
                    openSpots["in_floor"].push({tileX: tileX, tileY: tileY, level: this});
                }
                var centerRadius = 3;
                if(
                    tileY > centerRadius
                    && tileY < walls.rows - centerRadius - 1
                ) {
                    openSpots["near_center"].push({tileX: tileX, tileY: tileY, level: this});
                }
                if(
                    walls.getTile(tileX, tileY)
                    && walls.getTile(tileX, tileY + 1)
                    && (
                        !walls.getTile(tileX - 1, tileY, true)
                        //&& !walls.getTile(tileX - 1, tileY + 1, true)
                        || !walls.getTile(tileX + 1, tileY, true)
                        //&& !walls.getTile(tileX + 1, tileY + 1, true)
                    )
                ) {
                    openSpots["walls"].push({tileX: tileX, tileY: tileY, level: this});
                }
            }
        }
    }

    public function fillLeft(offsetY:Int) {
        for(tileY in 0...MIN_LEVEL_HEIGHT_IN_TILES) {
            walls.setTile(0, tileY + offsetY * MIN_LEVEL_HEIGHT_IN_TILES);
        }
    }

    public function fillRight(offsetY:Int) {
        for(tileY in 0...MIN_LEVEL_HEIGHT_IN_TILES) {
            walls.setTile(
                walls.columns - 1,
                tileY + offsetY * MIN_LEVEL_HEIGHT_IN_TILES
            );
        }
    }

    public function fillTop(offsetX:Int) {
        for(tileX in 0...MIN_LEVEL_WIDTH_IN_TILES) {
            walls.setTile(tileX + offsetX * MIN_LEVEL_WIDTH_IN_TILES, 0);
        }
    }

    public function fillBottom(offsetX:Int) {
        for(tileX in 0...MIN_LEVEL_WIDTH_IN_TILES) {
            walls.setTile(
                tileX + offsetX * MIN_LEVEL_WIDTH_IN_TILES,
                walls.rows - 1
            );
        }
    }

    private function hasOpenSpot(spotType, tileX, tileY) {
        for(openSpot in openSpots[spotType]) {
            if(openSpot.tileX == tileX && openSpot.tileY == tileY) {
                return true;
            }
        }
        return false;
    }

    public function updateGraphic() {
        tiles = new Tilemap(
            'graphics/stone.png',
            walls.width, walls.height, walls.tileWidth, walls.tileHeight
        );
        for(tileX in 0...walls.columns) {
            for(tileY in 0...walls.rows) {
                if(walls.getTile(tileX, tileY)) {
                    tiles.setTile(tileX, tileY, 0);
                }
                //if(hasOpenSpot("on_floor", tileX, tileY)) {
                    //tiles.setTile(tileX, tileY, 1);
                //}
            }
        }
        graphic = tiles;
    }
}

