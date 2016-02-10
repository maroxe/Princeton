%cd Documents/Princeton/ORF523/hw1/

%% Load Image
A=imread('nash.jpg');
A=im2double (A) ;
A=rgb2gray(A) ;
[m,n] = size(A);

%% SVD decomposition
[U,S,V] = svd(A);

%% arrays initialization
k_range = [25 50 100 200];
diff_norm = zeros('like', k_range);
total_savings = zeros('like', k_range);

%% Plot the original image
subplot(1,length(k_range)+1, 1);
imshow(A);
title('original')

for i = 1:length(k_range)
    k = k_range(i);
    Uk = U; Sk = S; Vk = V;
    Sk(k+1:end, k+1:end) = 0;
    Uk(:, k+1:end) = 0;
    Vk(:, k+1:end) = 0;
    Ak = Uk * Sk * Vk';
    diff_norm(i) = norm(A - Ak,'fro');
    total_savings(i) = prod(size(A)) ... % size of A
    - k*m ...% size of Uk
    - k*n ... % size of Vk
    - k; % size of Sigma
    
    subplot(1,length(k_range)+1, i+1);
    imshow(Ak);
    title(['k = ' int2str(k)])
end
print('compressed','-dpng')

%% Plot ||A_k - A||_F
figure
plot(k_range, diff_norm, ...
     '-*',...
     'LineWidth',2,...
     'MarkerEdgeColor','k',...
     'MarkerFaceColor',[.49 1 .63],...
     'MarkerSize',10)
title('||A_k - A||_F')
xlabel('k')
print('diffnorm','-dpng')

%% Plot total savings
figure
plot(k_range, total_savings,...
     '-*',...
     'LineWidth',2,...
     'MarkerEdgeColor','k',...
     'MarkerFaceColor',[.49 1 .63],...
     'MarkerSize',10)

title('Total savings')
xlabel('k')
print('totalsavings','-dpng')

%% Plot original and compressed for k = 200
figure
subplot(1,2, 1);
imshow(A);
title('original')
subplot(1,2, 2);
imshow(Ak);
title('k = 200')
print('compare','-dpng')

