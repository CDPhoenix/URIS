# -*- coding: utf-8 -*-
"""
Created on Tue May 16 21:18:34 2023

@author: 86130
"""

import torch

# Create a 3-dimensional tensor
x = torch.randn(2, 3, 4)  # Shape: (batch_size, dim1, dim3)

# Transform `dim1` and `dim3`
x_transformed = x.permute(2,1,0)  # Permute `dim1` and `dim3`

# Print the shapes before and after transformation
print("Original shape:", x.shape)
print("Transformed shape:", x_transformed.shape)
