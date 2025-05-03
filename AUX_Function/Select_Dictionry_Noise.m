function [D,selected_dictionary] = Select_Dictionry_Noise(Y_mag,Dn,K_S,number_frame,type_noise,n_type)
Y_mag = Y_mag(:,1:number_frame);
m = size(Dn,2);
indx = cell(n_type,1);
for i = 1:n_type
    indx{i} = ((i-1)*m/n_type + 1 :(i)*m/n_type);
end 
param.L = K_S;
param.lambda=0.15; % not more than 20 non-zeros coefficients
param.numThreads=-1; % number of processors/cores to use; the default choice is -1
param.mode=2;        % penalized formulation

alpha = mexLasso(Y_mag,Dn,param);
alpha = full(alpha);
for i = 1:n_type
       norm_X(i) = sum(sum(alpha(indx{i},:).^2)); 
end


[~, highest_norm_index] = max(norm_X);

switch highest_norm_index
    case 1
        selected_dictionary = 'Babble';
        D = Dn(:,indx{1});
    case 2
        selected_dictionary = 'F16';
         D = Dn(:,indx{2});
    case 3
        selected_dictionary = 'Factory';
         D = Dn(:,indx{3});
    case 4
        selected_dictionary = 'Market';
        D = Dn(:,indx{4});
    case 5
        selected_dictionary = 'Piano';
        D = Dn(:,indx{5});
    case 6
        selected_dictionary = 'Police';
        D = Dn(:,indx{6});
    case 7 
        selected_dictionary = 'Street';
        D = Dn(:,indx{7});
    case 8
        selected_dictionary = 'Subway';
        D = Dn(:,indx{8});
    case 9
        selected_dictionary = 'Volvo';
        D = Dn(:,indx{9});
    case 10
        selected_dictionary = 'White';
        D = Dn(:,indx{10});
end
disp(['                Add noise is * * * ' , type_noise ])
disp(['  The selected dictionary is: ', selected_dictionary]);
