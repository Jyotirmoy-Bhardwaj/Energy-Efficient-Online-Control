
% This CODE shows how to design an A2C agent to train over a water 
% distribution environment.

%--------------------------------------------------------
num_days = 2; % Number of days
[WaterDemand,T_max] = generateWaterDemand(num_days);
[energyPrice,T_max] = estimateEnergyPrice(num_days);
plot(WaterDemand)

%---------------------------------------------------------
mdl = "watertankscheduling";
open_system(mdl)

%---------------------------------------------------------
h0 = 3; % m
SampleTime = 1;
H_max = 7; % Max tank height (m)
A_tank = 40; % Area of tank (m^2)

%---------------------------------------------------------
actInfo = rlFiniteSetSpec([0,1,2,3,4,5,6]);

%actInfo = rlFiniteSetSpec([0,1,2,3]);
obsInfo = rlNumericSpec([1,1]);
env = rlSimulinkEnv(mdl,mdl+"/RL Agent",obsInfo,actInfo);
env.ResetFcn = @(in)localResetFcn(in);
%----------------Create AC Agent----------------------------
% Fix the random generator seed for reproducibility.
rng(0);

criticNetwork = [
    featureInputLayer(obsInfo.Dimension(1),'Normalization','none','Name','state')
    fullyConnectedLayer(32,'Name','CriticStateFC1')
    reluLayer('Name','CriticRelu1')
    fullyConnectedLayer(1, 'Name', 'CriticFC')];
criticNetwork = dlnetwork(criticNetwork);

criticOpts = rlOptimizerOptions('LearnRate',1e-2,'GradientThreshold',1);

critic = rlValueFunction(criticNetwork,obsInfo);


actorNetwork = [
    featureInputLayer(actInfo.Dimension(1),'Normalization','none','Name','state')
    fullyConnectedLayer(32, 'Name','ActorStateFC1')
    reluLayer('Name','ActorRelu1')
    fullyConnectedLayer(7,'Name','ActorStateFC2')
    softmaxLayer('Name','actionProb')];
actorNetwork = dlnetwork(actorNetwork);

actorOpts = rlOptimizerOptions('LearnRate',1e-2,'GradientThreshold',1);

actor = rlDiscreteCategoricalActor(actorNetwork,obsInfo,actInfo);
%actor = rlDiscreteCategoricalActor(actorNetwork,obsInfo,actInfo);


agentOpts = rlACAgentOptions(...
    'ActorOptimizerOptions',actorOpts, ...
    'CriticOptimizerOptions',criticOpts,...
    'EntropyLossWeight',0.01);


agent = rlACAgent(actor,critic,agentOpts);

trainOpts = rlTrainingOptions(...
    'MaxEpisodes',1000,...
    'MaxStepsPerEpisode',48,...
    'Verbose',false,...
    'Plots','training-progress',...
    'StopTrainingCriteria','AverageReward',...
    'StopTrainingValue',480,...
    'ScoreAveragingWindowLength',10); 


%Save agents using SaveAgentCriteria if necessary
trainOpts.SaveAgentCriteria = 'EpisodeReward';
trainOpts.SaveAgentValue = -42;

doTraining = true;
if doTraining
    set_param(mdl+"/Manual Switch",'sw','0');
    stats = train(agent,env,trainOpts);
else
    load("SimulinkWaterDistributionDQN.mat")       
end

%----------------------Simulate AC Agent ----------------------
set_param(mdl+"/Manual Switch",'sw','0');
NumSimulations = 30;
simOptions = rlSimulationOptions('MaxSteps',24,...
    'NumSimulations', NumSimulations);
env.ResetFcn("Reset seed");
experienceDQN = sim(env,agent,simOptions);




%-------Water Demand Function-----------------------
function [WaterDemand,T_max] = generateWaterDemand(num_days)

    t = 0:(num_days*24)-1; % hr
    T_max = t(end);
    %Demand_mean = [10, 20, 30, 40, 50, 60, 70, 60, 50, 40, 30, 20, 10, ...
     %   20, 30, 40, 50, 60, 70, 60, 50, 40, 30, 20]'; % m^3/hr

    

    Demand_mean = [28, 28, 28, 45, 55, 110, 280, 450, 310, 170, 160, 145, 130, ...
        150, 165, 155, 170, 265, 360, 240, 120, 83, 45, 28]'; % m^3/hr

    Demand = repmat(Demand_mean,1,num_days);
    Demand = Demand(:);

    % Add noise to demand
    a = -20; % m^3/hr
    b = 20; % m^3/hr
    Demand_noise = a + (b-a).*rand(numel(Demand),1);

    WaterDemand = timeseries(Demand + Demand_noise,t);
    WaterDemand.Name = "Water Demand";
end


%------Reset Function---------------------------------
function in = localResetFcn(in)

    % Use a persistent random seed value to evaluate the agent and the baseline
    % controller under the same conditions.
    persistent randomSeed
    if isempty(randomSeed)
        randomSeed = 0;
    end
    if strcmp(in,"Reset seed")
        randomSeed = 0;
        return
    end    
    randomSeed = randomSeed + 1;
    rng(randomSeed)
    
    % Randomize water demand.
    num_days = 2;
    H_max = 7;
    [WaterDemand,~] = generateWaterDemand(num_days);
    assignin('base','WaterDemand',WaterDemand)

    % Randomize initial height.
    h0 = 3*randn;
    %h0 = 3;
    while h0 <= 0 || h0 >= H_max
        h0 = 3*randn;
    end
    blk = 'watertankscheduling/Water Tank System/Initial Water Height';

    in = setBlockParameter(in,blk,'Value',num2str(h0));

end

%-----------Energy Price Function-----------------------

function [energyPrice,T_max] = estimateEnergyPrice(num_days)

    t = 0:(num_days*24)-1; % hr
    T_max = t(end);

    energy_mean = [1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2, 1, ...
        2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2]'; % m^3/hr

    
    %energy_mean = [28, 28, 28, 45, 55, 110, 280, 450, 310, 170, 160, 145, 130, ...
     %   150, 165, 155, 170, 265, 360, 240, 120, 83, 45, 28]'; % m^3/hr
    
    energy = repmat(energy_mean,1,num_days);
    energy = energy(:);
    %energy = 0.1*flip(energy);
    
    % Add noise to demand
    a = -1; % m^3/hr
    b = 1; % m^3/hr
    Demand_noise = a + (b-a).*rand(numel(energy),1);
    energyPrice = timeseries(energy + Demand_noise,t);
    energyPrice.Name = "Energy Price";
end










