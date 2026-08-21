package modding.api;

typedef PlantData = {
    var id:Int;
    var name:String;
    var sunCost:Int;
    var cooldown:Float;
    var health:Int;
    @:optional var damage:Int;
    @:optional var range:Float;
}

typedef ZombieData = {
    var id:Int;
    var name:String;
    var health:Int;
    var speed:Float;
    @:optional var armor:Int;
}

typedef LevelConfig = {
    var waves:Array<WaveConfig>;
    @:optional var music:String;
    @:optional var background:String;
    @:optional var startSun:Int;
}

typedef WaveConfig = {
    var time:Float;
    var zombies:Array<ZombieSpawn>;
}

typedef ZombieSpawn = {
    var id:Int;
    var lane:Int;
    @:optional var count:Int;
    @:optional var delay:Float;
}

enum ScriptLane {
    Lane(n:Int);
    Random;
    All;
}

enum DamageType {
    Normal;
    Fire;
    Ice;
    Explosive;
    Instant;
}
