# -*- coding: utf-8 -*-
"""
Created on Tue May 16 11:24:44 2023

@author: Phoenix WANG, Department of Mechanical Engineering, THE HONG KONG POLYTECHNIC UNIVERSITY
"""

import scipy.io as scio
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch import optim
import torchvision
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

path = 'D:/PolyU/year3 sem02/URIS/COMSOL Practice/3DCases/2023.05.11/'

cases = ['38_38_38_','38_76_38_','38_114_38_','38_114_76_','38_38_114_','38_76_114_','76_76_76_']

exper = ['ht.dfluxMag','T']

rowspace = ['88']

NU_path = path + 'NU.mat'

RE_path = path + 'RE.mat'

LSC_path = path + 'LSC.mat'

Tensorcontainer,Arraycontainer = [],[]

Nusselt = scio.loadmat(NU_path)['NU'][0]

Nusselt = np.log10(Nusselt)



Reynold = scio.loadmat(RE_path)['RE'][0]*0.01

Lsc = scio.loadmat(LSC_path)['LSC'][0]

Flatten = 0

for i in range(len(cases)):
    
    datafile = path + cases[i] + rowspace[0] + '.mat'
    data = scio.loadmat(datafile)
    #data1 = torch.tensor(data['ArrayLog'])
    Arraycontainer.append(data['ArrayLog'])
    Tensorcontainer.append(torch.tensor(data['ArrayLog']).cuda())

#张量补零

Height_size = []

for i in range(len(Tensorcontainer)):
    
    Height_size.append(list(Tensorcontainer[i].size())[1])

Space_height = max(Height_size)

for i in range(len(Tensorcontainer)):
    
    sizes = list(Tensorcontainer[i].size())
    
    delta = Space_height - sizes[1]
    
    if delta != 0:
        zeros = torch.zeros(sizes[0],delta,sizes[2]).cuda()
        Tensorcontainer[i] = torch.cat((zeros,Tensorcontainer[i]),dim = 1)
    Tensorcontainer[i] = Tensorcontainer[i].permute(2,0,1)


#Flatten the data
batch_size = 16

if Flatten == 1:

    dataset = torch.Tensor(sizes[0]*len(Tensorcontainer),Space_height*sizes[2]).cuda()

    for i in range(len(Tensorcontainer)):
        Tensorcontainer[i] = torch.reshape(Tensorcontainer[i],(sizes[0],Space_height*sizes[2]))
        dataset[i*sizes[0]:(i+1)*sizes[0],:] = Tensorcontainer[i]
else:
    dataset = torch.Tensor(len(Tensorcontainer),sizes[2],sizes[0],Space_height).cuda()
    for i in range(len(Tensorcontainer)):
        dataset[i,:,:,:] = Tensorcontainer[i]

#data = scio.loadmat(path)

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
        self.fc1_Re = nn.Linear(7,7)
        self.fc3 = nn.Linear(2,16)
        self.fc4 = nn.Linear(16,1)
        self.act = nn.ReLU()
        
    def forward(self,Input,Re):
        x1 = self.conv1(Input)
        x2 = self.conv2(x1)
        x3 = self.conv3(x2)
        x3 = self.flatten(x3)
        fc1 = self.fc1(x3)
        fc2 = self.fc2(fc1)
        Re = torch.tensor(Re).cuda()
        Re = Re.to(torch.float32)
        fc_1 = self.fc1_Re(Re)
        fc_1 = torch.reshape(fc_1,(7,1))
        x4 = torch.cat((fc_1,fc2),dim=1)
        x5 = self.fc3(x4)
        output = self.fc4(x5)
        #output = self.act(x5)
        return output


model = Model(332,53,batch_size,5,1,1).cuda()

learning_rate = 0.001
epoch = 100
clip = 5.0
criterion = nn.MSELoss()
criterion = criterion.cuda()
optimizer =  optim.Adam(model.parameters(), lr=learning_rate)
Loss = []
Nusselt = torch.tensor(Nusselt).cuda()
Nusselt = Nusselt.to(torch.float32)
#Nusselt = torch.reshape(Nusselt,(len(Nusselt),1))
#Nusselt = F.normalize(Nusselt,p=2,dim=0)

for j in range(epoch):
    
    for i in range(int(sizes[2]/batch_size)):
        data = dataset[:,i*batch_size:(i+1)*batch_size,:,:]
        output = model.forward(data,Reynold)
        loss = criterion(output,Nusselt)
        loss.backward()
        torch.nn.utils.clip_grad_norm(model.parameters(), clip)
        optimizer.step()
    

    loss_print = loss.item()
    Loss.append(loss_print)
    print(loss_print)

plt.figure()
plt.plot(Loss)







