clear all
clc

% 读入图片
im = imread('1.jpg');

figure;
imshow(im); 

% 求出旋转矩阵
a = 20 / 180 * pi;
R = [cos(a), sin(a); -sin(a), cos(a)];
 
% 求出图片大小 ch为通道数 h为高度 w为宽度
sz = size(im);
h = sz(1);
w = sz(2);
ch = sz(3);
c = [w;h] /2;

%  fid=fopen('coordinate_30.txt','w');
%  fprintf(fid,"x1\t\ty1\t\tx0\t\t\tyo\n");
 
% 初始化结果图像
im2 = uint8(zeros(h, w, 3));
for k = 1:ch                    %遍历输出图像所有位置的像素
    for i = 1:h
       for j = 1:w  
          p = [j; i];           % p :输出图像的像素坐标
          % round为四舍五入
          pp = round(R*(p-c)+c);    %pp ：对应到输入图像的像素坐标
          %逆向进行像素的查找 
%             if(k==1)
%                 fprintf(fid,"%d,\t\t%d,\t\t%d,\t\t%d\t\n",i,j,pp(1),pp(2));
%             end          
            if (pp(1) >= 1 && pp(1) <= w && pp(2) >= 1 && pp(2) <= h)
                im2(i, j, k) = im(pp(2), pp(1), k);  
            end
       end
    end
end
 
% 显示图像
figure;
imshow(im2);