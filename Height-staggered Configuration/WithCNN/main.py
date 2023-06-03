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
from SHUFFLE import Shuffle

SEED = 6 #Proposed by Alice ZHAO

torch.manual_seed(SEED)
torch.cuda.manual_seed(SEED)

path = 'D:/PolyU/year3 sem02/URIS/COMSOL Practice/3DCases/2023.05.11/'

cases = ['38_38_38_','38_76_38_','38_114_38_','38_114_76_','38_38_114_','38_76_114_','76_76_76_']

exper = ['ht.dfluxMag','T']

rowspaces = ['88','882','8858']

Flatten = 0

batch_size = 16

Tensorcontainer,Arraycontainer = [],[]

dataRead = MatRead(Tensorcontainer, Arraycontainer, path, cases, rowspaces, batch_size)

dataset = dataRead.datasetGenerate(Flatten)

hc = dataRead.paramsRead('hc',target = 0)
U = dataRead.paramsRead('V',target = 0)
PowerInput = 100


hc = torch.cat((hc,U),dim=1)

dataset,hc = Shuffle(dataset,hc,SEED)

U = hc[:,-1]

hc = hc[:,0]
hc = hc.unsqueeze(1)


#hc = hc.unsqueeze(1)


train_data_X = dataset[0:14,:,:,:]
train_data_Y = hc[0:14]
train_backup = U[0:14]

test_data_X = dataset[14:,:,:,:]
test_data_Y = hc[14:]
test_backup = U[14:]


#Define Model and SGD
model = Model(332,53,332,53,batch_size,1,3,1,1).cuda()
learning_rate = 0.001
epoch = 100#220
clip = 5.0
criterion = nn.MSELoss()
criterion = criterion.cuda()
optimizer =  optim.Adam(model.parameters(), lr=learning_rate)
Loss = []

MAE = nn.L1Loss() #Absolute Error

sizes = list(dataset.size())

#Training

for j in range(epoch):
    
    for i in range(int(sizes[1]/batch_size)):
        data = train_data_X[:,i*batch_size:(i+1)*batch_size,:,:]
        Temp_array = data.unsqueeze(1)
        output = model.forward(Temp_array,data,train_backup,PowerInput)
        loss = torch.sqrt(criterion(output,train_data_Y))
        loss.backward()
        torch.nn.utils.clip_grad_norm_(model.parameters(), clip)
        optimizer.step()
    
    #loss_print = loss.item()
    #Loss.append(loss_print)
    #print(loss_print)
    
    if j % 1 == 0:
        loss_print = loss.item()
        Loss.append(loss_print)
        print(loss_print)
        #print("\r",end="")
        #print("Download progress: {}%: ".format(i), "▋" * (i // 2), end="")

#Loss.pop(0)

plt.figure()
plt.plot(Loss)

Error = []

#Testing

for i in range(int(sizes[1]/batch_size)):
    data = test_data_X[:,i*batch_size:(i+1)*batch_size,:,:]
    Temp_array = data.unsqueeze(1)
    output = model.forward(Temp_array,data,test_backup,PowerInput)
    #error = (output - test_data_Y)/test_data_Y
    loss = MAE(output,test_data_Y)/torch.mean(test_data_Y)
    Error.append(loss.cpu().detach().numpy())
    
Error_avg = sum(Error)/len(Error)

Error_numpyMean = np.mean(Error)
print(Error_numpyMean)


fig,ax = plt.subplots()
x = np.linspace(0,7,7)
ax.plot(x,test_data_Y.cpu().detach().numpy(),label='test_data')
ax.plot(x,output.cpu().detach().numpy(),label='Prediction')
ax.legend()
ax.set_title('Performance on test data')
ax.set_xlabel('Case number')
ax.set_ylabel('Coefficient of convective heat transfer')
ax.text(3.5,300,'Absolute avg Error: ' + str(Error_numpyMean))
plt.show()








