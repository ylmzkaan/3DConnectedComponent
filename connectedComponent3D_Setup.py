# -*- coding: utf-8 -*-
"""
Created on Mon Mar 12 18:54:07 2018

@author: kaany
"""


from distutils.core import setup
from Cython.Build import cythonize
import numpy

setup(
    ext_modules = cythonize("connectedComponent3D.pyx"),
    include_dirs=[numpy.get_include()]
)
