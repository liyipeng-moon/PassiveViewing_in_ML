function [C,timingfile,userdefined_trialholder] = dms2_userloop(MLConfig,TrialRecord)

C = [];
timingfile = 'dms2.m';
userdefined_trialholder = '';

% The very first call to this userloop function is made before a task
% starts and it is for retrieving the name(s) of the timing file(s).
% We will return without determining the trial condition for the first call.
persistent FirstCall
if isempty(FirstCall), FirstCall = true; return, end


% The code below selects a condition randomly without replacement and
% repeats error trials immediately.

% TrialRecord.CurrentTrialNumber of the n-th trial is (n-1) in the userloop.
persistent cond
if 0==TrialRecord.CurrentTrialNumber  % run only once
    % Conditions = { cond_num, sample, match, match_position, nonmatch, nonmatch_position }
    Conditions = { 1, 'A.bmp', 'A.bmp', [-6 0], 'B.bmp', [6 0]; 
        2, 'A.bmp', 'A.bmp', [6 0], 'B.bmp', [-6 0];
        3, 'B.bmp', 'B.bmp', [-6 0], 'A.bmp', [6 0];
        4, 'B.bmp', 'B.bmp', [6 0], 'A.bmp', [-6 0];
        5, 'C.bmp', 'C.bmp', [-6 0], 'D.bmp', [6 0]; 
        6, 'C.bmp', 'C.bmp', [6 0], 'D.bmp', [-6 0];
        7, 'D.bmp', 'D.bmp', [-6 0], 'C.bmp', [6 0];
        8, 'D.bmp', 'D.bmp', [6 0], 'C.bmp', [-6 0] };

    % Randomize conditions and add block numbers
    cond = [num2cell(ones(4,1)) Conditions(randperm(4),:);  % Block 1: A & B
        num2cell(2*ones(4,1)) Conditions(4+randperm(4),:);  % Block 2: C & D
        num2cell(3*ones(8,1)) Conditions(randperm(8),:) ];  % Block 3: A, B, C & D
end

% when all the conditions are used, end the task.
if isempty(cond)
    TrialRecord.NextBlock = -1;
    return
end

% Assign a new condition if the last trial was a success.
if isempty(TrialRecord.TrialErrors) || 0==TrialRecord.TrialErrors(end)  % TrialRecord.TrialErrors is empty at the beginning.
    % Userloop does not need the block and condition numbers. This is just
    % for your record keeping.
    TrialRecord.NextBlock = cond{1,1};      % block number
    TrialRecord.NextCondition = cond{1,2};  % condition number

    TrialRecord.User.cond = cond(1,3:end);
    cond(1,:) = [];                         % remove the used condition
end

