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
import entities.Level;

class GameScene extends Scene
{
    public static inline var MAP_TILE_SIZE = 16;
    public static inline var MIN_NUMBER_OF_TRAPS = 10;
    public static inline var MAX_NUMBER_OF_TRAPS = 100;
    public static inline var BASE_ICE_RADIUS = 9;
    public static inline var BASE_SPIKE_TRAP_RADIUS = 5;

    public static var currentCheckpoint:Vector2 = null;
    public static var sfx:Map<String, Sfx> = null;

    public static var lives:Int = 3;
    public static var floorNumber:Int = 1;

    public var curtain(default, null):Curtain;
    public var openSpots(default, null):Map<String, Array<TileCoordinates>>;
    private var startMapBlueprint:Grid;
    private var hallwayMapBlueprint:Grid;
    private var endMapBlueprint:Grid;
    private var allBlueprint:Grid;
    private var map:Grid;
    private var allLevels:Array<Level>;
    private var player:Player;
    private var pauseTimer:Alarm;

    override public function begin() {
        Random.randomSeed = floorNumber;
        curtain = add(new Curtain());
        loadMaps(0);
        placeLevels();
        placeTraps();
        if(sfx == null) {
            sfx = [
                "restart" => new Sfx("audio/restart.wav")
            ];
        }
        pauseTimer = new Alarm(1, function() {
            var allEntities = new Array<Entity>();
            getAll(allEntities);
            for(entity in allEntities) {
                entity.active = true;
            }
        });
        addTween(pauseTimer);
    }

    public function onDeath() {
        lives -= 1;
        HXP.alarm(3.5, function() {
            curtain.fadeIn();
            HXP.alarm(0.5, function() {
                if(lives == 0) {
                    HXP.scene = new GameOver();
                }
                else {
                    HXP.scene = new FloorTitle();
                }
            });
        });
    }

    static public function stopAmbience() {
    }

