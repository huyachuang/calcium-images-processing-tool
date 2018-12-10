function varargout = one_clicke(varargin)
% ONE_CLICKE MATLAB code for one_clicke.fig
%      ONE_CLICKE, by itself, creates a new ONE_CLICKE or raises the existing
%      singleton*.
%
%      H = ONE_CLICKE returns the handle to a new ONE_CLICKE or the handle to
%      the existing singleton*.
%
%      ONE_CLICKE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ONE_CLICKE.M with the given input arguments.
%
%      ONE_CLICKE('Property','Value',...) creates a new ONE_CLICKE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before one_clicke_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to one_clicke_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help one_clicke

% Last Modified by GUIDE v2.5 23-Nov-2018 11:04:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @one_clicke_OpeningFcn, ...
                   'gui_OutputFcn',  @one_clicke_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%**************************************************************************%
function Image_ButtonDownFcn(hObject,eventdata, handles)
global CaSignal
CaSignal = image_buttonDown_fcn(hObject,eventdata, handles, CaSignal);
CaSignal = Update_Image_Fcn(handles, CaSignal, true);

function CaSignal = Update_Image_Fcn(handles, CaSignal, restore_zoom)
CaSignal = update_image_show(handles, CaSignal, restore_zoom);
CaSignal.h_image.ButtonDownFcn = {@Image_ButtonDownFcn, handles};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes just before one_clicke is made visible.
function one_clicke_OpeningFcn(hObject, eventdata, handles, varargin)
global CaSignal
handles.output = hObject;
% initialize CaSignal
% about ROI
CaSignal.ROIs = {};
CaSignal.ROI_num = 0;
CaSignal.ROI_T_num = 0;
CaSignal.TempROI = {};
CaSignal.ROIDiameter = 12;

% about showing image
CaSignal.imagePathName = pwd;
CaSignal.showing_image = [];
CaSignal.imageFilename = '';
CaSignal.imagePathName = '';
CaSignal.mean_images = [];
CaSignal.max_images = [];
CaSignal.max_mean_image = [];
CaSignal.showing_image = [];
CaSignal.current_trial = 0;
CaSignal.total_trial = 0;
CaSignal.top_percentile = 100.0;
CaSignal.bottom_percentile = 0.0;
% about showing sub_image
CaSignal.TempXY = [64, 64];
CaSignal.RedrawBasedOnTempROI = true;
CaSignal.SummarizedMask = [];
%about machine learning
CaSignal.imageData = [];

CaSignal.localFCNModelFilename = '';
CaSignal.localFCNModelPathName = '';
CaSignal.localFCNModel = [];
CaSignal.ROIDetectorFilename = '';
CaSignal.ROIDetectorPathName = '';
CaSignal.ROIDetector = [];

set(handles.ModelPathEdit, 'String', pwd);
set(handles.ROIDetectorPathEdit, 'String', pwd);
cd(fileparts(which(mfilename)));
addpath('./utils');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes one_clicke wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = one_clicke_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on button press in ChoseFileButton.
function ChoseFileButton_Callback(hObject, eventdata, handles)


function DataPathEdit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function DataPathEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over axes background.
function ImageShowAxes_ButtonDownFcn(hObject, eventdata, handles)


% --- Executes on button press in ModelChooseButton.
function ModelChooseButton_Callback(hObject, eventdata, handles)
global CaSignal
dataPath = get(handles.ModelPathEdit,'String');
[filename, pathName] = uigetfile(fullfile(dataPath, '*.mat'), 'Load Image File');
if isequal(filename,0)
	return;
end
set(handles.ModelPathEdit,'String', fullfile(pathName, filename));
CaSignal.localFCNModelFilename = filename;
CaSignal.localFCNModelPathName = pathName;
disp('Loading Local FCN Model')
CaSignal.localFCNModel = load(fullfile(CaSignal.localFCNModelPathName, CaSignal.localFCNModelFilename));
disp('Done')
set(handles.DrawROICheckbox, 'Enable', 'on');
set(handles.RegisterROIButton, 'Enable', 'on');
set(handles.LocalFCNRetrainButton, 'Enable', 'on');
set(handles.ChooseROIDetectorButton, 'Enable', 'on');



function ModelPathEdit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function ModelPathEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function SubimageShowAxes_CreateFcn(hObject, eventdata, handles)

