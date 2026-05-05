% This function requires the matlab2tikz package.
% It can be installed from:
%   https://github.com/matlab2tikz/matlab2tikz
% If it is not installed, run the following in the MATLAB console:
%   addpath(genpath('path_to_matlab2tikz'));
%   savepath;

function export_tikz_plot(fig, base_name, width, height)
    if nargin < 3
        width = '0.8\textwidth';
    end
    if nargin < 4
        height = '0.5\textwidth';
    end

    if exist('matlab2tikz', 'file') ~= 2
        error('export_tikz_plot:missingDependency', ...
            'matlab2tikz is not available on the MATLAB path.');
    end

    root_dir = fileparts(fileparts(mfilename('fullpath')));
    tex_path = fullfile(root_dir, [base_name '.tex']);

    matlab2tikz(tex_path, ...
        'figurehandle', fig, ...
        'showInfo', false, ...
        'standalone', false, ...
        'width', width, ...
        'height', height);
end
