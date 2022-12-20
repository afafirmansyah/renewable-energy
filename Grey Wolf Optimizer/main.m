clc;
clear;
close all;

h = figure(1); 
axis square; axis([0 100 0 100]); grid on; 
title('Use the left click (First Click Pos Prey other Whales)');
xlabel('Press a right click for exitting');
      
%% Input postion of Whales and Prey
exit = 0; X = cat(1); Y = cat(1); count=0;
while exit == 0
  [x, y, button] = ginput(1);     % Mouse input
  if(button == 3), exit = 1;      % Right click
   else    % Storing the coordinates
  
    if count==0
       Xprey = x;
       Yprey = y;
       plot(Xprey,Yprey,'ks','MarkerSize',12,'MarkerFaceColor',[1 0 1]);
     else
       X(length(X)+1) = x;
       Y(length(Y)+1) = y;
       plot(X,Y,'ro','MarkerSize',8,'MarkerFaceColor',[0 0 1]);
    end
    hold on;
    axis square; axis([0 100 0 100]); grid on; 
    title('Use the left click (First Click Pos Prey other Whales)');
    xlabel('Press a right click for exitting');
    count=count+1;
  end
end
hold off; close(h);


plot(Xprey,Yprey,'ks','MarkerSize',12,'MarkerFaceColor',[1 0 1]);
hold on;
plot(X,Y,'ro','MarkerSize',8,'MarkerFaceColor',[0 0 1]);

%% set GWO parametr
Costfunction=@(position,xprey,yprey) distance(position,xprey,yprey);
Max_iter=300; % Maximum numbef of iterations

dim=2;
lb=0;
ub=100;

%% % initialize alpha, beta, and delta_pos
Alpha_pos=zeros(1,dim);
Alpha_score=inf; %change this to -inf for maximization problems

Beta_pos=zeros(1,dim);
Beta_score=inf; %change this to -inf for maximization problems

Delta_pos=zeros(1,dim);
Delta_score=inf; %change this to -inf for maximization problems

%Initialize the positions of search agents
Positions=[X' Y'];

Convergence_curve=zeros(1,Max_iter);

l=0;% Loop counter

% Main loop
while l<Max_iter
    for i=1:size(Positions,1)  
        
       % Return back the search agents that go beyond the boundaries of the search space
        Flag4ub=Positions(i,:)>ub;
        Flag4lb=Positions(i,:)<lb;
        Positions(i,:)=(Positions(i,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;               
        
        % Calculate objective function for each search agent
        fitness=Costfunction(Positions(i,:),Xprey,Yprey);
        
        % Update Alpha, Beta, and Delta
        if fitness<Alpha_score 
            Alpha_score=fitness; % Update alpha
            Alpha_pos=Positions(i,:);
        end
        
        if fitness>Alpha_score && fitness<Beta_score 
            Beta_score=fitness; % Update beta
            Beta_pos=Positions(i,:);
        end
        
        if fitness>Alpha_score && fitness>Beta_score && fitness<Delta_score 
            Delta_score=fitness; % Update delta
            Delta_pos=Positions(i,:);
        end
    end
    
    
    a=2-l*((2)/Max_iter); % a decreases linearly fron 2 to 0
    
    % Update the Position of search agents including omegas
    for i=1:size(Positions,1)
        for j=1:size(Positions,2)     
                       
            r1=rand(); % r1 is a random number in [0,1]
            r2=rand(); % r2 is a random number in [0,1]
            
            A1=2*a*r1-a; % Equation (3.3)
            C1=2*r2; % Equation (3.4)
            
            D_alpha=abs(C1*Alpha_pos(j)-Positions(i,j)); % Equation (3.5)-part 1
            X1=Alpha_pos(j)-A1*D_alpha; % Equation (3.6)-part 1
                       
            r1=rand();
            r2=rand();
            
            A2=2*a*r1-a; % Equation (3.3)
            C2=2*r2; % Equation (3.4)
            
            D_beta=abs(C2*Beta_pos(j)-Positions(i,j)); % Equation (3.5)-part 2
            X2=Beta_pos(j)-A2*D_beta; % Equation (3.6)-part 2       
            
            r1=rand();
            r2=rand(); 
            
            A3=2*a*r1-a; % Equation (3.3)
            C3=2*r2; % Equation (3.4)
            
            D_delta=abs(C3*Delta_pos(j)-Positions(i,j)); % Equation (3.5)-part 3
            X3=Delta_pos(j)-A3*D_delta; % Equation (3.5)-part 3             
            
            Positions(i,j)=(X1+X2+X3)/3;% Equation (3.7)
            
        end
    end
    l=l+1;    
    Convergence_curve(l)=Alpha_score;
    
   disp(['Iteration:' num2str(l) '   Best  Fitness:' num2str(Convergence_curve(l))]);
   
   clf(figure(1));
   plot(Xprey,Yprey,'ks','MarkerSize',12,'MarkerFaceColor',[1 0 1]);
   hold on;

   plot(Positions(:,1),Positions(:,2),'ro','MarkerSize',8,'MarkerFaceColor',[0 0 1]);
    xlim([-10 110])
    ylim([-10 110])
   pause(0.01);
    
    
end

 
figure(2);
semilogy(Convergence_curve,'r','LineWidth',2);
xlabel('Iteration');
ylabel('Cost');



