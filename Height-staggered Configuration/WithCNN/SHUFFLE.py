# -*- coding: utf-8 -*-
"""
Created on Fri Jun  2 14:51:44 2023

@author: Phoenix WANG, Deparment of Mechanical Engineering, THE HONG KONG POLYTECHNIC UNIVERSITY
"""

import torch
import numpy as np
import random

def Shuffle(x,y,SEED = 6,use_cuda = True):

        random.seed(SEED)
        
        index = list(range(len(x)))
        random.shuffle(index)
        if use_cuda == True:
            TempX = torch.zeros(x.size()).cuda()
            TempY = torch.zeros(y.size()).cuda()
        else:
            TempX = torch.zeros(x.size())
            TempY = torch.zeros(y.size())
        
        for i in range(len(x)):
            TempX[index[i]] = x[i]
            TempY[index[i]] = y[i]
            
            
        
        return TempX,TempY
