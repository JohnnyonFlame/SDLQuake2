id Software's Quake2 3.21+Changes by Steven Fuller <relnev@icculus.org>, 
                                     et al.


For this to be of any use, you _must_ own a copy of Quake 2.  The demo would
also work, but you might as well buy the full thing now.

These modifications are intended for Linux users, as I do not have have
access to other platforms.

Be sure to install SDL 1.2 (http://www.libsdl.org) if you want to use the
softsdl or sdlgl drivers, or the sdlquake2 binary.

You can change what drivers you wish to build by editing the Makefile and
changing the BUILD_ lines at the very top.

'make' will, by default, build both the debug and release files.
To build fully optimized binaries: make build_release
The resulting binaries are then put in releasei386.


To install the Quake2 gamedata:
-------------------------------
(installdir is wherever you want to install quake2, and cdromdir is wherever
you mount the Quake 2 CD-ROM)
1. copy <cdromdir>/Install/Data/baseq2/pak0.pak to <installdir>/baseq2/
2. copy <cdromdir>/Install/Data/baseq2/videos/ to <installdir>/baseq2/
   (optional)
3. Download q2-3.20-x86-full.exe from
   ftp://ftp.idsoftware.com/idstuff/quake2/ or a mirror site, and extract the 
   contents to a temporary directory (use unzip -L, as this is a standard zip
   file).
4. copy <q2-3.20-x86-full.exe temp directory>/baseq2/pak1.pak to
   <installdir>/baseq2/
5. copy <q2-3.20-x86-full.exe temp directory>/baseq2/pak2.pak to
   <installdir>/baseq2/
6. copy <q2-3.20-x86-full.exe temp directory>/baseq2/players/ to 
   <installdir>/baseq2/

To install this program:
------------------------
(builddir is either debugi386 or releasei386)
1. copy <builddir>/gamei386.so to <installdir>/baseq2/
2. copy <builddir>/ref_*.so to <installdir>
3. copy <builddir>/quake2 to <installdir>
4. copy <builddir>/sdlquake2 to <installdir> (optional)


To run:
-------
cd <installdir> && ./quake2
Or:
quake2 +set basedir <installdir>

/etc/quake2.conf is no longer needed; instead, the ref_*.so files are loaded
from basedir (basedir is "." by default, and can only be set at the command
line).

Configuration files and such are saved in ~/.quake2/, so <installdir> can be
made read-only or whatever.

WARNING: Please do not make quake2 or any of the libraries suid root!

NOTE: Save games will most likely not work across different versions or
builds (this is due to how savegames were stored).


Commonly used commands:
-----------------------
cd_nocd 0               // disable CD audio
s_initsound 0           // disable sound
_windowed_mouse 0       // disable mouse-grabbing
gl_ext_multitexture 0   // disable OpenGL Multitexturing (requires a
                           vid_restart)
vid_ref <driver>        // select a video driver (softx is the original
                           X11-only, softsdl is SDL software, sdlgl is 
                           SDL OpenGL)
vid_fullscreen 0        // disable fullscreen mode
vid_restart             // restart video driver
snd_restart             // restart sound driver
basedir <dir>           // point quake2 to where the data is
gl_driver <libGL.so>    // point quake2 to your libGL


Website:
--------
I'll post any updates I make at http://www.icculus.org/quake/ 
(which currently redirects to http://www.icculus.org/~relnev/)

Anonymous CVS access:
---------------------
cvs -d:pserver:anonymous@icculus.org:/cvs/cvsroot login
      (password is "anonymous" without the quotes.)
cvs -z3 -d:pserver:anonymous@icculus.org:/cvs/cvsroot co quake2

Questions:
----------
What's the best way of handling international keyboards with SDL?

TODO:
-----
Fix save games.
Suggestions, anyone?

v0.0.8: [XX/XX/XX] CVS
-------

v0.0.7: [12/28/01]
-------
+ Merged in Quake2 3.21 source.

v0.0.6: [12/27/01]
-------
+ Made Makefile somewhat easier to configure.
+ X11 GLX driver now included.
+ Added "ctrl-g" (toggle mouse grab) and "alt-enter" (toggle fullscreen)
  to SDL drivers.
+ SDL audio and cdrom support. (Robert Bäuml)
+ ~/.quake2/ support (Stephen Anthony, Ludwig Nussel)
+ LinuxPPC support (William Aoki)

v0.0.5: [12/23/01]
-------
+ Better SDL de/initialization (fixes crashes for some people).
+ Removed trailing '\r's from files; removed a few files.

v0.0.4: [12/23/01]
-------
+ Mouse Wheel (SDL buttons 4 and 5).
+ Fixed bug with changing the sound options in game (using the menus).
+ Fixed Makefile to build both build_debug and build_release by default.

v0.0.3: [12/22/01]
-------
+ Fixed the texture wrapping with movies.
+ Enabled the OpenGL extensions under Linux.
+ Added support for GL_ARB_multitexture.

v0.0.2: [12/22/01]
-------
+ Added ref_sdlgl.so (SDL OpenGL Renderer).
+ v0.0.1 Bugfixes.

v0.0.1: [12/22/01]
-------
+ Updates to Linux Makefile (it was missing a few files).
+ Added ref_softsdl.so (Software SDL Renderer).
- OpenGL not yet supported.

Thanks:
-------
John Allensworth
Stephen Anthony
William Aoki
Robert Bäuml
Ryan C. Gordon
Ludwig Nussel
Zachary 'zakk' Slater
Matti Valtonen
