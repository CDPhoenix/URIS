# -*- coding: utf-8 -*-
"""
Created on Tue May 23 11:35:24 2023

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
from matRead import MatRead
from model import Model

path = 'D:/PolyU/year3 sem02/URIS/COMSOL Practice/3DCases/2023.05.11/'

cases = ['38_38_38_','38_76_38_','38_114_38_','38_114_76_','38_38_114_','38_76_114_','76_76_76_']

exper = ['ht.dfluxMag','T']

rowspaces = ['88','882','8858']

Flatten = 0
batch_size = 16
Tensorcontainer,Arraycontainer = [],[]

dataRead = MatRead(Tensorcontainer, Arraycontainer, path, cases, rowspaces, batch_size)

dataset = dataRead.datasetGenerate(Flatten)

hc = dataRead.paramsRead('hc')

train_data_X = dataset[0:4,:,:,:]
train_data_Y = hc[0:4]

test_data_X = dataset[4:7,:,:,:]
test_data_Y = hc[4:7]



model = Model(332,53,batch_size,5,1,1).cuda()
learning_rate = 0.0001
epoch = 1000
clip = 5.0
criterion = nn.MSELoss()
criterion = criterion.cuda()
optimizer =  optim.Adam(model.parameters(), lr=learning_rate)
Loss = []


sizes = list(dataset.size())

for j in range(epoch):
    
    for i in range(int(sizes[1]/batch_size)):
        data = train_data_X[:,i*batch_size:(i+1)*batch_size,:,:]
        output = model.forward(data,hc)
        loss = criterion(output,train_data_Y)
        loss.backward()
        torch.nn.utils.clip_grad_norm(model.parameters(), clip)
        optimizer.step()
    
    #loss_print = loss.item()
    #Loss.append(loss_print)
    #print(loss_print)
    
    if j % 10 == 0:
        loss_print = loss.item()
        Loss.append(loss_print)
        print(loss_print)

plt.figure()
plt.plot(Loss)

Error = []

for i in range(int(sizes[1]/batch_size)):
    data = test_data_X[:,i*batch_size:(i+1)*batch_size,:,:]
    output = model.forward(data,hc)
    error = (output - test_data_Y)/test_data_Y
    #loss = criterion(output,test_data_Y)
    Error.append(abs(error.cpu().detach().numpy()))

Error_avg = sum(Error)/len(Error)
plt.figure()
plt.plot(Error_avg)

Error_numpyMean = np.mean(Error)







