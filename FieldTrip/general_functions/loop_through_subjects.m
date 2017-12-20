function [] = loop_through_subjects(subjects, data_dir, ...
                        function_name, cfg, output, input, figures_dir, ... 
                        overwrite)
% This function loops through all subjects, applies the supplied function
% ("function_name") with the given configuration ("cfg") and spits out the 
% output ("output") given the input ("input").

% time total length of operation
tstart = tic;

n_subjects = length(subjects);

for subject_index = 1:n_subjects
    % set save path and save name
    subject = subjects{subject_index};
	save_path = fullfile(data_dir, subject, 'ses-meg', 'meg');
    figures_path = fullfile(figures_dir, subject);
    % establish input names
    n_inputs = length(input);
    load_names = cell(1, n_inputs);
    for input_index = 1:n_inputs
        load_names{input_index} = fullfile(save_path, input{input_index});
    end
    % establish output names
    n_outputs = length(output);
    save_names = cell(1, n_outputs);
    for output_index = 1:n_outputs
        if isempty(figures_dir)
            save_names{output_index} = fullfile(save_path, ...
                                                output{output_index});
        else
            save_names{output_index} = fullfile(figures_path, ...
                                                output{output_index});
        end
    end

    % check if file exists and whether overwriting is permitted
    do_the_operation = overwrite || isempty(output) || ...
                      (~exist([save_names{1} '.mat'], 'file') && ...
                       ~exist([save_names{1} '.fig'], 'file')) || ...
                       (~isempty(figures_dir) && ~cfg.save_figure);
    if do_the_operation
        % load input file(s) (if not empty)
        if ~isempty(input)
            if ~iscell(input)
                error('Input must be specified as a cell array of strings')
            end
            n_inputs = length(input);
            input_variables = cell(1, n_inputs);
            for input_index = 1:n_inputs
                disp(['Loading ' input{input_index} ...
                    ' for: ' subject])
                % load as a struct
                tic; s = load(load_names{input_index}); toc 
                input_variables{input_index} = s; 
            end
        else
            input_variables = save_path; %% path for non-mat files
        end
        % some functions require the subject and save_path
        cfg.subject = subject;
        cfg.save_path = save_path;
        % evaluate function and assign to "output_variable
        tic;
        output_variables = feval(function_name, cfg, input_variables);
        T = toc;
        fprintf(['\n\nApplying function: ' function_name ...
                ' for subject: ' ...
                subject ' took: ' num2str(T) ' s; or: ' ...
                num2str(T/60) ' min.; or: ' ...
                num2str(T/3600) ' h\n\n'])
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
                            ' for: ' subject]);
                    if size_output_variable < two_gigabyte
                        tic; 
                        savefig(output_variable, save_names{output_index});
                        toc
                    else
                        tic;
                        hgsave(output_variable, ...
                                save_names{output_index}, '-v7.3'); toc
                    end
                end
            else
                % save the mat file
                disp(['Saving ' output{output_index} ' for: ' ...
                        subject])
                s = struct(output_variable); %#ok<*NASGU>
                tic;
                save([save_names{output_index} '.mat'], version, ...
                    '-struct', 's'); toc
            end    
        end
    else
        disp([save_names{1} ' already exists. Set "overwrite" to "true"'...
                          ' to overwrite']);
    end
end

T = toc(tstart);
if do_the_operation
    fprintf(['\n\nApplying function: ' function_name ...
             ' for ' num2str(n_subjects) ' subject(s)' ...
             ' took: ' num2str(T) ' s; or: ' ...
             num2str(T/60) ' min.; or: ' ...
             num2str(T/3600) ' h\n\n'])
end
