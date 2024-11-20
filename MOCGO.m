
%__________________________________________________________________     %
%        MOCGO: Multi-objective Chaos Game Optimization (MOCGO)         %
%                                                                       %
%                                                                       %
%                  Developed in MATLAB R2023a (MacOs)                   %
%                                                                       %
%                      Author and programmer                            %
%                ---------------------------------                      %
%                Nima Khodadadi (ʘ‿ʘ)   University of Miami             %
%                         SeyedAli Mirjalili                            %
%                             e-Mail                                    %
%                ---------------------------------                      %
%                      Nima.khodadadi@miami.edu                         %
%                                                                       %
%                                                                       %
%                            Homepage                                   %
%                ---------------------------------                      %
%                    https://nimakhodadadi.com                          %
%                                                                       %
%                                                                       %
%                                                                       %
%                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% ----------------------------------------------------------------------- %

function [Archive_costs]=MOCGO(MaxIt,Archive_size,Seed_Number,nVar,method,m)
if method==3
    TestProblem=sprintf('P%d',m);
    fobj = Ptest(TestProblem);
    xrange  = xboundaryP(TestProblem);
    nVar=max(size(xrange));
    % Lower bound and upper bound
    lb=xrange(:,1)';
    ub=xrange(:,2)';
end
%% MOCGO Parameters
alpha=0.1;  % Grid Inflation Parameter
nGrid=30;   % Number of Grids per each Dimension
beta=4; %=4;    % Leader Selection Pressure Parameter
gamma=2;    % Extra (to be deleted) Repository Member Selection Pressure
%% Initialization
CGO=CreateEmptyParticle(Seed_Number);
Seed=zeros(Seed_Number,nVar);
for i=1:Seed_Number
    CGO(i).Velocity=0;
    CGO(i).Position=zeros(1,nVar);
    for j=1:nVar
        CGO(i).Position(1,j)=unifrnd(lb(j),ub(j),1);
    end
    CGO(i).Cost=fobj(CGO(i).Position')';
    Seed(i,:)=CGO(i,:).Position;
    CGO(i).Best.Position=CGO(i).Position;
    CGO(i).Best.Cost=CGO(i).Cost;
end
CGO=DetermineDominations(CGO);
Archive=GetNonDominatedParticles(CGO);
Archive_costs=GetCosts(Archive);
G=CreateHypercubes(Archive_costs,nGrid,alpha);
for i=1:numel(Archive)
    [Archive(i).GridIndex Archive(i).GridSubIndex]=GetGridIndex(Archive(i),G);
end

%% Search Process of the CGO
for Iter=1:MaxIt
    for i=0:Seed_Number
        %% Generate New Solutions
        Leader=SelectLeader(Archive,beta);
        % Random Numbers
        I=randi([1,2],1,12); % For Beta and Gamma
        Ir=randi([0,1],1,5); % For Alpha
        % Random Groups
        RandGroupNumber=randperm(Seed_Number,1);
        RandGroup=randperm(Seed_Number,RandGroupNumber);
        % Mean of Random Group
        MeanGroup=mean(Seed(RandGroup,:)).*(length(RandGroup)~=1)...
            +Seed(RandGroup(1,1),:)*(length(RandGroup)==1);
        % New Seeds
        Alpha(1,:)=rand(1,nVar);
        Alpha(2,:)= 2*rand(1,nVar)-1;
        Alpha(3,:)= (Ir(1)*rand(1,nVar)+1);
        Alpha(4,:)= (Ir(2)*rand(1,nVar)+(~Ir(2)));
        ii=randi([1,4],1,3);
        SelectedAlpha= Alpha(ii,:);
        CGO(4*i+1,:).Position=SelectedAlpha(1,:).*(I(1)*Leader.Position-I(2)*MeanGroup);
        CGO(4*i+2,:).Position=Leader.Position+SelectedAlpha(2,:).*(I(3)*MeanGroup-I(4));
        CGO(4*i+3,:).Position=MeanGroup+SelectedAlpha(3,:).*(I(5)*Leader.Position-I(6));
        CGO(4*i+4,:).Position=unifrnd(lb,ub);
        for j=1:4
            % Checking/Updating the boundary limits for Seeds
            CGO(4*i+j,:).Position=min(max(CGO(4*i+j).Position,lb),ub);
            % Evaluating New Solutions
            CGO(4*i+j,:).Cost=fobj(CGO(4*i+j,:).Position')';
        end
    end
    CGO=DetermineDominations(CGO);
    non_dominated_CGO=GetNonDominatedParticles(CGO);
    Archive=[Archive
        non_dominated_CGO];
    Archive=DetermineDominations(Archive);
    Archive=GetNonDominatedParticles(Archive);
    for i=1:numel(Archive)
        [Archive(i).GridIndex Archive(i).GridSubIndex]=GetGridIndex(Archive(i),G);
    end
    if numel(Archive)>Archive_size
        EXTRA=numel(Archive)-Archive_size;
        Archive=DeleteFromRep(Archive,EXTRA,gamma);
        Archive_costs=GetCosts(Archive);
        G=CreateHypercubes(Archive_costs,nGrid,alpha);
    end
    disp(['In iteration ' num2str(Iter) ': Number of solutions in the archive = ' num2str(numel(Archive))]);
    save results
    costs=GetCosts(CGO);
    Archive_costs=GetCosts(Archive);
end
end
