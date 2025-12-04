# Logitech MX Master 3 Extras for Linux With logiops

The Logitech Options program isn't available for Linux, but by a nice guy on GitHub ([PixlOne](https://github.com/PixlOne)) created an open source project that lets you obtain some of that functionality. It's called [logiops](https://github.com/PixlOne/logiops). It works in conjunction with the [Solaar](https://github.com/pwr-Solaar/Solaar) project as well, which I find especially handy since that shows your available battery life in the system tray and lets you pair/unpair devices with the Logitech Unifying Receiver.

Here are some additional pages with info that I used to generate this documentation:

- <https://github.com/PixlOne/logiops/wiki/Configuration>
- <https://github.com/PixlOne/logiops/blob/master/logid.example.cfg>
- <https://github.com/torvalds/linux/blob/master/include/uapi/linux/input-event-codes.h>
- <https://wiki.archlinux.org/index.php/Logitech_MX_Master>
- <https://www.logitech.com/en-us/products/mice/mx-master-3.910-005620.html>

## Installation

Installation instructions for different distributions are available from the developer, but here are the commands for an Ubuntu workstation (I've verified it works with 20.04, 21.10, and 22.04):

```bash
sudo apt install -y cmake libevdev-dev libudev-dev libconfig++-dev
git clone https://github.com/PixlOne/logiops
cd logiops
mkdir build
cd build
cmake ..
make
sudo make install
sudo touch /etc/logid.cfg
sudo systemctl enable --now logid
```

## My /etc/logid.cfg File

This setup is pretty basic. Although gestures are supported and an example config with that is provided within the GitHub project, the only functionality I wanted to add that I couldn't get from Solaar, was a way to launch the GNOME Activities window (i.e. press the Super/Meta/Logo key) with the mouse. Here's how:

```bash
echo 'devices: (
{
    name: "Wireless Mouse MX Master 3";
    smartshift:
    {
        on: true;
        threshold: 10;
    };
    hiresscroll:
    {
        hires: true;
        invert: false;
        target: false;
    };
    dpi: 1000;

    buttons: (
        {
            cid: 0x52;
            action =
            {
                type: "Keypress";
                keys: ["KEY_LEFTMETA"];
            };
        }
    );
}
);' | sudo tee /etc/logid.cfg 
sudo systemctl restart logid
```

### Programmable Mouse Buttons

Note that I chose to configure the scroll wheel button, but any of the following buttons are available for you to play with:

- 0x52 - scroll wheel button
- 0x53 - back button
- 0x56 - forward button
- 0xc3 - thumb button (default "Gesture" button with Logitech Options software)
- 0xc4 - mode shift button (by default toggles between ratchet and free-spin wheel modes)

## Extra Notes

Example output running ```sudo logid -v``` after creating /etc/logid.cfg:

```bash
[ERROR] I/O Error while reading /etc/logid.cfg: FileIOException
[DEBUG] Unsupported device /dev/hidraw1 ignored
[DEBUG] Unsupported device /dev/hidraw2 ignored
[DEBUG] Unsupported device /dev/hidraw0 ignored
[WARN] Error adding device /dev/hidraw4: std::exception
[INFO] Detected receiver at /dev/hidraw3
[INFO] Device Wireless Mouse MX Master 3 not configured, using default config.
[INFO] Device found: Wireless Mouse MX Master 3 on /dev/hidraw3:1
[DEBUG] /dev/hidraw3:1 remappable buttons:
[DEBUG] CID  | reprog? | fn key? | mouse key? | gesture support?
[DEBUG] 0x50 |         |         | YES        | 
[DEBUG] 0x51 |         |         | YES        | 
[DEBUG] 0x52 | YES     |         | YES        | YES
[DEBUG] 0x53 | YES     |         | YES        | YES
[DEBUG] 0x56 | YES     |         | YES        | YES
[DEBUG] 0xc3 | YES     |         | YES        | YES
[DEBUG] 0xc4 | YES     |         | YES        | YES
[DEBUG] 0xd7 | YES     |         |            | YES
[DEBUG] Thumb wheel detected (0x2150), capabilities:
[DEBUG] timestamp | touch | proximity | single tap
[DEBUG] YES       | YES   | YES       | YES       
[DEBUG] Thumb wheel resolution: native (18), diverted (120)
```

### Solaar Rules

In Ubuntu 22.04, Solaar adds the ability to create your own rules for modifying the mouse button behavior, but after spending about 15 minutes reading through the [official documentation](https://pwr-solaar.github.io/Solaar/rules), and trying to create user rules, I was unable to figure out how to replicate the Logitech Options behavior I was expecting - namely assigning commands to specific buttons. Perhaps it was because "rule processing only fully works under X11" and Ubuntu uses Wayland?

Either way, the process I originally documented for Ubuntu 20.04 worked flawlessly for me with Ubuntu 22.04. By specifying the button ID and the action in the `/etc/logid.cfg` file, it just works. The config described below is pretty basic, so I recommend checking out the logiops wiki [Configuration](https://github.com/PixlOne/logiops/wiki/Configuration) page for more advanced options with actions and gestures.
