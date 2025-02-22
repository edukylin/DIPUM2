function d = bayesgauss(X, CA, MA, P)
%BAYESGAUSS Bayes classifier for Gaussian patterns.
%   D = BAYESGAUSS(X, CA, MA, P) computes the Bayes decision
%   functions of the n-dimensional patterns in the rows of X. CA is
%   an array of size n-by-n-by-W containing W covariance matrices of
%   size n-by-n, where W is the number of classes. MA is an array of
%   size n-by-W, whose columns are the corresponding mean vectors. A
%   covariance matrix and a mean vector must be specified for each
%   class. X is of size K-by-n, where K is the number of patterns
%   to be classified. P is a 1-by-W array, containing the
%   probabilities of occurrence of each class. If P is not included
%   in the argument, the classes are assumed to be equally likely.  
%
%   D is a column vector of length K. Its ith element is the class
%   number assigned to the ith vector in X during classification.  

%   Copyright 2002-2009 R. C. Gonzalez, R. E. Woods, and S. L. Eddins
%   From the book Digital Image Processing Using MATLAB, 2nd ed.,
%   Gatesmark Publishing, 2009.
%
%   Book web site: http://www.imageprocessingplace.com
%   Publisher web site: http://www.gatesmark.com/DIPUM2e.htm

% Verify number of inputs.
error(nargchk(3, 4, nargin)) 
n = size(CA, 1); % Dimension of patterns.

% Protect against the possibility that the class number is included
% as an (n + 1)th element of the vectors.
X = double(X(:, 1:n)); 
W = size(CA, 3); % Number of pattern classes.
K = size(X, 1);  % Number of patterns to classify.
if nargin == 3
   P(1:W) = 1/W; % Classes assumed equally likely.
else
   if sum(P) ~= 1 
      error('Elements of P must sum to 1.'); 
   end
end
% Compute the determinants.
for J = 1:W 
   DM(J) = det(CA(:, :, J)); 
end
    
% Evaluate the decision functions. Note the use of function
% mahalanobis discussed in Section 13.2.
MA = MA'; % Organize the mean vectors as rows.
for J = 1:W
   C = CA(:, :, J);
   M = MA(J, :);
   L(1:K, 1) = log(P(J));
   DET(1:K, 1) = 0.5*log(DM(J));
   if P(J) == 0;
      D(1:K, J) = -inf;
   else
      D(:, J) = L - DET - 0.5*mahalanobis(X, C, M);
   end
end

% Find the coordinates of the maximum value in each row. These
% maxima give the class of each pattern.
[i, j] = find(bsxfun(@eq, D, max(D, [], 2)));
% Re-use X. It contains now the max value along each column.
X = [i j]; 
% Eliminate multiple classifications of the same patterns. Since
% the class assignment when two or more decision functions give
% the same value is arbitrary, we need to keep only one.
X = sortrows(X);
[b, m] = unique(X(:, 1));
X = X(m, :);
% X is now sorted, with the 2nd column giving the class of the
% pattern number in the 1st col.;  i.e., X(j, 1) refers to the jth
% input pattern, and X(j, 2) is its class number.

% Output the result of classification. d is a column vector with
% length equal to the total number of input patterns. The elements
% of d are the classes into which the patterns were classified.
d = X(:, 2);

