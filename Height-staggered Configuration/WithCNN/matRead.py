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
        self.parameters = {'NU':'NU',
                           'RE':'RE',
                           'LSC':'LSC',
                           'hc':'hc',
                           'PRs':'PRs',
                           'V':'V'}
        self.batch_size = batch_size
        self.CUDA = CUDA
        
    def datasetGenerate(self,Flatten):
        
        
        for j in range(len(self.rowspace)):
            
            for i in range(len(self.cases)):
                
                datafile = self.path + self.cases[i] + self.rowspace[j] + '.mat'
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
        params_temp = 0
        for i in range(len(self.rowspace)):
            param_path = self.path + self.parameters[param] + self.rowspace[i] + '.mat'
            params = scio.loadmat(param_path)[param][0]
            
            if target == 1:
                params = np.log10(params)
            
            params = params.astype(np.float64)
            params = torch.tensor(params)
            if i == 0:
                params_temp = params
            else:
                params_temp = torch.cat((params,params_temp),dim = 0)
                    
        
        if self.CUDA == True:
            params_temp = params_temp.cuda()
        
        params_temp = params_temp.to(torch.float32)
        params_temp = torch.reshape(params_temp,(list(params_temp.size())[0],1))
        
        return params_temp










