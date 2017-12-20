function [] = apply_across_subjects(subjects, data_dir, ...
                                    function_name, cfg, output, input, ...
                                    figures_dir, overwrite, ...
                                    running_on_grand_average)
% This function applies a function ("function name) across all subjects
% (a grand average). Input is/are the input file(s) and output is/are the
% output file(s)

% time total length of operation
tstart = tic;

% establish whether function should be run (does output already exist?)
output_path_data    = fullfile(data_dir, 'grand_averages');
output_path_figures = fullfile(figures_dir, 'grand_averages');
n_outputs = length(output);
save_names = cell(1, n_outputs);
for output_index = 1:n_outputs
    if isempty(figures_dir)
        save_names{output_index} = fullfile(output_path_data, ...
                                            output{output_index});
    else
        save_names{output_index} = fullfile(output_path_figures, ...
                                            output{output_index});
    end
end
n_subjects = length(subjects);


% should the operation be run?
do_the_operation = overwrite || ...
                   (~exist([save_names{1} '.mat'], 'file') && ...
                    ~exist([save_names{1} '.fig'], 'file')) || ...
                    (~isempty(figures_dir) && ~cfg.save_figure);

if do_the_operation
    if ~running_on_grand_average
        % data cell to put single subject data into
        data_cell = cell(1, n_subjects);
        % get the relevant data for each subject
        for subject_index = 1:n_subjects
            subject = subjects{subject_index};
            save_path = fullfile(data_dir, subject, 'ses-meg', 'meg');
            % establish input names
            n_inputs = length(input);
            load_names = cell(1, n_inputs);
            for input_index = 1:n_inputs
                load_names{input_index} = fullfile(save_path, ...
                                                   input{input_index});
            end
            % load input file(s)
            if ~iscell(input)
                error('Input must be specified as a cell array of strings')
            end
            input_variables = cell(1, n_inputs);
            for input_index = 1:n_inputs
                disp(['Loading ' input{input_index} ' for: ' ...
                      subject])
                % load as a struct
                tic; s = load(load_names{input_index}); toc
                input_variables{input_index} = s;
            end
            data_cell{subject_index} = input_variables;      
        end
    else %% running on grand averages
            % establish input names, (grand averages)
            n_inputs = length(input);
            load_names = cell(1, n_inputs);
            for input_index = 1:n_inputs
                load_names{input_index} = fullfile(output_path_data, ...
                                                   input{input_index});
            end
            input_variables = cell(1, n_inputs);
            for input_index = 1:n_inputs
                disp(['Loading ' input{input_index} ...
                      ' from grand_averages'])
                % load as a struct
                tic; s = load(load_names{input_index}); toc
                input_variables{input_index} = s;
            end
            data_cell = input_variables;            
    end
    % apply the function to all subjects
    output_variables = feval(function_name, cfg, data_cell);
    
    if ~iscell(output_variables)
        error('Output must be specified as a cell array of strings')
    end
    % save output
    n_outputs = length(output_variables);
    for output_index = 1:n_outputs
        output_variable = output_variables{output_index};
        % size of output variable
        temp = whos('output_variable');
        size_output_variable = temp.bytes;
        two_gigabyte = 2147483648;
        if size_output_variable >= two_gigabyte
            version = '-v7.3';
        else
            version = '-v7';
        end
        
        if isa(output_variable, 'matlab.ui.Figure') % is it a figure?
            if cfg.save_figure

                disp(['Saving figure ' output{output_index} ...
                        ' for: grand averages']);
                if size_output_variable < two_gigabyte
                    tic; savefig(output_variable, save_names{output_index});toc
                else
                    tic; hgsave(output_variable, save_names{output_index}, ...
                           '-v7.3'); toc
                end
            end
        else
            % save the mat file
            disp(['Saving ' output{output_index} ' in grand averages'])
            s = struct(output_variable); %#ok<*NASGU>
            tic;
            save([save_names{output_index} '.mat'], version, ...
                '-struct', 's'); toc
        end
    end
else
    disp([save_names{1} ' already exists. Set "overwrite" '... 
                'to "true" to overwrite']);
end

T = toc(tstart);
if do_the_operation
    fprintf(['\n\nApplying function: ' function_name ...
             ' for ' num2str(n_subjects) ' subject(s)' ...
             ' took: ' num2str(T) ' s; or: ' ...
             num2str(T/60) ' min.; or: ' ...
             num2str(T/3600) ' h\n\n'])
end