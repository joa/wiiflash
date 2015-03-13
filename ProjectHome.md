WiiFlash has been developped by [Joa Ebert](http://blog.je2050.de/) and [Thibault Imbert](http://www.bytearray.org/).

It is a project dedicated to the Wiimote and Flash® applications consisting of two main parts:

  * WiiFlash Server
  * WiiFlash ActionScript API

## Downloading ##
We suggest you to use an SVN client like [tortoiseSVN](http://tortoisesvn.tigris.org/) or [subclipse](http://subclipse.tigris.org/) (with FlexBuilder 2) to download the WiiFlash source code instad of using the featured wiiflash\_api.zip. This way you stay always up-to-date.
Since people have often problems with downloading from a repository we put the file up there for users that do not want to deal with SVN.
If you like to use SVN and the help on Google Code is not enough for you there is also an [article](http://wiki.papervision3d.org/index.php?title=Download_from_SVN) in the [Papervision3D wiki](http://wiki.papervision3d.org/) about this issue.

## API ##
WiiFlash is very easy to use. You can connect a Wiimote in Flash with three lines of code and start reading your data.

```
var wiimote: Wiimote = new Wiimote();
wiimote.addEventListener( Event.CONNECT, onWiimoteConnect );
wiimote.connect();
```

We also support the new DOM event model of Flash. For people that are bored of all the listeners we have simple boolean flags too.

### Using the DOM event model ###
```
[...]

wiimote.addEventListener( ButtonEvent.A_PRESS, onAPress );
wiimote.addEventListener( ButtonEvent.A_RELEASE, onARelease );

[...]

private function onAPress( event: ButtonEvent ): void
{
	wiimote.rumble = true;
}
	
private function onARelease( event: ButtonEvent ): void
{
	wiimote.rumble = false;
}
```

### Using simple flags ###
```
private function onEnterFrame( event: Event ): void
{
	//Rumble while A and B are pressed
	wiimote.rumble = wiimote.a && wiimote.b;
}
```