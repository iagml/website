#!/bin/bash

jupyter nbconvert --output-dir='./notebooks' --to html --template jupyter.tpl assets/uploads/*.ipynb