function ImageShowAxes_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in SaveButton.
function SaveButton_Callback(hObject, eventdata, handles)
global CaSignal
CaSignal = save_roi_fcn(CaSignal, handles);
CaSignal = Update_Image_Fcn(handles, CaSignal, true);


% --- Executes on key press with focus on SaveButton and none of its controls.
function SaveButton_KeyPressFcn(hObject, eventdata, handles)


% --- Executes on button press in ReDrawButton.
function ReDrawButton_Callback(hObject, eventdata, handles)
global CaSignal
CaSignal = redraw_fcn(handles, CaSignal);



% --- Executes on button press in DeleteButton.
function DeleteButton_Callback(hObject, eventdata, handles)
global CaSignal
if numel(CaSignal.TempROI) > 0 && CaSignal.TempROI{7} <= CaSignal.ROI_num && CaSignal.TempROI{8} == 'T'
	sprintf('delete ROI %d', CaSignal.TempROI{7})
	CaSignal.SummarizedMask(CaSignal.SummarizedMask == CaSignal.TempROI{7}) = 0;
	CaSignal.ROI_T_num = CaSignal.ROI_T_num - 1;
	set(handles.ROINumShowText, 'String', num2str(CaSignal.ROI_T_num));
	CaSignal.ROIs{CaSignal.TempROI{7}}{8} = 'F';
	CaSignal.TempROI{8} = 'F';
	CaSignal = Update_Image_Fcn(handles, CaSignal, true);
	CaSignal = update_subimage_show(handles, CaSignal, true);
end



% --- Executes on button press in MaxMeanBox.
function MaxMeanBox_Callback(hObject, eventdata, handles)
global CaSignal
if get(hObject,'Value') == 1
	CaSignal.showing_image = CaSignal.max_mean_image;
	set(handles.MeanBox,'Value', 0);
	set(handles.MaxBox,'Value', 0);
else
	CaSignal.showing_image = CaSignal.mean_images(:, :, CaSignal.current_trial);
	set(handles.MaxBox,'Value', 0);
	set(handles.MaxMeanBox,'Value', 0);
end
CaSignal = Update_Image_Fcn(handles, CaSignal, true);
CaSignal = update_subimage_show(handles, CaSignal, true);



% --- Executes on button press in MeanBox.
function MeanBox_Callback(hObject, eventdata, handles)
global CaSignal
if get(hObject,'Value') == 1
	CaSignal.showing_image = CaSignal.mean_images(:, :, CaSignal.current_trial);
	set(handles.MaxMeanBox,'Value', 0);
	set(handles.MaxBox,'Value', 0);
else
	CaSignal.showing_image = CaSignal.mean_images(:, :, CaSignal.current_trial);
	set(handles.MaxBox,'Value', 0);
	set(handles.MaxMeanBox,'Value', 0);
end
CaSignal = Update_Image_Fcn(handles, CaSignal, true);
CaSignal = update_subimage_show(handles, CaSignal, true);


% --- Executes on button press in MaxBox.
function MaxBox_Callback(hObject, eventdata, handles)
global CaSignal
if get(hObject,'Value') == 1
	CaSignal.showing_image = CaSignal.max_images(:, :, CaSignal.current_trial);
	set(handles.MaxMeanBox,'Value', 0);
	set(handles.MeanBox,'Value', 0);
else
	CaSignal.showing_image = CaSignal.mean_images(:, :, CaSignal.current_trial);
	set(handles.MaxBox,'Value', 0);
	set(handles.MaxMeanBox,'Value', 0);
end
CaSignal = Update_Image_Fcn(handles, CaSignal, true);
CaSignal = update_subimage_show(handles, CaSignal, true);


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
global CaSignal
CaSignal.top_percentile = get(hObject, 'Value');
CaSignal = Update_Image_Fcn(handles, CaSignal, true);
CaSignal = update_subimage_show(handles, CaSignal, true);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
global CaSignal
CaSignal.bottom_percentile = get(hObject, 'Value');
CaSignal = Update_Image_Fcn(handles, CaSignal, true);
CaSignal = update_subimage_show(handles, CaSignal, true);

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function TrialNumEdit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function TrialNumEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in NextTrialButton.
function NextTrialButton_Callback(hObject, eventdata, handles)
global CaSignal
CaSignal.current_trial = CaSignal.current_trial + 1;
if CaSignal.current_trial > CaSignal.total_trial
	CaSignal.current_trial = CaSignal.current_trial - CaSignal.total_trial;
