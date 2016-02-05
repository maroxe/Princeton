A=imread('nash.jpg');
A=im2double (A) ;
A=rgb2gray(A) ;

[U,S,V] = svd(A);

k_range = [25 50 100 200]

subplot(1,length(k_range)+1, 1);
imshow(A);
title('original')

for i = 1:length(k_range)
    k = k_range(i)
    Uk = U; Sk = S; Vk = V;
    Sk(k:end, k:end) = 0;
    Uk(:, k:end) = 0;
    Vk(:, k:end) = 0;
    Ak = Uk * Sk * Vk';
    norm(A - Ak,'fro')
    subplot(1,length(k_range)+1, i+1);
    imshow(Ak);
    title(['k = ' int2str(k)])
end

