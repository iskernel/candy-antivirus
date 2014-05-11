#!/bin/bash

#Configures the necesary packages for running candy-antivirus 
sudo apt-get install perl 
sudo apt-get install cpan

sudo cpan LWP::Simple
sudo cpan Test::More
sudo cpan PadWalker