end
if get(handles.MaxBox,'Value') == 1
	CaSignal.showing_image = CaSignal.max_images(:, :, CaSignal.current_trial);
elseif get(handles.MeanBox,'Value') == 1
	CaSignal.showing_image = CaSignal.mean_images(:, :, CaSignal.current_trial);
end
CaSignal = Update_Image_Fcn(handles, CaSignal, true);
CaSignal = update_subimage_show(handles, CaSignal, true);
set(handles.TrialNumEdit, 'String', sprintf('%d/%d', CaSignal.current_trial, CaSignal.total_trial));


% --- Executes on button press in PreviousTrialButton.
function PreviousTrialButton_Callback(hObject, eventdata, handles)
global CaSignal
CaSignal.current_trial = CaSignal.current_trial - 1;
if CaSignal.current_trial < 1
	CaSignal.current_trial = CaSignal.total_trial + CaSignal.current_trial;
end
if get(handles.MaxBox,'Value') == 1
	CaSignal.showing_image = CaSignal.max_images(:, :, CaSignal.current_trial);
elseif get(handles.MeanBox,'Value') == 1
	CaSignal.showing_image = CaSignal.mean_images(:, :, CaSignal.current_trial);
end
CaSignal = Update_Image_Fcn(handles, CaSignal, true);
CaSignal = update_subimage_show(handles, CaSignal, true);
set(handles.TrialNumEdit, 'String', sprintf('%d/%d', CaSignal.current_trial, CaSignal.total_trial));



function GoToTrialNoEdit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function GoToTrialNoEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GoToButton.
function GoToButton_Callback(hObject, eventdata, handles)
global CaSignal
CaSignal.current_trial = int16(str2num(get(handles.GoToTrialNoEdit, 'String')));
if CaSignal.current_trial > CaSignal.total_trial
	CaSignal.current_trial = CaSignal.current_trial - CaSignal.total_trial;
elseif CaSignal.current_trial < 1
	CaSignal.current_trial = CaSignal.total_trial + CaSignal.current_trial;
end
if get(handles.MaxBox,'Value') == 1
	CaSignal.showing_image = CaSignal.max_images(:, :, CaSignal.current_trial);
elseif get(handles.MeanBox,'Value') == 1
	CaSignal.showing_image = CaSignal.mean_images(:, :, CaSignal.current_trial);
end
CaSignal = Update_Image_Fcn(handles, CaSignal, true);
CaSignal = update_subimage_show(handles, CaSignal, true);
set(handles.TrialNumEdit, 'String', sprintf('%d/%d', CaSignal.current_trial, CaSignal.total_trial));


% --------------------------------------------------------------------
function SaveROIInfoTool_ClickedCallback(hObject, eventdata, handles)
global CaSignal
% ROIInfo = {};
ROImask = {};
n = 0;
for i = 1:CaSignal.ROI_num 
	if CaSignal.ROIs{i}{8} == 'T'
		n = n+1;
% 		ROIInfo{n} =  CaSignal.ROIs{i};
% 		ROIInfo{n}{7} = n;
		tempMask = zeros(size(CaSignal.imageData, 1), size(CaSignal.imageData, 2));
		y_start = CaSignal.ROIs{i}{1};
		y_end = CaSignal.ROIs{i}{2};
		x_start = CaSignal.ROIs{i}{3};
		x_end = CaSignal.ROIs{i}{4};
		tempRoi = CaSignal.ROIs{i}{5};
		tempMask(y_start:y_end, x_start:x_end) = tempRoi(1:y_end - y_start + 1, 1:x_end - x_start + 1);
		ROImask{n} = tempMask;
	end
end

[file, path] = uiputfile('*.mat', 'Save ROI masks');
if isequal(file,0) || isequal(path,0)
	answer = questdlg('Sure you do NOT want save ROI masks ?', 'Alert query');
	switch answer
		case 'Yes'
			return;
		case 'No'
			[file, path] = uiputfile('*.mat', 'Save trained model file');
			if isequal(file,0) || isequal(path,0)
				return
			end
		case 'Cancel'
			[file, path] = uiputfile('*.mat', 'Save trained model file');
			if isequal(file,0) || isequal(path,0)
				return
			end
	end
