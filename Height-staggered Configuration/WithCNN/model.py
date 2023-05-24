# -*- coding: utf-8 -*-
"""
Created on Tue May 23 11:38:32 2023

@author: Phoenix WANG, Department of Mechanical Engineering, THE HONG KONG POLYTECHNIC UNIVERSITY
"""
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch import optim
import torchvision
import numpy as np
import pandas as pd

class Model(nn.Module):
    def __init__(self,width,depth,batch_size,kernel_size,stride,padding):
        super(Model, self).__init__()
        self.width = width
        self.depth = depth
        self.kernel_size = kernel_size
        self.stride = stride
        self.padding = padding
        self.channels = batch_size
                
        self.conv1 = nn.Conv2d(self.channels,32,self.kernel_size,self.stride,self.padding)
        
        self.width = self.width + 2*self.padding - (self.kernel_size-1)
        self.depth = self.depth + 2*self.padding - (self.kernel_size-1)
        
        self.conv2 = nn.Conv2d(32,64,self.kernel_size,self.stride,self.padding)
        
        self.width = self.width + 2*self.padding - (self.kernel_size-1)
        self.depth = self.depth + 2*self.padding - (self.kernel_size-1)
        
        self.conv3 = nn.Conv2d(64,3,self.kernel_size,self.stride,self.padding)
        
        self.width = self.width + 2*self.padding - (self.kernel_size-1)
        self.depth = self.depth + 2*self.padding - (self.kernel_size-1)
        
        
        
        self.flatten = nn.Flatten()
        self.fc1 = nn.Linear(self.width*self.depth*3,64)
        self.fc2 = nn.Linear(64,1)
        self.fc1_hc = nn.Linear(7,7)
        #self.fc3 = nn.Linear(2,16)
        self.fc3 = nn.Linear(1,16)
        self.fc4 = nn.Linear(16,1)
        self.act = nn.ReLU()
        
    def forward(self,Input,hc):
        x1 = self.conv1(Input)
        x2 = self.conv2(x1)
        x3 = self.conv3(x2)
        x3 = self.flatten(x3)
        fc1 = self.fc1(x3)
        fc2 = self.fc2(fc1)
        #hc = torch.tensor(hc).cuda()
        #hc = hc.to(torch.float32)
        #fc_1 = self.fc1_hc(hc)
        #fc_1 = torch.reshape(fc_1,(7,1))
        #x4 = torch.cat((fc_1,fc2),dim=1)
        #x5 = self.fc3(x4)
        x5 = self.fc3(fc2)
        output = self.fc4(x5)
        #output = self.act(x5)
        return output
    
#Siamese Neural Network