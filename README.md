# Welcome!

This repository is intended to help get you set up for the first time or reinitialize a clean machine.  This is intended to set up a new Ubuntu machine.  Of course you are welcomed to preview the commands that you are asked to run but the point of this repo is to give everyone a consistent agreement on shared setup and configuration so that our shared scripts run properly.

Thank you for your attention, please help improve this, and enjoy!

First you'll need to set the following variables.  Ask for SSO_START_URL if you haven't already been given it.

```
export NAME="<First Last>"
export EMAIL=<you@psyome.com>
export SSO_START_URL=<url>
```

Next, to set up your machine's identity, run the following in your terminal:

```
wget -qO- https://raw.githubusercontent.com/loveworks/onboarding/main/0.ssh.sh > 0.ssh.sh
chmod 700 0.ssh.sh
./0.ssh.sh
rm 0.ssh.sh
```

This will open a browser window on GitHub that will allow you to add the public key that was generated and written to your console.  This will set you up for using SSH to securely contribute code (Thank you!) and before that in pulling down the relevant code.

After you've added your new key, go ahead and run the following:

```
wget -qO- https://raw.githubusercontent.com/loveworks/onboarding/main/1.setup.sh > 1.setup.sh
wget -qO- https://raw.githubusercontent.com/loveworks/onboarding/main/default.zshrc > default.zshrc
wget -qO- https://raw.githubusercontent.com/loveworks/onboarding/main/launch.json > launch.json
wget -qO- https://raw.githubusercontent.com/loveworks/onboarding/main/settings.json > settings.json

chmod 700 1.setup.sh
./1.setup.sh
rm 1.setup.sh
rm default.zshrc
rm launch.json
rm settings.json
```

That should give you a baseline setup with which to start coding (we assume `code /src/loveworks` as the standard setup).  Well... It is, of course, a little more complicated than that...  We need to add you into the systems first.  For now, just ask Erik for help.  Make sure he sets you up with vars.sh while he's at it.
