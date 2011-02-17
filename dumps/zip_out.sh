#!/bin/sh

rm /a/wikistats/zip_all/out_$1.zip
cd /a/out/out_$1/EN
zip -r /a/wikistats/zip_all/out_$1.zip *
