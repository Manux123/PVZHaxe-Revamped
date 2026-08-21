class Level_1_1 extends LevelScript
{
    var _zombiesKilled:Int = 0;
    var _targetKills:Int = 10;

    override public function onCreate():Void
    {
        trace('[Level_1_1] Level init. Matar $_targetKills zombies para ganar.');
    }

    override public function onPlantingPhase():Void
    {
        state.hud.addSun(50);
        trace('[Level_1_1] Planting phase. +50 bonus suns.');
    }

    override public function onStart():Void
    {
        trace('[Level_1_1] ¡The zombies are coming!');

        state.spawnZombie('basic', 820, 150, true);
    }

    override public function onZombieKilled(zombie:Zombie):Void
    {
        _zombiesKilled++;
        trace('[Level_1_1] Zombie killed. $_zombiesKilled / $_targetKills');

        if (_zombiesKilled >= _targetKills)
            state.triggerWin();
    }

    override public function onPlantPlaced(plant:Plant, row:Int, col:Int):Void
    {
        trace('[Level_1_1] Plant placed in a row $row, column $col');
    }

    override public function onWin():Void
    {
        trace('[Level_1_1] Victory! All zombies eliminated.');
    }
}
