package core.sprites;

typedef AnimationData =
{
	var ?offsets:Array<Float>;
	var ?prefix:String;
	var ?indices:Array<Float>;
	var ?postfix:String;
	var ?fps:Int;
	var ?looped:Bool;
}