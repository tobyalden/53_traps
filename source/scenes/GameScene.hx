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
    public static inline var NUMBER_OF_TRAPS = 53;

    public static var currentCheckpoint:Vector2 = null;
    public static var sfx:Map<String, Sfx> = null;

    public var curtain(default, null):Curtain;
    private var roomMapBlueprint:Grid;
    private var hallwayMapBlueprint:Grid;
    private var shaftMapBlueprint:Grid;
    private var allBlueprint:Grid;
    private var map:Grid;
    private var allLevels:Array<Level>;
    private var player:Player;

    override public function begin() {
        curtain = add(new Curtain());
        curtain.fadeOut(1);
        loadMaps(0);
        placeLevels();
        if(sfx == null) {
            sfx = [
                "restart" => new Sfx("audio/restart.wav")
            ];
        }
    }

    static public function stopAmbience() {
    }

    override public function update() {
        if(Main.inputPressed("restart")) {
            GameScene.currentCheckpoint = null;
            //stopAmbience();
            HXP.scene = new GameScene();
            sfx["restart"].play();
        }
        super.update();
        camera.setTo(player.centerX - HXP.width / 3, 0);
        //camera.setTo(
            //Math.floor(player.centerX / HXP.width) * HXP.width,
            //Math.floor(player.centerY / HXP.height) * HXP.height,
            //0, 0
        //);
    }

    private function loadMaps(mapNumber:Int) {
        var mapPath = 'maps/${'test'}.oel';
        var xml = Xml.parse(Assets.getText(mapPath));
        var fastXml = new haxe.xml.Fast(xml.firstElement());
        var mapWidth = Std.parseInt(fastXml.node.width.innerData);
        var mapHeight = Std.parseInt(fastXml.node.height.innerData);
        map = new Grid(mapWidth, mapHeight, MAP_TILE_SIZE, MAP_TILE_SIZE);
        roomMapBlueprint = new Grid(
            mapWidth, mapHeight, MAP_TILE_SIZE, MAP_TILE_SIZE
        );
        hallwayMapBlueprint = new Grid(
            mapWidth, mapHeight, MAP_TILE_SIZE, MAP_TILE_SIZE
        );
        shaftMapBlueprint = new Grid(
            mapWidth, mapHeight, MAP_TILE_SIZE, MAP_TILE_SIZE
        );
        allBlueprint = new Grid(
            mapWidth, mapHeight, MAP_TILE_SIZE, MAP_TILE_SIZE
        );
        if(fastXml.hasNode.rooms) {
            for (r in fastXml.node.rooms.nodes.rect) {
                roomMapBlueprint.setRect(
                    Std.int(Std.parseInt(r.att.x) / MAP_TILE_SIZE),
                    Std.int(Std.parseInt(r.att.y) / MAP_TILE_SIZE),
                    Std.int(Std.parseInt(r.att.w) / MAP_TILE_SIZE),
                    Std.int(Std.parseInt(r.att.h) / MAP_TILE_SIZE)
                );
                allBlueprint.setRect(
                    Std.int(Std.parseInt(r.att.x) / MAP_TILE_SIZE),
                    Std.int(Std.parseInt(r.att.y) / MAP_TILE_SIZE),
                    Std.int(Std.parseInt(r.att.w) / MAP_TILE_SIZE),
                    Std.int(Std.parseInt(r.att.h) / MAP_TILE_SIZE)
                );
            }
        }
        if(fastXml.hasNode.hallways) {
            for (r in fastXml.node.hallways.nodes.rect) {
                hallwayMapBlueprint.setRect(
                    Std.int(Std.parseInt(r.att.x) / MAP_TILE_SIZE),
                    Std.int(Std.parseInt(r.att.y) / MAP_TILE_SIZE),
                    Std.int(Std.parseInt(r.att.w) / MAP_TILE_SIZE),
                    Std.int(Std.parseInt(r.att.h) / MAP_TILE_SIZE)
                );
                allBlueprint.setRect(
                    Std.int(Std.parseInt(r.att.x) / MAP_TILE_SIZE),
                    Std.int(Std.parseInt(r.att.y) / MAP_TILE_SIZE),
                    Std.int(Std.parseInt(r.att.w) / MAP_TILE_SIZE),
                    Std.int(Std.parseInt(r.att.h) / MAP_TILE_SIZE)
                );
            }
        }
        if(fastXml.hasNode.shafts) {
            for (r in fastXml.node.shafts.nodes.rect) {
                shaftMapBlueprint.setRect(
                    Std.int(Std.parseInt(r.att.x) / MAP_TILE_SIZE),
                    Std.int(Std.parseInt(r.att.y) / MAP_TILE_SIZE),
                    Std.int(Std.parseInt(r.att.w) / MAP_TILE_SIZE),
                    Std.int(Std.parseInt(r.att.h) / MAP_TILE_SIZE)
                );
                allBlueprint.setRect(
                    Std.int(Std.parseInt(r.att.x) / MAP_TILE_SIZE),
                    Std.int(Std.parseInt(r.att.y) / MAP_TILE_SIZE),
                    Std.int(Std.parseInt(r.att.w) / MAP_TILE_SIZE),
                    Std.int(Std.parseInt(r.att.h) / MAP_TILE_SIZE)
                );
            }
        }
    }

    private function sealLevel(
        level:Level, tileX:Int, tileY:Int, checkX:Int, checkY:Int
    ) {
        if(
            !roomMapBlueprint.getTile(tileX + checkX - 1, tileY + checkY)
            && !hallwayMapBlueprint.getTile(tileX + checkX - 1, tileY + checkY)
        ) {
            level.fillLeft(checkY);
        }
        if(
            !roomMapBlueprint.getTile(tileX + checkX + 1, tileY + checkY)
            && !hallwayMapBlueprint.getTile(tileX + checkX + 1, tileY + checkY)
        ) {
            level.fillRight(checkY);
        }
        if(
            !roomMapBlueprint.getTile(tileX + checkX, tileY + checkY - 1)
            && !shaftMapBlueprint.getTile(tileX + checkX, tileY + checkY - 1)
        ) {
            level.fillTop(checkX);
        }
        if(
            !roomMapBlueprint.getTile(tileX + checkX, tileY + checkY + 1)
            && !shaftMapBlueprint.getTile(tileX + checkX, tileY + checkY + 1)
        ) {
            level.fillBottom(checkX);
        }
    }

    private function placeLevels() {
        var placedStart = false;
        allLevels = new Array<Level>();
        var levelTypes = ["room", "hallway", "shaft"];
        var count = 0;
        for(mapBlueprint in [
            roomMapBlueprint, hallwayMapBlueprint, shaftMapBlueprint
        ]) {
            for(tileX in 0...mapBlueprint.columns) {
                for(tileY in 0...mapBlueprint.rows) {
                    if(
                        mapBlueprint.getTile(tileX, tileY)
                        && !map.getTile(tileX, tileY)
                    ) {
                        var canPlace = false;
                        while(!canPlace) {
                            var levelType = levelTypes[count];
                            if(count == 0 && !placedStart) {
                                levelType = "start";
                                placedStart = true;
                            }
                            var level = new Level(
                                tileX * Level.MIN_LEVEL_WIDTH,
                                tileY * Level.MIN_LEVEL_HEIGHT,
                                levelType
                            );
                            var levelWidth = Std.int(
                                level.width / Level.MIN_LEVEL_WIDTH
                            );
                            var levelHeight = Std.int(
                                level.height / Level.MIN_LEVEL_HEIGHT
                            );
                            canPlace = true;
                            for(checkX in 0...levelWidth) {
                                for(checkY in 0...levelHeight) {
                                    if(
                                        map.getTile(
                                            tileX + checkX, tileY + checkY
                                        )
                                        || !mapBlueprint.getTile(
                                            tileX + checkX, tileY + checkY
                                        )
                                    ) {
                                        canPlace = false;
                                    }
                                }
                            }
                            if(canPlace) {
                                for(checkX in 0...levelWidth) {
                                    for(checkY in 0...levelHeight) {
                                        map.setTile(
                                            tileX + checkX, tileY + checkY
                                        );
                                        //sealLevel(
                                            //level,
                                            //tileX, tileY,
                                            //checkX, checkY
                                        //);
                                    }
                                }
                                level.updateGraphic();
                                add(level);
                                for(entity in level.entities) {
                                    entity.moveBy(level.x, level.y);
                                    add(entity);
                                    if(entity.name == "player") {
                                        player = cast(entity, Player);
                                    }
                                }
                                allLevels.push(level);
                            }
                        }
                    }
                }
            }
            count++;
        }
    }
}
