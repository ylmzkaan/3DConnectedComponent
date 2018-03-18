# -*- coding: utf-8 -*-
"""
Created on Sun Mar 11 21:43:39 2018

@author: kaany
"""

import numpy as np
cimport numpy as np
cimport cython
from cpython cimport array
import array

@cython.wraparound(False)
@cython.nonecheck(False)
@cython.boundscheck(False)
def main(np.ndarray[np.int_t, ndim=3] arr):
    """
    Input arguments: arr -> The array which connected component algo. is applied 
                            type: 3D numpy array dtype=np.int
    Returns: numberOfComponents -> Number of distinct components in the input array -> int
             labels -> It has the same dims with input array. It contains the labels of each 
                       element inside the input array(label 0 is background)
                       
    equivalencydict -> Contains which component label is connected to which component label -> dict
    """
    cdef np.ndarray[np.int_t, ndim=3] labels = np.zeros_like(arr, dtype=np.int)
    cdef dict equivalencydict = {}
    cdef int numberOfComponents
    
    labels, equivalencydict = getConnectedComponents(arr, equivalencydict)
    labels = applyEquivalencyDictToLabels(labels, equivalencydict)
    numberOfComponents = len(np.unique(labels)) - 1
    return [numberOfComponents, labels]

@cython.wraparound(False)
@cython.nonecheck(False)
@cython.boundscheck(False)
cdef getConnectedComponents(np.ndarray[np.int_t, ndim=3] arr, dict equivalencydict): 
    """
    Input arguments: arr -> The array which connected component is applied -> 3D numpy array 
                            dtype=np.int
                     equivalencydict -> Contains which component label is connected to which 
                                         component label type: dict
    Returns: labels -> It has the same dims with input array. It contains the labels of each 
                       element inside the input array(label 0 is background)
             equivalencydict 
    
    
    For each element in the input array, if the element is True on the input array, the function
    checks the labeled neighbors of that element. If there is no labeled neighbor, the element
    gets a new label buy incrementing currentComp by 1. If there are labeled
    neighbors, then the minimum of the neighbor labels is assigned to the
    element.
    """
    cdef np.ndarray[np.int_t, ndim=3] labels = np.zeros_like(arr, dtype=np.int)
    cdef int currentComp = 0
    cdef int z
    cdef int y
    cdef int x
    cdef int zmax = arr.shape[0]
    cdef int ymax = arr.shape[1]
    cdef int xmax = arr.shape[2]
    cdef array.array neighborLabels = array.array('i', [])
    
    #Iterate over each element of arr
    for z in range(1, zmax - 1):
        print(z)
        for y in range(ymax):
            for x in range(xmax):
                if arr[z, y, x] == 0:
                    continue
                else:
                    neighborLabels = getNeighborLabels(arr, labels, (z, y, x))
                    labels, equivalencydict, currentComp = labeling(labels, neighborLabels, currentComp, 
                                                                    equivalencydict, z, y, x)
    return labels, equivalencydict

@cython.wraparound(False)
@cython.nonecheck(False)
@cython.boundscheck(False)
cdef getNeighborLabels(np.ndarray[np.int_t, ndim=3] arr, np.ndarray[np.int_t, ndim=3] labels, 
                       tuple centerIndex):
    """
    Input Arguments: centerIndex -> The index of the element which its neighbors are going to be searched
    Returns: neighborLabels -> It contains the labels of suitable neighbors
    (Neighbors which are true on the input array and are not labeled before during runtime are considered
    as suitable)
    
    neighbors: This is 2D numpy array which contains all the 26 neighbors around the element which is
               located at centerIndex(z, y, x)
    neighborsLabels: This is array which contains the labels of neighbors if there are any suitable
                     neighbors (Due to performance considerations, array is used instead of list)
    
    If a neighbor is True on the input array and if it has been labeled before during runtime
    (Otherwise it would be 0), then add the label of this neighbor to neighborLabels array.
    
    """
    cdef np.ndarray[np.int_t, ndim=2] neighbors = get26Neighbors(centerIndex)
    cdef array.array neighborLabels = array.array('i', [])
    cdef np.ndarray[np.int_t, ndim=1] neighbor_index
    
    for neighbor_index in neighbors:
        if arr[tuple(neighbor_index)] == 1 and labels[tuple(neighbor_index)] != 0:
            neighborLabels.append(labels[tuple(neighbor_index)])
    return neighborLabels

