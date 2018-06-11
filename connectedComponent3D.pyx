# -*- coding: utf-8 -*-
"""
Created on Sat Apr  7 18:08:23 2018

@author: kaany
"""


from collections import deque
import numpy as np
cimport numpy as np
cimport cython
import logging
logging.basicConfig(level=logging.debug)

def main(binary3DArray):
    cdef q = deque()
    cdef int[:,:,:] binary3DArray_view = binary3DArray
    
    logging.info("Starting 3D Connected Component")
    
    cdef np.ndarray[np.int_t, ndim=3] labels
    cdef int numberOfComponents
    labels, numberOfComponents = connectedComponent3D(binary3DArray_view, q)
    
    return (labels, numberOfComponents)
    
@cython.wraparound(False)
@cython.nonecheck(False)
@cython.boundscheck(False)
cdef connectedComponent3D(int[:,:,:] binary3DArray, q):
    
    cdef np.ndarray[np.int_t, ndim=3] labels = np.zeros_like(binary3DArray)

    cdef Py_ssize_t zmax = <Py_ssize_t>binary3DArray.shape[0]
    cdef Py_ssize_t ymax = <Py_ssize_t>binary3DArray.shape[1]
    cdef Py_ssize_t xmax = <Py_ssize_t>binary3DArray.shape[2]
    cdef Py_ssize_t z, y, x
    cdef int currentComponent = 1
    cdef int neighbors[26][3]
    cdef int newItem[3]
    
    for z in range(1, zmax-1):
        for y in range(1, ymax-1):
            for x in range(1, xmax-1):
                if binary3DArray[z, y, x] == 1 and labels[z, y, x] == 0:
                    q.append((z,y,x))
                    while len(q) != 0:
                        newItem = q.popleft()
                        labels[newItem[0], newItem[1], newItem[2]] = currentComponent
                        neighbors = [[newItem[0]-1, newItem[1]-1, newItem[2]-1],   [newItem[0]-1, newItem[1]-1, newItem[2]],   [newItem[0]-1, newItem[1]-1, newItem[2]+1],
                                     [newItem[0]-1, newItem[1], newItem[2]-1],     [newItem[0]-1, newItem[1], newItem[2]],     [newItem[0]-1, newItem[1], newItem[2]+1],
                                     [newItem[0]-1, newItem[1]+1, newItem[2]-1],   [newItem[0]-1, newItem[1]+1, newItem[2]],   [newItem[0]-1, newItem[1]+1, newItem[2]+1],
                                     [newItem[0], newItem[1]-1, newItem[2]-1],     [newItem[0], newItem[1]-1, newItem[2]],     [newItem[0], newItem[1]-1, newItem[2]+1],
                                     [newItem[0], newItem[1], newItem[2]-1],       [newItem[0], newItem[1], newItem[2]+1],     [newItem[0], newItem[1]+1, newItem[2]-1],
                                     [newItem[0], newItem[1]+1, newItem[2]],       [newItem[0], newItem[1]+1, newItem[2]+1],   [newItem[0]+1, newItem[1]-1, newItem[2]-1],
                                     [newItem[0]+1, newItem[1]-1, newItem[2]],     [newItem[0]+1, newItem[1]-1, newItem[2]+1], [newItem[0]+1, newItem[1], newItem[2]-1],
                                     [newItem[0]+1, newItem[1], newItem[2]],       [newItem[0]+1, newItem[1], newItem[2]+1],   [newItem[0]+1, newItem[1]+1, newItem[2]-1],
                                     [newItem[0]+1, newItem[1]+1, newItem[2]],     [newItem[0]+1, newItem[1]+1, newItem[2]+1]]                        
                        for neighbor in neighbors:
                            if binary3DArray[neighbor[0], neighbor[1], neighbor[2]] == 1 and labels[neighbor[0], neighbor[1], neighbor[2]] == 0:
                                labels[neighbor[0], neighbor[1], neighbor[2]] = currentComponent
                                q.append([neighbor[0], neighbor[1], neighbor[2]])
                    currentComponent += 1
    return labels, currentComponent

