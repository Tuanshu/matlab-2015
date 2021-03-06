clear all
tic
% Data reading & stacking
folder_path='D:\151207_Jan related\151208_AMO update\2. Teeth\2. Ovine\2.2.3\2.2.3 Raw data\';

%parts=regexp(folder_path_without_index, '\','split');
%Parent_folder=folder_path_without_index(1:(length(folder_path_without_index)-length(parts{end})));

cmin=12;%12;%11
cmax_set=16;%16;%60;%120;%20;
X_offset=10;
Y_offset=30;

frame_width=648;
frame_height=488;


num_of_frame_per_division=16;

normalization_factor=50;


%%
division_number=0:30;
temp_frame_volume=zeros(frame_width,frame_height,num_of_frame_per_division*length(division_number));
cd(folder_path);
for NN=1:length(division_number)
    file_path=[folder_path sprintf('%08d',division_number(NN))];
    fin=fopen(file_path);
    A=fread(fin,[frame_width,frame_height*num_of_frame_per_division],'float32','b');
    if fin ==-1
        k=k+1;
        fclose('all');
    else
        for q=1:num_of_frame_per_division
        temp_frame_volume(:,:,(NN-1)*num_of_frame_per_division+q)=A(:,(frame_height*(q-1)+1):frame_height*q);
        end               
        fclose('all');
    end
    disp(NN);
end
%%

%Adjusted_Volume=(temp_frame_volume-cmin)/cmax_set;  %因為無從做max intensity判斷, 只好用固定值
%Adjusted_Volume(Adjusted_Volume<0)=0; 
%Adjusted_Volume(Adjusted_Volume>1)=1; 


%% B-scan
cmin=8;%12;%11
cmax_set=30;%16;%60;%120;%20;

NNN=136;
B_scan(:,:)=temp_frame_volume(:,NNN,:);
B_scan_Adjusted=(B_scan'-cmin)/cmax_set;
imagesc(B_scan_Adjusted);
    colormap('gray');
    caxis([0 1]);
    axis equal
    xlim([0 size(B_scan_Adjusted,2)]);
    ylim([0 size(B_scan_Adjusted,1)]);

%% Volume Reducing
Start_Searching_Index=120;
End_Searching_Index=300;
Reduced_Volume=permute(temp_frame_volume(:,:,Start_Searching_Index:End_Searching_Index),[2 1 3]);

%%
imagesc(Reduced_Volume(:,:,50));
    caxis([0 50]);

    colormap('gray');
    axis equal
    %%
NNN=136;
B_scan_Reduced(:,:)=Reduced_Volume(:,NNN,:);
B_scan_Reduced_Adjusted=(B_scan_Reduced'-cmin)/cmax_set;
imagesc(B_scan_Reduced_Adjusted);
    colormap('gray');
    caxis([0 1]);
    axis equal
    xlim([0 size(B_scan_Reduced_Adjusted,2)]);
    ylim([0 size(B_scan_Reduced_Adjusted,1)]);

%%
    
Q=132;
B_scan_Temp(:,:)=Reduced_Volume(:,Q,:);
B_scan_Temp_Adjusted=(B_scan_Temp'-cmin)/cmax_set;

imagesc(B_scan_Temp_Adjusted); 
colormap('gray');
caxis([0 1]);
axis equal
xlim([0 size(B_scan_Reduced_Adjusted,2)]);
ylim([0 size(B_scan_Reduced_Adjusted,1)]);

    %%
    %Q=5;
    %imagesc(Element(:,:,Q));
    
%%


%% 3D volume opening
Sphere_Radius=2;
Element=ones(Sphere_Radius*2+1,Sphere_Radius*2+1,Sphere_Radius*2+1);
Xgrid=ones(size(Element,1),size(Element,2),size(Element,3));
Ygrid=ones(size(Element,1),size(Element,2),size(Element,3));
Zgrid=ones(size(Element,1),size(Element,2),size(Element,3));

for p=1:size(Element,2)
    Xgrid(p,:,:)=p;
end
for q=1:size(Element,1)
    Ygrid(:,q,:)=q;
end
for w=1:size(Element,3)
    Zgrid(:,:,w)=w;
end

Element((((Xgrid-(Sphere_Radius+1)).^2+(Ygrid-(Sphere_Radius+1)).^2+(Zgrid-(Sphere_Radius+1)).^2).^0.5)>Sphere_Radius)=0;
    %%
    %Q=5;
    %imagesc(Element(:,:,Q));
    
%%
Opened_Volume=imopen(Reduced_Volume,Element);
Closed_Volume=imclose(Reduced_Volume,Element);

%% B-scan Opened
cmin=8;%12;%11
cmax_set=80;%16;%60;%120;%20;

NNN=136;
B_scan_Opened(:,:)=Opened_Volume(:,NNN,:);
B_scan_Opened_Adjusted=(B_scan_Opened'-cmin)/cmax_set;
imagesc(B_scan_Opened_Adjusted);
    colormap('gray');
    caxis([0 1]);
    axis equal
    xlim([0 size(B_scan_Opened_Adjusted,2)]);
    ylim([0 size(B_scan_Opened_Adjusted,1)]);

    
    
    
%% 3D volume opening along Z only
Sphere_Radius=2;
Element_Z=ones(1,1,Sphere_Radius*2+1);
Xgrid=ones(size(Element_Z,1),size(Element_Z,2),size(Element_Z,3));
Ygrid=ones(size(Element_Z,1),size(Element_Z,2),size(Element_Z,3));
Zgrid=ones(size(Element_Z,1),size(Element_Z,2),size(Element_Z,3));

for p=1:size(Element_Z,2)
    Xgrid(p,:,:)=p;
end
for q=1:size(Element_Z,1)
    Ygrid(:,q,:)=q;
end
for w=1:size(Element_Z,2)
    Zgrid(:,:,w)=w;
end

Element_Z((((Zgrid-(Sphere_Radius+1)).^2).^0.5)>Sphere_Radius)=0;
    %%
    Q=2;
    imagesc(Element_Z(:,:,Q));
    
%%
Opened_Z_Volume=imopen(Reduced_Volume,Element_Z);
%% B-scan Opened along Z
cmin=8;%12;%11
cmax_set=80;%16;%60;%120;%20;

NNN=136;
B_scan_Opened_Z(:,:)=Opened_Z_Volume(:,NNN,:);
B_scan_Opened_Z_Adjusted=(B_scan_Opened_Z'-cmin)/cmax_set;

subplot (3,1,1)

imagesc(B_scan_Reduced_Adjusted);
    colormap('gray');
    caxis([0 0.5]);
    axis equal
    xlim([0 size(B_scan_Reduced_Adjusted,2)]);
    ylim([0 size(B_scan_Reduced_Adjusted,1)]);
    axis off
subplot (3,1,2)

imagesc(B_scan_Opened_Adjusted);
    colormap('gray');
    caxis([0 0.5]);
    axis equal
    xlim([0 size(B_scan_Opened_Adjusted,2)]);
    ylim([0 size(B_scan_Opened_Adjusted,1)]);
    axis off
subplot (3,1,3)

imagesc(B_scan_Opened_Z_Adjusted);
    colormap('gray');
    caxis([0 0.5]);
    axis equal
    xlim([0 size(B_scan_Opened_Z_Adjusted,2)]);
    ylim([0 size(B_scan_Opened_Z_Adjusted,1)]);
    axis off

%%
%% Peak searching 

[max_value max_index_map_Reduced]=max(Reduced_Volume(:,:,:),[],3);
[max_value max_index_map_Opened_Reduced]=max(Opened_Volume(:,:,:),[],3);
[max_value max_index_map_Closed_Reduced]=max(Closed_Volume(:,:,:),[],3);
[max_value max_index_map_Opened_Z_Reduced]=max(Opened_Z_Volume(:,:,:),[],3);

max_index_map=max_index_map_Reduced+Start_Searching_Index-1;
max_index_map_Opened=max_index_map_Opened_Reduced+Start_Searching_Index-1;
max_index_map_Closed=max_index_map_Closed_Reduced+Start_Searching_Index-1;
max_index_map_Opened_Z=max_index_map_Opened_Z_Reduced+Start_Searching_Index-1;
%%
subplot (3,1,1)

imagesc(max_index_map);
    colormap('gray');
    axis equal
    xlim([0 size(max_index_map,2)]);
    ylim([0 size(max_index_map,1)]);
subplot (3,1,2)

imagesc(max_index_map_Opened);
    colormap('gray');
    axis equal
    xlim([0 size(max_index_map_Opened,2)]);
    ylim([0 size(max_index_map_Opened,1)]);
subplot (3,1,3)

imagesc(max_index_map_Opened_Z);
    colormap('gray');
    axis equal
    xlim([0 size(max_index_map_Opened_Z,2)]);
    ylim([0 size(max_index_map_Opened_Z,1)]);



%%
Height_map=max_index_map*0.2;

Height_map_Closed=max_index_map_Closed*0.2;
surf(30-Height_map_Closed(:,end:-1:1),'LineWidth',0.01,'EdgeAlpha',0.1);
axis equal
xlim([0 size(Height_map_Closed,2)]);
ylim([0 size(Height_map_Closed,1)]);
axis off
view(70,10);

%% Reversed Height map

Reversed_Height_map=30-Height_map;
imagesc(Reversed_Height_map);
axis equal

xlim([0 size(Height_map,2)]);
ylim([0 size(Height_map,1)]);
axis off
%% Running window removing outliner (outliner = point away from local mean by N std

Sample_Size=10;  %size of the matrix, must be odd number

%Weight_mask=ones(Sample_Size);
Weight_mask=fspecial('gaussian', Sample_Size,Sample_Size/4);    %gaussian mask
imagesc(Weight_mask);
colormap('gray');
axis equal
xlim([0 size(Weight_mask,2)]);
ylim([0 size(Weight_mask,1)]);
axis off

% std
Std_map=zeros(size(Height_map,1)-Sample_Size,size(Height_map,2)-Sample_Size);
for p=1:(size(Height_map,1)-Sample_Size+1)
    for q=1:(size(Height_map,2)-Sample_Size+1)
        Local_Sample=Height_map(p:(p+Sample_Size-1),q:(q+Sample_Size-1));
        Mean=mean(Local_Sample(:));
        Std_map(p,q)=(sum(sum(((Local_Sample-Mean).^2).*Weight_mask))).^0.5;
        
    end
end
%%
imagesc(Std_map);
colormap('gray');
axis equal
xlim([0 size(Std_map,2)]);
ylim([0 size(Std_map,1)]);
axis off

%% Z separation
First_index=10;
Second_index=10;
First_Zone=zeros(size(Reduced_Volume,1),size(Reduced_Volume,2),First_index);
Second_Zone=zeros(size(Reduced_Volume,1),size(Reduced_Volume,2),Second_index);

for p=1:size(Reduced_Volume,1)
    for q=1:size(Reduced_Volume,2)
        if max_index_map_Closed_Reduced(p,q)+First_index+Second_index<size(Reduced_Volume,3)
            First_Zone(p,q,:)=Reduced_Volume(p,q,(max_index_map_Closed_Reduced(p,q)+1):(max_index_map_Closed_Reduced(p,q)+First_index));
            Second_Zone(p,q,:)=Reduced_Volume(p,q,(max_index_map_Closed_Reduced(p,q)+First_index+1):(max_index_map_Closed_Reduced(p,q)+First_index+Second_index));
        elseif max_index_map_Closed_Reduced(p,q)+First_index<size(Reduced_Volume,3)
            First_Zone(p,q,:)=Reduced_Volume(p,q,(max_index_map_Closed_Reduced(p,q)+1):(max_index_map_Closed_Reduced(p,q)+First_index));
            Second_Zone(p,q,1:size(Reduced_Volume(p,q,(max_index_map_Closed_Reduced(p,q)+First_index+1):end),3))=Reduced_Volume(p,q,(max_index_map_Closed_Reduced(p,q)+First_index+1):end);
        else
            First_Zone(p,q,1:size(Reduced_Volume(p,q,(max_index_map_Closed_Reduced(p,q)+1):end),3))=Reduced_Volume(p,q,(max_index_map_Closed_Reduced(p,q)+1):end);
    
        end
    end
end

Ratio_Map=mean(Second_Zone,3)./mean(First_Zone,3);


imagesc(Ratio_Map(:,:));
caxis([0 2]);
colormap('gray');
axis equal
xlim([0 size(Second_Zone,2)]);
ylim([0 size(Second_Zone,1)]);
axis off

%% 示意圖
QQ=136;

subplot (2,1,1)

imagesc(B_scan_Reduced_Adjusted);
    colormap('gray');
    caxis([0 1]);
    axis equal
    xlim([0 size(B_scan_Reduced_Adjusted,2)]);
    ylim([0 size(B_scan_Reduced_Adjusted,1)]);
    axis off
    
    
subplot (2,1,2)

Forced_max=1;
Forced_min=0;
B_scan_Reduced_Adjusted_Note=repmat(B_scan_Reduced_Adjusted,[1 1 3]);
B_scan_Reduced_Adjusted_Note=(B_scan_Reduced_Adjusted_Note-Forced_min)/(Forced_max-Forced_min);
B_scan_Reduced_Adjusted_Note(B_scan_Reduced_Adjusted_Note>1)=1;
B_scan_Reduced_Adjusted_Note(B_scan_Reduced_Adjusted_Note<0)=0;

for p=1:size(B_scan_Reduced_Adjusted_Note,2)
    B_scan_Reduced_Adjusted_Note((max_index_map_Closed_Reduced(p,QQ)+1):(max_index_map_Closed_Reduced(p,QQ)+First_index),p,1)=1;
    B_scan_Reduced_Adjusted_Note((max_index_map_Closed_Reduced(p,QQ)+1):(max_index_map_Closed_Reduced(p,QQ)+First_index),p,2)=0;
    B_scan_Reduced_Adjusted_Note((max_index_map_Closed_Reduced(p,QQ)+1):(max_index_map_Closed_Reduced(p,QQ)+First_index),p,3)=0;

    B_scan_Reduced_Adjusted_Note((max_index_map_Closed_Reduced(p,QQ)+First_index+1):(max_index_map_Closed_Reduced(p,QQ)+First_index+Second_index),p,1)=0;
    B_scan_Reduced_Adjusted_Note((max_index_map_Closed_Reduced(p,QQ)+First_index+1):(max_index_map_Closed_Reduced(p,QQ)+First_index+Second_index),p,2)=1;
    B_scan_Reduced_Adjusted_Note((max_index_map_Closed_Reduced(p,QQ)+First_index+1):(max_index_map_Closed_Reduced(p,QQ)+First_index+Second_index),p,3)=0;
end
    

image(B_scan_Reduced_Adjusted_Note);
    axis equal
    xlim([0 size(B_scan_Reduced_Adjusted,2)]);
    ylim([0 size(B_scan_Reduced_Adjusted,1)]);
    axis off


%%

mkdir(sprintf('%s_stiched_image\\',folder_path_without_index));
imwrite(stiched_image_write,[sprintf('%s_stiched_image\\',folder_path_without_index),sprintf('stiched_image_offset%.1f micron_X%d_Y%d',(start_index_offset_from_max+(NNN-1)*stack_sampling_spacing)*0.2,X_mosaic_starting_index,Y_mosaic_starting_index),'.png']);
fout=fopen([sprintf('%s_stiched_image\\',folder_path_without_index),sprintf('stiched_image_offset%.1f micron_X%d_Y%d',(start_index_offset_from_max+(NNN-1)*stack_sampling_spacing)*0.2,X_mosaic_starting_index,Y_mosaic_starting_index)],'w+');
fwrite(fout,stiched_image,'float32','b');
    %dlmwrite([sprintf('%s_stiched_image\\',folder_path_without_index),sprintf('stiched_image_offset%.1f micron_X%d_Y%d',(start_index_offset_from_max+(NNN-1)*stack_sampling_spacing)*0.2,X_mosaic_starting_index,Y_mosaic_starting_index),'.txt'],stiched_image_write,'delimiter','\t','newline','pc','precision', '%.6f');


%%
imagesc(stiched_image_write);
    colormap('gray');
    caxis([0 1]);
    axis equal
    xlim([0 size(stiched_image,2)]);
    ylim([0 size(stiched_image,1)]);
    
    
    %fin=fopen([sprintf('%s_stiched_image\\',folder_path_without_index),sprintf('stiched_image_offset%.1f micron_X%d_Y%d',(start_index_offset_from_max+(NNN-1)*stack_sampling_spacing)*0.2,X_mosaic_starting_index,Y_mosaic_starting_index)]);
    %loaded_file=fread(fin,[size(stiched_image,1),size(stiched_image,2)],'float32','b');
    
    
    %imagesc(loaded_file);
    %colormap('gray');
    %caxis([0 1]);
    %axis equal
    %xlim([0 size(stiched_image,2)]);
    %ylim([0 size(stiched_image,1)]);
    %imagesc(histeq(stiched_image,[0 1]));
    %colormap('gray');
    %caxis([0 1]);
    %axis equal
    %xlim([0 size(stiched_image,2)]);
    %ylim([0 size(stiched_image,1)]);
    
    
    %fin2=fopen([cd,'\divide\',sprintf('stiched_image_%.1f micron',(starting_frame_index+(NNN-1)*frame_average_factor)*0.2)]);
    %QQQ=fread(fin2,[size(stiched_image,1),size(stiched_image,2)],'float32','b');

    %imagesc(histeq(stiched_image,[0.2:0.001:0.5]));

    %for QQQ=1:4
    %    Normailzed_image=(mean(stiched_volume(:,:,((QQQ-1)*4+1):((QQQ)*4)),3)-cmin)/cmax;
    %    Normailzed_image(Normailzed_image>1)=1;
    %    %stiched_images(:,:,NN)=mean(stiched_volume,3);
    %    imwrite(Normailzed_image,[cd,'\divide\',sprintf('stiched_image_%d.png',(NN-1)*4+QQQ),'.png']);
    %end
    %for QQQ=1:16
    %    Normailzed_image=(mean(stiched_volume(:,:,QQQ),3)-cmin)/cmax;
    %    Normailzed_image(Normailzed_image>1)=1;
        %stiched_images(:,:,NN)=mean(stiched_volume,3);
    %    imwrite(Normailzed_image,[cd,'\divide3\',sprintf('stiched_image_%d.png',(NN-1)*16+QQQ),'.png']);
    %end
    %stiched_volume=zeros(frame_width_eff*X_mosaic_number+X_overlapping,frame_height_eff*Y_mosaic_number+Y_overlapping,num_of_frame_per_division);
toc
%
disable=1;
if disable==0
frame_starting_index=85;
total_frame_number=20;

%stiched_image=mean(stiched_volume(:,:,frame_starting_index:(frame_starting_index+total_frame_number-1)),3);


%
NNN=1;
stiched_image=stiched_images(:,:,NNN);

imagesc(stiched_image);
colormap('gray');
caxis([cmin cmax]);
axis equal
xlim([0 size(stiched_image,2)]);
ylim([0 size(stiched_image,1)]);

Normailzed_image=(stiched_image-cmin)/cmax;
Normailzed_image(Normailzed_image>1)=1;

imagesc(Normailzed_image);
colormap('gray');
caxis([0 1]);
axis equal
xlim([0 size(stiched_image,2)]);
ylim([0 size(stiched_image,1)]);

%% Stacking
%Frame_spacing=5;
%Stacking_starting_frame=1;
%Total_stacked_frame_number=38;

%for qq=1:Total_stacked_frame_number
%    findex=Stacking_starting_frame+(qq-1)*Frame_spacing;
%    stiched_image=mean(stiched_volume(:,:,findex:(findex+total_frame_number-1)),3);
%    Normailzed_image=(stiched_image-cmin)/cmax;
%    Normailzed_image(Normailzed_image>1)=1;
%    imwrite(Normailzed_image,[cd,'\divide\',sprintf('averaged_frame_%d.png',qq),'.png']);
%end

end
 fclose all