@cython.wraparound(False)
@cython.nonecheck(False)
@cython.boundscheck(False)
cdef applyEquivalencyDictToLabels(np.ndarray[np.int_t, ndim=3] labels, dict equivalencydict):
    """
    The equivalencydict is a sorted dictionary. By iterating over it in reverse direction, 
    the equivalencydict is applied to labels array.
    """
    cdef tuple item
    
    for item in sorted(list(equivalencydict.items()), key=lambda x:x[0], reverse=True):
        print(item)
        labels[labels == item[0]] = item[1]
    return labels

@cython.wraparound(False)
@cython.nonecheck(False)
@cython.boundscheck(False)
cdef get6Neighbors(tuple index):
    """
    Input arguments: index -> This is the index(z, y, x) of element whose neighbors are need to be
    calculated. type: tuple
    Returns: neighbors -> indices of 6-neighbors 
    
    This function calculates all 6 neighbors of an element in 3D space. 
    In order to see what a 6-neighbors is check the 29/38 slide in below link. Left figure is 6-n and
    right one is 26-neighbors.
    Link: http://slideplayer.com/slide/8645709/
    """
    cdef np.ndarray[np.int_t, ndim=2] neighbors = np.array([[index[0], index[1]-1, index[2]],
                                                           [index[0], index[1]+1, index[2]],
                                                           [index[0], index[1], index[2]-1], 
                                                           [index[0], index[1], index[2]+1],
                                                           [index[0]-1, index[1], index[2]], 
                                                           [index[0]+1, index[1], index[2]]], dtype=np.int)
    return np.resize(neighbors, (6,3))

@cython.wraparound(False)
@cython.nonecheck(False)
@cython.boundscheck(False)
cdef labeling(np.ndarray[np.int_t, ndim=3] labels, array.array neighborLabels, int currentComp,  
              dict equivalencydict, int z, int y, int x):
    """
    This function assigns the appropriate label to element(with indices z, y, x which are passed in as
    input arguments).
    If there is no suitable neighbor around the element(z, y, x) then a new component is created and
    assigned to the element. Else, the minimum of the neigbors' labels around the element is 
    assigned to the element.
    """
    if len(neighborLabels) == 0:
        currentComp += 1
        labels[z, y, x] = currentComp
    else:
        labels[z, y, x] = np.amin(neighborLabels)
        equivalencydict = addLabelsToEquivalencyDict(labels, neighborLabels,  
                                                     equivalencydict, z, y, x)
    return labels, equivalencydict, currentComp

@cython.wraparound(False)
@cython.nonecheck(False)
@cython.boundscheck(False)
cdef addLabelsToEquivalencyDict(np.ndarray[np.int_t, ndim=3] labels, array.array neighborLabels,  
                                dict equivalencydict, int z, int y, int x):
    """
    This function creates the spatial relationship between the neighbors of an element(z, y, x).
    The neighbors of an element are also connected to each other but they may not have the same
    component due to the complexity of the objects in the input array. Equivalencydict dictionary
    saves the information of which label is connected to which label. This equivalencydict is then
    applied to labels at the end of the main function.
    """
    cdef int label
    
    for label in neighborLabels:
        if label != labels[z, y, x]:
            equivalencydict[label] = labels[z, y, x]
    return equivalencydict

@cython.wraparound(False)
@cython.nonecheck(False)
@cython.boundscheck(False)
cdef get26Neighbors(tuple index):
    """
    Input arguments: index -> This is the index(z, y, x) of element whose neighbors are need to be
    calculated. type: tuple
    Returns: neighbors -> indices of 26-neighbors 
    
    This function calculates all 16 neighbors of an element in 3D space. 
    In order to see what a 26-neighbors is check the 29/38 slide in below link. Left figure is 6-n and
    right one is 26-neighbors.
    Link: http://slideplayer.com/slide/8645709/
    
    """
    cdef np.ndarray zz 
    cdef np.ndarray yy 
    cdef np.ndarray xx
    
    zz,yy,xx = np.mgrid[(index[0]-1):(index[0]+2) , (index[1]-1):(index[1]+2), (index[2]-1):(index[2]+2)]
    cdef np.ndarray[np.int_t, ndim=2] neighbors = np.vstack((zz.flatten(), yy.flatten(), xx.flatten())).T.astype(np.int)
    #Delete the center which is not a neighbor but the element itself and resize the neighbors
    np.delete(neighbors, [36,37,38])
    return np.resize(neighbors, (26,3))
