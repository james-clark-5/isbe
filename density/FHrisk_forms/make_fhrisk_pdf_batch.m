function make_fhrisk_pdf_batch(xls_file, form_folder, sheet)

if nargin < 3
    sheet = 1;
end

%Read in the data from the excel spreadsheet
[dummy, dummy, patient_data] = xlsread(xls_file, sheet);

%Need to extract name, nhs_id and dob from each cell - this version assumes
% we have columns in the xls - Name, NHS no, Address DOB. Assume first row
% is header file so start from second row
for pp = 2:size(patient_data,1)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Column order:
    % FullName | NhsNumber | DateOfBirth | AppointmentDate
    try
        %Find the spaces in the name
        spaces = find(patient_data{pp,1} == ' ');

        %Take the surname name as the string before the first space (missing
        %out the comma)
        if isempty(spaces)
            second_name = patient_data{pp,1};
        else
            second_name = patient_data{pp,1}(1:spaces(1)-1);
            if strcmpi(second_name(end), ',')
                second_name(end) = [];
            end
        end

        %Similarly the second string
        full_name = patient_data{pp,1};

        %Take the dob from the 3rd column
        dob = patient_data{pp,3};
        if valid_date(dob)

        else
            display(['DOB is not valid. Skipping this patient:', full_name]);
            continue;
        end

        %for the numbers we need to check whether these are stored numerically
        %or as text

        %%Take the NHS id from the 2nd column
        nhs_error = false;
        nhs_id = patient_data{pp,2};   
        if ischar(nhs_id)
            %Find the spaces in the NHS id and discard
            nhs_id(nhs_id == ' ') = [];
            %convert nhs_id string into a number
            nhs_id = str2num(nhs_id); %#ok
            if isempty(nhs_id)
                nhs_error = true;
            end
        elseif ~isnumeric(nhs_id)
            %if not numeric and not a string we have a problem...
            nhs_error = true;
        end

        if isempty(nhs_error)
            %We have a problem with the nhs_id
            display(['NHS num is not valid. Skipping this patient:', full_name]);
            continue;
        end
        
        %Take the appointment date from the 4th column
        app_date = patient_data{pp,4};
        if valid_date(app_date)

        else
            display(['Appointment date is not valid. Skipping this patient:', full_name]);
            continue;
        end

        display(['Name: ' full_name ', ID: ' num2str(nhs_id) ' DOB: ' dob ' App date: ' app_date]);
        make_fhrisk_pdf(full_name, second_name, nhs_id, dob, app_date, form_folder);
    catch
        display(lasterr);
        display(['Skipping row: ', num2str(pp)]);
    end
end


function date_ok = valid_date(date_string)

    date_ok =...
        (length(date_string) == 8 && date_string(3) == '/' && date_string(6) == '/') ||...
        (length(date_string) == 10 && date_string(3) == '/' && date_string(6) == '/');
        

    
    