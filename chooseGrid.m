function grid = chooseGrid

% what is in the directory
gridFunctions = dir('grids/grid_*.m');

% print options for the user
fprintf_subtitle('Choose a grid:');
for ii = 1:length(gridFunctions)
  fprintf('  [%d]: %s\n', ii, gridFunctions(ii).name(6:end-2));
  %fprintf([ num2str(ii) '. ' d(ii).name(6:end-2) '\n']);
end
fprintf('\n');

% demand input
idx = demandnumberinput('      >>> ', 1:L(gridFunctions));
%idx = demandnumberinput(['Enter 1-' num2str(length(d)) ': '],1:length(d));

% return the grid
grid = feval(str2func(gridFunctions(idx).name(1:end-2)));