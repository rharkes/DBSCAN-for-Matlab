function [class]=fdbscan(xy,k,Eps)
%class(i) = 0 when point i is an outlier
%           1...65534 when part of a cluster (core or border)

%if kdtree is not yet compiled, try to do so.
if ~(exist('kdtree_build')==3)
    warning('mex file ''kdtree_build'' not found. Attempt to compile them from source')
    if ~exist('kdtree_build.cpp','file')
        error('source file ''kdtree_build.cpp'' not found. Please include the path to its location, for example by using addpath.')
        %addpath('..\kdtree-master\toolbox');
    else
        run kdtree_compile.m
    end
end

class = zeros(size(xy,1),1,'uint16');
cluster = 1;
tree = kdtree_build(xy);
%first classify every point as undefined (0)
%outliers will be classified as 1
while any(class==0)
    idx = find(class==0,1,'first'); %get an undefined point
    idxs = kdtree_ball_query(tree, xy(idx,:), Eps); % (find all points in Eps including self)
    if length(idxs)>(k+1) %core point
        cluster = cluster+1;
        class(idx)=cluster;
        idxs(class(idxs)>1)=[]; %no need to redo already allocated points
        class = expandcluster(xy,tree,class,Eps,k,idxs,cluster);
    else %outlier or border point, classify as outlier for now
        class(idx)=1;
    end
end
class = class-1; %(outliers were 1, now 0)
end

function [class] = expandcluster(xy,tree,class,Eps,k,idxs,cluster)
%check all idxs. If enough neighbors are within limits, expand with it.
%else add the borderpoint    
if isempty(idxs),return;end
class(idxs)=cluster; %add the unallocated and outliers to the cluster
%plot(xy(class==cluster,1),xy(class==cluster,2),'r.',xy(class~=cluster,1),xy(class~=cluster,2),'b.');drawnow

for ct = 1:length(idxs) %first one is self
    if class(idxs(ct))>1&&class(idxs(ct))~=cluster %already in another cluster
        continue;
    end    
    idxs2 = kdtree_ball_query(tree, xy(idxs(ct),:), Eps); % (find all points in radius Eps including self)
    if length(idxs2)>(k+1) %core point
        idxs2(class(idxs2)>1)=[]; %no need to redo already allocated points (including self)
        class = expandcluster(xy,tree,class,Eps,k,idxs2,cluster);
    else %idxs(ct) is a border point
    end
end
end
