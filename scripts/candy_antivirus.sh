#!/bin/bash

cd ..
default_dir=`pwd`

export PERL5LIB=$default_dir/lib
perl CandyAntivirus.pl
