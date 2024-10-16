x=50;
y=10;
im_classique=imread('../Image/text0.png');
nb_iteration = 100;
im_classique_double = double(im_classique);
patch_size = 7;
epsilon = 0.1

patch = ones (patch_size,patch_size,3, "uint8");

size_x = size(im_classique_double,1);
size_y = size(im_classique_double,2);
x = 130;
y = 130;
I = ones(x,x,3, "double");



patch(:,:,:) = im_classique_double((size_x / 2 - patch_size/2):(size_x / 2 + patch_size/2)-1, (size_x / 2 - patch_size/2):(size_x / 2 + patch_size/2)-1,:);

I((x/2-patch_size/2) : (x/2+patch_size/2)-1,(x/2-patch_size/2):(x/2+patch_size/2)-1,:) = patch(:,:,:);


im_mask = zeros(x,x,1);
im_mask((x/2-patch_size/2) : (x/2+patch_size/2)-1,(x/2-patch_size/2):(x/2+patch_size/2)-1,:) = 1;
neighbour_filter = [1,1,1;1,1,1;1,1,1];



moitie_patch = uint8(patch_size/2);
moitie_patch = double(moitie_patch);


 iterat = 0;

  borne_dico = double(size_x- (2* moitie_patch ));
  dico_ressemblance = zeros(borne_dico * borne_dico ,1);

  dico_x_min = zeros(borne_dico * borne_dico ,1);
  dico_y_min = zeros(borne_dico * borne_dico ,1);

while (iterat <= nb_iteration)
  im_neigh_mask = conv2(im_mask ,neighbour_filter,'same');
  im_neighbour = (1 - im_mask) .*  im_neigh_mask;
  im_bordure = zeros(size(im_neighbour,1),size(im_neighbour,2));
  im_bordure(moitie_patch+1:x-moitie_patch,moitie_patch+1:x-moitie_patch,:) = im_neighbour(moitie_patch+1:x-moitie_patch,moitie_patch+1:x-moitie_patch,:);
  [value,position] = max(im_bordure(:));
  [x_max,y_max]=ind2sub(size(im_bordure),position);



  patch_B = I(x_max - moitie_patch+1:x_max+moitie_patch-1,y_max-moitie_patch+1: y_max + moitie_patch-1,:);
  patch_M = im_mask(x_max - moitie_patch+1:x_max+moitie_patch-1,y_max-moitie_patch+1: y_max + moitie_patch-1);
  % indices = find( M <= (1+eps) min(M(:)) ) 
  mini = realmax;
% faire une matrice des ressemblance
  for ii=moitie_patch :size_x-moitie_patch
    for jj=moitie_patch:size_y-moitie_patch
        patch_A = im_classique_double(ii - moitie_patch+1:ii+moitie_patch-1,jj-moitie_patch+1: jj + moitie_patch-1,:);
        ressemblance = sum(sum(sum((patch_A-patch_B).^2,3).*patch_M));
        dico_ressemblance((jj- moitie_patch)+1 + (ii - moitie_patch)* borne_dico) =ressemblance; 
        dico_x_min((jj- moitie_patch)+1 + (ii - moitie_patch)* borne_dico) = ii;
        dico_y_min((jj- moitie_patch)+1 + (ii - moitie_patch)* borne_dico) = jj;
        if(ressemblance <= mini)
          
          mini = ressemblance;
          x_min = ii;
          y_min= jj;
        endif

      end
   end
   if(mini != 0)
    yoyo = mini;
   endif
   
   limite = (1+epsilon) * min(dico_ressemblance(:));
   indices = find( dico_ressemblance(:) <= limite ) ;
  

   valeur =     dico_ressemblance(ii + jj);
   aleatoire = uint8(1 + (size(indices,1)-1)*rand(1));
   if(aleatoire ==0)
    aleatoire = 1;
   endif

   indice_aleatoire =   indices(aleatoire);

   patch_trouve = im_classique(dico_x_min(indice_aleatoire) - moitie_patch+1:dico_x_min(indice_aleatoire)+moitie_patch-1,dico_y_min(indice_aleatoire)-moitie_patch+1: dico_y_min(indice_aleatoire) + moitie_patch-1,:);

    I(x_max,y_max,:) = patch_trouve(moitie_patch, moitie_patch,:);
    im_mask(x_max,y_max,:) = 1;

   iterat++

 endwhile
 
 

#wp tjr impair milieu = pixel  sert a voir la coherence des autres a coté
%wp

figure(2);
subplot(1,2,1)
imshow(im_classique,[])
title('normal')
subplot(1,2,2)
imshow(uint8(I),[])
title('converti')

