# 3DConnectedComponent

This a Cython implementation of the 26-Neighbors 3D Connected Component Algorithm which is used in image processing. The algorithm is based on Depth First Search.


HOW TO USE:

1- On your command window, cd into folder that you keep the connectedComponent3D.pyx and connectedComponent3D_Setup.py files. 

2- Then, to compile the code, execute the following:

    python connectedComponent3D_Setup.py build_ext -i
    
3- To import the module, on your IDE or interactive shell, execute the following:
    import connectedComponent3D

Example Code:
    numberOfConnectedComponents, connectedComponentLabels = connectedComponent3D.main(array) 

Input arguments: 

    binary3DArray -> The array which the connected component algorithm will be applied to. This array should be binary and its
    type should be 3D numpy array (dtype=np.int).

Returns:

    numberOfComponents -> This is the number of distinct components found within the input array. Its type is int.

    labels -> This has the same dimensions with the input array. If an element belongs to background, then its label appears 
    to be 0 in the labels array. If an element belongs to a component, then its label becomes a positive integer. 
    The label of an element which is located at binary3DArray[z, y, x] is saved at labels[z, y, x]. 



BASIC FLOW OF THE ALGORITHM:

-The algorithm receives a binary 3D array as input. 

-It starts to iterate over each element of the input array. 

-If an element of the input array is zero, nothing happens. 

-If an element of the input array is one, then its 26-neighbors are checked. The following link shows what 26-neighbors is. 
Link: http://slideplayer.com/slide/8645709/

-The neighbors which have a value of one in the input array and a value of zero in the labels array are pushed into a queue. These neighbors are called as appropriate neighbors.

-If there is no appropriate neighbor around an element of the input array, this means this element is not connected to any component 
yet. In this case, if the queue is non-empty, a new item is popped from the queue and its neighbors are checked. If the queue is empty, then a new component number is assigned to succeeding elements.

