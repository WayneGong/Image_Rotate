
m = 10;
n = 20;
a=[];
for i = 1:m
    for j = 1:n
        a(i,j) = i*j;
        
        sprintf ("%d,%d:%d\n",i,j,a(i,j))
    end
end
 