import numpy as np

"""
Vector are built from components, which are ordinary numbers. We can think of a vector as a list of numbers, and vector algebra as operations performed on the numbers in the list. In other words vector is the numpy 1-D array.

Vector Dot Product
In mathematics, the dot product or scalar product is an algebraic operation that takes two equal-length sequences of numbers and returns a single number.
For this we will use dot method.
"""


# creating a 1-D list (Horizontal)
list1 = [5, 6, 9]

# creating a 1-D list (Horizontal)
list2 = [1, 2, 3]

# creating first vector
vector1 = np.array(list1)

# printing vector1
print("First Vector  : " + str(vector1))

# creating secodn vector
vector2 = np.array(list2)

# printing vector2
print("Second Vector : " + str(vector2))

# getting dot product of both the vectors
# a . b = (a1 * b1 + a2 * b2 + a3 * b3)
# a . b = (a1b1 + a2b2 + a3b3)
dot_product = vector1.dot(vector2)

# printing dot product
print("Dot Product   : " + str(dot_product))
