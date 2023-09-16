#!/bin/bash
### python3 -m pip install rootmeapi

python3 -c "__import__('rootmeapi').RootMeAPI().login('$1')"
