#!/bin/bash

ulimit -v 4000000

nice perl SquidLoadScan.pl
