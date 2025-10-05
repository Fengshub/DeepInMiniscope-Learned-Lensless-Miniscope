%% list-RL algorithm test reconstruction
%  paper: DeepInMiniscope: Deep learning–powered physics-informed integrated miniscope (https://www.science.org/doi/10.1126/sciadv.adr6687)
%% load psf
a=readtable('lenscoordinates.xls')
a=table2array(a);
a=a*1000; % lens coordinates in um
%% load psf
p=zeros(3072,2048); % choose the pixel numbers based on input image size
% (a(idx,1)-3000)/2.9+1080/2
% (a(idx,2)-2000)/2.9+1920/2
pxsize=1.85; % pixel size in um
for idx=1:108
%     p(a(idx,1),a(idx,2))=1;
    ax=round((a(idx,1)-3000)/1.85+3072/2);ay=round((a(idx,2)-2000)/1.85+2048/2);
    if ax>=1 && ax<=3072 && ay>=1 && ay<=2048
        p(ax,ay)=1;
    % else
    %     bb=1;
    end
end
figure
imagesc(imgaussfilt(p',5));
p2=flip(p,1);
figure
imagesc(imgaussfilt(p2',5));
psf=p2'; % adjust psf referring to microlens array orientation
%%  ray tracing forward model (build pixel-voxel and voxel-pixel mappping lists)
srxmin=-0.0;srxmax=-0.0;srymin=-0.0;srymax=-0.0; % crop ratio of reconstruction FOV referring to input image size, -0.5 crops to center of frame, positive values extend reconstruction outside input image area
Sox=1;Soy=1;
Nx=2048;Ny=3072;
orx=2048/2;ory=3072/2;
dsr=3; % downsampling ratio
zc=8; % number of reconstruction depths
step=0.1; % reconstruction dpeth per step (mm)
base=4.9-floor(zc/2)*step; % start depth in object space from microlens array (mm)
sminx=1-Nx*srxmin;sminy=1-Ny*srymin;smaxx=Nx*(1+srxmax);smaxy=Ny*(1+srymax);
Nxo=round((smaxx-sminx)/dsr)+1;Nyo=round((smaxy-sminy)/dsr)+1;
h1=zeros(Nx*Ny,150); % mapped voxel indicies for every image pixel
h2=zeros(zc*Nxo*Nyo,50); % mapped pixel indicies for every reconstruction voxel

%---------------------=ray tracing forward model---------------------------
for ridx=1:zc % object depths
    disp(ridx)
    disd=base+step*(ridx-1); % object distance
    mag=1.6/disd; % magnification as ratio of image distance / object distance
    scale=1+mag;
    [cx0,cy0]=find(psf~=0);
    for idx1=sminx:dsr:smaxx % object x coordinate
        iidx1=ceil((idx1-sminx+1)/dsr);
        cx=round((cx0-idx1*Sox)*scale+idx1*Sox); % projected pixel x coordinates
        for idx2=sminy:dsr:smaxy % object y coordinate
            iidx2=ceil((idx2-sminy+1)/dsr);
            cy=round((cy0-idx2*Soy)*scale+idx2*Soy); % projected pixel y coordinates
            for idx3=1:length(cx)
                sx=cx(idx3)-idx1*Sox; % lateral x shift between mapped voxel and pixel
                sy=cy(idx3)-idx2*Soy; % lateral y shift between mapped voxel and pixel
                dis=sqrt(sx^2+sy^2); % lateral distance between mapped voxel and pixel
%                 if (cy(idx3)>1) && (cx(idx3)>1) && (cx(idx3)<=2048) && (cy(idx3)<=3072) &&(dis<1200)
                if (cy(idx3)>1) && (cx(idx3)>1) && (cx(idx3)<=Nx) && (cy(idx3)<=Ny) && (dis<1200) % condition for mapping to be included in forward model

                    h1((cy(idx3)-1)*Nx+cx(idx3),h1((cy(idx3)-1)*Nx+cx(idx3),1)+2)=(ridx-1)*Nxo*Nyo+(iidx2-1)*Nxo+iidx1; % vectorized voxel indicies (column-> row -> depth)
                    h1((cy(idx3)-1)*Nx+cx(idx3),1)=h1((cy(idx3)-1)*Nx+cx(idx3),1)+1; % number of mapped voxels for current pixel

                    h2((ridx-1)*Nxo*Nyo+(iidx2-1)*Nxo+iidx1,h2((ridx-1)*Nxo*Nyo+(iidx2-1)*Nxo+iidx1,1)+2)=(cy(idx3)-1)*Nx+cx(idx3); % vectorized pixel indicies (column -> row)
                    h2((ridx-1)*Nxo*Nyo+(iidx2-1)*Nxo+iidx1,1)=h2((ridx-1)*Nxo*Nyo+(iidx2-1)*Nxo+iidx1,1)+1; % number of mapped pixels for current voxel
                end
            end
        end
    end
end
%% load input image as im
im=load('polygonletters_raw.mat')
pz=zc; % number of reconstruction depths
obj=rand(Nxo*Nyo*pz,1); % initial guess of object
im=im/max(im(:));
img=reshape(im,[Nx*Ny,1]);
%% list-RL deconvolution basic version no regularization
maxIter=3;
correction=zeros(1,length(obj));
for n = 1:maxIter
    tic
    disp(['   iteration ',num2str(n)])
    C=zeros(length(img),1);
    for h1p=1:length(img)
        for h1v=2:h1(h1p,1)
            C(h1p)=C(h1p)+obj(h1(h1p,h1v));%*cos(atan(dis/1100))^2;
        end
    end
    C(C==0)=1;
    R=img./C;
    for h2v=1:length(obj)
        correction(h2v)=0;
        for h2p=2:h2(h2v,1)
            correction(h2v)=correction(h2v)+R(h2(h2v,h2p));
        end
        obj(h2v)=obj(h2v)*correction(h2v);
    end
    toc
end
%% plot reconstructed volume depth-by-depth
close all
nplane=zc;
medfiltsize=3;
obj2=reshape(obj,[Nxo Nyo nplane]);
obj3=zeros(size(obj2));

for idx=5:5%1:nplane
    figure
    tempm=obj2(:,:,idx);
    tempm=medfilt2(tempm,[medfiltsize medfiltsize]);
    tempm=(imgaussfilt(tempm,1));
    tempmimc=imgaussfilt(imdilate(tempm,ones(7)),15);
    tempm=(tempm./tempmimc);
    obj3(:,:,idx)=tempm;
    imagesc(imrotate(tempm,180))
    daspect([1 1 1])
    title(['depth ',num2str(idx)])
    % saveas(gcf, ['../../results/2D_',targetname,'/2D_',targetname,'_RL_depth',num2str(idx),'.png'])
end