end
% if exist(fullfile(CaSignal.imagePathName, 'ROIInfo'), 'dir') == 0
% 	mkdir(fullfile(CaSignal.imagePathName, 'ROIInfo'));
% end
disp('Save ROI info');
% save(fullfile(CaSignal.imagePathName, 'ROIInfo', 'ROIInfo.mat'), 'ROImask');
save(fullfile(path, file), 'ROImask');


% --------------------------------------------------------------------
function OpenFileTool_ClickedCallback(hObject, eventdata, handles)
global CaSignal
[filename, pathName] = uigetfile(fullfile(CaSignal.imagePathName, '*.tif*'), 'Load Image File');
if isequal(filename,0)
	return;
end
CaSignal.imageFilename = filename;
CaSignal.imagePathName = pathName;
disp('Loading Image Data')
[CaSignal.mean_images, CaSignal.max_images] = load_image_data(CaSignal.imagePathName);
disp('Done')
CaSignal.max_mean_image = max(CaSignal.mean_images, [], 3);
CaSignal.imageData = gray2RGB(CaSignal.max_mean_image);
CaSignal.current_trial = 1;
CaSignal.total_trial = size(CaSignal.mean_images, 3);
set(handles.TrialNumEdit, 'String', sprintf('%d/%d', CaSignal.current_trial, CaSignal.total_trial));
CaSignal.showing_image = CaSignal.mean_images(:, :, CaSignal.current_trial);
CaSignal.SummarizedMask = zeros(size(CaSignal.imageData, 1), size(CaSignal.imageData, 2));
CaSignal.top_percentile = 100.0;
CaSignal.bottom_percentile = 0.0;
CaSignal = Update_Image_Fcn(handles, CaSignal, false);
set(handles.LoadROIButton, 'Enable', 'on');
set(handles.ModelChooseButton, 'Enable', 'on');
% set(handles.ModelPathEdit, 'String', CaSignal.imagePathName);
% set(handles.GlobalModelPathEdit, 'String', CaSignal.imagePathName);



% --- Executes on button press in DrawROICheckbox.
function DrawROICheckbox_Callback(hObject, eventdata, handles)


% --- Executes on button press in LoadROIButton.
function LoadROIButton_Callback(hObject, eventdata, handles)
global CaSignal
[filename, pathname] = uigetfile(fullfile(CaSignal.imagePathName, '*.mat'), 'Load ROI File');
if isequal(filename,0)
	return;
end
set(handles.figure1, 'pointer', 'watch');
drawnow;
ROIs = load_roi(fullfile(pathname, filename), CaSignal);
CaSignal.ROIs = ROIs;
CaSignal.ROI_num = size(CaSignal.ROIs, 2);
CaSignal.ROI_T_num = CaSignal.ROI_num;
if CaSignal.ROI_num > 0
	CaSignal.TempROI = CaSignal.ROIs{1};
	set(handles.CurrentROINoEdit, 'String', num2str(CaSignal.TempROI{7}));
	CaSignal = update_subimage_show(handles, CaSignal, true);
end
set(handles.ROINumShowText, 'String', num2str(CaSignal.ROI_T_num));
CaSignal = generate_summarizedMask(CaSignal);
CaSignal = Update_Image_Fcn(handles, CaSignal, true);
set(handles.figure1, 'pointer', 'arrow');


% --- Executes on button press in RegisterROIButton.
function RegisterROIButton_Callback(hObject, eventdata, handles)
global CaSignal
[filename, pathname] = uigetfile(fullfile(CaSignal.imagePathName, '*.tif*'), 'Load Previous Session Image File');
if isequal(filename,0)
	return;
end
set(handles.figure1, 'pointer', 'watch')
drawnow;
[mean_images, max_images] = load_image_data(pathname);
max_mean_image = max(mean_images, [], 3);
set(handles.figure1, 'pointer', 'arrow')
[filename, pathname] = uigetfile(fullfile(pathname, '*.mat'), 'Load Previous Session ROI File');
if isequal(filename,0)
	return;
