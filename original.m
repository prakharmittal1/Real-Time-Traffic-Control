z=0;
for y=1:2 %loop for number of snapshots to be taken
cam=webcam(1); %defining object of webcam
for idx = 1:70 %delay for snapshot
  i0 = snapshot(cam);
  image(i0);
end

i1=rgb2gray(i0); %converting RGB image to greyscale
i2=imresize(i1,1/4); %resizing image
figure,imshow(i2);
id=imadd(i2,50); %enhancing intensity
figure,imshow(id); 
i3=im2double(i2); %converting image to double data type 
figure,imshow(i3); 
[m,n]=size(i3); 
% power law transformtion for image enhancement
c=1;
g=[0.5 0.7 0.9 1 2 3 4 5 6];
for r=1:length(g)
    for p=1:m
        for q=1:n
            i4(p,q)=c*(i3(p,q).^g(r));
        end
    end
figure,imshow(i4);
title('Power-law transformation');xlabel('Gamma='),xlabel(g(r));
end
[h, w] = size(i4);
% filtering image
filter = [0.0174 0.348 0.04348 0.0348 0.0174; 0.0348 0.0782 0.1043 0.0782 0.0348; 0.0435 0.1043 0.1304 0.1043 0.0435;0.0348 0.0782 0.1043 0.0782 0.0348; 0.0174 0.348 0.04348 0.0348 0.0174];
Mx = [-1 0 1; -2 0 2; -1 0 1];
My = [-1 -2 -1; 0 0 0; 1 2 1];
for v = 2 : 120
    for u = 2 : 120
        sum = 0;
        for i = -2 : 2
            for j = -2 : 2
                sum = sum + (i4(u,v)*filter(i+3, j+3));
            end
        end
        IDx(u,v) = sum;
    end
end

%APPLYING SOBEL MASK ON X-DIRECTION

for v = 2:119
         for u = 2:119
             
             sum1 = 0;
            
              for i=-1:1
                for j=-1:1
                    sum1 = sum1 + IDx(u+i,v+j)*Mx(i+2,j+2);
                end
              end
            IDxx(u,v) = sum1;
         end
end

%APPLYING SOBEL MASK ON Y-DIRECTION

for v = 2:119
         for u = 2:119
             
             sum2 = 0;
             
              for i=-1:1
                for j=-1:1
                 sum2 = sum2 + IDx(u+i,v+j)*My(i+2,j+2);
                end
              end
            IDyy(u,v) = sum2;
         end
end

for v = 2:119
   for u = 2:119
        mod(u,v) = abs(IDxx(u,v)) + abs(IDyy(u,v));
   end
end
supimg(u,v) = 0;
for v = 2 : 118
    for u = 2 : 118
        theta(u,v) = abs(atand(IDyy(u,v)/IDxx(u,v))); 
        ntheta(u,v)=0;
        if ((theta(u,v) >= 0) && (theta(u,v) <= 22.5) || (theta(u,v) >= 157.5) && (theta(u,v) <= 180))
            ntheta(u,v) = 0;
        end
        
        if ((theta(u,v) >= 22.5) && (theta(u,v) <= 67.5))
            ntheta(u,v) = 45;
        end
        
        if ((theta(u,v) >= 67.5) && (theta(u,v) <= 112.5))
            ntheta(u,v) = 90;
        end
        
        if ((theta(u,v) >= 112.5) && (theta(u,v) <= 180))
            ntheta(u,v) = 135;
        end
    
        %     N O N - M A X I M U M   S U P P R E S S I O N
       
        if ntheta(u,v) == 0
            if (mod(u, v) < mod(u-1, v) || mod(u, v) < mod(u+1, v))
                    supimg(u,v) = 0;
            else supimg(u,v)= mod(u,v);
            end
        end
            
         if ntheta(u,v) == 45
                if (mod(u, v) < mod(u+1, v-1) || mod(u, v) < mod(u-1, v+1))
                    supimg(u,v) = 0;
                else supimg(u,v)= mod(u,v);
                end
         end
                
            
         if ntheta(u,v) == 90
                if (mod(u, v) < mod(u, v-1) || mod(u, v) < mod(u, v+1))
                    supimg(u,v) = 0;
                else supimg(u,v)= mod(u,v);
                end
         end
               
          if ntheta(u,v) == 135
                if (mod(u, v) < mod(u-1, v-1) || mod(u, v) < mod(u+1, v+1))
                    supimg(u,v) = 0;    
                else supimg(u,v) = mod(u,v);%Supimg -- Image obtained after Non-mSupression
                end
          end
                
    end
end
    %    E N D  O F  N O N - M A X I M U M   S U P P R E S S I O N


%T H R E S H O L D I N G

th = 8.0;   %High Threshhold
%th = max(supimg);
tl = th/6; %Low Threshhold
gnh(u,v) = 0;
gnl(u,v) = 0;
for v = 2 : 118
    for u = 2 : 118
        if(supimg(u,v) >= th)
            gnh(u,v) = supimg(u,v);
        end
        if(supimg(u,v) >= tl)
            gnl(u,v) = supimg(u,v);
        end
     
    end
    
end
% E N D  OF T H R E S H O L D I N G
resimg = gnl - gnh;   %Edge of the Image 


%subplot (1, 2, 1),imshow(ID);axis image; title('Original Image');
%subplot (1, 2, 2),imshow(resimg);axis image; title('Canny Edge Image');

subplot (2, 3, 1),imshow(i4);axis image; title('Original Image');
subplot (2, 3, 2),imshow(IDx);axis image; title('Filtered Image');
subplot (2, 3, 3),imshow(IDxx);axis image; title('X- Direction Image');
subplot (2, 3, 4),imshow(IDyy);axis image; title('Y- Direction Image');
subplot (2, 3, 5),imshow(supimg);axis image; title('Non-Max Suppress');
subplot (2, 3, 6),imshow(resimg);axis image; title('Canny Edge');

if ((y==1) && (z==0))
    pic1=resimg;
else
    pic2=resimg;
end

%imshow(resimg);
pause(3);
clear cam;
end

ait_picmatch(pic1,pic2);
