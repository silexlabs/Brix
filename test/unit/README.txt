/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */

UNIT TESTS FOR BRIX COMPONENTS AND CLASSES

Unit tests in brix uses the munit unit testing library: https://github.com/massiveinteractive/MassiveUnit
This library has the advantages to work seamlessly with mcover, a code coverage framework for Haxe: https://github.com/massiveinteractive/MassiveCover
And mockatoo, a mocking framework for Haxe: https://github.com/massiveinteractive/mockatoo

To run the tests, you need to setup munit first. I won't copy paste here what is explained on the munit GitHub wiki so first look at it if you 
haven't done this step yet.

To run the tests, open a terminal and go to this directory (/test/unit/). Type "haxelib run munit test" and the tests should run. Test report should be 
displayed in your default web browser.

If some tests do not pass whereas you did not modify the test nor brix sources, please report it as an issue in the Brix GitHub issue tracker.

To add new test classes, you can use the src/ExampleTestTemplate.hx file as a template to write your test classes.