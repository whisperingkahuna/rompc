function [O_inf, kstar, lptime] = maximalPI(A, E, Phi, opt)
%[O_inf, kstar, lptime] = maximalPI(A, E, Phi, opt)
%
%Compute maximal admissible PI set given the constraint set Phi. See method from Kolmanovsky
%and Gilbert (1998).
%
% Inputs:
%   A: strictly stable system matrix, x = A*x
%   E: output matrix phi = E*x
%   Phi: constraint polyhedron on output phi (MPT3 Polyhedron)
%   opt: opt.solver specifies solver to use
%
% Returns:
%   O_inf: maximal admissible RPI set
%   kstar: number of iterations required to find RPI set
%   lptime: time spent solving linear programs

fprintf('Computing maximal admissible PI set [Kolmanovsky and Gilbert (1998)].\n');

N = size(Phi.A, 1);
lptime = 0;
Ho_k = Phi.A*E;
H_o = Ho_k;
b_o = Phi.b;

% Normalize support vectors
for i = 1:N
    nm = norm(H_o(i,:));
    H_o(i,:) = H_o(i,:)/nm;
    b_o(i,:) = b_o(i,:)/nm;
end

kmax = 1000;
for i = 1:kmax
    Ho_k = Ho_k*A;
    
    % Check termination conditions
    satisfied = ones(N,1);
    
    % Define support function for current O_k
    [prob] = supportFunction(size(H_o, 2), size(H_o, 1), opt);
    hO = prob([], H_o, b_o);
    max_change = 0;
    for j = 1:N
        [~,~,~,~,~,solver] = hO(Ho_k(j,:)');
        lptime = lptime + solver.solvertime;
        if solver.problem == 0
        	h_j = -solver.solveroutput.fval;
        elseif solver.problem == 2 % objective unbounded
        	h_j = inf;
        else
        	fprintf('Solver failed.\n');
			return;
        end
        
        % Check if adding constraint would change the set, if yes then add it
        if h_j > Phi.b(j)
            change = 100*abs(h_j - Phi.b(j))/h_j;
            if change > max_change
                max_change = change;
            end
            nm = norm(Ho_k(j,:));
            H_o = [H_o; Ho_k(j,:)./nm];
            b_o = [b_o; Phi.b(j)/nm];
            satisfied(j) = 0;
        end
    end
    
    % If no new constraints were added, O_k+1 = O_k
    if all(satisfied)
        break;
    else
        fprintf('k = %d, %d of %d constraints added, max change = %.2f%%.\n', i, N-sum(satisfied), N, max_change);
    end   
end

if i == kmax
    fprintf('Max iterations met.\n\n');
    O_inf = 0;
    kstar = 0;
else
    fprintf('Computed O_inf in %d iterations.\n\n', i);
    O_inf = Polyhedron(H_o, b_o);
    kstar = i-1;
end
end


