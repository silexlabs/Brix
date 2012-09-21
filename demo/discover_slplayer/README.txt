Author: Thomas Fétiveau
Lisence: GPL
Copyright: Silex Labs

To run this demo: 

First, download the cocktail library there: https://github.com/silexlabs/Cocktail

Then, simply configure an alias in your Apache conf like this one :
	
	Alias /slplayer/ "E:/PATH_TO_MY_FILES/slplayer_repository/" 

	<Directory "E:/PATH_TO_MY_FILES/slplayer_repository/">
		Options Indexes FollowSymLinks MultiViews
		AllowOverride all
			Order allow,deny
		Allow from all
	</Directory>

Then edit the build_js.hxml and build_as3.hxml files to set the right path to the cocktail lib on your local drive in the last -cp value.	

Then, compile for the both as3 and js targets (run "haxe build_js.hxml" and "haxe build_as3.hxml").	You may need to change the classpath values of these command lines to the place you've put your cocktail directory.
	
Finally open a browser on http://127.0.0.1/slplayer/demo/discover_slplayer/SLPlayer.html to see the HTML/js output
	
And http://127.0.0.1/slplayer/demo/discover_slplayer/index_as3.html for the AS3 output