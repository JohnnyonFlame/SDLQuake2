id Software's Quake2 3.21+Changes by Steven Fuller <relnev@icculus.org>, 
                                     et al.


For this to be of any use, you _must_ own a copy of Quake 2.  The demo would
also work, but you might as well buy the full thing now.

These modifications are intended for Linux users, as I do not have have
access to other platforms.

Be sure to install SDL 1.2 (http://www.libsdl.org) if you want to use the
softsdl or sdlgl drivers, or the sdlquake2 binary.

'make' will, by default, build both the debug and release files.
To build fully optimized binaries: make build_release
The resulting binaries are then put in releasei386.


Makefile options:
-----------------
(quake2 and gamei386.so are always built, but the following options can be
 changed by editing the Makefile)
BUILD_SDLQUAKE2		Build sdlquake2, a quake2 binary that uses SDL for
                        CD audio and sound access (default = YES).
BUILD_SVGA              Build ref_soft.so, a quake2 video driver that uses
                        SVGAlib (default = NO).
BUILD_X11               Build ref_softx.so, a quake2 video driver that uses
                        X11 (default = YES).
BUILD_GLX               Build ref_glx.so, a quake2 video driver that uses
                        X11's GLX (default = YES).
BUILD_FXGL              Build ref_gl.so [might be renamed to fxgl later], 
                        a quake2 video driver that uses fxMesa (default =
                        NO).  This option is currently untested because I do 
                        not have a Voodoo 1 or 2.
BUILD_SDL               Build ref_softsdl.so, a quake2 video driver that
                        uses SDL (default = YES).
BUILD_SDLGL             Build ref_sdlgl.so, a quake2 video driver that uses
                        OpenGL with SDL (default = YES).
BUILD_CTFDLL            Build the Threewave CTF gamei386.so (default = NO).


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

WARNING: Please do not make quake2 or any of the libraries suid root!  Doing
so is at your own risk.

NOTE: Save games will not work across different versions or builds, because
of the way they are stored.

Dedicated Server:
-----------------
If there is a demand for it, I can add support for an explicit q2ded binary.
Else, using +set dedicated 1 should be fine.

Joystick Support:
-----------------
None yet.

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
dedicated 1             // run quake2 as a dedicated server

When using these commands on the quake2 command line, use +set to cause the
variables be set before the config files are loaded (important for
gl_driver). e.g.
./quake2 +set vid_ref glx +set gl_driver /usr/lib/libGL.so.1

If quake2 crashes when trying to load an OpenGL based driver (glx, sdlgl),
make sure its not loading the wrong libGL.

Have a NVIDIA card and it _still_ crashes? Try 
export LD_PRELOAD=/usr/lib/libGL.so, and run quake2 again.

Is lighting slow in OpenGL (while firing, explosions, etc.)? Disable
multitexturing (gl_ext_multitexture 0; vid_restart).


Website:
--------
I'll post any updates I make at http://www.icculus.org/quake2/ 
(which currently redirects to http://www.icculus.org/~relnev/)

Mailing List:
-------------
to subscribe: send a blank email to quake2-subscribe@icculus.org
to post: send email to quake2@icculus.org

Anonymous CVS access:
---------------------
cvs -d:pserver:anonymous@icculus.org:/cvs/cvsroot login
      (password is "anonymous" without the quotes.)
cvs -z3 -d:pserver:anonymous@icculus.org:/cvs/cvsroot co quake2

Bugzilla:
---------
https://bugzilla.icculus.org

TODO:
-----
Try out RCG's key idea.
Fix save games.
Verify FXGL works.
Joystick support.
Fullscreen/DGA support in X11 driver.
Fully switch to glext.h.
Suggestions, anyone?

v0.0.9: [XX/XX/XX] CVS
-------

v0.0.8: [01/04/02]
-------
+ Fixed C-only ref_soft building.
+ SDL CD audio looping fix (Robert Bäuml)
+ ~/.quake2/<game> added to the search path for mods. (Ludwig Nussel)
+ Minor change to fix compilation with OpenGL 1.3 headers.
+ Fixed changing video drivers using the menu.
+ Fixed autoexec.cfg on startup.
+ Sparc Linux support (Vincent Cojot)

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
Vincent Cojot
Michel Dänzer
Ryan C. Gordon
Ludwig Nussel
Peter van Paassen
Zachary 'zakk' Slater
Matti Valtonen
