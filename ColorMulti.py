import numpy as np
import os
import sys
import scipy.io as sio
import tensorflow as tf
from tensorflow.keras.layers import Add

# external project dependencies
sys.path.append(os.path.join(os.path.dirname("__file__"), 'ext', 'neuron'))
sys.path.append(os.path.join(os.path.dirname("__file__"), 'ext', 'pytools_lib'))

from ext.neuron.neurite.tf.layers import SpatialTransformer
## load the MSDATA
Org = sio.loadmat('/home2/HWGroup/wangfw/MAGICNET/BrainStorm/BSTry2/atlas_try/bai_jiacheng.mat')['Org']
MOrg = np.flip(np.transpose(np.abs(Org),[1,2,0,3]),0).astype(np.float32)
MOrg1k = MOrg[:, :, :, 0]

x_target_dir = r'/home3/HWGroup/wangfw/BSTry2/FLOW/'
x_target_list = os.listdir(x_target_dir)
savedir = r'/home3/HWGroup/wangfw/BSTry2/B0multi_contrast/'
flowcodir = r'/home3/HWGroup/wangfw/BSTry2/FLOW_CO/'
flowcodir_list = os.listdir(flowcodir)


for f in flowcodir_list:
    Mcolor = np.zeros(np.shape(MOrg1k) + (5,), dtype=np.float32)
    print(f)
    flowfilename = flowcodir + f + '/Flow_Core.mat'
    F = sio.loadmat(flowfilename)
    flow_color = F['FLOW_COLOR']
    flow_color_norm = flow_color/np.max(flow_color)
    ## for mag of the b1000,apply the flow_color with different range

    enlarge = [2,10,20,30,40]

    for m in range(len(enlarge)):
        flow_color_norm_1 = flow_color_norm * enlarge[m]
        transformed_out = Add(name='add_color_delta')([MOrg1k[np.newaxis,...,np.newaxis], flow_color_norm_1[np.newaxis,...]])
        MOrg1000color = np.squeeze(transformed_out.eval(session=tf.compat.v1.Session()))
        print(Mcolor.shape)
        print(MOrg1000color.shape)
        Mcolor[:,:,:,m] = MOrg1000color[:,:,:,1]
    savemat = savedir + f + '.mat'
    sio.savemat(savemat,{'Mcolor':Mcolor})

