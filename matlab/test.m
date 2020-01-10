% ����ͼƬ
im = imread('1.jpg');

figure;
imshow(im); 

% �����ת����
a = -30 / 180 * pi;
R = [cos(a), -sin(a); sin(a), cos(a)];
 
% ���ͼƬ��С chΪͨ���� hΪ�߶� wΪ����
sz = size(im);
h = sz(1);
w = sz(2);
ch = sz(3);
c = [h; w] / 2;




      

% ��ʼ�����ͼ��
im2 = uint8(zeros(h, w, 3));
for k = 1:ch
    for i = 1:h
       for j = 1:w
          p = [i;j];
            
          % roundΪ��������
          pp = round(R*(p-c)+c);
          %����������صĲ���
          if (pp(1) >= 1 && pp(1) <= h && pp(2) >= 1 && pp(2) <= w)
             im2(i, j, k) = im(pp(1), pp(2), k); 
          end
       end
    end
end
 
% ��ʾͼ��
figure;
imshow(im2);