end
disp('Registering ROIs')
set(handles.figure1, 'pointer', 'watch')
drawnow;
ROIs = load_roi(fullfile(pathname, filename), CaSignal);
registered_ROIs = register_roi(ROIs, max_mean_image, CaSignal.max_mean_image, CaSignal);
CaSignal.ROIs = registered_ROIs;
CaSignal.ROI_num = size(CaSignal.ROIs, 2);
CaSignal.ROI_T_num = CaSignal.ROI_num;
set(handles.ROINumShowText, 'String', num2str(CaSignal.ROI_T_num));
if numel(CaSignal.ROIs) > 0
	CaSignal.TempROI = CaSignal.ROIs{1};
	CaSignal = update_subimage_show(handles, CaSignal, true);
	set(handles.CurrentROINoEdit, 'String', num2str(CaSignal.TempROI{7}));
end
CaSignal = generate_summarizedMask(CaSignal);
CaSignal = Update_Image_Fcn(handles, CaSignal, true);
set(handles.figure1, 'pointer', 'arrow')
disp('Done')


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
global CaSignal
if strcmp(eventdata.Key, 'space')
	SaveButton_Callback(hObject, eventdata, handles)
elseif strcmp(eventdata.Key, 'd') && CaSignal.TempROI{7} <= CaSignal.ROI_num
	DeleteButton_Callback(hObject, eventdata, handles);
elseif strcmp(eventdata.Key, 'r')
	ReDrawButton_Callback(hObject, eventdata, handles);
elseif strcmp(eventdata.Key, 'n')
	FindNextButton_Callback(hObject, eventdata, handles);
else
	return
end

% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% global CaSignal
% if strcmp(eventdata.Key, 'space')
% 	SaveButton_Callback(hObject, eventdata, handles)
% elseif strcmp(eventdata.Key, 'd') && CaSignal.TempROI{7} <= CaSignal.ROI_num
% 	DeleteButton_Callback(hObject, eventdata, handles);
% elseif strcmp(eventdata.Key, 'r')
% 	ReDrawButton_Callback(hObject, eventdata, handles);
% elseif strcmp(eventdata.Key, 'n')
% 	FindNextButton_Callback(hObject, eventdata, handles);
% else
% 	return
% end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
answer = questdlg('Save ROI information ?', 'Save query');
switch answer
    case 'Yes'
		SaveROIInfoTool_ClickedCallback(hObject, eventdata, handles)
        delete(hObject);
    case 'No'
       delete(hObject);
    case 'Cancel'
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)


% --- Executes on button press in DeleteAllButton.
function DeleteAllButton_Callback(hObject, eventdata, handles)
global CaSignal
answer = questdlg('Do you want to delete all ROI information ?', 'Alert query');
switch answer
    case 'Yes'
		CaSignal = delete_all_roi(CaSignal);
		set(handles.CurrentROINoEdit, 'String', '0');
		CaSignal = Update_Image_Fcn(handles, CaSignal, true);
		CaSignal = update_subimage_show(handles, CaSignal, true);
    case 'No'
		return
    case 'Cancel'
		return
end


% --- Executes on button press in LocalFCNRetrainButton.
function LocalFCNRetrainButton_Callback(hObject, eventdata, handles)
global CaSignal
datapath = uigetfile_n_dir(CaSignal.imagePathName, 'Chose folders used to train');
if numel(datapath) ~= 0
	CaSignal = retrain_localFCN(CaSignal, datapath);
	set(handles.ModelPathEdit,'String', ...
		fullfile(CaSignal.localFCNModelPathName, CaSignal.localFCNModelFilename));
end

function CurrentROINoEdit_Callback(hObject, eventdata, handles)
global CaSignal
current_roi_no = str2double(get(hObject,'String'));
current_roi_no = floor(current_roi_no);
if numel(CaSignal.ROIs) > 0
	if current_roi_no > CaSignal.ROI_num
		current_roi_no = CaSignal.ROI_num;
	elseif current_roi_no < 1
		current_roi_no = 1;
	end
	CaSignal.TempROI = CaSignal.ROIs{current_roi_no};
	CaSignal.RedrawBasedOnTempROI = true;
	CaSignal = update_subimage_show(handles, CaSignal, true);
	CaSignal = Update_Image_Fcn(handles, CaSignal, true);
end


% --- Executes during object creation, after setting all properties.
function CurrentROINoEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ShowROINoCheckbox.
function ShowROINoCheckbox_Callback(hObject, eventdata, handles)
global CaSignal
CaSignal = update_subimage_show(handles, CaSignal, true);
CaSignal = Update_Image_Fcn(handles, CaSignal, true);



