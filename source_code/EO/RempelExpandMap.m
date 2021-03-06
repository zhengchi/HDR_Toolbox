function expand_map=RempelExpandMap(L, video_flag)
%
%		 expand_map=RempelExpandMap(L, video_flag)
%
%
%		 Input:
%			-L: a luminance channel
%			-video_flag: a flag, true if a video is used
%
%		 Output:
%			-expand_map: the final expand map
%
%     Copyright (C) 2011  Francesco Banterle
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%

%saturated pixels threshold
thresholdImg=250/255;		%Images
thresholdVideo=230/255;		%Videos

if(~exist('video_flag'))
    video_flag = 0;
end

if(video_flag)
	threshold=thresholdVideo;
else
	threshold=thresholdImg;
end

%binary map for saturated pixels
mask=zeros(size(L));
mask(L>threshold)=1;
mask=double(bwmorph(mask,'clean'));

%Filtering with a 150x150 Gaussian kernel size
sbeFil=GaussianFilter(mask,30);

%Normalization
sbeFilMax=max(sbeFil(:));									
if(sbeFilMax>0.0)
	sbeFil=sbeFil/sbeFilMax;
end

%Calculation of the gradients of L using a 5x5 mask to have thick edges
Sy=[-1,-4,-6,-4,-1,...
       -2,-8,-12,-8,-2,...
       0,0,0,0,0,...
       2,8,12,8,2,...
       1,4,6,4,1];
Sx=Sy';

dy=imfilter(L,Sy);
dx=imfilter(L,Sx);

grad=sqrt(dx.^2+dy.^2);         %magnitude of the directional gradient
grad=grad/max(grad(:));

%threshold for the gradient
tr=0.05;                       

%maximum number of iteration for the flood fill
maxIter=2048;
for k=1:maxIter
    %Flood fill
    tmp=double(bwmorph(mask,'dilate'));
    tmp=abs(tmp-mask);
    val1 = sum(mask(:));
    mask((tmp>0.5)&grad<tr)=1;
   
    %ended?
    if((sum(mask(:))-val1)<1)
        break;
    end  
end

%Multiply the flood fill mask with the BEF
expand_map=sbeFil.*GaussianFilter(mask,1);
end