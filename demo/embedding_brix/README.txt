Author: Thomas Fétiveau
Lisence: GPL
Copyright: Silex Labs

This demo intends to show how to embed an Brix application to an existing application. Embedding several Brix applications within the same application without class conflict is also possible. Here the folders src_brix_01 and src_brix_02 are two source folders of two different Brix applications.

To run this demo: 
	
Set a proper environment : download cocktail, set the right path to the cocktail lib in the build_js.hxml and build_as3.hxml files of both brix applications.

Compile the both applications (folder src_brix_01 and src_brix_02) for flash and for js. Compile also the parent flash application (src_as3/build.hxml).

Test it by opening output.html and output.swf in a web browser.