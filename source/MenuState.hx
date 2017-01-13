package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.ui.FlxButton;
import haxe.io.Bytes;
import sys.net.UdpSocket;
import sys.net.Address;
import sys.net.Host;
import sys.net.Socket;
//import cpp.__std.sys.net.UdpSocket;

class MenuState extends FlxState
{

	private var host:UdpSocket;
	private var client:UdpSocket;
	private var localHost:Address;
	private var throwawayAddress:Address;

	override public function create():Void
	{
		super.create();
		host = new UdpSocket();
		host.setBlocking(false);
		host.bind(new Host("127.0.0.1"), 20001);

		client = new UdpSocket();
		client.setBlocking(false);

		localHost = new Address();
		localHost.host = new Host("127.0.0.1").ip;
		localHost.port = 20001;
		FlxG.log.add("Sending to server: STATUS: " + 
			client.sendTo(Bytes.ofString("Hey!"), 0, 4, localHost));

		var buf:Bytes = Bytes.alloc(4);
		var addr = new Address();
		FlxG.log.add("Receiving from server: STATUS: " + 
			host.readFrom(buf, 0, 4, addr));
		FlxG.log.add("Received: " + buf.toString());
		FlxG.log.add("From " + addr.host + ":" + addr.port);

		var btn = new FlxButton(20, 20, "Send 'Hey!'", udpSender("Hey!"));
		add(btn);

		throwawayAddress = new Address();
	}

	private function udpSender(data:String):Void->Void{
		return function():Void{
			udpSend(data, localHost);
		}
	}

	private function udpSend(data:String, target:Address):Bool{
		try{
			FlxG.log.add("Sending to server: STATUS: " + 
				client.sendTo(Bytes.ofString(data), 0, data.length, target));
			return true;
		}catch(e:Dynamic){
			FlxG.log.add("Error sending data: " + e);
			return false;
		}
	}

	private function readSocket():Bool{
		var buf:Bytes = Bytes.alloc(4);
		try{
			FlxG.log.add("Receiving from server: STATUS: " + 
			host.readFrom(buf, 0, 4, throwawayAddress));
			FlxG.log.add("Received: " + buf.toString());
			FlxG.log.add("From " + throwawayAddress.host + ":" + throwawayAddress.port);	
			return true;
		}catch(e:Dynamic){
			FlxG.log.add("Error sending data: " + e);
			return false;
		}		
	}

	override public function update(elapsed:Float):Void
	{
		var cool:Dynamic = Socket.select([host], [], [], 0);
		if(cool.read.length > 0){
			readSocket();
		}
		super.update(elapsed);		
	}
}