    public function pause(pauseDuration:Float) {
        var allEntities = new Array<Entity>();
        getAll(allEntities);
        for(entity in allEntities) {
            if(entity == curtain) {
                continue;
            }
            entity.active = false;
        }
        pauseTimer.reset(pauseDuration);
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
        startMapBlueprint = new Grid(
            mapWidth, mapHeight, MAP_TILE_SIZE, MAP_TILE_SIZE
        );
        hallwayMapBlueprint = new Grid(
            mapWidth, mapHeight, MAP_TILE_SIZE, MAP_TILE_SIZE
        );
        endMapBlueprint = new Grid(
            mapWidth, mapHeight, MAP_TILE_SIZE, MAP_TILE_SIZE
        );
        allBlueprint = new Grid(
            mapWidth, mapHeight, MAP_TILE_SIZE, MAP_TILE_SIZE
        );
        if(fastXml.hasNode.start) {
            for (r in fastXml.node.start.nodes.rect) {
                startMapBlueprint.setRect(
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
        if(fastXml.hasNode.end) {
            for (r in fastXml.node.end.nodes.rect) {
                endMapBlueprint.setRect(
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
            !startMapBlueprint.getTile(tileX + checkX - 1, tileY + checkY)
            && !hallwayMapBlueprint.getTile(tileX + checkX - 1, tileY + checkY)
        ) {
            level.fillLeft(checkY);
        }
        if(
            !startMapBlueprint.getTile(tileX + checkX + 1, tileY + checkY)
            && !hallwayMapBlueprint.getTile(tileX + checkX + 1, tileY + checkY)
        ) {
            level.fillRight(checkY);
        }
        if(
            !startMapBlueprint.getTile(tileX + checkX, tileY + checkY - 1)
            && !endMapBlueprint.getTile(tileX + checkX, tileY + checkY - 1)
        ) {
            level.fillTop(checkX);
        }
        if(
            !startMapBlueprint.getTile(tileX + checkX, tileY + checkY + 1)
            && !endMapBlueprint.getTile(tileX + checkX, tileY + checkY + 1)
        ) {
            level.fillBottom(checkX);
        }
    }

    private function placeLevels() {
        allLevels = new Array<Level>();
        var levelTypes = ["start", "hallway", "end"];
        var count = 0;
        for(mapBlueprint in [
            startMapBlueprint, hallwayMapBlueprint, endMapBlueprint
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

    private function placeTraps() {
        // Collect open spots
        openSpots = [
            "edges" => new Array<TileCoordinates>(),
            "on_ceiling" => new Array<TileCoordinates>(),
            "on_floor" => new Array<TileCoordinates>(),
            "on_floor_with_headroom" => new Array<TileCoordinates>(),
            "in_floor" => new Array<TileCoordinates>(),
            "near_center" => new Array<TileCoordinates>(),
            "walls" => new Array<TileCoordinates>()
        ];
        for(level in allLevels) {
            for(spotType in level.openSpots.keys()) {
                if(level.openSpots.exists(spotType)) {
                    for(openSpot in level.openSpots[spotType]) {
                        openSpots[spotType].push(openSpot);
                    }
                }
            }
        }
        for(spotType in openSpots.keys()) {
            HXP.shuffle(openSpots[spotType]);
        }
        var numberOfTraps = MathUtil.ilerp(MIN_NUMBER_OF_TRAPS, MAX_NUMBER_OF_TRAPS, floorNumber / 99);
        for(i in 0...numberOfTraps) {
            var openSpot = openSpots["edges"].pop();
            var enemy = HXP.choose(
                "spikeball", "icicle", "ice", "medusa", "ballspewer",
                "spiketrap", "spiketurtle", "jumper"
            );
            //enemy = HXP.choose("jumper");
            if(enemy == "spikeball") {
                var trap = new SpikeBall(new Vector2(
                    openSpot.level.x + openSpot.tileX * Level.TILE_SIZE + Level.TILE_SIZE / 2,
                    openSpot.level.y + openSpot.tileY * Level.TILE_SIZE + Level.TILE_SIZE / 2
                ));
                add(trap);
            }
            else if(enemy == "icicle") {
                var openSpot = openSpots["on_ceiling"].pop();
                var trap = new Icicle(
                    openSpot.level.x + openSpot.tileX * Level.TILE_SIZE,
                    openSpot.level.y + openSpot.tileY * Level.TILE_SIZE
                );
                add(trap);
            }
            else if(enemy == "ice") {
                var openSpot = openSpots["in_floor"].pop();
                var iceRadius = BASE_ICE_RADIUS + HXP.choose(-2, 0, 2, 4);
                var tileStart = Std.int(Math.round(-iceRadius / 2));
                var tileEnd = tileStart + iceRadius;
                for(tileX in tileStart...tileEnd) {
                    for(tileY in tileStart...tileEnd) {
                        if(openSpot.level.walls.getTile(
                            openSpot.tileX + tileX, openSpot.tileY + tileY, false
                        )) {
                            var trap = new IceBlock(
                                openSpot.level.x + (openSpot.tileX + tileX) * Level.TILE_SIZE,
                                openSpot.level.y + (openSpot.tileY + tileY) * Level.TILE_SIZE
                            );
                            add(trap);
                        }
                    }
                }
            }
            else if(enemy == "medusa") {
                var openSpot = openSpots["near_center"].pop();
                var trap = new Medusa(
                    openSpot.level.x + openSpot.tileX * Level.TILE_SIZE,
                    openSpot.level.y + openSpot.tileY * Level.TILE_SIZE
                );
                add(trap);
            }
            else if(enemy == "ballspewer") {
                var openSpot = openSpots["walls"].pop();
                var trap = new BallSpewer(
                    openSpot.level.x + openSpot.tileX * Level.TILE_SIZE,
                    openSpot.level.y + openSpot.tileY * Level.TILE_SIZE,
                    !openSpot.level.walls.getTile(openSpot.tileX - 1, openSpot.tileY, true)
                );
                //openSpot.level.walls.setTile(openSpot.tileX, openSpot.tileY, false);
                add(trap);
            }
            else if(enemy == "spiketrap") {
                var spikeTrapRadius = BASE_SPIKE_TRAP_RADIUS + HXP.choose(-2, -1, 0, 1, 2);
                //var spikeTrapRadius = BASE_SPIKE_TRAP_RADIUS;
                var openSpot = openSpots["in_floor"].pop();
                var tileStart = Std.int(Math.round(-spikeTrapRadius / 2));
                var tileEnd = tileStart + spikeTrapRadius;
                for(tileX in tileStart...tileEnd) {
                    for(tileY in tileStart...tileEnd) {
                        if(
                            openSpot.level.walls.getTile(
                                openSpot.tileX + tileX, openSpot.tileY + tileY
                            )
                            && !openSpot.level.walls.getTile(
                                openSpot.tileX + tileX, openSpot.tileY + tileY - 1, true
                            )
                        ) {
                            var trap = new SpikeTrap(
                                openSpot.level.x + (openSpot.tileX + tileX) * Level.TILE_SIZE,
                                openSpot.level.y + (openSpot.tileY + tileY) * Level.TILE_SIZE
                            );
                            add(trap);
                        }
                    }
                }
            }
            else if(enemy == "spiketurtle") {
                var openSpot = openSpots["on_floor"].pop();
                var trap = new SpikeTurtle(
                    openSpot.level.x + openSpot.tileX * Level.TILE_SIZE,
                    openSpot.level.y + openSpot.tileY * Level.TILE_SIZE
                );
                add(trap);
            }
            else if(enemy == "jumper") {
                var openSpot = openSpots["on_floor_with_headroom"].pop();
                var trap = new Jumper(
                    openSpot.level.x + openSpot.tileX * Level.TILE_SIZE,
                    openSpot.level.y + openSpot.tileY * Level.TILE_SIZE - 2
                );
                add(trap);
            }
        }

        // Remove conflicting enemies
        // TODO: maybe should just delete any that are touching...
        //var spikeTraps = new Array<Entity>();
        //getClass(SpikeTrap, spikeTraps);
        //var iceBlocks = new Array<Entity>();
        //getClass(IceBlock, iceBlocks);
        //var ballSpewers = new Array<Entity>();
        //getClass(BallSpewer, ballSpewers);
        //for(iceBlock in iceBlocks) {
            //for(spikeTrap in spikeTraps) {
                //if(spikeTrap.collideWith(iceBlock, spikeTrap.x, spikeTrap.y) != null) {
                    //remove(iceBlock);
                //}
            //}
            //for(ballSpewer in ballSpewers) {
                //if(ballSpewer.collideWith(iceBlock, ballSpewer.x, ballSpewer.y) != null) {
                    //remove(iceBlock);
                //}
            //}
        //}
    }
}
