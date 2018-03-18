# 3DConnectedComponent

This a Cython implementation of the 26-Neighbors 3D Connected Component Algorithm which is used in image processing.

NOTE: This version of the function has severe performance issues. For a 255X512X512 binary matrix, the function 
takes approximately 5 minutes to be executed.

HOW TO USE:
1- On your command window, cd into folder that you keep the connectedComponent3D.pyx and connectedComponent3D_Setup.py files. 
2- Then, to compile the code, execute the following:
    python connectedComponent3D_Setup.py build_ext --inplace
3- To import the module, on your IDE or interactive shell, execute the following:
    import connectedComponent3D

EXAMPLE:
nOfComps, Labels = connectedComponent3D.main(array) function:

FURTHER EXPLANATION:
This is the main function. 

Input arguments: array -> The array which the connected component algorithm will be applied. This array should be binary and its
type should be 3D numpy array (dtype=np.int).

Returns:
nOfComps -> This is the number of distinct components found within the input array. Its type is int.

Labels -> This has the same dimensions with the input array. If an element belongs to background, then its label appears to be 0 in the
Labels array. If an element belongs to a component, then its label becomes a non-zero integer. The label of an element which is 
located at array[z, y, x] is saved at Labels[z, y, x]. 

BASIC FLOW OF THE ALGORITHM:

-The algorithm receives the 3D array as input. 

-It starts to iterate over each element of the input array. The input array has to be binary. 

-If an element of the input array is zero, nothing happens. 

-If an element of the input array is one, then its 26-neighbors are checked. By editing the line 99, it is possible to use the 
6-neighbors instead. The following link shows what 6-neighbors and 26-neighbors are. Link: http://slideplayer.com/slide/8645709/

-The neighbors which has a value of one in the input array and zero in the Labels array are saved as appropriate neighbors.

-If there is no appropriate neighbor around an element of the input array, this means this element is not connected to any component 
yet. Thus a new component number is assigned to this element and saved in the Labels array.

-However, if an element of the input array has one or more neighbors around it, the minimum of the different labels around the element
is assigned to that element as the label(A label shows to which component a particular element is connected to).

-All neighbors of an element are said to be connected to each other. These relationships are recorded inside equivalencydict variable.

-Due to the nature of the algorithm, after iterating through all of the elements of the input array, some components have different
labels alhtough they are connected to each other. Using the equivalency dict, this bug is fixed.

To learn more about connected component algorithm, watch the following video. It implements the 2D version of the algorithm. However,
this 3D algorithm is based on the same principle as the video below.
Video: https://www.youtube.com/watch?v=hMIrQdX4BkE&t=58s
