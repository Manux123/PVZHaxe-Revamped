package core.api;

#if windows
import discord_rpc.DiscordRpc;
#end

class DiscordRPC
{
	public static var id:String = "884169727415566417";

	public static function init()
	{
		DiscordRpc.start({
			clientID: id,
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		DiscordRpc.presence({
			details: 'Version: [PRIVATE BETA 2]',
			state: 'Loading...',
			largeImageKey: 'discord_rpc_512',
			largeImageText: 'Plants VS Zombies: Haxe Edition'
		});
	}

	public static function changePressence(state:String, ?details:String = 'Version: [PRIVATE BETA 2]',
			?largeImageText:String = 'Plants VS Zombies: Haxe Edition', ?largeImageKey:String = 'discord_rpc_512', ?smallImageKey:String = 'discord_rpc_512',
			?smallImageText:String = '')
	{
		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: largeImageKey,
			largeImageText: largeImageText,
			smallImageKey: smallImageKey,
			smallImageText: smallImageText,
		});
	}

	// I just stole the fuckin' code from the github lol \\
	static function onReady()
	{
		// Updating Discord Rich Presence
		DiscordRpc.presence({
			details: 'Version: [PRIVATE BETA 2]',
			state: 'In the Main Menu.',
			largeImageKey: 'discord_rpc_512',
			largeImageText: 'Plants VS Zombies: Haxe Edition'
		});
	}

	static function onError(_code:Int, _message:String)
	{
		trace('[DISCORD RPC] Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('[DISCORD RPC] Disconnected! $_code : $_message');
	}

	public static function shutdown()
	{
		DiscordRpc.shutdown();
	}

	public static function process()
	{
		DiscordRpc.process();
	}
}
