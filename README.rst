========
vnc-wrap
========

If you have enabled Mac OS X's built-in VNC server ("Screen Sharing") and make
any use of it, you are hopefully aware that it is pretty desperately insecure.
It does not support encrypted connections, so your username and password are
simple to sniff.

One solution, if you don't want to buy the OS X Server edition or a more
expensive VNC server, is to send the VNC connection over an encrypted SSH
tunnel.

This requires a few things:

* You understand what SSH connections are
* You have enabled "Remote Login" (the SSH server) in the Sharing preference
  pane on the remote machine
* You have an account on the remote machine (not just a VNC password)

..but not much else.

--------------
Using vnc-wrap
--------------

To use vnc-wrap, simply launch it. You'll be asked for a hostname. When given,
vnc-wrap will try to create an ssh tunnel there. If it succeeds, it will then
start up Screen Sharing so that it connects through the tunnel.

------------------
More detailed info
------------------

* By default, vnc-wrap will not specify a remote username to SSH. If your
  account on the remote machine has a different name from your local account,
  you can either configure SSH always to use the right username when
  connecting to the other machine (see `ssh_config(5)`_) or give your username
  along with the hostname when vnc-wrap prompts. Example:
  "``othername@some.host``".

* The first time you connect somewhere, vnc-wrap might ask for your ssh
  password. It will store it in the OS X Keychain so that it won't have to ask
  again. If you don't want your password stored there, you should really set
  up `SSH keys`_ and configure your ssh-agent so that vnc-wrap doesn't need to
  ask for a password.

* Screen Sharing will also probably ask for a password the first time you
  connect somewhere with vnc-wrap, even if you have stored the VNC password
  for that host in your keychain. The remote host will look like a new one to
  Screen Sharing.

  (icky detail: all remote hosts will be called "localhost", as far as Screen
  Sharing can tell, but vnc-wrap will use the same local listening port for
  the same destination host to the extent it can do so, since Screen Sharing
  stores VNC passwords in the keychain indexed by remote hostname *and* port.
  So you should only need to tell Screen Sharing to store your password once,
  should you care to do so.)

.. _ssh_config(5): http://developer.apple.com/library/mac/#documentation/
                   Darwin/Reference/ManPages/man5/ssh_config.5.html
.. _SSH keys: http://developer.apple.com/library/mac/#documentation/
              MacOSXServer/Conceptual/XServer_ProgrammingGuide/Articles/SSH.html

--------------------
Building from source
--------------------

Sorry, I'm not hardcore enough to know how to build this in an automated way.
Let me know if you have some fu for it. But here are the manual steps:

* Start AppleScript Editor
* Open the ``vnc-wrap.applescript`` file.
* From the menu, choose File, Save As..., and save ``vnc-wrap`` with File
  Format: Application.
* This will cause "Bundle Contents" icon in the toolbar to become un-grayed.
  Click it to open the Bundle Contents sidebar.
* Drag the ``askpass.sh`` file from another Finder window into the Bundle
  Contents sidebar.
* Save ``vnc-wrap`` again and exit AppleScript editor.
* ``vnc-wrap.app`` should now be everything you need.
