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
