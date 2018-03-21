# WAM
Wesnoth Addon Manager
---------------------
This is a tool I wrote to help me and my brother manage addons for the Battle for Wesnoth game, because we frequently were removing and reinstalling specific sets of addons. I figured caching the addons on disk would speed this up, so I wrote this to make it easier- instead of manually moving the them in and out of Wesnoth's addon directory.

The Battle for Wesnoth: https://www.wesnoth.org/

Note: I can't guarantee too active development on this, but pull requests are welcome! (Note that you must license your code as GNU GPLv3 or compatible, or I won't accept it.)

ToDo
----
* Write setup script.
* Make UI better.
	* Use something other than eval to do command line options?
* Add more intelligent dependency management.
	* Maybe generate a graph of all addons' dependencies?
* Maybe rewrite the python code as shell?
