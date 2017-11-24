function [] = create_image_files_from_figure_files(subjects, ...
                                                    figures_dir, ...
                                                    inputs, ...
                                                    format, resolution, ...
                                                    overwrite)
% This function creates images from saved figures

close all hidden

n_inputs = length(inputs);
n_subjects = length(subjects);

for subject_index = 1:n_subjects
    subject = subjects{subject_index};
    for input_index = 1:n_inputs
        input = inputs{input_index};
        full_path = fullfile(figures_dir, subject, input);
        file_ending = format((end-3):end);
        do_the_operation = overwrite || ...
            ~exist([full_path '.' file_ending], 'file');
        
        if do_the_operation
            disp(['Loading figure ' input ' for: ' subject])
            tic; h = openfig(full_path); toc;
            disp(['Saving image ' input ' for: ' subject])
            tic; print(h, full_path, format, resolution); toc;
            close all hidden
        else
            disp(['Image ' input ' already exists for: ' subject ...
                'Set "overwrite" to "true" to overwrite']);
        end
    end
end