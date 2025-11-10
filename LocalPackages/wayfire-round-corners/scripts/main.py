#!/usr/bin/env python

# A simple script to apply a shader to all toplevel views.

import os
import sys
import signal
from wayfire import WayfireSocket
from wayfire.extra.wpe import WPE

if len(sys.argv) == 1:
    print(f"Usage: {sys.argv[0]} /path/to/filters/shader")
    exit(-1)

sock = WayfireSocket()
wpe = WPE(sock)

sock.watch(['view-mapped', 'view-tiled'])

def unset_view_shaders():
    for view in sock.list_views():
        wpe.unset_view_shader(view["id"])

for view in sock.list_views():
    if view["role"] != "toplevel":
        continue
    if view["tiled-edges"] == 0 and view["fullscreen"] == False:
        wpe.set_view_shader(view["id"], os.path.abspath(str(sys.argv[1])))

def signal_handler(sig, frame):
    exit(0)

signal.signal(signal.SIGTERM, signal_handler)

while True:
    try:
        msg = sock.read_next_event()
        if "event" in msg:
            if msg["view"]["role"] != "toplevel":
                    continue
            if msg["event"] == "view-mapped":
                view_id = msg["view"]["id"]
                if msg["view"]["tiled-edges"] == 0 and msg["view"]["fullscreen"] == False:
                    wpe.set_view_shader(view_id, os.path.abspath(str(sys.argv[1])))
            elif msg["event"] == "view-tiled" and "view" in msg:
                view_id = msg["view"]["id"]
                # round them corners when the window floats
                if msg["view"]["tiled-edges"] == 0 and msg["view"]["fullscreen"] == False:
                    wpe.set_view_shader(view_id, os.path.abspath(str(sys.argv[1])))
                else:
                    # don't round corners if the window is maximized/tiled/fullscreened
                    wpe.unset_view_shader(view_id)
                

    except KeyboardInterrupt:
        unset_view_shaders()
        sock.client.close()
        exit(0)
    except SystemExit:
        unset_view_shaders()
        sock.client.close()
        exit(0)
