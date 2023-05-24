# -*- coding: utf-8 -*-
"""
Created on Tue May 16 11:24:44 2023

@author: Phoenix WANG, Department of Mechanical Engineering, THE HONG KONG POLYTECHNIC UNIVERSITY
"""

import scipy.io as scio
import torch
import numpy as np


class MatRead():
    def __init__(self,Tensorcontainer,Arraycontainer,path,cases,rowspace,batch_size,CUDA = True):
        self.tensor = Tensorcontainer
        self.Array = Arraycontainer
        self.path = path
        self.cases = cases
        self.rowspace = rowspace
        self.parameters = {'NU':'NU.mat',
                           'RE':'RE.mat',
                           'LSC':'LSC.mat',
                           'hc':'hc.mat',
                           'PRs':'PRs.mat'}
        self.batch_size = batch_size
        self.CUDA = CUDA
        
    def datasetGenerate(self,Flatten):
        
        for i in range(len(self.cases)):
            
                
            datafile = self.path + self.cases[i] + self.rowspace[0] + '.mat'
            data = scio.loadmat(datafile)
            #data1 = torch.tensor(data['ArrayLog'])
            self.Array.append(data['ArrayLog'])
            self.tensor.append(torch.tensor(data['ArrayLog']).cuda())
        
        #张量补零
        
        Height_size = []

        for i in range(len(self.tensor)):
            
            Height_size.append(list(self.tensor[i].size())[1])
        
        Space_height = max(Height_size)
        
        
        
        for i in range(len(self.tensor)):
            
            sizes = list(self.tensor[i].size())
            
            delta = Space_height - sizes[1]
            
            if delta != 0:
                zeros = torch.zeros(sizes[0],delta,sizes[2]).cuda()
                self.tensor[i] = torch.cat((zeros,self.tensor[i]),dim = 1)
            self.tensor[i] = self.tensor[i].permute(2,0,1)
        
        
        #Flatten the data
        if Flatten == 1:
        
            dataset = torch.Tensor(sizes[0]*len(self.tensor),Space_height*sizes[2]).cuda()
        
            for i in range(len(self.tensor)):
                self.tensor[i] = torch.reshape(self.tensor[i],(sizes[0],Space_height*sizes[2]))
                dataset[i*sizes[0]:(i+1)*sizes[0],:] = self.tensor[i]
        else:
            dataset = torch.Tensor(len(self.tensor),sizes[2],sizes[0],Space_height).cuda()
            for i in range(len(self.tensor)):
                dataset[i,:,:,:] = self.tensor[i]
        
        return dataset
    
    def paramsRead(self,param,target=1):
        param_path = self.path + self.parameters[param]
        params = scio.loadmat(param_path)[param][0]
        if target == 1:
            params = np.log10(params)
        
        params = torch.tensor(params)
        
        if self.CUDA == True:
            params = params.cuda()
        
        params = params.to(torch.float32)
        params = torch.reshape(params,(list(params.size())[0],1))
        
        return params










