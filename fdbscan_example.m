%generate data
rndpts = 1E3;
cluster = 40;
pt_cluster = 50;
d_cluster = repmat(0.005,[1,cluster]);
xy = nan(rndpts+cluster*pt_cluster,2);
xy(1:rndpts,:)=rand(rndpts,2);
for ct = 1:cluster
    start = rndpts+1+(ct-1)*pt_cluster;
    finish = start+pt_cluster-1;
    ct
    loc = rand(1,2)
    xy(start:finish,:)=randn(pt_cluster,2)*d_cluster(ct)+loc;
end

%fdbscan
tic;class=fdbscan(xy,10,0.0065);toc
figure(1);clf;hold on;
Ncl = max(class);
pts=nan(1,Ncl);
for ct = 1:Ncl
    plot(xy(class==ct,1),xy(class==ct,2),'.');
    pts(ct) = sum(class==ct);
end
plot(xy(class==0,1),xy(class==0,2),'k.');
axis equal
title(sprintf('found %d clusters with on averages %.2f points',Ncl,mean(pts)))