function ROIDetectorPathEdit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function ROIDetectorPathEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ChooseROIDetectorButton.
function ChooseROIDetectorButton_Callback(hObject, eventdata, handles)
global CaSignal
dataPath = get(handles.ROIDetectorPathEdit,'String');
[filename, pathName] = uigetfile(fullfile(dataPath, '*.mat'), 'Load ROI Detector');
if isequal(filename,0)
	return;
end
set(handles.ROIDetectorPathEdit,'String', fullfile(pathName, filename));
disp('Loading ROI Detector');
CaSignal.ROIDetector = load(fullfile(pathName, filename));
disp('Done')
CaSignal.ROIDetectorFilename = filename;
CaSignal.ROIDetectorPathName = pathName;
set(handles.DetectROIButton,'Enable', 'on');
set(handles.ROIDetectorRetrainButton,'Enable', 'on');


% --- Executes on button press in DetectROIButton.
function DetectROIButton_Callback(hObject, eventdata, handles)
global CaSignal
disp('Detecting ROIs')
set(handles.figure1, 'pointer', 'watch')
drawnow;
CaSignal = detect_roi(CaSignal);
set(handles.ROINumShowText, 'String', num2str(CaSignal.ROI_T_num));
CaSignal = generate_summarizedMask(CaSignal);
CaSignal = update_subimage_show(handles, CaSignal, true);
CaSignal = Update_Image_Fcn(handles, CaSignal, true);
disp('Done')
set(handles.figure1, 'pointer', 'arrow')


% --- Executes on button press in ROIDetectorRetrainButton.
function ROIDetectorRetrainButton_Callback(hObject, eventdata, handles)
global CaSignal
datapath = uigetfile_n_dir(CaSignal.imagePathName, 'Chose folders used to train');
if numel(datapath) ~= 0
	CaSignal = retrain_roi_detector(CaSignal, datapath);
	set(handles.ROIDetectorPathEdit,'String', ...
		fullfile(CaSignal.ROIDetectorPathName, CaSignal.ROIDetectorFilename));
end


% --- Executes on button press in NextROIButton.
function NextROIButton_Callback(hObject, eventdata, handles)
global CaSignal
current_roi_no = str2double(get(handles.CurrentROINoEdit,'String'));
next_roi_no = floor(current_roi_no) + 1;
if next_roi_no > CaSignal.ROI_num
	next_roi_no = 1;
end
CaSignal.TempROI = CaSignal.ROIs{next_roi_no};
CaSignal.RedrawBasedOnTempROI = true;
while ~CaSignal.TempROI{8}
	next_roi_no  = next_roi_no + 1;
	if next_roi_no > CaSignal.ROI_num
		next_roi_no = 1;
	end
	CaSignal.TempROI = CaSignal.ROIs{next_roi_no};
end
set(handles.CurrentROINoEdit, 'String', num2str(next_roi_no));
CaSignal = update_subimage_show(handles, CaSignal, true);
CaSignal = Update_Image_Fcn(handles, CaSignal, true);


% --- Executes on button press in PreviousROIButton.
function PreviousROIButton_Callback(hObject, eventdata, handles)
global CaSignal
current_roi_no = str2double(get(handles.CurrentROINoEdit,'String'));
previous_roi_no = floor(current_roi_no) - 1;
if previous_roi_no < 1
	previous_roi_no = CaSignal.ROI_num;
end
CaSignal.TempROI = CaSignal.ROIs{previous_roi_no};
CaSignal.RedrawBasedOnTempROI = true;
while ~CaSignal.TempROI{8}
	previous_roi_no  = previous_roi_no + 1;
	if previous_roi_no < 1
		previous_roi_no = CaSignal.ROI_num;
	end
	CaSignal.TempROI = CaSignal.ROIs{previous_roi_no};
end
set(handles.CurrentROINoEdit, 'String', num2str(previous_roi_no));
CaSignal = update_subimage_show(handles, CaSignal, true);
CaSignal = Update_Image_Fcn(handles, CaSignal, true);


% --- Executes on button press in SetROIDIAButton.
function SetROIDIAButton_Callback(hObject, eventdata, handles)
global CaSignal

prompt = {'Enter ROI Diameter:'};
title = 'Set ROI Diameter';
dims = [1 35];
definput = {num2str(CaSignal.ROIDiameter)};
answer = inputdlg(prompt,title,dims,definput);
CaSignal.ROIDiameter = str2double(answer{1});
set(handles.ROIDiameterShowText, 'String', answer{1});
