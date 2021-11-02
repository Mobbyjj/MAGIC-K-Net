% clear;
% clc;

ncoil = 1;

rootdir = '/home3/HWGroup/wangfw/BSTry2/B1000Multi_Coil_Co/';
tnames = {'di_yuchang','gao_ning','liang_jianqing','liu_yan','yan_jinlong','zhou_xiaofeng'};

b1K = [];
b1k = [];
for i = 1:length(tname)
    for j = 1:length(tname)
        tname = tnames(i);
        load([rootdir,tname,'/',tname(i),tname(j),'_2.mat']);
        b1K = cat(4,b1K,b1000);
    end
    b1k = cat(5,b1k,b1K);
    clear b1K;
    b1K = [];
end
save('showimg.mat','b1k');
