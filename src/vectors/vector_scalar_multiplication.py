# importing numpy
import numpy as np

"""
Vector-Scalar Multiplication

Multiplying a vector by a scalar is called scalar multiplication. To perform scalar multiplication, we need to multiply the scalar by each component of the vector.
"""

# creating a 1-D list (Horizontal)
list1 = [1, 2, 3]

# creating first vector
vector = np.array(list1)

# printing vector1
print("Vector  : " + str(vector))

# scalar value
scalar = 2

# printing scalar value
print("Scalar  : " + str(scalar))

# getting scalar multiplication value
# s * v = (s * v1, s * v2, s * v3)
scalar_mul = vector * scalar

# printing dot product
print("Scalar Multiplication : " + str(scalar_mul))
