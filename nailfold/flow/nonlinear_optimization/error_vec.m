function [res, d_error,s_error, Jrows,Jcols] = ...
    error_vec(var_vec, sz_vec, observations, ...
              rho_function, f_clear_persistent)
% Compute the error vector for the parameters given.
% If more than four outputs are requested, the sparsity pattern of the
% Jacobian will also be returned as two vectors containing the row and
% column indices of the nonzeros.
          
if (nargin==0 && nargout==0), test(); return; end

if ~exist('f_clear_persistent','var'), f_clear_persistent = false; end

if f_clear_persistent
    brightness_error_vec([],[],[], true);
    smoothness_error_vec([],[],[], true);
    return
end
                                         
if ~exist('rho_function','var') || isempty(rho_function)
    rho_function = 'quadratic'; 
end
                                         
if (nargout >= 5)
    [d_error, p_test, JrowsD,JcolsD] = brightness_error_vec(var_vec, sz_vec, observations); 
    [s_error, JrowsS,JcolsS] = smoothness_error_vec(var_vec, sz_vec, observations);
    
    Jrows = [JrowsD; JrowsS+length(d_error)];
    Jcols = [JcolsD; JcolsS];
else
    d_error = brightness_error_vec(var_vec, sz_vec, observations); 
    s_error = smoothness_error_vec(var_vec, sz_vec, observations); 
end

% Compute weighted residual vector.
% This is the common weighting between prior (s) and likelihood (d) that is
% very wishy-washy.
a = 0.8;
res = [   a  * d_error; 
       (1-a) * s_error];
   
% Apply robust error function: 
%   'quadratic', 'charbonnier', 'lorentzian' or 'geman-mcclure'
if ~strcmp(rho_function, 'quadratic')
    res = sqrt(rho(res, rho_function));
end


function test()
clc;

[variables, observations, var_vec, sz_vec] = create_dummy_variables();

% Clear the persistents first
error_vec([],[],[],[], true);

[res, de, se, Jrows,Jcols] = ...
    error_vec(var_vec, sz_vec, observations, []);

nv = sum(sz_vec);
nr = length(res);

JP = sparse(Jrows,Jcols, 1, nr,nv);
HP = JP'*JP;

figure(1); clf;
    spy(JP);
      
figure(2); clf;
    spy(HP);
