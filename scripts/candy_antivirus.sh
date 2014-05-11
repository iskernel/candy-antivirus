#!/bin/bash

if [ ! -f "CandyAntivirus.pl" ]; then
    cd ..
fi

default_dir=`pwd`

export PERL5LIB=$default_dir/lib
perl CandyAntivirus.pl
